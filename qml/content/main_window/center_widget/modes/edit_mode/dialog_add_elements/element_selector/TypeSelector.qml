// element_selector/TypeSelector.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 4

    property var model: null
    property int selectedIndex: -1
    signal typeSelected(int index, string typeId)

    Repeater {
        model: root.model
        delegate: ItemDelegate {
            width: parent.width
            height: 70
            highlighted: root.selectedIndex === index
            hoverEnabled: true

            background: Rectangle {
                color: root.selectedIndex === index ? "#2a2a2a" : "#1e1e1e"
                radius: 6
            }

            contentItem: RowLayout {
                spacing: 15
                Layout.fillHeight: true

                Rectangle {
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 45
                    radius: 8
                    color: root.selectedIndex === index ? "#2196F3" : "#444444"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: model.icon
                        font.family: "Font Awesome 5 Free"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "white"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3
                    Text {
                        text: model.name_type
                        color: root.selectedIndex === index ? "white" : "#e0e0e0"
                        font.pixelSize: 15
                        font.bold: root.selectedIndex === index
                    }
                    Text {
                        text: model.description
                        color: "#999999"
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        Layout.maximumWidth: 180
                    }
                }

                Text {
                    text: "→"
                    color: "#888888"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    visible: root.selectedIndex === index
                }
            }

            onClicked: root.typeSelected(index, model.typeId)
        }
    }
}
