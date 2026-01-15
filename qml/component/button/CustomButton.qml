import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Button {
    id: root

    property int m_width: 25
    property int m_height: 25

    // Кастомные цвета (можно задавать извне)
    property color colorDisabled: "#cccccc"
    property color colorDisabledText: "#888888"

    property color colorDefault: "#67aa25"
    property color colorMouseOver: "#7ece2d"
    property color colorPressed: "#558b1f"

    property color colorDefaultText: "white"
    property color colorMouseOverText: "#ff007f"
    property color colorPressedText: "#81848c"

    property int m_text_size: 10

    property color border_color: "#999"
    property int border_width: 1


    QtObject{
        id: internal

        property var dynamicColor: if(root.down){
                                       root.down ? colorPressed : colorDefault
                                   }else{
                                       root.hovered ? colorMouseOver : colorDefault
                                   }

        property var dynamicColorText: if(root.down){
                                       root.down ? colorPressedText : colorDefaultText
                                   }else{
                                       root.hovered ? colorMouseOverText : colorDefaultText
                                   }
    }

    // Автоматический выбор цвета
    background: Rectangle {
        implicitWidth: root.m_width
        implicitHeight: root.m_height
        radius: 6
        color: {
            if (!root.enabled) return "#cccccc"; // серый — заблокировано
            return root.pressed ? root.colorPressed
                 : root.hovered ? root.colorMouseOver
                 : root.colorDefault;
        }

        border.color: root.border_color
        border.width: root.border_width

        // Тень (опционально)
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }
    }

    // Стиль текста
    contentItem: Text {
        text: root.text
        font.family: "Times New Roman"
        font.pointSize: root.m_text_size
        color: {
            if (!root.enabled) return "#888888"; // тусклый текст
            return root.pressed ? root.colorPressedText
                 : root.hovered ? root.colorMouseOverText
                 : root.colorDefaultText;
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
    }
    padding: 0
}
