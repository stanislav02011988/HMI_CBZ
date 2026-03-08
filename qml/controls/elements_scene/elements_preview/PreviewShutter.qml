import QtQuick
import QtQuick.Layouts

import "../elements/shutter"

Item{
    id: root
    visible: false

    property alias shutter: shutter

    Component {
        id: shutter
        Shutter {}
    }
}
