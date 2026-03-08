// qml/content/logic_window/edit_logic/component/left_panel/panels/scene_list_element_panel/SceneTreeDelegate.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var modelData: null
    property int depth: 0
    property var sceneModel: null
    property int modelIndex: 0

    width: parent ? parent.width : 300
    height: 30
    visible: true

    Rectangle {
        anchors.fill: parent
        color: "#3a3d42"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: depth * 20
            spacing: 5

            Text {
                text: modelData ? modelData.icon : "?"
                font.pixelSize: 14
            }

            Text {
                text: modelData ? modelData.name : "NULL"
                color: modelData ? modelData.color : "#aaa"
                font.bold: modelData ? modelData.bold : false
                font.pixelSize: 12
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (sceneModel && modelData) {
                    sceneModel.selectElement(modelData)
                }
            }
        }
    }
}
