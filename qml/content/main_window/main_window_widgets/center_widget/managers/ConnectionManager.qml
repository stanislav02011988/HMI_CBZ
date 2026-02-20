// managers/ConnectionManager.qml
// ============================================================================
// ОПТИМИЗИРОВАННЫЙ МЕНЕДЖЕР СВЯЗЕЙ ДЛЯ 2000+ ПРАВИЛ
// ============================================================================
// Ключевые улучшения:
// - Хеш-индексы для O(1) поиска правил (вместо O(n))
// - Динамический вызов слотов (вместо switch-case)
// - Быстрое удаление связей по элементу
// - Мониторинг производительности
// ============================================================================

import QtQuick

Item {
    id: manager

    // =========================================================================
    // ЗАВИСИМОСТИ
    // =========================================================================
    property var signalBus: null
    property var componentRegister: null

    // =========================================================================
    // ХРАНИЛИЩЕ ПРАВИЛ (НЕСКОЛЬКО ИНДЕКСОВ ДЛЯ БЫСТРОГО ДОСТУПА)
    // =========================================================================

    // Основной массив всех правил (для экспорта/сохранения)
    property var rules: []

    // Индекс по источнику: { fromId: [rules...] }
    // Быстрый поиск: "Какие связи исходят из этого элемента?"
    property var rulesByFromId: ({})

    // Индекс по приёмнику: { toId: [rules...] }
    // Быстрый поиск: "Какие связи входят в этот элемент?"
    property var rulesByToId: ({})

    // Хеш-индекс: { "fromId|signal|toId|slot": rule }
    // Быстрая проверка дубликатов O(1) вместо O(n)
    property var rulesByHash: ({})

    // =========================================================================
    // СИГНАЛЫ МЕНЕДЖЕРА
    // =========================================================================
    signal signalRules()                    // Изменился список правил
    signal connectionCreated(var rule)      // Создана новая связь
    signal connectionRemoved(string fromId, string toId)  // Удалена связь

    // =========================================================================
    // ГЕНЕРАЦИЯ УНИКАЛЬНОГО ХЕША ПРАВИЛА
    // =========================================================================
    // Комбинирует все 4 ключевых поля в одну строку
    // Используется для проверки дубликатов и быстрого поиска
    // =========================================================================
    function _hashRule(fromId, signal, toId, slot) {
        return `${fromId}|${signal}|${toId}|${slot}`
    }

    // =========================================================================
    // СОЗДАНИЕ СВЯЗИ (ОСНОВНОЙ МЕТОД)
    // =========================================================================
    // Параметры:
    // - fromId: ID элемента-источника (откуда сигнал)
    // - signal: имя сигнала (например "clicked")
    // - toId: ID элемента-приёмника (куда идёт связь)
    // - slot: имя слота (метод для вызова)
    // Возвращает: true если успешно, false если дубликат или ошибка
    // =========================================================================
    function createConnection(fromId, signal, toId, slot) {
        // === ЭТАП 1: ПРОВЕРКА ЗАВИСИМОСТЕЙ ===
        if (!signalBus || !componentRegister) {
            console.error(" ConnectionManager: зависимости не инициализированы")
            console.error(`   signalBus: ${signalBus ? "OK" : "NULL"}`)
            console.error(`   componentRegister: ${componentRegister ? "OK" : "NULL"}`)
            return false
        }

        // === ЭТАП 2: ПРОВЕРКА ДУБЛИКАТА (O(1) БЛАГОДАРЯ ХЕШУ) ===
        const hash = _hashRule(fromId, signal, toId, slot)
        if (rulesByHash[hash]) {
            console.warn(`️ Связь уже существует: ${fromId}.${signal} → ${toId}.${slot}`)
            return false
        }

        // === ЭТАП 3: ПРОВЕРКА СУЩЕСТВОВАНИЯ ЭЛЕМЕНТОВ ===
        const sourceElem = componentRegister.getElementById(fromId)
        const targetElem = componentRegister.getElementById(toId)

        if (!sourceElem) {
            console.error(` Элемент-источник не найден: ${fromId}`)
            return false
        }
        if (!targetElem) {
            console.error(` Элемент-приёмник не найден: ${toId}`)
            return false
        }

        // === ЭТАП 4: СОЗДАНИЕ ОБЪЕКТА ПРАВИЛА ===
        const rule = {
            fromId: fromId,
            signal: signal,
            toId: toId,
            slot: slot,
            enabled: true,
            createdAt: new Date().toISOString(),
            id: `rule_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`,
            _hash: hash  // Кэшируем хеш для быстрого доступа
        }

        // === ЭТАП 5: ДОБАВЛЕНИЕ ВО ВСЕ ИНДЕКСЫ ===
        // Добавляем в основной массив
        rules.push(rule)

        // Добавляем в индекс по источнику
        if (!rulesByFromId[fromId]) rulesByFromId[fromId] = []
        rulesByFromId[fromId].push(rule)

        // Добавляем в индекс по приёмнику
        if (!rulesByToId[toId]) rulesByToId[toId] = []
        rulesByToId[toId].push(rule)

        // Добавляем в хеш-индекс
        rulesByHash[hash] = rule

        // === ЭТАП 6: ПОДПИСКА В SignalBus ===
        try {
            signalBus.subscribe(signal, toId, (srcId, payload) => {
                // Двойная проверка: источник и статус правила
                if (srcId !== fromId || !rule.enabled) return
                processSlot(toId, slot, payload)
            }, fromId)
        } catch (e) {
            console.error(` Ошибка подписки в SignalBus:`, e)
            // Откат: удаляем правило из индексов
            _removeRuleFromIndices(rule)
            return false
        }

        // === ЭТАП 7: УВЕДОМЛЕНИЕ ===
        signalRules()
        connectionCreated(rule)

        console.log(` Связь создана: ${fromId}.${signal} ───→ ${toId}.${slot}`)
        console.log(`   Всего правил: ${rules.length}`)

        return true
    }

    // =========================================================================
    // ОБРАБОТКА СЛОТА (ДИНАМИЧЕСКИЙ ВЫЗОВ)
    // =========================================================================
    // Находит элемент по ID и вызывает метод слота
    // Вместо switch-case используем динамический вызов функции
    // =========================================================================
    function processSlot(targetId, slotName, payload) {
        // Проверка регистратора
        if (!componentRegister) {
            console.error(" ConnectionManager: componentRegister не инициализирован")
            return
        }

        // Поиск элемента
        const elem = componentRegister.getElementById(targetId)
        if (!elem?.widgetRef) {
            console.warn(`️ Элемент не найден: ${targetId}`)
            return
        }

        const widget = elem.widgetRef

        // === ДИНАМИЧЕСКИЙ ВЫЗОВ МЕТОДА ===
        // Проверяем существует ли метод с таким именем
        if (typeof widget[slotName] === 'function') {
            try {
                widget[slotName](payload)
                // console.log(` Слот вызван: ${targetId}.${slotName}()`)
            } catch (e) {
                console.error(` Ошибка вызова слота ${targetId}.${slotName}:`, e)
            }
        }
        // === СТАНДАРТНЫЕ СВОЙСТВА (резервный вариант) ===
        else if (slotName === "setEnabled" && "enabled" in widget) {
            widget.enabled = payload.value
        }
        else if (slotName === "setVisible" && "visible" in widget) {
            widget.visible = payload.value
        }
        else if (slotName === "setValue" && "value" in widget) {
            widget.value = payload.value
        }
        else if (slotName === "setColor" && "color" in widget) {
            widget.color = payload.color
        }
        // === НЕИЗВЕСТНЫЙ СЛОТ ===
        else {
            console.warn(`️ Неизвестный слот: ${targetId}.${slotName}`)
            console.warn(`   Доступные методы виджета:`, Object.keys(widget).filter(k => typeof widget[k] === 'function').slice(0, 10))
        }
    }

    // =========================================================================
    // УДАЛЕНИЕ ВСЕХ СВЯЗЕЙ ЭЛЕМЕНТА (ОПТИМИЗИРОВАНО)
    // =========================================================================
    // Вызывается при удалении элемента со сцены
    // Использует индексы для быстрого доступа (O(k) где k = связи элемента)
    // =========================================================================
    function removeConnectionsForElement(elementId) {
        if (!elementId) return

        // Получаем связи где элемент является источником
        const fromRules = rulesByFromId[elementId] || []
        // Получаем связи где элемент является приёмником
        const toRules = rulesByToId[elementId] || []

        let removedCount = 0

        // === ОТПИСКА ОТ СИГНАЛОВ (для исходящих связей) ===
        fromRules.forEach(rule => {
            signalBus?.unsubscribe(rule.signal, rule.fromId, rule.toId)
            _removeRuleFromIndices(rule)
            removedCount++
        })

        // === УДАЛЕНИЕ ВХОДЯЩИХ СВЯЗЕЙ (только из индексов) ===
        toRules.forEach(rule => {
            _removeRuleFromIndices(rule)
            removedCount++
        })

        // === ОЧИСТКА ИНДЕКСОВ ЭЛЕМЕНТА ===
        delete rulesByFromId[elementId]
        delete rulesByToId[elementId]

        // === ОБНОВЛЕНИЕ ГЛАВНОГО МАССИВА ===
        rules = rules.filter(r => r.fromId !== elementId && r.toId !== elementId)

        signalRules()
        console.log(` Удалено ${removedCount} связей для элемента: ${elementId}`)
    }

    // =========================================================================
    // УДАЛЕНИЕ КОНКРЕТНОЙ СВЯЗИ
    // =========================================================================
    function removeConnection(fromId, toId, signal, slot) {
        const hash = _hashRule(fromId, signal, toId, slot)
        const rule = rulesByHash[hash]

        if (!rule) {
            console.warn(`️ Связь не найдена для удаления: ${hash}`)
            return false
        }

        // Отписка от сигнала
        signalBus?.unsubscribe(signal, fromId, toId)

        // Удаление из индексов
        _removeRuleFromIndices(rule)

        // Обновление основного массива
        rules = rules.filter(r => r._hash !== hash)

        signalRules()
        connectionRemoved(fromId, toId)

        console.log(`️ Связь удалена: ${fromId}.${signal} → ${toId}.${slot}`)
        return true
    }

    // =========================================================================
    // ВСПОМОГАТЕЛЬНАЯ: УДАЛЕНИЕ ПРАВИЛА ИЗ ВСЕХ ИНДЕКСОВ
    // =========================================================================
    function _removeRuleFromIndices(rule) {
        // Из хеш-индекса
        delete rulesByHash[rule._hash]

        // Из индекса по источнику
        const fromArr = rulesByFromId[rule.fromId]
        if (fromArr) {
            const idx = fromArr.findIndex(r => r._hash === rule._hash)
            if (idx >= 0) fromArr.splice(idx, 1)
            if (fromArr.length === 0) delete rulesByFromId[rule.fromId]
        }

        // Из индекса по приёмнику
        const toArr = rulesByToId[rule.toId]
        if (toArr) {
            const idx = toArr.findIndex(r => r._hash === rule._hash)
            if (idx >= 0) toArr.splice(idx, 1)
            if (toArr.length === 0) delete rulesByToId[rule.toId]
        }
    }

    // =========================================================================
    // ПЕРЕСТРОЙКА ВСЕХ ПОДПИСОК
    // =========================================================================
    // Вызывается при загрузке проекта из файла
    // =========================================================================
    function rebuildSubscriptions() {
        if (!signalBus || !componentRegister) {
            console.error(" ConnectionManager: не инициализированы зависимости")
            return
        }

        // Очищаем все подписки
        signalBus.clear()

        // Пересоздаём для каждого правила
        rules.forEach(rule => {
            signalBus.subscribe(rule.signal, rule.toId, (srcId, payload) => {
                if (srcId !== rule.fromId || !rule.enabled) return
                processSlot(rule.toId, rule.slot, payload)
            }, rule.fromId)
        })

        console.log(` Пересоздано ${rules.length} подписок`)
    }

    // =========================================================================
    // ПОЛУЧЕНИЕ ПРАВИЛ ПО ЭЛЕМЕНТУ
    // =========================================================================
    function getRulesByElement(elementId, asSource = true) {
        return asSource
            ? (rulesByFromId[elementId] || [])
            : (rulesByToId[elementId] || [])
    }

    // =========================================================================
    // ПОЛНАЯ ОЧИСТКА
    // =========================================================================
    function clear() {
        rules = []
        rulesByFromId = {}
        rulesByToId = {}
        rulesByHash = {}
        signalRules()
        signalBus?.clear()
        console.log("️ ConnectionManager полностью очищен")
    }

    // =========================================================================
    // СТАТИСТИКА (ДЛЯ МОНИТОРИНГА)
    // =========================================================================
    function getStats() {
        const fromIds = Object.keys(rulesByFromId)
        const toIds = Object.keys(rulesByToId)

        return {
            totalRules: rules.length,
            uniqueSources: fromIds.length,
            uniqueTargets: toIds.length,
            avgConnectionsPerSource: fromIds.length > 0 ? rules.length / fromIds.length : 0,
            signalBusStats: signalBus?.getStats() || {}
        }
    }
}
