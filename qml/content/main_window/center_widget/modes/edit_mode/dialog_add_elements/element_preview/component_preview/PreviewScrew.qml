import QtQuick
import QtQuick.Layouts

import qml.content.main_window.center_widget.component.screw

Item{
    id: root
    visible: false

    property alias screw: screw

    Component {
        id: screw
        Screw {
            anchors.fill: parent
        }
    }
}
