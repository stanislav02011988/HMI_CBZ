// ComponentObjectRegister.qml
import QtQuick

Item {
    id: register
    // Единое хранилище всех элементов сцены
    property var elements: [] // [{ wrapper, config, widgetRef }]

    signal elementAdded(string id)
    signal elementRemoved(string id)
    signal registryChanged()

    function registerElement(wrapper, config, widgetRef) {
        if (getElementById(config.id_widget)) {
            console.warn(`ID "${config.id_widget}" уже существует!`)
            return false
        }

        elements.push({
            wrapper: wrapper,
            config: Object.assign({}, config),
            widgetRef: widgetRef,
            createdAt: new Date().toISOString()
        })
        elementAdded(config.id_widget)
        registryChanged()
        // console.log(`Зарегистрирован элемент: ${config.id_widget}`)
        return true
    }

    function unregisterElement(wrapper) {
        for (let i = elements.length - 1; i >= 0; i--) {
            if (elements[i].wrapper === wrapper) {
                const id = elements[i].config.id_widget
                elements.splice(i, 1)
                elementRemoved(id)
                registryChanged()
                console.log(`Удалён элемент: ${id}`)
                return true
            }
        }
        return false
    }

    function getElementById(id) {
        return elements.find(e => e.config.id_widget === id)
    }

    function getAllIds() {
        return elements.map(e => e.config.id_widget)
    }

    function exportSceneData() {
        return elements.map(e => ({
            type: e.wrapper.type,
            relX: e.wrapper.relX, relY: e.wrapper.relY,
            relW: e.wrapper.relW, relH: e.wrapper.relH,
            widgetConfig: e.config
        }))
    }

    function clear() {
        elements = []
        registryChanged()
        console.log("Регистр очищен")
    }
}
