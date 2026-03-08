// qml/content/main_window/dialogs/DialogConfirmDelete.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: dialog
    visible: false
    width: 400
    height: 200
    title: "Подтверждение удаления"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    Material.theme: Material.Dark
    Material.accent: "#F44336"

    property string elementName: ""
    property string elementId: ""
    property var onConfirmed: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "Вы уверены, что хотите удалить элемент?"
            font.pixelSize: 16
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: elementName || "Неизвестный элемент"
            font.pixelSize: 14
            color: "#FFC107"
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "ID: " + elementId
            font.pixelSize: 12
            color: "#888888"
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 10

            Button {
                Layout.fillWidth: true
                text: "Отмена"
                onClicked: dialog.close()
                background: Rectangle {
                    radius: 4
                    color: "#555555"
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                text: "Удалить"
                onClicked: {
                    if (typeof dialog.onConfirmed === 'function') {
                        dialog.onConfirmed(dialog.elementId)
                    }
                    dialog.close()
                }
                background: Rectangle {
                    radius: 4
                    color: "#F44336"
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
