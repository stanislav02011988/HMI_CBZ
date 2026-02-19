// managers/ConnectionManager.qml
import QtQuick

Item {
    id: manager
    property var signalBus: null
    property var componentRegister: null  // ← КРИТИЧЕСКИ ВАЖНОЕ ДОБАВЛЕНИЕ
    property var rules: [] // { fromId, signal, toId, slot, enabled }

    signal signalRules()

    signal connectionCreated(var rule)
    signal connectionRemoved(string fromId, string toId)

    // === СОЗДАНИЕ СВЯЗИ ===
    function createConnection(fromId, signal, toId, slot) {
        // === ЭТАП 1: ВХОД В ФУНКЦИЮ ===
        // console.log(` [ConnectionManager] ────────────────────────────────────────`)
        // console.log(` [ConnectionManager] createConnection ВЫЗВАНА`)
        // console.log(`    Параметры:`)
        // console.log(`      • fromId: "${fromId}" (тип: ${typeof fromId})`)
        // console.log(`      • signal: "${signal}" (тип: ${typeof signal})`)
        // console.log(`      • toId: "${toId}" (тип: ${typeof toId})`)
        // console.log(`      • slot: "${slot}" (тип: ${typeof slot})`)
        // console.log(`    Текущее состояние:`)
        // console.log(`      • rules.length: ${rules.length}`)
        // console.log(`      • signalBus: ${signalBus ? "ИНИЦИАЛИЗИРОВАН" : "НЕТ!"}`)
        // console.log(`      • componentRegister: ${componentRegister ? "ИНИЦИАЛИЗИРОВАН" : "НЕТ!"}`)

        // === ЭТАП 2: ПРОВЕРКА ИНИЦИАЛИЗАЦИИ ===
        if (!signalBus || !componentRegister) {
            // console.error(` [ConnectionManager] КРИТИЧЕСКАЯ ОШИБКА: Зависимости НЕ ИНИЦИАЛИЗИРОВАНЫ!`)
            // console.error(`   • signalBus: ${signalBus}`)
            // console.error(`   • componentRegister: ${componentRegister}`)
            // console.error(`   • Вызов стек: ${new Error().stack}`)
            return false
        }
        // console.log(`[ConnectionManager] Зависимости проверены — ВСЁ ОК`)

        // === ЭТАП 3: ПРОВЕРКА УНИКАЛЬНОСТИ ===
        const existingRule = rules.find(r =>
            r.fromId === fromId && r.signal === signal &&
            r.toId === toId && r.slot === slot
        )
        if (existingRule) {
            // console.warn(`[ConnectionManager] СВЯЗЬ УЖЕ СУЩЕСТВУЕТ!`)
            // console.warn(`   fromId: ${fromId} → toId: ${toId}`)
            // console.warn(`   signal: ${signal} → slot: ${slot}`)
            // console.warn(`   Текущее правило:`, JSON.stringify(existingRule))
            return false
        }
        // console.log(`[ConnectionManager] Уникальность проверена — новая связь`)

        // === ЭТАП 4: СОЗДАНИЕ ПРАВИЛА ===
        const rule = {
            fromId,
            signal,
            toId,
            slot,
            enabled: true,
            createdAt: new Date().toISOString(),
            id: `rule_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`
        }
        // console.log(` [ConnectionManager] Создано правило:`)
        // console.log(`   • ID правила: ${rule.id}`)
        // console.log(`   • Данные:`, JSON.stringify(rule, null, 2))

        // === ЭТАП 5: ПОДПИСКА НА СИГНАЛ ===
        try {
            // console.log(` [ConnectionManager] ПОПЫТКА ПОДПИСКИ в signalBus.subscribe()`)
            // console.log(`   • signal: "${signal}"`)
            // console.log(`   • targetId (toId): "${toId}"`)
            // console.log(`   • filterSourceId (fromId): "${fromId}"`)

            signalBus.subscribe(signal, toId, (srcId, payload) => {
                // === ДЕТАЛЬНЫЙ ЛОГ ПРИ ПОЛУЧЕНИИ СИГНАЛА ===
                // console.log(` [ConnectionManager] ПОЛУЧЕН СИГНАЛ "${signal}"`)
                // console.log(`   • Источник (srcId): "${srcId}"`)
                // console.log(`   • Цель (toId): "${toId}"`)
                // console.log(`   • Payload:`, JSON.stringify(payload, null, 2))
                // console.log(`   • Правило:`, JSON.stringify(rule, null, 2))

                // Фильтрация
                if (srcId !== fromId) {
                    // console.log(`   ️ ОТФИЛЬТРОВАНО: ожидаемый fromId="${fromId}", получен srcId="${srcId}"`)
                    return
                }
                if (!rule.enabled) {
                    // console.log(`    ОТФИЛЬТРОВАНО: правило отключено (enabled=false)`)
                    return
                }

                // console.log(` [ConnectionManager] СИГНАЛ ПРОШЁЛ ФИЛЬТРАЦИЮ — вызов processSlot()`)
                processSlot(toId, slot, payload)
            }, fromId)

            // console.log(` [ConnectionManager] ПОДПИСКА УСПЕШНО СОЗДАНА в signalBus`)
        } catch (e) {
            // console.error(` [ConnectionManager] ОШИБКА ПРИ ПОДПИСКЕ!`)
            // console.error(`   • Ошибка:`, e)
            // console.error(`   • Стек:`, e.stack)
            // console.log(`   • Откат: правило НЕ добавлено в rules`)
            return false
        }

        // === ЭТАП 6: СОХРАНЕНИЕ ПРАВИЛА ===
        rules.push(rule)
        signalRules()
        // console.log(` [ConnectionManager] Правило СОХРАНЕНО в rules (всего: ${rules.length})`)
        // console.log(`   • Последнее правило:`, JSON.stringify(rules[rules.length - 1], null, 2))

        // === ЭТАП 7: ВЫЗОВ СИГНАЛА ===
        try {
            connectionCreated(rule)
            // console.log(` [ConnectionManager] Сигнал connectionCreated ВЫЗВАН`)
        } catch (e) {
            // console.error(`️ [ConnectionManager] Ошибка при вызове connectionCreated:`, e)
        }

        // === ЭТАП 8: ФИНАЛЬНЫЙ ОТЧЁТ ===
        console.log(` [ConnectionManager] СВЯЗЬ УСПЕШНО СОЗДАНА!`)
        console.log(`   • ${fromId}.${signal} ───→ ${toId}.${slot}`)
        console.log(`   • ID правила: ${rule.id}`)
        console.log(`   • Всего правил: ${rules.length}`)
        console.log(` [ConnectionManager] ────────────────────────────────────────`)

        return true
    }

    // === ОБРАБОТКА СЛОТА ===
    function processSlot(targetId, slotName, payload) {
        if (!componentRegister) {
            console.error("ConnectionManager: componentRegister не инициализирован")
            return
        }

        const elem = componentRegister.getElementById(targetId)
        if (!elem?.widgetRef) {
            console.warn(`Элемент не найден для ID: ${targetId}`)
            return
        }

        switch(slotName) {
            case "setEnabled":
                elem.widgetRef.enabled = payload.value;
                break
            case "setVisible":
                elem.widgetRef.visible = payload.value;
                break
            // Расширяем по мере необходимости
            default:
                console.warn(`Неизвестный слот: ${slotName}`)
        }
    }

    // === УДАЛЕНИЕ ВСЕХ СВЯЗЕЙ ЭЛЕМЕНТА (КРИТИЧЕСКИ ВАЖНО!) ===
    function removeConnectionsForElement(elementId) {
        if (!elementId) return

        // Фильтруем правила, оставляя только не связанные с элементом
        const originalCount = rules.length
        rules = rules.filter(rule =>
            rule.fromId !== elementId && rule.toId !== elementId
        )
        signalRules()
        // Отписываемся от всех сигналов элемента через signalBus
        if (signalBus && typeof signalBus.unsubscribeAll === 'function') {
            signalBus.unsubscribeAll(elementId)
        }

        const removedCount = originalCount - rules.length
        if (removedCount > 0) {
            console.log(`Удалено ${removedCount} связей для элемента: ${elementId}`)
        }
    }

    // === УДАЛЕНИЕ КОНКРЕТНОЙ СВЯЗИ ===
    function removeConnection(fromId, toId, signal, slot) {
        const originalCount = rules.length
        rules = rules.filter(r =>
            !(r.fromId === fromId && r.toId === toId &&
              r.signal === signal && r.slot === slot)
        )

        if (rules.length < originalCount) {
            connectionRemoved(fromId, toId)
            signalRules()
            // console.log(`Связь удалена: ${fromId}.${signal} → ${toId}.${slot}`)
            console.log(`Связь удалена!!!!!!!!!!!!!!!!!!!!!!!!!`)
        }
    }

    // === ПОЛНАЯ ОЧИСТКА ===
    function clear() {
        rules = []
        signalRules()
        if (signalBus && typeof signalBus.clear === 'function') {
            signalBus.clear()
            console.log("ConnectionManager: все связи очищены")
        }
    }

    function rebuildSubscriptions() {
        if (!signalBus || !componentRegister) {
            console.error("ConnectionManager: не инициализированы зависимости")
            return
        }

        // Очищаем ВСЕ подписки в шине, но сохраняем правила
        signalBus.clear()

        // Пересоздаём подписки для каждого правила
        rules.forEach(rule => {
            signalBus.subscribe(rule.signal, rule.toId, (srcId, payload) => {
                if (srcId !== rule.fromId || !rule.enabled) return
                processSlot(rule.toId, rule.slot, payload)
            }, rule.fromId)
        })

        console.log(`ConnectionManager: пересоздано ${rules.length} подписок`)
    }
}
