// qml/content/logic_window/edit_logic/component/left_panel/panels/scene_list_element_panel/SceneElementDelegate.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var elementData
    property int elementIndex
    property var modelController

    height: 26
    color: "#3a3d42"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: elementData.level * 16
        spacing: 6

        // Раскрытие группы
        Item {
            width: 20
            height: parent.height
            visible: elementData.hasChildren

            Text {
                anchors.centerIn: parent
                text: elementData.expanded ? "▼" : "▶"
                color: "#aaa"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (modelController)
                        modelController.toggleExpand(elementIndex)
                }
            }
        }

        Text { text: elementData.icon }

        // Название
        Item {
            Layout.fillWidth: true
            height: parent.height

            Text {
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.RichText
                text: highlight(elementData.name, modelController ? modelController.searchText : "")
                color: elementData.color
                font.bold: elementData.bold
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.color = "#4a4d52"
                onExited: root.color = "#3a3d42"
                onClicked: {
                    if (modelController)
                        modelController.selectElement(elementData)
                }
            }
        }
    }

    function highlight(text, search) {
        if (!search || search === "")
            return text
        var regex = new RegExp("(" + search + ")", "ig")
        return text.replace(regex,"<font color='#00ff88'>$1</font>")
    }
}
