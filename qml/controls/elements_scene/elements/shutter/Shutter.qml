// qml/controls/elements_scene/widgets/ShutterButton.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.busManager

Button {
    id: root
    focusPolicy: Qt.NoFocus

    // ==========================================================
    // 1. ЭТАЛОННЫЙ РАЗМЕР
    // ==========================================================
    property real referenceWidth: 140
    property real referenceHeight: 48

    implicitWidth: referenceWidth
    implicitHeight: referenceHeight

    // ==========================================================
    // 2. МАСШТАБ
    // ==========================================================
    property real scaleX: width  > 0 ? width  / referenceWidth  : 1
    property real scaleY: height > 0 ? height / referenceHeight : 1
    property real scale: Math.min(scaleX, scaleY)

    property string componentGroupe: ""
    property string subtype: ""
    property string id_widget: ""
    property string name_widget: ""

    /* =========================================================
     * РЕЖИМЫ
     * ========================================================= */
    // true = Автоматический режим , false = Ручной режим
    property bool controlMode: false

    // false = Грубо, true = Точно
    property bool dosageMode: false

    /* =========================================================
     * СОСТОЯНИЕ ЗАТВОРА
     * 0 = CLOSED, 1 = OPENED, 2 = WAIT, 3 = ERROR
     * ========================================================= */
    property int state: 0

    /* =========================================================
     * 🔥 СИГНАЛЫ (добавлены для синхронизации)
     * ========================================================= */
    signal manualCoarseOpenRequest()
    signal manualFineOpenRequest()
    signal signalStateShutter(state: int)

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
    enabled: !controlMode && state !== 2
    hoverEnabled: !controlMode

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
     * ЛОГИКА КЛИКА
     * ========================================================= */
    onClicked: {
        emitSignal("btnShatter", "clicked", {
            state: 1
        })
    }

    /* =========================================================
     * СБРОС ПРИ ВКЛЮЧЕНИИ MANUAL
     * ========================================================= */
    onControlModeChanged: {
        if (!controlMode)   // Переход в MANUAL
            setClosed()
    }

    /* =========================================================
     * ФОН / ТРЕУГОЛЬНИКИ
     * ========================================================= */
    layer.enabled: true
    layer.effect: DropShadow {
        color: "#60000000"
        radius: 4
        horizontalOffset: 2
        verticalOffset: 2
    }

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

    // =========================================================
    // СЕРИАЛИЗАЦИЯ СВОЙСТВ ГАБОРИТНЫХ РАЗМЕРОВ ЭЛЕМНТА
    // =========================================================
    function getPropertiesSize() { return [] }
    function setPropertySize(name, value) { /* noop */ }
    function exportPropertiesSize() { return {} }
    function importProperties(data) { /* noop */ }
}
