// ============================================================================
// EditMode.qml
// Режим редактирования сцены
// Полностью самодостаточная версия без EditModeInternal
// ============================================================================

import QtQuick
import QtQuick.Controls

import qml.managers
import qml.controls.elements_scene
import qml.content.main_window.center_widget.modes.edit_mode.panel_button_edit_mode
import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements


Item {
    id: root
    anchors.fill: parent

    // ============================================================
    // ОСНОВНЫЕ СВОЙСТВА
    // ============================================================
    property bool editMode: true

    // ============================================================
    // НАСТРОЙКИ СЕТКИ
    // ============================================================
    property bool gridEnabled: false
    property int gridSpacing: 20
    property string gridColor: "#1a1a2e"
    property real gridOpacity: 0.3

    // ============================================================
    // КОРНЕВОЙ КОНТЕЙНЕР СЦЕНЫ
    // ============================================================
    // ВАЖНО:
    // Мы разделяем сцену на слои:
    // 1) backgroundLayer
    // 2) gridLayer
    // 3) elementsLayer
    // Это предотвращает перекрытие MouseArea и проблем с drag
    // ============================================================
    Item {
        id: sceneRoot
        anchors.fill: parent
        clip: true

        // --------------------------------------------------------
        // СЕТКА (рисуется поверх фона)
        // --------------------------------------------------------
        Item {
            id: gridLayer
            anchors.fill: parent
            z: 1

            // Вертикальные линии
            Repeater {
                id: verticalRepeater
                model: root.gridEnabled
                       ? Math.ceil(gridLayer.width / root.gridSpacing)
                       : 0

                Rectangle {
                    x: index * root.gridSpacing
                    width: 1
                    height: gridLayer.height
                    color: root.gridColor
                    opacity: root.gridOpacity
                }
            }

            // Горизонтальные линии
            Repeater {
                id: horizontalRepeater
                model: root.gridEnabled
                       ? Math.ceil(gridLayer.height / root.gridSpacing)
                       : 0

                Rectangle {
                    y: index * root.gridSpacing
                    height: 1
                    width: gridLayer.width
                    color: root.gridColor
                    opacity: root.gridOpacity
                }
            }
        }

        // --------------------------------------------------------
        // СЛОЙ ЭЛЕМЕНТОВ (ВСЕ EditableItem создаются здесь)
        // --------------------------------------------------------
        Item {
            id: elementsLayer
            anchors.fill: parent
            z: 2
        }

        // --------------------------------------------------------
        // КЛИК ПО ФОНУ (СБРОС ВЫДЕЛЕНИЯ)
        // --------------------------------------------------------
        MouseArea {
            anchors.fill: parent
            z: 0
            propagateComposedEvents: true

            onClicked: {
                QmlSceneManager.deselectAll()
            }
        }
    }

    // ============================================================
    // КЛАВИАТУРА
    // ============================================================
    focus: true
    Keys.onPressed: (event) => {
        // Ctrl + S — сохранение сцены
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
            QmlSceneManager.saveScene()
            event.accepted = true
        }
    }

    // ============================================================
    // ПРЕВЬЮ КОМПОНЕНТОВ (фабрика виджетов)
    // ============================================================
    PreviewComponents { id: previewComponents }

    // ============================================================
    // КОМПОНЕНТ-ОБЁРТКА
    // ============================================================
    // Каждый элемент сцены создаётся через этот Component
    // ============================================================
    Component {
        id: wrapperComponent
        EditableItem {
            editMode: root.editMode
            sceneContainer: elementsLayer
        }
    }

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================
    Component.onCompleted: {
        QmlSceneManager.configure({
            sceneController: root,
            sceneContainer: elementsLayer,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,
            editMode: root.editMode
        })

        QmlSceneManager.loadScene()
    }

    // =========================================================================
    // ИЗМЕНЕНИЕ НАСТРОЕК СЕТКИ
    // =========================================================================
    function toggleGrid(enabled) {
        root.gridEnabled = enabled
        // console.log(` Сетка: ${enabled ? "включена" : "выключена"}`)
    }

    function setGridSpacing(spacing) {
        root.gridSpacing = Math.max(10, Math.min(100, spacing))
    }

    // ============================================================
    // ДИАЛОГ ДОБАВЛЕНИЯ ЭЛЕМЕНТА
    // ============================================================
    DialogAddElements {
        id: dialogAddElement
        sceneController: root

        onSignalAddElement: (data) => {
            QmlSceneManager.addItemToScene(data)
        }
    }

    // ============================================================
    // ПАНЕЛЬ УПРАВЛЕНИЯ
    // ============================================================
    PanelButtonEditMode {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 15

        onSignalGridEnable: (check) => { toggleGrid(check) }
        onSignalClearScenes: QmlSceneManager.clearScene()
        onAddElementRequested: dialogAddElement.open()
        onSignalSave: QmlSceneManager.saveScene()
    }

    // ============================================================
    // РАМКА РЕЖИМА (для визуального отличия edit режима)
    // ============================================================
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "green"
        border.width: 2
        z: 1000
    }
}
