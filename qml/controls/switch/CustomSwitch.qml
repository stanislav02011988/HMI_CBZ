// CustomSwitch.qml
import QtQuick

Item {
    id: root

    // Внешние интерфейсы — только свойства и сигналы
    property bool checked: false
    property alias trackColorOn: track.colorOn
    property alias trackColorOff: track.colorOff
    property alias thumbColor: thumb.color

    signal toggled(bool checked)

    width: 40
    height: 20

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        border.color: "#999999"
        border.width: 1

        // Цвета задаются извне (по умолчанию — ваши)
        property color colorOn: "#21be2b"
        property color colorOff: "#cccccc"

        color: root.checked ? colorOn : colorOff

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }

    Rectangle {
        id: thumb
        width: root.height
        height: root.height
        radius: width / 2
        color: "#ffffff"
        border.color: "#888888"
        border.width: 1

        x: root.checked ? (track.width - width) : 0
        y: 0

        Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)  // передаём новое состояние наружу
        }
    }
}
