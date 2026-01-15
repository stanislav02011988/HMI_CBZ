import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Button {
    id: closeBtn

    property int m_width: 30
    property int m_height: 30

    implicitWidth: closeBtn.m_width
    implicitHeight: closeBtn.m_height
    padding: 0
    text: "✕"
    font.pixelSize: 16
    font.bold: true
    // Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

    contentItem: Text {
        text: closeBtn.text
        font.pixelSize: closeBtn.font.pixelSize
        font.bold: true
        color: closeBtn.hovered ? "white" : "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
    }

    background: Rectangle {
        anchors.fill: parent
        radius: 6
        color: closeBtn.hovered ? "#ff4d4d" : "#e0e0e0"
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
