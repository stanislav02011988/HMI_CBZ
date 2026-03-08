// qml\content\logic_window\edit_logic\component\left_panel\LogicLeftPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "panels"
import "panels/scene_list_element_panel"

Rectangle {

    color: "#81848c"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        ProjectTreePanel {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
        }

        StandardBlocksPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
        }

        SceneListElementPanel {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
