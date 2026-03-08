import QtQuick
import QtQuick.Layouts

import "../elements/tubing"

Item{
    id: root
    visible: false

    property alias tubingVertical: tubingVertical
    property alias tubingHorizontal: tubingHorizontal

    Component {
        id: tubingVertical
        TubingVertical {  }
    }
    Component {
        id: tubingHorizontal
        TubingHorizontal { }
    }
}
