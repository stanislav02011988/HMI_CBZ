import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Button {
    id: root

    // Включаем режим переключателя
    checkable: true

    property int m_width: 30
    property int m_height: 30
    property int m_radius: 6  // исправлено опечатка: было "m_raduis"

    property color m_background_color: "#e0e0e0"
    property color m_color_checked: "#ff4d4d"      // цвет при checked
    property color m_color_hovered: "#ff9999"      // цвет при наведении (не checked)
    property color m_borderColor: "#999"

    property color m_colorText: "yellow"
    property color m_colorTextChecked: "white"
    property color m_colorTextHovered: "white"

    implicitWidth: m_width
    implicitHeight: m_height

    padding: 0
    text: "✕"
    Layout.alignment: Qt.AlignCenter

    contentItem: Text {
        text: root.text
        font.family: "Times New Roman"
        font.pixelSize: 12
        font.bold: true
        color: {
            if (root.checked) {
                return root.m_colorTextChecked;
            } else if (root.hovered) {
                return root.m_colorTextHovered;
            } else {
                return root.m_colorText;
            }
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
    }

    background: Rectangle {
        anchors.fill: parent
        radius: root.m_radius
        color: {
            if (root.checked) {
                return root.m_color_checked;
            } else if (root.hovered) {
                return root.m_color_hovered;
            } else {
                return root.m_background_color;
            }
        }
        border.color: root.m_borderColor

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }
    }
}
