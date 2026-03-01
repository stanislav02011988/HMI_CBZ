// qml/managers/QmlRegisterComponentObject.qml
pragma Singleton
import QtQuick

// Импорт Python singleton
import python.py_register_component_object.interface_qml 1.0 as BackendModule


QtObject {
    id: root

    // ============================================================
    // BACKEND LINK
    // ============================================================
    // Ссылка на Python singleton.
    // Это НЕ создание объекта, а ссылка на уже зарегистрированный instance.
    readonly property var backend: BackendModule.RegisterComponentObject


    // ============================================================
    // DERIVED / PUBLIC PROPERTIES
    // ============================================================

    // Проксируем count для удобства биндингов в UI
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
    // Пробрасываем сигналы из Python singleton в QML wrapper.
    // Это позволяет UI НЕ знать о backend напрямую.

    Component.onCompleted: {
        backend.elementAdded.connect(root.elementAdded)
        backend.elementRemoved.connect(root.elementRemoved)
        backend.registryChanged.connect(root.registryChanged)
    }


    // ============================================================
    // PUBLIC API (Facade Layer)
    // ============================================================
    // Здесь можно:
    //  - валидировать данные
    //  - трансформировать структуры
    //  - логировать вызовы
    //  - нормализовать формат
    //  - добавлять кэширование

    function registerElement(wrapper, config, widgetRef) {
        return backend.registerElement(wrapper, config, widgetRef)
    }

    function unregisterElement(wrapper) {
        return backend.unregisterElement(wrapper)
    }

    function getElementById(id) {
        return backend.getElementById(id)
    }

    function getElementWrapper(id) {
        return backend.getElementWrapper(id)
    }

    function getElementWidgetRef(id) {
        return backend.getElementWidgetRef(id)
    }

    function getAllIds() {
        return backend.getAllIds()
    }

    function exportSceneData() {
        return backend.exportSceneData()
    }

    function clear() {
        backend.clear()
    }

    function contains(id) {
        return backend.contains(id)
    }
}
