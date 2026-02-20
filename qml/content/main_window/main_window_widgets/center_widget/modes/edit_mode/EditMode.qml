// module qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode EditMode.qml
import QtQuick
import QtQuick.Controls
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.panel_button_edit_mode
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements
import "edit_mode_internal"

Item {
    id: editMode
    anchors.fill: parent

    // ПРИНИМАЕМ ГЛОБАЛЬНЫЕ МЕНЕДЖЕРЫ ИЗ CenterWidget
    property var signalBus: null
    property var componentRegister: null  // ← Получаем извне
    property var connectionManager: null  // ← Получаем извне

    // Алиасы для сетки (без изменений)
    property alias gridEnabled: internal.gridEnabled
    property alias gridSpacing: internal.gridSpacing
    property alias gridColor: internal.gridColor
    property alias isModified: internal.isModified

    signal itemAdded(var item)
    signal itemRemoved(var item)
    signal sceneSaveRequested(var data)
    signal signalListIdScene(var items)

    // === ОСНОВНАЯ СЦЕНА С ПЕРЕДАЧЕЙ ГЛОБАЛЬНЫХ МЕНЕДЖЕРОВ ===
    EditModeInternal {
        id: internal
        anchors.fill: parent
        signalBus: editMode.signalBus
        componentRegister: editMode.componentRegister
        connectionManager: editMode.connectionManager

        onItemAdded: (item) => editMode.itemAdded(item)
        onItemRemoved: (item) => editMode.itemRemoved(item)
        onSceneSaveRequested: (data) => editMode.sceneSaveRequested(data)
    }

    // Диалог добавления
    DialogAddElements {
        id: dialogAddElement
        sceneController: editMode
    }

    // Панель управления
    PanelButtonEditMode {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 15
        onSignalGridEnable: (check) => editMode.gridEnabled = check
        onSignalClearScenes: editMode.clearScene()
        onAddElementRequested: dialogAddElement.open()
    }

    // Граница режима
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "green"
        border.width: 2
    }

    // === МЕТОДЫ УПРАВЛЕНИЯ (ИСПОЛЬЗУЮТ ГЛОБАЛЬНЫЕ МЕНЕДЖЕРЫ) ===
    function addItemToScene(config) {
        if (!config?.id_widget || componentRegister.getElementById(config.id_widget)) {
            console.error(`Дублирующийся ID: ${config?.id_widget}`)
            return null
        }
        return internal.addItemToScene(config)
    }

    function saveSceneToFile() {
        const sceneData = componentRegister.exportSceneData()
        sceneSaveRequested(sceneData)
        console.log(` Сохранено ${sceneData.length} элементов`)
    }

    function clearScene() {
        connectionManager.clear()      // Очищаем глобальный менеджер связей
        componentRegister.clear()      // Очищаем глобальный регистр
        internal.clearScene()          // Очищаем визуальную сцену
        console.log("Сцена полностью очищена")
    }

    function deselectAll() { internal.deselectAll() }
}
