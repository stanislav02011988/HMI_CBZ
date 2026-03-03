import QtQuick
import QtQuick.Layouts

import "../scales"

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
