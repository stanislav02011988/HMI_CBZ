// qml.content.main_window.main_window_widgets.center_widget CenterWidget.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import qml.managers
import qml.settings.project_settings

import qml.content.main_window.center_widget.modes.operating_mode
import qml.content.main_window.center_widget.modes.edit_mode

Item {
    id: centerWidget
    anchors.fill: parent

    property bool isActivateEditMode: QmlSceneManager.isActivateEditMode
    property bool editMode: false

    property alias mode: modeLoader.item

    Loader {
        id: modeLoader
        anchors.fill: parent
        sourceComponent: editMode ? editModeComponent : operatingModeComponent
    }

    Component { id: editModeComponent; EditMode { editMode: centerWidget.editMode } }
    Component { id: operatingModeComponent; OperatingMode { editMode: centerWidget.editMode } }

    // === КНОПКА ПЕРЕКЛЮЧЕНИЯ (ПОСЛЕ Loader, с высоким z) ===
    Button {
        id: modeToggleButton
        visible: centerWidget.isActivateEditMode
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        width: 180
        height: 36
        z: 1000  // 🔑 ГАРАНТИРУЕМ, ЧТО КНОПКА ВСЕГДА ПОВЕРХ ВСЕГО!
        // Визуальная обратная связь
        hoverEnabled: true
        text: centerWidget.editMode ? "⚙️ Режим работы" : "✏️ Режим редактирования"
        font.pixelSize: 13
        font.bold: true
        onClicked: {
            const newMode = !centerWidget.editMode
            centerWidget.editMode = newMode            
        }
        background: Rectangle {
            radius: 6
            // Динамический цвет: зелёный для редактирования, синий для работы
            color: {
                if (modeToggleButton.pressed) return centerWidget.editMode ? "#388E3C" : "#1565C0"
                if (modeToggleButton.hovered) return centerWidget.editMode ? "#66BB6A" : "#42A5F5"
                return centerWidget.editMode ? "#4CAF50" : "#2196F3"
            }
            border.color: "white"
            border.width: 1
        }
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Segoe UI"
        }
        ToolTip {
            id: modeToolTip
            text: centerWidget.editMode
                ? "Текущий режим: РЕДАКТИРОВАНИЕ\nНажмите для перехода в рабочий режим"
                : "Текущий режим: РАБОТА\nНажмите для перехода в режим редактирования"
            visible: modeToggleButton.hovered
            delay: 500
        }
    }
}
