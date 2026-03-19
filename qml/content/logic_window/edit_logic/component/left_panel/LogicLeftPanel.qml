// qml/content/logic_window/edit_logic/component/left_panel/LogicLeftPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "panels"
import "panels/panel_scene_list_element"
import "panels/panel_project_tree"

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        SplitView {
            id: splitView

            anchors.fill: parent
            anchors.margins: 6

            orientation: Qt.Vertical

            // =====================================================
            // PROJECT TREE PANEL
            // =====================================================
            Rectangle {
                id: projectWrapper

                radius: 6
                color: "transparent"
                border.color: "#666"
                border.width: 1

                SplitView.minimumHeight: 45
                SplitView.preferredHeight: projectPanel.collapsed ? 45 : 400

                ProjectTreePanel {
                    id: projectPanel
                    anchors.fill: parent
                    anchors.margins: 4
                }
            }

            // =====================================================
            // BLOCKS PANEL
            // =====================================================
            Rectangle {
                id: blocksWrapper

                radius: 6
                color: "transparent"
                border.color: "#666"
                border.width: 1

                SplitView.minimumHeight: 45
                SplitView.preferredHeight: blocksPanel.collapsed ? 45 : 400

                StandardBlocksPanel {
                    id: blocksPanel
                    anchors.fill: parent
                    anchors.margins: 4
                }
            }

            // =====================================================
            // SCENE PANEL
            // =====================================================
            Rectangle {
                id: sceneWrapper

                radius: 6
                color: "transparent"
                border.color: "red"
                border.width: 1

                SplitView.minimumHeight: 45
                SplitView.preferredHeight: scenePanel.collapsed ? 45 : 400

                SceneListElementPanel {
                    id: scenePanel
                    anchors.fill: parent
                    anchors.margins: 4
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
