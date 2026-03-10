// qml\content\logic_window\edit_logic\component\scene\LogicScene.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "panel_btn"
import "grid_layer"

Item {
    id: root

    // ==============================
    // Параметры камеры
    // ==============================
    property real zoom: 1.0
    property real minZoom: 0.2
    property real maxZoom: 5.0

    property real offsetX: 0
    property real offsetY: 0

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        color: "#666"
        radius: 6

        // --------------------------------------------------------
        // СЕТКА
        // --------------------------------------------------------
        GridLayer { id: gridLayer }

        // ==============================
        // VIEWPORT
        // ==============================
        Item {
            id: viewport
            anchors.fill: parent
            clip: true

            // ==========================
            // WORLD
            // ==========================
            Item {
                id: world
                x: root.offsetX
                y: root.offsetY
                width: viewport.width
                height: viewport.height
                scale: root.zoom
                transformOrigin: Item.TopLeft

                // === ДВА ТЕСТОВЫХ КВАДРАТА ===

                Rectangle {
                    width: 100
                    height: 100
                    color: "red"
                    x: 100
                    y: 30
                }

                Rectangle {
                    width: 100
                    height: 100
                    color: "blue"
                    x: 150
                    y: 150
                }
            }
        }

        // ==========================
        // УПРАВЛЕНИЕ МЫШЬЮ
        // ==========================
        MouseArea {
            id: mouseArea
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

    // ==========================
    // Панель Кнопок
    // ==========================
    PanelBauttons {
        id: panelBtn
        width: 60
        height: 100
        anchors.top: bg.top
        anchors.right: bg.right
        anchors.topMargin: 10
        anchors.rightMargin: 10

        onSignalActivateGridLayer: (check) => gridLayer.toggleGrid(check)
    }
}
