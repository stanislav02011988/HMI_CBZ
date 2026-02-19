// OperatingMode.qml
import QtQuick
import QtQuick.Controls
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_preview

Item {
    id: operatingRoot
    anchors.fill: parent

    property var sceneBus: null
    property var componentRegister: null
    property var connectionManager: null

    Item {
        id: sceneLayer
        anchors.fill: parent
        clip: true
    }

    PreviewComponents { id: previewComponents }

    Component.onCompleted: {
        if (!componentRegister || !componentRegister.elements || componentRegister.elements.length === 0) {
            console.log(" OperatingMode: сцена пуста (регистр не содержит элементов)")
            return
        }

        console.log(`OperatingMode: загрузка ${componentRegister.elements.length} элементов...`)

        // Очистка сцены
        for (var i = sceneLayer.children.length - 1; i >= 0; i--) {
            sceneLayer.children[i].destroy()
        }

        // Создание виджетов
        componentRegister.elements.forEach(elem => {
            if (!componentRegister || !componentRegister.elements.length) {
               console.log("ℹ️ OperatingMode: сцена пуста")
               return
            }

            console.log(`🚀 OperatingMode: загрузка ${componentRegister.elements.length} элементов...`)

            // ОЧИСТКА СЦЕНЫ
            for (var i = sceneLayer.children.length - 1; i >= 0; i--) {
               sceneLayer.children[i].destroy()
            }

            // Создаём виджет напрямую в сцене
            const widget = component.createObject(sceneLayer, {
                sceneBus: operatingRoot.sceneBus,
                id_widget: config.id_widget,
                name_widget: config.name_widget,
                level_cement_silos: config.level_cement_silos || 0,
                manualModeEnabled: config.manualModeEnabled || false,
                systemInEmergency: config.systemInEmergency || false,
                isZeroingInProgress: config.isZeroingInProgress || false
            })

            if (!widget) {
                console.error(` OperatingMode: ошибка создания виджета ${config.id_widget}`)
                return
            }
           // 🔑 КРИТИЧЕСКИ ВАЖНО: ПЕРЕСОЗДАНИЕ ПОДПИСОК ПОСЛЕ СОЗДАНИЯ ВИДЖЕТОВ!
           if (connectionManager && typeof connectionManager.rebuildSubscriptions === 'function') {
               connectionManager.rebuildSubscriptions()
               console.log(`✅ OperatingMode: подписки пересозданы для ${componentRegister.elements.length} элементов`)
           } else {
               console.warn("⚠️ ConnectionManager не поддерживает rebuildSubscriptions")
           }

            // Устанавливаем позицию и размеры
            widget.x = config.relX * sceneLayer.width
            widget.y = config.relY * sceneLayer.height
            widget.width = config.relW * sceneLayer.width
            widget.height = config.relH * sceneLayer.height

            console.log(` OperatingMode: загружен элемент ${config.id_widget} (${config.subtype})`)
        })

        console.log(` OperatingMode: сцена загружена (${componentRegister.elements.length} элементов)`)
    }

    function findWidgetById(id) {
        for (var i = 0; i < sceneLayer.children.length; i++) {
            const child = sceneLayer.children[i]
            if (child.id_widget === id) return child
        }
        return null
    }

    // ⚠️ НЕТ Connections здесь! Сигналы обрабатываются через ConnectionManager.subscribe()
}
