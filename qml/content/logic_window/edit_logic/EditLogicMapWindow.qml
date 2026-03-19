// qml\content\logic_window\edit_logic\EditLogicMapWindow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

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
    visible: false
    title: "Logic Editor"

    // color: "transparent"

    // =====================================================
    // РЕЖИМ FALSE - RUN MODE TRUE - EDIT MODE
    // =====================================================
    property bool editMode: false

    property string projectFilePath: ""

    property real leftPanelWidth: 300
    property real rightPanelWidth: 300

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#81848c"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // LogicTopBar {
            //     Layout.fillWidth: true
            //     Layout.preferredHeight: 50
            //     Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            // }

            SplitView {
                id: mainSplit
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 5
                orientation: Qt.Horizontal

                handle: Rectangle {
                    implicitWidth: 6
                    color: "#444"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SplitHCursor
                    }
                }

                // =====================================================
                // LEFT PANEL
                // =====================================================
                LogicLeftPanel {
                    id: logicLeftPanel
                    SplitView.minimumWidth: 200
                    SplitView.maximumWidth: 500
                    SplitView.preferredWidth: root.leftPanelWidth
                }

                // =====================================================
                // CENTER SCENE
                // =====================================================
                LogicScene {
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 400

                    stateWindow: root.visible
                    editMode: root.editMode
                }

                // =====================================================
                // RIGHT PANEL
                // =====================================================
                LogicRightPanel {
                    SplitView.minimumWidth: 250
                    SplitView.maximumWidth: 400
                    SplitView.preferredWidth: root.rightPanelWidth
                }
            }

            LogicStatusBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
            }
        }
    }
}
