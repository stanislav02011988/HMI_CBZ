// element_selector/SubtypeSelector.qml
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
    property string selectedType: ""
    signal subtypeSelected(int index, string subtypeId)

    Label {
        text: {
            if (root.selectedType === "silos") return "Виды силосов"
            if (root.selectedType === "screw") return "Типы шнеков"
            if (root.selectedType === "scales") return "Типы весов"
            if (root.selectedType === "pipes") return "Типы труб"
            if (root.selectedType === "shutter") return "Типы Затворов"
            if (root.selectedType === "valve") return "Типы Клапанов"
            if (root.selectedType === "tubing") return "Типы Трубы"
            return "Виды элементов"
        }
        font.bold: true
        font.pixelSize: 14
        color: "#aaaaaa"
        Layout.topMargin: 5
        Layout.leftMargin: 10
    }

    Repeater {
        model: root.model
        delegate: ItemDelegate {
            width: parent.width
            height: 85
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
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    radius: 6
                    color: "#3a3a3a"
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    Text {
                        text: model.name_sub_type
                        color: root.selectedIndex === index ? "#2196F3" : "#e0e0e0"
                        font.pixelSize: 14
                        font.bold: root.selectedIndex === index
                    }
                    Text {
                        text: model.description
                        color: "#999999"
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        Layout.maximumWidth: 160
                        elide: Text.ElideRight
                    }
                }
            }

            onClicked: root.subtypeSelected(index, model.subtypeId)
        }
    }
}
