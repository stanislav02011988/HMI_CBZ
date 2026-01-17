// FlipDigit.qml
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // === Внешние настраиваемые свойства ===
    property int digit: 0
    property string fontFamily: "Times New Roman"
    property color backgroundColor: "#e0e0e0"
    property color borderColor: "#999"
    property color fontColor: "#222"
    property color flipBackgroundColor: "#777"
    property color flipFontColor: "#555"
    property real borderWidth: height * 0.02
    property int flipDuration: 250
    property bool useRaisedText: true

    // Внутренние состояния
    property string currentText: digit.toString()
    property string nextText: digit.toString()

    readonly property real fontSize: height * 0.9

    // === 1. Фон — цельная цифра ===
    Rectangle {
        id: bgDigit
        anchors.fill: parent
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: root.borderWidth
        radius: 4

        Text {
            anchors.centerIn: parent
            text: currentText
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            color: root.fontColor
            style: root.useRaisedText ? Text.Raised : Text.Normal
            styleColor: "#000"
        }
    }

    // === 2. Анимационные половинки ===
    Item {
        id: animationLayer
        anchors.fill: parent
        visible: false

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Верхняя половинка
            Rectangle {
                id: topFlap
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.flipBackgroundColor
                border.color: "#555"
                border.width: root.borderWidth
                radius: 4
                clip: true

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    y: -parent.height
                    text: currentText
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    color: root.flipFontColor
                    style: root.useRaisedText ? Text.Raised : Text.Normal
                    styleColor: "#000"
                }

                transform: Rotation {
                    id: topRotation
                    origin.x: width / 2
                    origin.y: height
                    axis { x: 1; y: 0; z: 0 }
                    angle: 0
                }
            }

            // Нижняя половинка
            Rectangle {
                id: bottomFlap
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.flipBackgroundColor
                border.color: "#555"
                border.width: root.borderWidth
                radius: 4
                clip: true

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    y: parent.height
                    text: nextText
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    color: root.flipFontColor
                    style: root.useRaisedText ? Text.Raised : Text.Normal
                    styleColor: "#000"
                }

                transform: Rotation {
                    id: bottomRotation
                    origin.x: width / 2
                    origin.y: 0
                    axis { x: 1; y: 0; z: 0 }
                    angle: -180
                }
            }
        }
    }

    function setDigit(newDigit) {
        if (newDigit === digit) return;
        nextText = newDigit.toString();
        animationLayer.visible = true;
        flipAnimation.start();
        digit = newDigit;
    }

    SequentialAnimation {
        id: flipAnimation
        running: false

        ParallelAnimation {
            NumberAnimation {
                target: topRotation
                property: "angle"
                to: 180
                duration: root.flipDuration
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: topFlap
                property: "opacity"
                to: 0
                duration: root.flipDuration
            }
        }

        ScriptAction {
            script: {
                currentText = nextText;
                topRotation.angle = 0;
                topFlap.opacity = 1;
                bottomRotation.angle = -180;
                animationLayer.visible = false;
            }
        }
    }

    Component.onCompleted: {
        animationLayer.visible = false;
    }
}
