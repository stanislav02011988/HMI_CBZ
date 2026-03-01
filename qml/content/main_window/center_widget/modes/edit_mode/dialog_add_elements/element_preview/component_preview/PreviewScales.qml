import QtQuick
import QtQuick.Layouts

import qml.content.main_window.center_widget.component.scales

Item{
    id: root
    visible: false

    property alias scales: scales

    Component {
        id: scales
        Scales {
            anchors.fill: parent
        }
    }
}
