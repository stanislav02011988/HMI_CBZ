import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: parent.width
    height: parent.height

    // --- свойства для цветов треугольников ---
    property color leftColor: "#a8a8a8"
    property color rightColor: "#a8a8a8"

    // --- плавная анимация при изменении цветов ---
    Behavior on leftColor {
        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
    }
    Behavior on rightColor {
        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
    }

    // --- свойства для формы ---
    property int separation: 0 // расстояние между треугольниками

    // --- функции для изменения цвета ---

    function setColorTriangle(status) {
        if (status === "open"){
            leftColor = "green"
            rightColor = "green"
        }else if (status === "close") {
            leftColor = "#a8a8a8"
            rightColor = "#a8a8a8"
        }else if (status === "error") {
            leftColor = "red"
            rightColor = "red"
        }
    }

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

            const cx = width / 2
            const topY = 0
            const bottomY = height

            // левый треугольник
            ctx.beginPath()
            ctx.moveTo(cx - root.separation, topY)
            ctx.lineTo(cx - root.separation, bottomY)
            ctx.lineTo(0, topY)
            ctx.closePath()
            ctx.fillStyle = gradient(ctx, root.leftColor, 0, 0, width/2, height)
            ctx.fill()

            // правый треугольник
            ctx.beginPath()
            ctx.moveTo(cx + root.separation, topY)
            ctx.lineTo(cx + root.separation, bottomY)
            ctx.lineTo(width, topY)
            ctx.closePath()
            ctx.fillStyle = gradient(ctx, root.rightColor, width, 0, width/2, height)
            ctx.fill()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
    }

    // следим за изменением цветов и перерисовываем канвас
    Connections {
        target: root
        function onLeftColorChanged() { canvas.requestPaint() }
        function onRightColorChanged() { canvas.requestPaint() }
    }
}
