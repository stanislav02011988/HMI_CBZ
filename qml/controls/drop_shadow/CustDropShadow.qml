import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    property real baseUnitW
    property real baseUnitH
    property var target: null

    DropShadow {
        anchors.fill: parent
        source: root.target
        radius: Math.max(4, root.baseUnitW * 3)
        samples: 16
        color: "#60000000"
        horizontalOffset: Math.max(1, root.baseUnitW * 1.5)
        verticalOffset: Math.max(1, root.baseUnitH * 1.5)
    }
}
