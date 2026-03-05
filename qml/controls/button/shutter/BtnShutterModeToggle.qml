import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import qml.system

Button {
    id: root
    implicitWidth: 140
    implicitHeight: 48
    focusPolicy: Qt.NoFocus

    property string id_shutter_silos: ""
    property string name_shutter_silos: ""

    /* =========================================================
     * РЕЖИМЫ
     * ========================================================= */
    // true = Автоматический режим , false =Ручной режим
    property bool controlMode: false

    // false = Грубо, true = Точно
    property bool dosageMode: false

    /* =========================================================
     * СОСТОЯНИЕ ЗАТВОРА
     * 0 = CLOSED
     * 1 = OPENED
     * 2 = WAIT
     * 3 = ERROR
     * ========================================================= */
    property int state: 0

    /* =========================================================
     * СИГНАЛЫ
     * ========================================================= */
    signal manualCoarseOpenRequest()
    signal manualFineOpenRequest()
    signal signalStateShutter(state:int)
    /* =========================================================
     * API ДЛЯ КОНТРОЛЛЕРА / PLC
     * ========================================================= */
    function setClosed() { state = 0; root.signalStateShutter(state) }
    function setOpened() { state = 1; root.signalStateShutter(state) }
    function setWait()   { state = 2; root.signalStateShutter(state) }
    function setError()  { state = 3; root.signalStateShutter(state) }

    /* =========================================================
     * ДОСТУПНОСТЬ UI
     * ========================================================= */
    // AUTO → полный запрет взаимодействия
    enabled: controlMode && state !== 2
    hoverEnabled: controlMode

    /* =========================================================
     * ВИЗУАЛЬНЫЕ ПАРАМЕТРЫ
     * ========================================================= */
    property real separation: {
        switch (state) {
        case 1:   // OPENED
            return dosageMode ? 4 : 6
        case 2:   // WAIT
            return 3
        case 3:   // ERROR
            return 2
        default:  // CLOSED
            return 0
        }
    }

    property color currentColor: {
        switch (state) {
        case 1:   // OPENED
            return dosageMode ? "blue" : "green"
        case 2:   // WAIT
            return "yellow"
        case 3:   // ERROR
            return "red"
        default:  // CLOSED
            return "#a8a8a8"
        }
    }

    Behavior on separation { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    Behavior on currentColor { ColorAnimation { duration: 120 } }

    /* =========================================================
     * ЛОГИКА КЛИКА (ТОЛЬКО MANUAL)
     * ========================================================= */
    onClicked: {
        if (!controlMode)    // AUTO
            return

        if (dosageMode)
            manualFineOpenRequest()
        else
            manualCoarseOpenRequest()

        setWait()
    }

    /* =========================================================
     * СБРОС ПРИ ВКЛЮЧЕНИИ MANUAL
     * ========================================================= */
    onControlModeChanged: {
        if (controlMode)   // MANUAL
            setClosed()
    }

    /* =========================================================
     * ФОН / ТРЕУГОЛЬНИКИ (БЕЗ ИЗМЕНЕНИЙ)
     * ========================================================= */
    background: Item {
        anchors.fill: parent

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

                const cx = width / 2

                // левый треугольник
                ctx.beginPath()
                ctx.moveTo(cx - root.separation, 0)
                ctx.lineTo(cx - root.separation, height)
                ctx.lineTo(0, 0)
                ctx.closePath()
                ctx.fillStyle = gradient(ctx, root.currentColor, 0, 0, width / 2, height)
                ctx.fill()

                // правый треугольник
                ctx.beginPath()
                ctx.moveTo(cx + root.separation, 0)
                ctx.lineTo(cx + root.separation, height)
                ctx.lineTo(width, 0)
                ctx.closePath()
                ctx.fillStyle = gradient(ctx, root.currentColor, width, 0, width / 2, height)
                ctx.fill()
            }

            Connections {
                target: root
                function onSeparationChanged() { canvas.requestPaint() }
                function onCurrentColorChanged() { canvas.requestPaint() }
                function onStateChanged() { canvas.requestPaint() }
            }

            Component.onCompleted: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
    }
}
