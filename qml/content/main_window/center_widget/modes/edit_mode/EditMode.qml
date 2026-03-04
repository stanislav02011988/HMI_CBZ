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
    // СВОЙСТВА ДОСТУПНЫЕ ИЗ ВНЕ
    // ============================================================
    property alias viewport: viewport
    property alias world: world

    // ==============================
    // Параметры камеры
    // ==============================
    property real zoom: 1.0
    property real minZoom: 0.2
    property real maxZoom: 5.0

    property real offsetX: 0
    property real offsetY: 0

    // ============================================================
    // НАСТРОЙКИ СЕТКИ
    // ============================================================
    property bool gridEnabled: false
    property int gridSpacing: 20
    property string gridColor: "#1a1a2e"
    property real gridOpacity: 0.3

    // ==============================
    // VIEWPORT
    // ==============================

    Item {
        id: viewport
        anchors.fill: parent
        clip: true

        // --------------------------------------------------------
        // СЕТКА
        // --------------------------------------------------------
        Item {
            id: gridLayer
            anchors.fill: parent
            z: 1

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

        // ==========================
        // WORLD
        // ==========================
        Item {
            id: world
            x: root.offsetX
            y: root.offsetY
            width: 100000
            height: 100000
            scale: root.zoom
            transformOrigin: Item.TopLeft
        }

        // ==========================
        // УПРАВЛЕНИЕ МЫШЬЮ
        // ==========================
        MouseArea {
            id: mouseArea
            visible: editMode
            anchors.fill: parent
            hoverEnabled: false
            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true

            property point lastPos
            property bool panning: false

            cursorShape: panning
                         ? Qt.ClosedHandCursor
                         : Qt.ArrowCursor

            onPressed: (mouse) => {

                const ctrl = mouse.modifiers & Qt.ControlModifier

                // Ctrl + ЛКМ → панорама
                if (ctrl && mouse.button === Qt.LeftButton) {
                    panning = true
                    lastPos = Qt.point(mouse.x, mouse.y)
                    mouse.accepted = true
                    return
                }

                // ЛКМ без Ctrl → пока НЕ принимаем
                mouse.accepted = false
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.LeftButton)
                    panning = false
            }

            onPositionChanged: (mouse) => {

                if (!panning)
                    return

                let dx = mouse.x - lastPos.x
                let dy = mouse.y - lastPos.y

                root.offsetX += dx
                root.offsetY += dy

                lastPos = Qt.point(mouse.x, mouse.y)
            }

            onWheel: (wheel) => {

                if (!(wheel.modifiers & Qt.ControlModifier))
                    return

                wheel.accepted = true

                let oldZoom = root.zoom
                let factor = 1.15

                if (wheel.angleDelta.y > 0)
                    root.zoom *= factor
                else
                    root.zoom /= factor

                root.zoom = Math.max(root.minZoom,
                                     Math.min(root.maxZoom, root.zoom))

                let mouseX = wheel.x
                let mouseY = wheel.y

                let worldX = (mouseX - root.offsetX) / oldZoom
                let worldY = (mouseY - root.offsetY) / oldZoom

                root.offsetX = mouseX - worldX * root.zoom
                root.offsetY = mouseY - worldY * root.zoom
            }

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton &&
                    !(mouse.modifiers & Qt.ControlModifier)) {
                    QmlSceneManager.deselectAll()
                }
            }
        }
    }

    // ============================================================
    // КЛАВИАТУРА (отслеживание Ctrl для курсора)
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
            sceneContainer: world
            scene: viewport
        }
    }

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================
    Component.onCompleted: {
        QmlSceneManager.configure({
            sceneController: root,
            sceneContainer: world,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,
            editMode: root.editMode
        })

        QmlSceneManager.loadScene()
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
    // РАМКА РЕЖИМА (для визуального отличия edit режима)
    // ============================================================
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "green"
        border.width: 2
        radius: 4
        z: 1000
    }
}
