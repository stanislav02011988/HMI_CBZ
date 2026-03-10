// qml\content\logic_window\edit_logic\EditLogicMapWindow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material

import qml.managers

import "component/top_bar"
import "component/left_panel"
import "component/scene"
import "component/status_bar"
import "component/right_panel"

Window {
    id: root

    width: 1600
    height: 900
    visible: true
    title: "Logic Map"
    color: "#81848c"

    property string projectFilePath: ""

    property real leftPanelWidth: 320
    property real rightPanelWidth: 340

    // Component.onCompleted: {
    //     if (projectFilePath !== "") {
    //         QmlLogicProjectManager.loadLogicProjectManager(projectFilePath)
    //     }
    // }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =========================================
        // TOP BAR
        // =========================================

        LogicTopBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }

        // =========================================
        // CENTRAL CONTENT
        // =========================================

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // =====================================
            // LEFT PANEL
            // =====================================

            LogicLeftPanel {
                Layout.preferredWidth: root.leftPanelWidth
                Layout.fillHeight: true
            }

            // =====================================
            // CENTER SCENE
            // =====================================

            LogicScene {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // =====================================
            // RIGHT PANEL
            // =====================================

            LogicRightPanel {
                Layout.preferredWidth: root.rightPanelWidth
                Layout.fillHeight: true
            }
        }

        // =========================================
        // STATUS BAR
        // =========================================

        LogicStatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
        }
    }
}
