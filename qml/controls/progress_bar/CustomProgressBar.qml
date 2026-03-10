import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Item {
    id: root
    property real value: 0.0     // 0..1

    property bool vertical: false     // ориентация

    property bool visible_border_progress: false
    property bool animation_border: false

    property string textPosition: "right"   // варианты: "inside" | "right" | "left" | "bottom" | "top"

    property color glowColor: "#66cfff"// цвет свечения

    property int blockCount: 5    // количество квадратиков в прогрессе
    property int blockSpacing: 4

    property int borderRadius: 4
    property int borderWidth: 2
    property real padding: 6

    property int sizeText: 16

    implicitWidth: vertical ? 40 : 300
    implicitHeight: vertical ? 300 : 40

    readonly property int filledBlocks: Math.round(value * blockCount)
    readonly property color currentColor: getColor(value)    

    Behavior on value {
        NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
    }

    // Цвет в зависимости от процента
    function getColor(percent) {
        if (percent <= 0.25) {
            let t = percent / 0.25;
            return Qt.rgba(0.8 - 0.3 * t, 0.8 - 0.3 * t, 0.8 - 0.3 * t, 1);
        } else if (percent <= 0.50) {
            let t = (percent - 0.25) / 0.25;
            return Qt.rgba(1.0, 1.0 - 0.3 * t, 0.5 - 0.2 * t, 1);
        } else if (percent <= 0.75) {
            let t = (percent - 0.50) / 0.25;
            return Qt.rgba(0.6 - 0.4 * t, 0.9 - 0.5 * t, 0.6 - 0.4 * t, 1);
        }
        let t = (percent - 0.85) / 0.25;
        return Qt.rgba(1.0, 0.6 - 0.4 * t, 0.6 - 0.4 * t, 1);
    }

    // Контур с цветом, зависящим от значения
    Rectangle {
        id: borderRect
        anchors.fill: parent
        color: "transparent"
        radius: root.borderRadius
        visible: root.visible_border_progress
        border.width: root.borderWidth
        border.color: animation_border ? root.currentColor : "#777777"
        // border.color: root.currentColor

        Behavior on border.color {
            ColorAnimation { duration: 400 }
        }

        // ADDED: кликом левой кнопкой открываем диалог настроек
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) settingsDialog.open()
            }
        }
        // END ADDED
    }

    // Заполнение блоками
    Repeater {
        model: 10
        Item {
            width: root.vertical
                   ? parent.width - root.padding * 2
                   : ((parent.width - root.padding * 2) - (root.blockCount - 1) * root.blockSpacing) / root.blockCount
            height: root.vertical
                    ? ((parent.height - root.padding * 2) - (root.blockCount - 1) * root.blockSpacing) / root.blockCount
                    : parent.height - root.padding * 2

            x: root.vertical
                ? root.padding
                : root.padding + index * (width + root.blockSpacing)
            y: root.vertical
                ? parent.height - root.padding - height - index * (height + root.blockSpacing)
                : root.padding

            Rectangle {
                id: block
                anchors.fill: parent
                radius: 2
                border.color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: index < root.filledBlocks ? root.currentColor : "transparent" }
                    GradientStop { position: 1.0; color: index < root.filledBlocks ? Qt.darker(root.currentColor, 1.3) : "transparent" }
                }
                Behavior on gradient {
                    ColorAnimation { duration: 400 }
                }
            }

            DropShadow {
                anchors.fill: block
                horizontalOffset: 0
                verticalOffset: 0
                radius: 6
                samples: 16
                color: root.glowColor
                source: block
                Behavior on opacity {
                    NumberAnimation { duration: 400 }
                }
                opacity: index < root.filledBlocks ? 0.5 : 0
            }
        }
    }

    // Проценты
    Text {
        id: percentText
        visible: root.textPosition !== "none"   // "none" — скрыть текст
        text: Math.round(root.value * 100) + "%"
        font.bold: true
        font.pixelSize: root.sizeText
        // color: root.currentColor
        color: "black"

        // сброс якорей и расстановка по выбранной позиции
        function reposition() {
            anchors.centerIn = undefined
            anchors.left = undefined
            anchors.right = undefined
            anchors.top = undefined
            anchors.bottom = undefined
            anchors.verticalCenter = undefined
            anchors.horizontalCenter = undefined
            anchors.leftMargin = 0
            anchors.rightMargin = 0
            anchors.topMargin = 0
            anchors.bottomMargin = 0

            switch (root.textPosition) {
            case "inside":
                anchors.centerIn = borderRect
                break
            case "right":
                // справа и чуть ниже верхней границы
                anchors.left = borderRect.right
                anchors.top = borderRect.top
                anchors.leftMargin = 8
                anchors.topMargin = 0
                break
            case "left":
                anchors.right = borderRect.left
                anchors.top = borderRect.top
                anchors.rightMargin = 8
                anchors.topMargin = 8
                break
            case "bottom":
                anchors.horizontalCenter = borderRect.horizontalCenter
                anchors.top = borderRect.bottom
                anchors.topMargin = 8
                break
            case "top":
                anchors.horizontalCenter = borderRect.horizontalCenter
                anchors.bottom = borderRect.top
                anchors.bottomMargin = 8
                break
            case "none":
                // видимость уже выключена выше
                break
            }
        }

        Component.onCompleted: reposition()

        // правильная подписка на изменение свойств root
        Connections {
            target: root
            function onTextPositionChanged() { percentText.reposition() }
            function onVerticalChanged()      { percentText.reposition() } // если меняешь ориентацию
        }
    }

    Dialog {
        id: settingsDialog
        modal: true
        focus: true
        x: (root.width - width)/2
        y: (root.height - height)/2
        width: 340

        header: Rectangle {
            id: headerDialog
            height: 40
            color: "#333"
            radius: 4
            anchors.left: parent.left
            anchors.right: parent.right

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 30
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor

                    property real dragStartX: 0
                    property real dragStartY: 0

                    onPressed: {
                        dragStartX = mouse.x
                        dragStartY = mouse.y
                    }
                    onPositionChanged: {
                        settingsDialog.x += mouse.x - dragStartX
                        settingsDialog.y += mouse.y - dragStartY
                    }
                }
            }

            Text {
                text: "Настройки прогресс-бара"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                color: "white"
                font.bold: true
            }

            Button {
                id: closeBtn
                implicitWidth: 30
                implicitHeight: 30
                padding: 0
                text: "✕"
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                anchors {
                    margins: 10
                    right: headerDialog.right
                }

                contentItem: Text {
                    text: closeBtn.text
                    font.pixelSize: 0
                    font.bold: true
                    color: closeBtn.hovered ? "white" : "black" // меняем цвет при наведении
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
                onClicked: settingsDialog.close()
            }
        }

        contentItem: Column {
            spacing: 12
            padding: 12

            // blockCount
            Column {
                spacing: 4
                Text { text: "Количество блоков: " + root.blockCount }
                Slider {
                    from: 5; to: 60; stepSize: 1
                    value: root.blockCount
                    onValueChanged: root.blockCount = Math.round(value)
                }
            }

            // orientation
            CheckBox {
                text: "Вертикальная ориентация"
                checked: root.vertical
                onToggled: root.vertical = checked
            }

            // glow color
            Row {
                spacing: 8
                Text { text: "Свечение:" }
                TextField {
                    id: glowHex
                    placeholderText: "#66cfff"
                    text: String(root.glowColor)
                    selectByMouse: true
                    onAccepted: root.glowColor = text
                    width: 140
                }
                Button {
                    text: "Применить"
                    onClicked: root.glowColor = glowHex.text
                }
                Button {
                    text: "Случайный"
                    onClicked: root.glowColor = Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
                }
            }
        }

        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Close
            onRejected: settingsDialog.close()
        }
    }


}
