import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

AbstractButton {
    id: root
    implicitWidth: 140
    implicitHeight: 48
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    // --- режим работы ---
    property bool toggleMode: false   // false = momentaly, true = toggle
    checkable: toggleMode

    // --- подрежим дозировки ---
    property bool fineDose: false      // false = full, true = fine

    // --- интервал ожидания ответа от ПЛК ---
    property real inteval_reqest_plc: 3000

    // --- состояния ---
    // 0=закрыто, 1=открыто, 3=ожидание PLC, 4=ошибка
    property int mode: 0

    // размеры открытия
    property real separationFull: 10
    property real separationFine: 6
    property real separationWait: 3
    property real separationError: 2

    // блокировка при ошибке
    property bool lockOnError: true
    enabled: !(mode === 4 && lockOnError)

    // --- сигналы --- полное дозирование
    signal momentalyOpenShutterFullDose()
    signal momentalyCloseShutterFullDose()

    // --- сигналы --- тонкое дозирования
    signal momentalyOpenShutterFineDose()
    signal momentalyCloseShutterFineDose()

    // --- сигналы ---полное дозирование
    signal togglyOpenShutterFullDose()
    signal togglyCloseShutterFullDose()

    // --- сигналы ---тонкое дозирования
    signal togglyOpenShutterFineDose()
    signal togglyCloseShutterFineDose()

    // --- сигналы --- Для ПЛК
    signal reqestPlcOk()
    signal reqestPlcError()

    signal signalResetError()

    // --- текущий сдвиг ---
    property real separation: {
        if (!toggleMode) {
            if (mode === 1) return fineDose ? separationFine : separationFull
            return 0
        } else {
            if (mode === 1) return separationFull
            if (mode === 3) return separationWait
            if (mode === 4) return separationError
            return 0
        }
    }

    // --- текущий цвет ---
    property color currentColor: {
        if (!toggleMode) {
            if (mode === 1) return fineDose ? "blue" : "green"
            return "#a8a8a8"
        } else {
            if (mode === 1) return fineDose ? "blue" : "green"
            if (mode === 3) return "yellow"
            if (mode === 4) return "red"
            return "#a8a8a8"
        }
    }

    // --- анимации ---
    Behavior on separation { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    Behavior on currentColor { ColorAnimation { duration: 120 } }

    // --- momentaly ---
    onPressed: {
        if (!toggleMode) {
            mode = 1
            checkable = true
            if (fineDose) {
                momentalyOpenShutterFineDose()
            }
            else {
                momentalyOpenShutterFullDose()
            }
        }
    }
    onReleased: {
        if (!toggleMode) {
            mode = 0
            checkable = false
            if (fineDose)
                momentalyCloseShutterFineDose()
            else
                momentalyCloseShutterFullDose()
        }
    }

    // --- toggle ---
    onToggled: {
        if (toggleMode) {
            if (checked) {
                mode = 3 // ждём подтверждения PLC
                if (fineDose)
                    togglyOpenShutterFineDose()
                else
                    togglyOpenShutterFullDose()
                plcWaitTimer.restart()
            } else {
                plcWaitTimer.stop()
                mode = 0
                if (fineDose)
                    togglyCloseShutterFineDose()
                else
                    togglyCloseShutterFullDose()
            }
        }
    }

    // --- таймер ожидания PLC ---
    Timer {
        id: plcWaitTimer
        interval: root.inteval_reqest_plc
        repeat: false
        onTriggered: {
            if (mode === 3) {
                mode = 4
                root.reqestPlcError()
            }
        }
    }

    // --- функции управления ---
    function confirmPlcOk() {
        if (mode === 3) {
            plcWaitTimer.stop()
            mode = 1
            root.reqestPlcOk()
        }
    }
    function confirmPlcError() {
        plcWaitTimer.stop()
        mode = 4
        root.reqestPlcError()
    }
    function resetError() {
        if (mode === 4) {
            mode = 0
            checked = false
            signalResetError()
        }
    }

    function open() {
        if (!toggleMode) {
            mode = 1
            if (fineDose)
                momentalyOpenShutterFineDose()
            else
                momentalyOpenShutterFullDose()
        } else {
            if (!checked) {
                checked = true
                mode = 3
                if (fineDose)
                    togglyOpenShutterFineDose()
                else
                    togglyOpenShutterFullDose()
                plcWaitTimer.restart()
            }
        }
    }

    function close() {
        if (!toggleMode) {
            mode = 0
            if (fineDose)
                momentalyCloseShutterFineDose()
            else
                momentalyCloseShutterFullDose()
        } else {
            if (checked) {
                checked = false
                plcWaitTimer.stop()
                mode = 0
                if (fineDose)
                    togglyCloseShutterFineDose()
                else
                    togglyCloseShutterFullDose()
            }
        }
    }

    // --- фон (треугольники) ---
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
