pragma Singleton
import QtQuick
import qml.busManager

QtObject {
    id: root
    property var connections: []

    function load(conns) { connections = conns }

    Component.onCompleted: {
        QmlBusManager.subscribe("*", function(event, payload, topic){
            for (let i = 0; i < connections.length; i++) {
                const c = connections[i]
                const fromTopic = c.from.widget + "." + c.from.element
                if (topic === fromTopic && event === c.from.signal) {
                    const targetTopic = c.to.widget + "." + c.to.element
                    QmlBusManager.publish(targetTopic, c.to.slot, payload)
                }
            }
        })
    }
}
