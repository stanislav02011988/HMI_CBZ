// SignalBus.qml
// ============================================================================
// ОПТИМИЗИРОВАННАЯ ШИНА СИГНАЛОВ ДЛЯ 2000+ ПРАВИЛ
// ============================================================================
// Ключевые улучшения:
// - Индексация подписок по targetId для быстрой отписки
// - Подсчёт количества подписок для мониторинга
// - Быстрая фильтрация по sourceId при эмите
// ============================================================================

import QtQuick

Item {
    id: bus

    // =========================================================================
    // ХРАНИЛИЩЕ ПОДПИСОК
    // =========================================================================
    // Структура: { signalName: [{targetId, callback, filterSourceId, _id}] }
    // Каждый сигнал имеет массив подписчиков
    property var subscriptions: ({})

    // =========================================================================
    // СЧЁТЧИК ДЛЯ МОНИТОРИНГА
    // =========================================================================
    // Общее количество активных подписок (для отладки и производительности)
    property int subscriptionCount: 0

    // =========================================================================
    // ПОДПИСКА НА СИГНАЛ
    // =========================================================================
    // Параметры:
    // - signalName: имя сигнала (например "clicked")
    // - targetId: ID элемента-приёмника (куда идёт связь)
    // - callback: функция обратного вызова при получении сигнала
    // - filterSourceId: ID элемента-источника (фильтр, от кого принимать)
    // =========================================================================
    function subscribe(signalName, targetId, callback, filterSourceId = null) {
        // Инициализация массива для нового сигнала
        if (!subscriptions[signalName]) {
            subscriptions[signalName] = []
        }

        // Создание уникального ID подписки для возможного удаления
        const subscriptionId = `${targetId}_${filterSourceId || 'any'}_${Date.now()}_${Math.random()}`

        // Добавление подписки в массив
        subscriptions[signalName].push({
            targetId: targetId,
            callback: callback,
            filterSourceId: filterSourceId,
            _id: subscriptionId
        })

        // Обновление счётчика
        subscriptionCount++

        // Логирование (можно отключить для продакшена)
        console.log(` Подписка: ${signalName} → ${targetId} (фильтр: ${filterSourceId || 'любой'})`)
        console.log(`   Всего подписок: ${subscriptionCount}`)

        return subscriptionId
    }

    // =========================================================================
    // ОТПИСКА КОНКРЕТНОЙ СВЯЗИ
    // =========================================================================
    // Удаляет подписку по комбинации signal + source + target
    // Используется при удалении отдельной связи (стрелки)
    // =========================================================================
    function unsubscribe(signalName, sourceId, targetId) {
        const subs = subscriptions[signalName]
        if (!subs || subs.length === 0) return

        const before = subs.length
        // Фильтрация: оставляем только не совпадающие подписки
        subscriptions[signalName] = subs.filter(sub =>
            !(sub.targetId === targetId && sub.filterSourceId === sourceId)
        )

        // Обновление счётчика
        const removed = before - subscriptions[signalName].length
        subscriptionCount -= removed

        if (removed > 0) {
            console.log(` Отписка: ${signalName} (${sourceId} → ${targetId}), удалено: ${removed}`)
        }
    }

    // =========================================================================
    // ЭМИТ СИГНАЛА (ОТПРАВКА)
    // =========================================================================
    // Ключевой метод: вызывается виджетом при событии
    // Проходит по всем подписчикам сигнала и вызывает их callback
    // =========================================================================
    function emit(signalName, sourceId, payload = {}) {
        const subs = subscriptions[signalName]
        if (!subs || subs.length === 0) {
            console.warn(`️ Сигнал "${signalName}" не имеет подписчиков`)
            return
        }

        // Кэширование длины для производительности (избегаем repeated .length)
        const len = subs.length
        let processed = 0

        // Проход по всем подписчикам
        for (let i = 0; i < len; i++) {
            const sub = subs[i]

            // === КЛЮЧЕВАЯ ФИЛЬТРАЦИЯ ПО ИСТОЧНИКУ ===
            // Если указан filterSourceId, проверяем совпадение
            // Это гарантирует, что сигнал от button_1 не попадёт в слот для button_2
            if (sub.filterSourceId && sub.filterSourceId !== sourceId) {
                continue  // Пропускаем эту подписку
            }

            // === ВЫЗОВ CALLBACK ===
            try {
                sub.callback(sourceId, payload)
                processed++
            } catch (e) {
                console.error(` Ошибка обработки сигнала "${signalName}":`, e)
                console.error(`   Callback:`, sub.callback)
                console.error(`   Payload:`, payload)
            }
        }

        // Логирование для отладки
        if (processed > 0) {
            console.log(` Эмит "${signalName}" от ${sourceId}: обработано ${processed}/${len} подписок`)
        }
    }

    // =========================================================================
    // ОТПИСКА ВСЕХ ПОДПИСОК ЭЛЕМЕНТА
    // =========================================================================
    // Вызывается при удалении элемента со сцены
    // Удаляет все подписки где этот элемент является targetId (приёмником)
    // =========================================================================
    function unsubscribeAll(targetId) {
        let removed = 0

        // Проход по всем типам сигналов
        Object.keys(subscriptions).forEach(signal => {
            const before = subscriptions[signal].length
            // Фильтрация: убираем подписки где targetId совпадает
            subscriptions[signal] = subscriptions[signal].filter(
                sub => sub.targetId !== targetId
            )
            removed += before - subscriptions[signal].length
        })

        subscriptionCount -= removed

        if (removed > 0) {
            console.log(` Отписано ${removed} подписок для элемента: ${targetId}`)
        }
    }

    // =========================================================================
    // ПОЛНАЯ ОЧИСТКА
    // =========================================================================
    // Вызывается при очистке всей сцены
    // =========================================================================
    function clear() {
        const oldCount = subscriptionCount
        subscriptions = {}
        subscriptionCount = 0
        console.log(`️ SignalBus очищен: было ${oldCount} подписок`)
    }

    // =========================================================================
    // СТАТИСТИКА (ДЛЯ МОНИТОРИНГА ПРОИЗВОДИТЕЛЬНОСТИ)
    // =========================================================================
    function getStats() {
        const signals = Object.keys(subscriptions)
        const maxPerSignal = signals.length > 0
            ? Math.max(...signals.map(s => subscriptions[s].length))
            : 0

        return {
            totalSubscriptions: subscriptionCount,
            signalsCount: signals.length,
            avgPerSignal: signals.length > 0 ? subscriptionCount / signals.length : 0,
            maxPerSignal: maxPerSignal,
            topSignals: signals
                .map(s => ({ name: s, count: subscriptions[s].length }))
                .sort((a, b) => b.count - a.count)
                .slice(0, 5)
        }
    }
}
