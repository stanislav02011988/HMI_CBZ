// qml/system/QmlBusManager.qml
pragma Singleton
import QtQuick

import python.py_bus_manager.interface_qml

QtObject {

    // =====================================================
    // SUBSCRIBE
    // =====================================================

    function subscribe(topic, callback) {

        SceneBus.subscribe(topic)

        SceneBus.message.connect(function(t, e, payload){

            if (t === topic) {
                callback(e, payload)
            }

        })

    }

    // =====================================================
    // PUBLISH
    // =====================================================

    function publish(topic, event, payload) {

        SceneBus.publish(
            topic,
            event,
            payload
        )

    }

}
