// qml\content\logic_window\edit_logic\component\left_panel\panels\StandardBlocksPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property bool collapsed: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // ===============================
        // 🔷 ЗАГОЛОВОК (всегда виден)
        // ===============================
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 36
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
                    text: "Функциональные блоки"
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
            Layout.fillWidth: true
            Layout.preferredHeight: root.collapsed ? 0 : parent.height - 40
            clip: true
            color: "#2d2f33"
            radius: 6

            // 🔥 Плавная анимация изменения высоты
            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            // Сам контент панели
            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Text { text: "Line 1"; color: "#aaa" }
                Text { text: "Line 2"; color: "#aaa" }
                Button { text: "Click me"; font.pixelSize: 10 }
            }
        }
    }
}
