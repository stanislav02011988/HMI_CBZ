import QtQuick
import qml.busManager

QtObject {
    id: root

    property string widgetId
    property var slotTargets: []
    property var syncFn

    property var _map: ({})
    property string _topicBase: ""
    property var _callback: null
    property bool _initialized: false

    function start(){

        if (_initialized) {
            console.error("[ReactiveElement] DOUBLE INIT BLOCKED:", widgetId)
            return
        }

        _initialized = true

        _topicBase = widgetId

        console.log("[ReactiveElement] init:", widgetId)

        // map
        for (let i = 0; i < slotTargets.length; i++) {
            let t = slotTargets[i]
            _map[t.elementId] = t.object
        }

        // callback
        _callback = function(event, payload, topic) {

            if (!topic.startsWith(_topicBase + "."))
                return

            let elementId = topic.substring(_topicBase.length + 1)
            let targetObj = _map[elementId]

            if (!targetObj)
                return

            if (syncFn) {
                syncFn(event, payload, {
                    elementId: elementId,
                    object: targetObj
                })
            }
        }

        QmlBusManager.subscribe(_topicBase, _callback)

        console.log("[ReactiveElement] subscribed:", _topicBase)
    }

    Component.onDestruction: {
        console.log("[ReactiveElement] destroy:", widgetId)

        if (_callback) {
            QmlBusManager.unsubscribe(_topicBase, _callback)
        }

        _map = {}
        _callback = null
        _initialized = false
    }
}
