// logic/LogicMapWindow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material

Window {
    id: root
    width: 1600
    height: 900
    visible: true
    title: "Logic Map - Edit Mode"
    color: "#81848c"

    property real leftPanelWidth: 320
    property real rightPanelWidth: 340

    // =========================================================
    // ОСНОВНАЯ РАЗМЕТКА
    // =========================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================
        // TOP BAR
        // =====================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#81848c"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                Label {
                    text: "Logic Map Editor"
                    font.pixelSize: 18
                    color: "white"
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "Run Mode"
                }

                Button {
                    text: "Close"
                    onClicked: root.close()
                }
            }
        }

        // =====================================================
        // CENTRAL CONTENT (3 КОЛОНКИ)
        // =====================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // =================================================
            // LEFT PANEL
            // =================================================
            Rectangle {
                Layout.preferredWidth: root.leftPanelWidth
                Layout.fillHeight: true
                color: "#81848c"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6
                    anchors.margins: 6

                    // ---------- Project Tree ----------
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 3
                        radius: 6
                        color: "#2d2f33"

                        Label {
                            text: "Project Tree"
                            anchors.centerIn: parent
                            color: "#aaa"
                        }
                    }

                    // ---------- Standard Blocks ----------
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 3
                        radius: 6
                        color: "#2d2f33"

                        Label {
                            text: "Standard Blocks Library"
                            anchors.centerIn: parent
                            color: "#aaa"
                        }
                    }

                    // ---------- Custom Blocks ----------
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: "#2d2f33"

                        Label {
                            text: "Custom Scene Blocks"
                            anchors.centerIn: parent
                            color: "#aaa"
                        }
                    }
                }
            }

            // =================================================
            // CENTER LOGIC SCENE (ЗАГЛУШКА)
            // =================================================
            Rectangle {
                id: logicSceneContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1e1f22"

                Label {
                    text: "Logic Scene (Infinite Canvas Here)"
                    anchors.centerIn: parent
                    color: "#555"
                }

                // Кнопки Save / Export
                Column {
                    spacing: 8
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 10

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 4
                        color: "#3a3d41"

                        Label {
                            text: "S"
                            anchors.centerIn: parent
                            color: "white"
                        }
                    }

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 4
                        color: "#3a3d41"

                        Label {
                            text: "J"
                            anchors.centerIn: parent
                            color: "white"
                        }
                    }
                }
            }

            // =================================================
            // RIGHT PROPERTY PANEL
            // =================================================
            Rectangle {
                Layout.preferredWidth: root.rightPanelWidth
                Layout.fillHeight: true
                color: "#81848c"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    Label {
                        text: "Properties"
                        font.pixelSize: 16
                        color: "white"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: "#2d2f33"

                        Label {
                            text: "Selected Block Properties"
                            anchors.centerIn: parent
                            color: "#888"
                        }
                    }
                }
            }
        }

        // =====================================================
        // STATUS BAR
        // =====================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: "#2b2d30"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8

                Label {
                    text: "Zoom: 100%"
                    color: "#aaa"
                }

                Label {
                    text: "Blocks: 0"
                    color: "#aaa"
                }

                Label {
                    text: "Connections: 0"
                    color: "#aaa"
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: "Saved"
                    color: "#4caf50"
                }
            }
        }
    }
}
