import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Button {
    id: closeBtn

    property int m_width: 30
    property int m_height: 30
    property int m_raduis: 6

    property color m_background_color: "#e0e0e0"
    property color m_color_hovered: "#ff4d4d"
    property color m_borderColor: "#999"

    property color m_colorText: "yellow"
    property color m_colorTextHovered: "white"

    implicitWidth: closeBtn.m_width
    implicitHeight: closeBtn.m_height

    padding: 0
    text: "✕"
    font.pixelSize: 16
    font.bold: true
    // Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

    contentItem: Text {
        text: closeBtn.text
        font.family: "Times New Roman"
        font.pixelSize: 12
        font.bold: true
        color: closeBtn.hovered ? closeBtn.m_colorTextHovered : closeBtn.m_colorText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
    }

    background: Rectangle {
        anchors.fill: parent
        radius: closeBtn.m_raduis
        color: closeBtn.hovered ? closeBtn.m_color_hovered : closeBtn.m_background_color
        border.color: closeBtn.m_borderColor
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }
    }
}
