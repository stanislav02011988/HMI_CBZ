import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "panels"

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

        SceneBlocksPanel {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
