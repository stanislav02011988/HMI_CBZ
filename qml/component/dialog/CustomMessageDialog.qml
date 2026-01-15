import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import qml.component.button

Popup {
    id: root
    width: 320
    height: 160
    padding: 0
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.CloseOnEscape
    Overlay.modal: Rectangle {
            color: "transparent"
        }

    background: Rectangle {
        color: "#abcfab"
        radius: 6

        ColumnLayout {
            anchors.fill: parent
            anchors {
                leftMargin: 5
                rightMargin: 5
            }
            spacing: 5

            RowLayout {
                id: header
                height: 30
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Rectangle {
                    id: bgLogo
                    width: 65
                    height: header.height
                    color: "transparent"

                    Image {
                        source: "../../../res/svg/logo.svg"
                        width: bgLogo.width
                        height: 50
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                        anchors.horizontalCenter: bgLogo.horizontalCenter
                        anchors.verticalCenter: bgLogo.verticalCenter
                    }
                }

                Rectangle {
                    height: header.height
                    Layout.fillWidth: true
                    color: "yellow"
                }

                CustomButtonClose {
                    id: btnClose
                    m_width: 30
                    m_height: 30
                    onClicked: root.close()
                }
            }

            Text {
                text: qsTr("The document has been modified.")
                Layout.fillWidth: true
                font.bold: true
            }

            Text {
                text: qsTr("Do you want to save your changes?")
                Layout.fillWidth: true
                color: "#555"
            }

            RowLayout {
                id: layoutButton
                height: 100
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                spacing: 10

                CustomButton {
                    id: btnLogin1
                    text: "ОК"
                    m_width: 50
                    m_height: 30

                    colorDefault: "#67aa25"
                    colorMouseOver: "#7ece2d"
                    colorPressed: "#558b1f"

                    onClicked: root.close()
                }
            }
        }
    }
}
