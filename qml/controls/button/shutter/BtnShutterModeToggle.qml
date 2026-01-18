import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

AbstractButton {

    signal signalComandPlcOpenCloseShutter(string status_shutter, bool mode_dosage)

    id: root
    implicitWidth: 140
    implicitHeight: 48
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    
    // ---- Адресс Команды Открыть ----
    property string addressComandOpenFull: "null"

    // --- режим работы ---
    // false = momentary, true = toggle
    property bool modeToggleOrMomentary: false
    checkable: modeToggleOrMomentary

    // --- подрежим дозировки ---
    // false = Грубая дозировка, true = Тонкая дозировка
    property bool modeDosage: false

    // --- состояния открытия затвора---
    // 0=закрыто, 1=открыто, 2=ожидание PLC, 3=ошибка
    property int mode: 0

    // блокировка при ошибке
    property bool lockOnError: true
    enabled: !(mode === 4 && lockOnError)

    // --- интервал ожидания ответа от ПЛК ---
    property real inteval_reqest_plc: 1000

    // размеры открытия
    property real separationFull: 10
    property real separationFine: 6
    property real separationWait: 3
    property real separationError: 2

    // --- текущий сдвиг ---
    property real separation: {
        if (mode === 1) return modeDosage ? separationFine : separationFull
        if (mode === 3) return separationWait
        if (mode === 4) return separationError
        return 0
    }

    // --- текущий цвет ---
    property color currentColor: {
        if (mode === 1) return modeDosage ? "blue" : "green"
        if (mode === 3) return "yellow"
        if (mode === 4) return "red"
        return "#a8a8a8"
    }

    // --- анимации ---
    Behavior on separation { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    Behavior on currentColor { ColorAnimation { duration: 120 } }

    // --- momentary ---
    onPressed: {
        if (!modeToggleOrMomentary) {
            checkable = true
            mode = 3
            plcWaitTimer.restart()
            signalComandPlcOpenCloseShutter("open", root.modeDosage)
        }
    }
    onReleased: {
        if (!modeToggleOrMomentary) {
            mode = 3
            checkable = false
            plcWaitTimer.stop()
            plcWaitTimerClose.restart()
            signalComandPlcOpenCloseShutter("close", root.modeDosage)
        }
    }

    // --- toggle ---
    onToggled: {
        if (modeToggleOrMomentary) {
            if (checked) {
                mode = 3 // ждём подтверждения PLC
                plcWaitTimer.restart()
                signalComandPlcOpenCloseShutter("open", root.modeDosage)
            } else {
                mode = 3
                plcWaitTimer.stop()
                plcWaitTimerClose.start()
                signalComandPlcOpenCloseShutter("close", root.modeDosage)
            }
        }
    }

    // --- функции управления ---
    function getStatusPlcOpenOrClose(status_btn) {
        if (status_btn === "open"){
            mode = 1
            plcWaitTimer.stop()
            // btnShutterModeToggleOrMomentary.reqestPlcOk()
        } else if (status_btn === "close"){
            mode = 0
            plcWaitTimerClose.restart()
            // btnShutterModeToggleOrMomentary.reqestPlcOk()
        }
    }

    function getStatusPlcError() {
        plcWaitTimer.stop()
        plcWaitTimerClose.stop()
        mode = 4
        // btnShutterModeToggleOrMomentary.reqestPlcError()
    }

    function resetError() {
        if (mode === 4) {
            mode = 0
            checked = false
        }
    }

    function open() {
        if (!mode === 4) {
            if (!modeToggleOrMomentary) {
                mode = 3
            } else {
                if (!checked) {
                    checked = true
                    mode = 3
                    plcWaitTimer.restart()
                }
            }
        }
    }

    function close() {
        if (!mode === 4) {
            if (!modeToggleOrMomentary) {
                mode = 3
                plcWaitTimerClose.start()
            } else {
                if (checked) {
                    mode = 3
                    checked = false
                    plcWaitTimerClose.start()
                }
            }
        }
    }

    // --- таймер ожидания ответа от PLC ---
    Timer {
        id: plcWaitTimer
        interval: root.inteval_reqest_plc
        repeat: false
        onTriggered: {
            if (mode === 3) {
                mode = 4
                // btnShutterModeToggleOrMomentary.reqestPlcError()
            }
        }
    }

    // // --- таймер ожидания ответа от PLC ---
    Timer {
        id: plcWaitTimerClose
        interval: root.inteval_reqest_plc
        repeat: false
        onTriggered: {
            if (mode === 3) {
                mode = 4
                // btnShutterModeToggleOrMomentary.reqestPlcError()
            }
        }
    }

    // --- фон (треугольники) --- Content
    background: Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#60000000"
            radius: 4
            horizontalOffset: 2
            verticalOffset: 2
        }

        Canvas {
            id: canvas
            anchors.fill: parent

            function gradient(ctx, color, x1, y1, x2, y2) {
                const g = ctx.createLinearGradient(x1, y1, x2, y2)
                g.addColorStop(0, color)
                g.addColorStop(1, Qt.darker(color, 1.3))
                return g
            }

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                const cx = width/2
                const topY = 0
                const bottomY = height

                // левый
                ctx.beginPath()
                ctx.moveTo(cx - root.separation, topY)
                ctx.lineTo(cx - root.separation, bottomY)
                ctx.lineTo(0, topY)
                ctx.closePath()
                ctx.fillStyle = gradient(ctx, root.currentColor, 0, 0, width/2, height)
                ctx.fill()

                // правый
                ctx.beginPath()
                ctx.moveTo(cx + root.separation, topY)
                ctx.lineTo(cx + root.separation, bottomY)
                ctx.lineTo(width, topY)
                ctx.closePath()
                ctx.fillStyle = gradient(ctx, root.currentColor, width, 0, width/2, height)
                ctx.fill()
            }

            Connections {
                target: root

                function onSeparationChanged() { canvas.requestPaint() }
                function onCurrentColorChanged() { canvas.requestPaint() }
                function onModeChanged() { canvas.requestPaint() }
                function onCheckedChanged() { canvas.requestPaint() }
            }

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()
        }
    }
}
