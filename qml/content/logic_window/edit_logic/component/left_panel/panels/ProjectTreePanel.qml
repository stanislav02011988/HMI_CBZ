// qml\content\logic_window\edit_logic\component\left_panel\panels\ProjectTreePanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.managers

Item {
    id: root

    // ===============================
    // 🔷 СОСТОЯНИЕ: свёрнуто/развёрнуто
    // ===============================
    property bool collapsed: true  // По умолчанию свёрнуто

    signal collapsedChangedExternal(bool collapsed)
    onCollapsedChanged: { collapsedChangedExternal(collapsed) }

    ListModel {
        id: projectTreeModel
    }

    Component.onCompleted: {
        projectTreeModel.clear()

        var data = QmlProjectManager.dict

        console.log("PROJECT DATA:", data)
        console.log("NAME:", QmlProjectManager.installationName)

        projectTreeModel.append({
            name: QmlProjectManager.installationName,
            type: "project"
        })

        projectTreeModel.append({
            name: "Scene",
            type: "folder"
        })

        projectTreeModel.append({
            name: "Nodes",
            type: "folder"
        })
    }

    // ===============================
    // 🔷 ЗАГОЛОВОК (всегда виден)
    // ===============================
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 36
        color: "#3a3d42"
        radius: 6
        border.color: root.collapsed ? "#555" : "transparent"

        // Клик переключает состояние
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.collapsed = !root.collapsed
            onEntered: header.color = "#4a4d52"
            onExited: header.color = "#3a3d42"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            // Индикатор ▶ / ▼
            Text {
                Layout.preferredWidth: 16
                horizontalAlignment: Text.AlignHCenter
                text: root.collapsed ? "▶" : "▼"
                color: "#888"
                font.pixelSize: 12
            }

            // Название
            Text {
                Layout.fillWidth: true
                text: "Древо проекта"
                color: "white"
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }
    }

    // ===============================
    // 🔷 КОНТЕНТ (скрывается при сворачивании)
    // ===============================
    Rectangle {
        id: content
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // 🔥 КЛЮЧЕВОЙ МОМЕНТ: высота зависит от состояния
        height: root.collapsed ? 0 : 160  // 0 = скрыто, 160 = развёрнуто

        // 🔥 Обрезаем контент, который "вылезает" за границы
        clip: true

        color: "#2d2f33"

        // 🔥 Плавная анимация изменения высоты
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        ListView {
            anchors.fill: parent
            model: projectTreeModel

            delegate: Rectangle {
                width: parent.width
                height: 24
                color: "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    text: model.name
                    color: "#ccc"
                    font.pixelSize: 12
                }
            }
        }
    }
}
