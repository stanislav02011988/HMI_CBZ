// qml/system/ReactiveElement.qml
import QtQuick
import system 1.0

Item {

    id: root

    property string elementId: ""

    property bool reactive: true

    property bool _internalUpdate: false

    property string topic: "element." + elementId


    // =====================================================
    // ОТПРАВКА
    // =====================================================

    function emitEvent(event, payload) {

        if (!reactive)
            return

        if (_internalUpdate)
            return

        QmlBusManager.publish(
            topic,
            event,
            payload
        )

    }


    // =====================================================
    // ПОДПИСКА
    // =====================================================

    Component.onCompleted: {

        if (!reactive)
            return

        QmlBusManager.subscribe(topic, function(event, payload){

            root._internalUpdate = true

            root.handleEvent(event, payload)

            root._internalUpdate = false

        })

    }


    // =====================================================
    // ПЕРЕОПРЕДЕЛЯЕТСЯ В ДОЧЕРНИХ КОМПОНЕНТАХ
    // =====================================================

    function handleEvent(event, payload) {
    }

}
