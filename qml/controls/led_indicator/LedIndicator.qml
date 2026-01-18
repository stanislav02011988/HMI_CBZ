import QtQuick

Rectangle {
    id: led_indicator
    width: 12
    height: 12
    border.width: 1
    border.color: enabled ? "#006400" : "#555"
    smooth: true

    property bool actualEnabled: false

    property color onColor: "#00ff00"
    property color glowEdge: "#004400"

    property string mode: "off"     // "off", "on", "blink"
    property int blinkInterval: 500

    Timer {
            id: blinkTimer
            interval: blinkInterval
            running: (mode === "blink")
            repeat: true
            onTriggered: actualEnabled = !actualEnabled
        }

    // Управление actualEnabled
        Component.onCompleted: {
            if (mode === "on") {
                actualEnabled = true
            } else if (mode === "off") {
                actualEnabled = false
            }
        }

    onModeChanged: {
        if (mode === "on") {
            blinkTimer.stop()
            actualEnabled = true
        } else if (mode === "off") {
            blinkTimer.stop()
            actualEnabled = false
        } else if (mode === "blink") {
            actualEnabled = true
            blinkTimer.start()
        }
    }

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: actualEnabled ? onColor : "#00000000"
        }
        GradientStop {
            position: 1.0
            color: actualEnabled ? glowEdge : "#00000000"
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        opacity: 0.3
        Rectangle {
            width: parent.width
            height: parent.height / 2
            radius: width / 2
            color: "white"
            opacity: 0.15
            anchors.top: parent.top
        }
    }
}
