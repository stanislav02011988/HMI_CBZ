// qml/delegates/ProjectDelegate.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {

    id: root
    width: 250
    height: 300

    property var projectData

    // Сигналы для родителя
    signal editRequested(string projectFile)
    signal deleteRequested(string idUuic)

    Rectangle {
        anchors.fill: parent
        radius: 8
        border.width: 1
        border.color: "#555"
        color: "#3a3d42"

        ColumnLayout {
            anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: header
                color: "transparent"
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        id: rectangle1
                        width: 200
                        height: 200
                        color: "#00ffffff"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        Text {
                            text: projectData.installationName || "Новый проект"
                            font.bold: true
                            font.pixelSize: 16
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            anchors.fill: parent
                        }
                    }

                    Rectangle {
                        id: rectangle2
                        width: 200
                        height: 200
                        color: "#00ffffff"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        CheckBox {
                            id: checkBox
                            text: qsTr("Автозагрузка проекта")
                            anchors.fill: parent
                            font.family: "Times New Roman"
                            font.pointSize: 10
                        }
                    }


                }
            }

            Rectangle {
                id: imageConteiner
                width: 200
                height: 200
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Image {
                    id: image
                    anchors.fill: parent
                    source: projectData.previewInstallation && projectData.previewInstallation !== "" ? projectData.previewInstallation : ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: editRequested(projectData.project_file)
                }
            }

            Rectangle {
                id: dataCreate
                width: 200
                height: 200
                color: "transparent"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: 50
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text { text: "Создан: " + (projectData.created || ""); font.pixelSize: 10; Layout.fillHeight: true; Layout.fillWidth: true; color: "lightgray" }
                    Text { text: "Последнее: " + (projectData.last_saved || ""); font.pixelSize: 10; Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter; Layout.fillHeight: true; Layout.fillWidth: true; color: "lightgray" }
                }
            }

            Rectangle {
                id: rectangle
                width: 200
                height: 200
                color: "transparent"
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                RowLayout {
                    anchors.fill: parent
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Button {
                        text: "Открыть"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        onClicked: editRequested(projectData.project_file)
                    }
                    Button {
                        text: "Удалить"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        onClicked: deleteRequested(projectData.id_uuic)
                    }
                }
            }
        }
    }
}
