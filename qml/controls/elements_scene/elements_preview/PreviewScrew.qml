import QtQuick
import QtQuick.Layouts

import "../screw"

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
