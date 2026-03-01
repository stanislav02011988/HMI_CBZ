// drag_line/ConnectionDragLine.qml
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property Item sceneContainer: null
    property point startPoint: Qt.point(0, 0)
    property point currentPoint: Qt.point(0, 0)
    property bool isValidTarget: false
    property bool isInvalidTarget: false  // ← НОВОЕ СВОЙСТВО
    property string sourceId: ""
    property string targetId: ""

    // 🔑 ЦВЕТА ДЛЯ 3 СОСТОЯНИЙ
    readonly property color lineColor: {
        if (isInvalidTarget) return "red"
        return isValidTarget ? "#4CAF50" : "#2196F3"
    }
    readonly property color arrowColor: {
        if (isInvalidTarget) return "red"
        return isValidTarget ? "#4CAF50" : "#2196F3"
    }

    width: sceneContainer ? sceneContainer.width : 0
    height: sceneContainer ? sceneContainer.height : 0
    z: 1000

    readonly property real arrowSize: 10
    readonly property real angle: Math.atan2(
        currentPoint.y - startPoint.y,
        currentPoint.x - startPoint.x
    )

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeColor: lineColor  // ← ИСПОЛЬЗУЕМ СВОЙСТВО
            strokeWidth: 1
            fillColor: "transparent"
            startX: startPoint.x
            startY: startPoint.y
            PathLine { x: currentPoint.x; y: currentPoint.y }
        }

        ShapePath {
            fillColor: arrowColor  // ← ИСПОЛЬЗУЕМ СВОЙСТВО
            strokeColor: "transparent"
            PathMove { x: currentPoint.x; y: currentPoint.y }
            PathLine {
                x: currentPoint.x - arrowSize * Math.cos(angle - Math.PI/6)
                y: currentPoint.y - arrowSize * Math.sin(angle - Math.PI/6)
            }
            PathLine {
                x: currentPoint.x - arrowSize * Math.cos(angle + Math.PI/6)
                y: currentPoint.y - arrowSize * Math.sin(angle + Math.PI/6)
            }
            PathLine { x: currentPoint.x; y: currentPoint.y }
        }
    }

    // Визуальная подсказка при валидной цели
    Rectangle {
        visible: isValidTarget && !isInvalidTarget
        x: currentPoint.x - 8
        y: currentPoint.y - 8
        width: 16; height: 16
        color: "#4CAF50"
        radius: 8
        opacity: 0.3
        z: 1001
    }

    // 🔴 ВИЗУАЛЬНАЯ ПОДСКАЗКА ПРИ НЕДОПУСТИМОЙ ЦЕЛИ
    Rectangle {
        visible: isInvalidTarget
        x: currentPoint.x - 8
        y: currentPoint.y - 8
        width: 16; height: 16
        color: "red"
        radius: 8
        opacity: 0.3
        z: 1001
    }

    // 🔍 ОТЛАДОЧНЫЙ ЛОГ
    // onIsValidTargetChanged: {
    //     console.log(` ConnectionDragLine: ВАЛИДНАЯ ЦЕЛЬ = ${isValidTarget}`)
    // }
    // onIsInvalidTargetChanged: {
    //     console.log(` ConnectionDragLine: НЕДОПУСТИМАЯ ЦЕЛЬ = ${isInvalidTarget}`)
    // }
}
