import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: 300; height: 180

    property point topLeft: Qt.point(width * 0.0, height * 0.0)
    property point topRight: Qt.point(width * 1.0, height * 0.0)
    property point bottomLeft: Qt.point(width * 0.06, height * 1.0)
    property point bottomRight: Qt.point(width * 0.94, height * 1.0)

    property real level: 0.9
    property color fillColor: "#e6e6e6"
    property color liquidColor: "dodgerblue"
    property color borderColor: "black"
    property int  borderWidth: 1

    // helper functions...
    function lerp(p, q, t){ return Qt.point(p.x + (q.x-p.x)*t, p.y + (q.y-p.y)*t) }
    function dist(p,q){ var dx=q.x-p.x, dy=q.y-p.y; return Math.sqrt(dx*dx+dy*dy) }

    property real _tLeft:  Math.min(0.49, borderWidth / Math.max(1, dist(topLeft, bottomLeft)))
    property real _tRight: Math.min(0.49, borderWidth / Math.max(1, dist(topRight, bottomRight)))

    property point iTopLeft:     lerp(topLeft,     bottomLeft,  _tLeft)
    property point iTopRight:    lerp(topRight,    bottomRight, _tRight)
    property point iBottomLeft:  lerp(bottomLeft,  topLeft,     _tLeft)
    property point iBottomRight: lerp(bottomRight, topRight,    _tRight)

    property point _levelLeft:  lerp(iTopLeft,  iBottomLeft,  1 - level)
    property point _levelRight: lerp(iTopRight, iBottomRight, 1 - level)

    /* ----- внешняя подложка (фон) ----- */
    Shape {
        anchors.fill: parent
        // можно задать preferredRendererType, если нужно попробовать другой рендерер:
        // preferredRendererType: Shape.CurveRenderer

        // Включаем слой и samples для улучшенного сглаживания конкретно этого Shape:
        layer.enabled: true
        layer.samples: 4   // или 8 — пробуй

        ShapePath {
            strokeWidth: 0
            fillColor: root.fillColor
            startX: topLeft.x; startY: topLeft.y
            PathLine { x: topRight.x;    y: topRight.y }
            PathLine { x: bottomRight.x; y: bottomRight.y }
            PathLine { x: bottomLeft.x;  y: bottomLeft.y }
            PathLine { x: topLeft.x;     y: topLeft.y }
        }
    }

    /* ----- жидкость — внутренний полигон (не доходит до бордера) ----- */
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeWidth: 0
            fillColor: root.liquidColor

            startX: _levelLeft.x;  startY: _levelLeft.y
            PathLine { x: _levelRight.x;    y: _levelRight.y }
            PathLine { x: iBottomRight.x;   y: iBottomRight.y }
            PathLine { x: iBottomLeft.x;    y: iBottomLeft.y }
            PathLine { x: _levelLeft.x;     y: _levelLeft.y }
        }
    }

    /* ----- бордер сверху ----- */
    Shape {
        anchors.fill: parent
        z: 10
        // layer и samples для бордера, если нужен антиалиасинг у обводки:
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin   // или MiterJoin, BevelJoin
            capStyle: ShapePath.FlatCap

            startX: topLeft.x;  startY: topLeft.y
            PathLine { x: topRight.x;    y: topRight.y }
            PathLine { x: bottomRight.x; y: bottomRight.y }
            PathLine { x: bottomLeft.x;  y: bottomLeft.y }
            PathLine { x: topLeft.x;     y: topLeft.y }
        }
    }

    Behavior on level { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad } }
}
