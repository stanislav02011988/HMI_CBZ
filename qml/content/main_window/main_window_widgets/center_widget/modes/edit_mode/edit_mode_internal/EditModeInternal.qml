// edit_mode_internal/EditModeInternal.qml
import QtQuick
import QtQuick.Controls
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_preview
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.internal.manager_line

Item {
    id: root
    anchors.fill: parent

    // === МЕНЕДЖЕРЫ ===
    property var sceneBus: null
    property var componentRegister: null
    property var connectionManager: null

    property alias managerLine: managerLine

    property var selectedItems: []
    property var rulesArray: []

    // === СЕТКА ===
    property bool gridEnabled: false
    property int gridSpacing: 20
    property color gridColor: "green"

    // === СОСТОЯНИЕ ===
    property bool isModified: false

    signal itemAdded(var item)
    signal itemRemoved(var item)
    signal sceneSaveRequested(var data)
    signal signalListIdScene(var list)

    // =====================================================
    //  ГЛАВНЫЙ СЛОЙ СЦЕНЫ
    // =====================================================
    Item {
        id: sceneLayer
        anchors.fill: parent
        clip: true

        // СЕТКА
        Repeater {
            model: gridEnabled ? Math.ceil(sceneLayer.width / gridSpacing) : 0
            Rectangle {
                x: index * gridSpacing
                width: 1; height: sceneLayer.height
                color: gridColor
            }
        }
        Repeater {
            model: gridEnabled ? Math.ceil(sceneLayer.height / gridSpacing) : 0
            Rectangle {
                y: index * gridSpacing
                height: 1; width: sceneLayer.width
                color: gridColor
            }
        }

        // ФОН (сброс выделения)
        MouseArea {
            id: backgroundMouseArea
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
            onClicked: (mouse) => {
                deselectAll()
                mouse.accepted = true
            }
        }

        //  МЕНЕДЖЕР СТРЕЛОК (ЕДИНЫЙ ЦЕНТР УПРАВЛЕНИЯ)
        ManagerLine {
            id: managerLine
            anchors.fill: parent
            rulesArray: root.rulesArray
            componentRegister: root.componentRegister
            connectionManager: root.connectionManager
            sceneLayer: sceneLayer
        }
    }

    // =====================================================
    // КЛАВИАТУРА
    // =====================================================
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            if (managerLine.dragState === 1) {
                managerLine.cleanupDrag()
            } else if (managerLine.dragState === 2 && managerLine.confirmDialog?.visible) {
                managerLine.confirmDialog.close()
                managerLine.cleanupDrag()
            }
            event.accepted = true
        }
    }

    // === ПРЕВЬЮ КОМПОНЕНТОВ ===
    PreviewComponents { id: previewComponents }

    // === КОМПОНЕНТ ОБЁРТКИ  ===
    Component {
        id: editableWrapperComponent
        EditableItem {
            editMode: true
            sceneContainer: sceneLayer
            sceneController: root
            connectionManager: root.connectionManager
            componentRegister: root.componentRegister
            sceneBus: root.sceneBus
        }
    }

    // =====================================================
    // 🔑 ИНИЦИАЛИЗАЦИЯ МЕНЕДЖЕРОВ
    // =====================================================
    Component.onCompleted: {
        if (connectionManager && Array.isArray(connectionManager.rules)) {
            rulesArray = connectionManager.rules.slice()
            console.log(` rulesArray инициализирован: ${rulesArray.length} связей`)
        }
    }

    Connections {
        target: connectionManager
        function onSignalRules() {
            if (connectionManager && Array.isArray(connectionManager.rules)) {
                rulesArray = connectionManager.rules.slice()
            } else {
                rulesArray = []
            }
        }
    }

    // =====================================================
    // 🔑 ДОБАВЛЕНИЕ ЭЛЕМЕНТА
    // =====================================================
    function addItemToScene(data) {
        const component = previewComponents.getPreviewComponent(data.subtype)
        if (!component) return null

        const isSilos = (data.subtype === "silos_vertical")
        const relW = isSilos ? 0.05 : 0.1
        const relH = isSilos ? 0.25 : 0.1
        const offset = (componentRegister?.elements.length || 0) * 0.15

        const wrapper = editableWrapperComponent.createObject(sceneLayer, {
            type: data.subtype,
            relX: Math.min(0.7, 0.1 + (offset % 0.6)),
            relY: Math.min(0.7, 0.15 + (offset * 0.5) % 0.6),
            relW: relW,
            relH: relH,
            isSelected: false,
            widgetComponent: component,
            widgetConfig: {
                sceneBus: root.sceneBus,
                id_widget: data.id_widget,
                name_widget: data.name_widget,
            }
        })

        if (!wrapper || !wrapper.widgetInstance) {
            console.error(" Ошибка создания обёртки или виджета")
            if (wrapper) wrapper.destroy()
            return null
        }

        if (componentRegister) {
            if (!componentRegister.registerElement(wrapper, data, wrapper.widgetInstance)) {
                wrapper.destroy()
                return null
            }
        }

        wrapper.requestSelect.connect((toggle) => selectItem(wrapper, toggle))
        wrapper.requestDelete.connect(() => removeItem(wrapper))

        isModified = true
        itemAdded(wrapper)
        signalListIdScene(componentRegister?.getAllIds() || [])

        return wrapper
    }

    // =====================================================
    // 🔑 УДАЛЕНИЕ ЭЛЕМЕНТА
    // =====================================================
    function removeItem(wrapper) {
        if (!wrapper || !componentRegister) return

        const widget = wrapper.widgetInstance
        const elementId = widget?.id_widget

        if (elementId && connectionManager) {
            connectionManager.removeConnectionsForElement(elementId)
        }

        componentRegister.unregisterElement(wrapper)
        wrapper.destroy()

        itemRemoved(wrapper)
        isModified = true
        signalListIdScene(componentRegister.getAllIds())

        // Обновляем индексы соединений
        connectionArrowManager.refreshConnectionIndices()
    }

    // =====================================================
    // 🔑 ВЫДЕЛЕНИЕ ЭЛЕМЕНТОВ
    // =====================================================
    function deselectAll() {
        for (let i = 0; i < selectedItems.length; i++) {
            selectedItems[i].isSelected = false
        }
        selectedItems = []
    }

    function selectItem(wrapper, toggle = false) {
        if (toggle && selectedItems.includes(wrapper)) {
            wrapper.isSelected = false
            selectedItems.splice(selectedItems.indexOf(wrapper), 1)
        } else if (toggle) {
            wrapper.isSelected = true
            selectedItems.push(wrapper)
        } else {
            deselectAll()
            wrapper.isSelected = true
            selectedItems.push(wrapper)
        }

        if (wrapper && wrapper.forceActiveFocus) {
            wrapper.forceActiveFocus()
        }
    }

    // =====================================================
    // 🔑 ОЧИСТКА СЦЕНЫ
    // =====================================================
    function clearScene() {
        if (componentRegister) componentRegister.clear()
        if (connectionManager) connectionManager.clear()

        for (let i = sceneLayer.children.length - 1; i >= 0; i--) {
            const child = sceneLayer.children[i]
            if (child.hasOwnProperty("requestDelete")) child.destroy()
        }

        isModified = false
        signalListIdScene([])

        connectionArrowManager.cleanupDrag()

        console.log(" Сцена очищена")
    }

    // =====================================================
    // !!!!!!!!!!!!!!! СОХРАНЕНИЕ СЦЕНЫ (Тут еще надо работать Это просто заглушка)
    // =====================================================
    function saveSceneToFile() {
        if (!isModified || !componentRegister) return

        const sceneData = componentRegister.exportSceneData()
        sceneSaveRequested(sceneData)
        isModified = false

        console.log(` Сохранено ${sceneData.length} элементов`)
    }
}
