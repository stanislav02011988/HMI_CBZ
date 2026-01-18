import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

AbstractButton {
    id: root
    width: 20
    height: 20

    implicitWidth: 40
    implicitHeight: 20

    property int borderRadus: 10

    background: Rectangle {
        radius: borderRadus
        color: root.hovered ? "#666666" : "#e0e0e0" // при наведении — тёмный фон
        border.color: "#999"
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }
    }
}
