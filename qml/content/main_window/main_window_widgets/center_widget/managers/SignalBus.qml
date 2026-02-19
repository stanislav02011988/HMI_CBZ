// SignalBus.qml
import QtQuick

Item {
    id: bus
    property var subscriptions: ({})

    // Подписка с фильтрацией по источнику
    function subscribe(signalName, targetId, callback, filterSourceId = null) {
        if (!subscriptions[signalName]) subscriptions[signalName] = []
        subscriptions[signalName].push({
            targetId, callback, filterSourceId
        })
        console.log(`Подписка: ${signalName} → ${targetId}`)
    }

    // Эмит сигнала
    function emit(signalName, sourceId, payload = {}) {
        const subs = subscriptions[signalName] || []
        subs.forEach(sub => {
            if (sub.filterSourceId && sub.filterSourceId !== sourceId) return
            try { sub.callback(sourceId, payload) }
            catch (e) { console.error("Ошибка обработки сигнала:", e) }
        })
    }

    // Отписка ВСЕХ подписок для элемента
    function unsubscribeAll(targetId) {
        Object.keys(subscriptions).forEach(signal => {
            subscriptions[signal] = subscriptions[signal].filter(
                sub => sub.targetId !== targetId
            )
        })
        // console.log(`Отписка всех сигналов для: ${targetId}`)
    }

    // Полная очистка
    function clear() {
        subscriptions = {}
        console.log("SignalBus очищен")
    }
}
