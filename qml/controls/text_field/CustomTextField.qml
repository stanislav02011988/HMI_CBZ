import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

TextField {
    id: textField

    // Custom Properties
    property color colorDefault: "#282c34"
    property color colorOnFocus: "#242831"
    property color colorMouseOver: "#2B2F38"

    QtObject{
        id: internal

        property var dynamicColor: if(textField.focus){
                                        textField.focus ? colorOnFocus : colorDefault
                                   }else{
                                       textField.hovered ? colorMouseOver : colorDefault
                                   }
    }

    implicitWidth: 300
    implicitHeight: 40

    placeholderText: qsTr("Type something")

    color: "#ffffff"
    background: Rectangle {
        color: internal.dynamicColor
        radius: 4
        border.color: "#999"
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            radius: 8
            samples: 16
            verticalOffset: 2
        }
    }

    selectByMouse: true
    selectedTextColor: "#FFFFFF"
    selectionColor: "#ff007f"
    placeholderTextColor: "#81848c"
}
