import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Button {
    id: root

    // Кастомные цвета (можно задавать извне)
    property color colorDefault: "#67aa25"
    property color colorMouseOver: "#7ece2d"
    property color colorPressed: "#558b1f"

    property color colorDefaultText: "white"
    property color colorMouseOverText: "#ff007f"
    property color colorPressedText: "#81848c"

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
        implicitWidth: 25
        implicitHeight: 25
        radius: 6
        color: root.pressed ? root.colorPressed
              : root.hovered ? root.colorMouseOver
              : root.colorDefault

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
        font.family: "Segoe UI"
        font.pointSize: 10
        color: internal.dynamicColorText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
    }

    // Убираем стандартные отступы
    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
}
