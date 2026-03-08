import QtQuick
import QtQuick.Layouts

import "../elements/screw"

Item{
    id: root
    visible: false

    property alias screw: screw

    Component {
        id: screw
        Screw {}
    }
}
