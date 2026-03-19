import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Button {
    id: root
    implicitWidth: 140
    implicitHeight: 48
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    property string componentGroupe: ""
    property string subtype: ""
    property string id_widget: ""
    property string name_widget: ""

    // Градиенты для всех состояний
    property color normalLeftStart:   "#a8a8a8"
    property color normalLeftEnd:     "#7f837f"
    property color normalRightStart:  "#a8a8a8"
    property color normalRightEnd:    "#a8a8a8"

    property color hoverLeftStart:    "#767676"
    property color hoverLeftEnd:      "#e5474747"
    property color hoverRightStart:   "#767676"
    property color hoverRightEnd:     "#e5474747"

    property color pressedLeftStart:  "#009e03"
    property color pressedLeftEnd:    "#006602"
    property color pressedRightStart: "#009e03"
    property color pressedRightEnd:   "#006602"

    property color disabledLeftStart:  "#cccccc"
    property color disabledLeftEnd:    "#999999"
    property color disabledRightStart: "#cccccc"
    property color disabledRightEnd:   "#999999"

    property real  borderWidth:  2
    property real  centerShift:  0.0
    property real  innerGap:     0.0

    property bool pressedAuto: false
    property int intervalPressed: 2000

    Accessible.role: Accessible.Button

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

            function createGradient(ctx, startColor, endColor, x1, y1, x2, y2) {
                const grad = ctx.createLinearGradient(x1, y1, x2, y2);
                grad.addColorStop(0, startColor);
                grad.addColorStop(1, endColor);
                return grad;
            }

            function getFillStyle(ctx, leftOrRight) {
                if (!root.enabled) {
                    return leftOrRight === "left"
                        ? createGradient(ctx, root.disabledLeftStart, root.disabledLeftEnd, 0, 0, width*0.5, height)
                        : createGradient(ctx, root.disabledRightStart, root.disabledRightEnd, width, 0, width*0.5, height);
                }
                if (root.down) {
                    return leftOrRight === "left"
                        ? createGradient(ctx, root.pressedLeftStart, root.pressedLeftEnd, 0, 0, width*0.5, height)
                        : createGradient(ctx, root.pressedRightStart, root.pressedRightEnd, width, 0, width*0.5, height);
                }
                if (root.hovered) {
                    return leftOrRight === "left"
                        ? createGradient(ctx, root.hoverLeftStart, root.hoverLeftEnd, 0, 0, width*0.5, height)
                        : createGradient(ctx, root.hoverRightStart, root.hoverRightEnd, width, 0, width*0.5, height);
                }
                // обычное состояние
                return leftOrRight === "left"
                    ? createGradient(ctx, root.normalLeftStart, root.normalLeftEnd, 0, 0, width*0.5, height)
                    : createGradient(ctx, root.normalRightStart, root.normalRightEnd, width, 0, width*0.5, height);
            }

            onPaint: {
                const ctx = getContext("2d");
                const w = width, h = height;
                ctx.clearRect(0,0,w,h);

                let cx = w * (0.5 + Math.max(-0.45, Math.min(0.45, root.centerShift)));
                let cy = h/2;

                // левый треугольник
                ctx.fillStyle = getFillStyle(ctx, "left");
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(cx - root.innerGap*0.5, cy);
                ctx.lineTo(0, h);
                ctx.closePath();
                ctx.fill();

                // правый треугольник
                ctx.fillStyle = getFillStyle(ctx, "right");
                ctx.beginPath();
                ctx.moveTo(w, 0);
                ctx.lineTo(cx + root.innerGap*0.5, cy);
                ctx.lineTo(w, h);
                ctx.closePath();
                ctx.fill();
            }

            Connections {
                target: root
                function updateAll() { canvas.requestPaint(); }

                function onDownChanged() { updateAll(); }
                function onHoveredChanged() { updateAll(); }
                function onEnabledChanged() { updateAll(); }
            }

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()
        }
    }

    Keys.onSpacePressed: root.clicked()
    Keys.onEnterPressed: root.clicked()
    Keys.onReturnPressed: root.clicked()    

    function getPropertiesSize() { return [] }
    function setPropertySize(name, value) { /* noop */ }
    function exportPropertiesSize() { return {} }
    function importProperties(data) { /* noop */ }
}
