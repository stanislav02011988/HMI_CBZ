// qml\registers\QmlRegisterComponentLogicMap.qml
pragma Singleton
import QtQuick

import python.py_register_component_logic_map.interface_qml 1.0 as BackendModule

QtObject {
    id: root

    // ============================================================
    // BACKEND LINK
    // ============================================================
    readonly property var backend: BackendModule.RegisterComponentLogicMap


    // ============================================================
    // DERIVED / PUBLIC PROPERTIES
    // ============================================================
    readonly property int count: backend.count

    // ============================================================
    // PUBLIC SIGNALS (Proxy layer)
    // ============================================================
    signal elementAdded(string id)
    signal elementRemoved(string id)
    signal registryChanged()


    // ============================================================
    // SIGNAL FORWARDING
    // ============================================================
    Component.onCompleted: {
        backend.elementAdded.connect(root.elementAdded)
        backend.elementRemoved.connect(root.elementRemoved)
        backend.registryChanged.connect(root.registryChanged)
    }

    function registerElement(wrapper, widgetRef) { return backend.registerElement(wrapper, widgetRef) }
    function getElementById(id) { return backend.getElementById(id) }
    function unregisterElement(wrapper) { return backend.unregisterElement(wrapper) }
    function clear() { backend.clear() }

    function exportSceneData() { return backend.exportSceneData() }
    function exportElementData(id_widget) { return backend.exportElementData(id_widget) }
}
