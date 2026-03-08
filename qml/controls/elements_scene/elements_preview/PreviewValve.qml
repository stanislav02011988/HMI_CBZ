import QtQuick
import QtQuick.Layouts

import "../elements/valve"

Item{
    id: root
    visible: false

    property alias valve_air: valve_air

    Component {
        id: valve_air
        ValveAir { }
    }
}
