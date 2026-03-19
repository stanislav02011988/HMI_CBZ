// qml/busManager/QmlBusManager.qml
pragma Singleton
import QtQuick
import python.py_bus_manager.interface_qml

QtObject {

    id: root

    // topic → callbacks
    property var _subscriptions: ({ })

    // --------------------------------------------------
    // INIT ROUTER
    // --------------------------------------------------

    Component.onCompleted: {
        BusManager.message.connect(function(topic, event, payload){

            let total = 0

            // 1. точное совпадение
            const exact = root._subscriptions[topic]
            if (exact) {
                total += exact.length
                for (let i = 0; i < exact.length; i++) {
                    exact[i](event, payload, topic)
                }
            }

            // 2. wildcard по widgetId
            const parts = topic.split(".")
            if (parts.length > 1) {
                const base = parts[0]

                const wildcard = root._subscriptions[base]
                if (wildcard) {
                    total += wildcard.length
                    for (let i = 0; i < wildcard.length; i++) {
                        wildcard[i](event, payload, topic)
                    }
                }
            }

            console.log("[Bus] dispatch:", topic, event, "listeners:", total)
        })
    }

    // --------------------------------------------------
    // SUBSCRIBE
    // --------------------------------------------------
    function subscribe(topic, callback) {
        if (!topic || !callback)
            return

        if (!_subscriptions[topic]) {
            _subscriptions[topic] = []
            BusManager.subscribe(topic)
        }

        let list = _subscriptions[topic]

        // ❗ БЛОКИРУЕМ ДУБЛЬ
        if (list.indexOf(callback) !== -1) {
            console.warn("[Bus] duplicate subscribe BLOCKED:", topic)
            return
        }

        list.push(callback)

        console.log("[Bus] subscribe ->", topic, "count:", list.length)
    }

    // --------------------------------------------------
    // UNSUBSCRIBE
    // --------------------------------------------------
    function unsubscribe(topic, callback) {
        const list = _subscriptions[topic]

        if (!list)
            return

        const index = list.indexOf(callback)

        if (index !== -1) {
            list.splice(index, 1)
        }

        console.log("[Bus] unsubscribe ->", topic, "count:", list.length)

        if (list.length === 0) {
            delete _subscriptions[topic]
        }
    }

    // --------------------------------------------------
    // PUBLISH
    // --------------------------------------------------
    function publish(topic, event, payload) {
        console.log("[Bus] publish:", topic, event)
        BusManager.publish(topic, event, payload)
    }
}
