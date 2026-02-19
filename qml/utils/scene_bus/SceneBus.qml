// SceneBus.qml
// Централизованная шина событий для связывания элементов без прямых зависимостей.
import QtQuick 2.15

QtObject {
    id: sceneBus

    // Сигнал: тип события, ID источника, данные
    signal eventEmitted(string eventType, string sourceId, var payload)

    // Эмит события
    function emit(eventType, sourceId, payload = {}) {
        eventEmitted(eventType, sourceId, payload)
    }

    // Хранилище подписок: { eventType → [ { targetId, handler } ] }
    property var subscriptions: ({})

    // Подписка
    function subscribe(eventType, targetId, handler) {
        if (!subscriptions[eventType]) subscriptions[eventType] = []
        subscriptions[eventType].push({ targetId: targetId, handler: handler })
    }

    // Отписка по targetId
    function unsubscribe(targetId) {
        for (var type in subscriptions) {
            var list = subscriptions[type]
            for (var i = list.length - 1; i >= 0; i--) {
                if (list[i].targetId === targetId) {
                    list.splice(i, 1)
                }
            }
        }
    }

    // Автоматическая маршрутизация при эмите
    onEventEmitted: (eventType, sourceId, payload) => {
        var list = subscriptions[eventType]
        if (!list) return
        for (var i = 0; i < list.length; i++) {
            var sub = list[i]
            if (typeof sub.handler === 'function') {
                sub.handler(sourceId, payload)
            }
        }
    }
}
