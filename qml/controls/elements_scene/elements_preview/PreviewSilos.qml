import QtQuick
import QtQuick.Layouts

import "../silos"

Item{
    id: root
    visible: false

    property alias silos_vertical: silos_vertical

    Component {
        id: silos_vertical
        SilosVertical {
            anchors.fill: parent
        }
    }
}
