// internal/ConnectionArrow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Shapes
import "OrthogonalRouter.js" as Router

Item {
    id: root

    property alias contextMenu: contextMenu

    property bool editMode: true
    property Item fromItem
    property Item toItem
    property string fromSignal
    property string toSlot

    property var connectionManager: null
    property var componentRegister: null

    property int connectionIndex: 0
    // =====================================================
    // 🔑 ИНТЕРАКТИВНОСТЬ
    // =====================================================
    property bool isHovered: false
    property real baseWidth: 2.5
    property real hoverWidth: 4.0
    property real lineWidth: isHovered ? hoverWidth : baseWidth
    property real hitTestWidth: 10  // ✅ 10px (5px с каждой стороны от линии)

    // ✅ УНИКАЛЬНЫЙ ЦВЕТ ДЛЯ КАЖДОЙ ЛИНИИ
    property color baseLineColor: generateLineColor()
    property color lineColor: isHovered ? Qt.lighter(baseLineColor, 1.3) : baseLineColor


    // =====================================================
    // 🔑 ФУНКЦИЯ: Генерация цвета на основе connectionIndex
    // =====================================================
    function generateLineColor() {
        const seed = connectionIndex +
                    (fromItem?.widgetInstance?.id_widget || "").length +
                    (toItem?.widgetInstance?.id_widget || "").length

        const hue = (seed * 137.508) % 360
        const saturation = 70 + (seed % 20)
        const lightness = 45 + (seed % 20)

        return hslToRgb(hue / 360, saturation / 100, lightness / 100)
    }

    function hslToRgb(h, s, l) {
        let r, g, b

        if (s === 0) {
            r = g = b = l
        } else {
            const hue2rgb = (p, q, t) => {
                if (t < 0) t += 1
                if (t > 1) t -= 1
                if (t < 1/6) return p + (q - p) * 6 * t
                if (t < 1/2) return q
                if (t < 2/3) return p + (q - p) * (2/3 - t) * 6
                return p
            }

            const q = l < 0.5 ? l * (1 + s) : l + s - l * s
            const p = 2 * l - q
            r = hue2rgb(p, q, h + 1/3)
            g = hue2rgb(p, q, h)
            b = hue2rgb(p, q, h - 1/3)
        }

        return Qt.rgba(r, g, b, 1)
    }

    readonly property Item sceneLayer:
        fromItem?.sceneContainer || toItem?.sceneContainer

    readonly property bool fromIsWide:
        fromItem ? (fromItem.width > fromItem.height) : true

    readonly property bool toIsWide:
        toItem ? (toItem.width > toItem.height) : true

    // =====================================================
    // ИНДЕКСЫ ПОРТОВ
    // =====================================================

    readonly property int fromSignalIndex: {
        if (!fromItem?.widgetInstance?.exposedSignals || !fromSignal) return -1
        const signals = Object.keys(fromItem.widgetInstance.exposedSignals)
        return signals.indexOf(fromSignal)
    }

    readonly property int toSlotIndex: {
        if (!toItem?.widgetInstance?.exposedSlots || !toSlot) return -1
        const slots = Object.keys(toItem.widgetInstance.exposedSlots)
        return slots.indexOf(toSlot)
    }

    readonly property int fromSignalCount: {
        if (!fromItem?.widgetInstance?.exposedSignals) return 0
        return Object.keys(fromItem.widgetInstance.exposedSignals).length
    }

    readonly property int toSlotCount: {
        if (!toItem?.widgetInstance?.exposedSlots) return 0
        return Object.keys(toItem.widgetInstance.exposedSlots).length
    }

    // =====================================================
    // КООРДИНАТЫ ПОРТОВ
    // =====================================================

    readonly property real fromSignalLocalX: {
        if (fromSignalIndex === -1 || !fromItem) return 0
        if (fromIsWide) {
            return (fromItem.width - 18) / 2 + (fromSignalIndex - (fromSignalCount - 1) / 2) * 26
        } else {
            return -22
        }
    }

    readonly property real fromSignalLocalY: {
        if (fromSignalIndex === -1 || !fromItem) return 0
        if (fromIsWide) {
            return -22
        } else {
            return (fromItem.height - 18) / 2 + (fromSignalIndex - (fromSignalCount - 1) / 2) * 26
        }
    }

    readonly property real fromPortX: fromItem ? (fromItem.x + fromSignalLocalX + 9) : 0
    readonly property real fromPortY: fromItem ? (fromItem.y + fromSignalLocalY + 9) : 0

    readonly property real toSlotLocalX: {
        if (toSlotIndex === -1 || !toItem) return 0
        if (toIsWide) {
            return (toItem.width - 18) / 2 + (toSlotIndex - (toSlotCount - 1) / 2) * 26
        } else {
            return toItem.width + 8
        }
    }

    readonly property real toSlotLocalY: {
        if (toSlotIndex === -1 || !toItem) return 0
        if (toIsWide) {
            return toItem.height + 8
        } else {
            return (toItem.height - 18) / 2 + (toSlotIndex - (toSlotCount - 1) / 2) * 26
        }
    }

    readonly property real toPortX: toItem ? (toItem.x + toSlotLocalX + 9) : 0
    readonly property real toPortY: toItem ? (toItem.y + toSlotLocalY + 9) : 0

    // =====================================================
    // ПРЕПЯТСТВИЯ
    // =====================================================

    readonly property var obstacles: {
        if (!sceneLayer)
            return []
        const obs = []
        for (let i = 0; i < sceneLayer.children.length; i++) {
            const child = sceneLayer.children[i]
            if (!child.widgetInstance)
                continue
            if (child === toItem || child === fromItem)
                continue
            obs.push(child)
        }
        return obs
    }

    // =====================================================
    // МАРШРУТ
    // =====================================================

    readonly property var routePoints: {
        if (!fromItem || !toItem || fromPortX === 0 || fromPortY === 0) {
            return []
        }
        const route = Router.buildRoute(
            fromItem,
            toItem,
            fromPortX,
            fromPortY,
            toPortX,
            toPortY,
            fromIsWide,
            toIsWide,
            obstacles || [],
            connectionIndex
        )
        return route || []
    }

    // =====================================================
    // BOUNDING BOX
    // =====================================================

    function computeBounds() {
        if (!routePoints || routePoints.length === 0)
            return { minX: 0, minY: 0, maxX: 0, maxY: 0 }

        var minX = routePoints[0].x
        var minY = routePoints[0].y
        var maxX = routePoints[0].x
        var maxY = routePoints[0].y

        for (var i = 1; i < routePoints.length; i++) {
            minX = Math.min(minX, routePoints[i].x)
            minY = Math.min(minY, routePoints[i].y)
            maxX = Math.max(maxX, routePoints[i].x)
            maxY = Math.max(maxY, routePoints[i].y)
        }

        return { minX, minY, maxX, maxY }
    }

    readonly property var bounds: computeBounds()

    x: bounds.minX - 20
    y: bounds.minY - 20
    width: bounds.maxX - bounds.minX + 40
    height: bounds.maxY - bounds.minY + 40

    // =====================================================
    // ПОДСКАЗКА
    // =====================================================

    ToolTip {
        id: connectionToolTip
        visible: root.isHovered && editMode
        delay: 500
        timeout: 5000

        text: {
            const fromName = fromItem?.widgetInstance?.name_widget || fromItem?.widgetInstance?.id_widget || "—"
            const fromId = fromItem?.widgetInstance?.id_widget || "—"
            const fromSignalDesc = fromItem?.widgetInstance?.exposedSignals?.[fromSignal] || fromSignal || "—"

            const toName = toItem?.widgetInstance?.name_widget || toItem?.widgetInstance?.id_widget || "—"
            const toId = toItem?.widgetInstance?.id_widget || "—"
            const toSlotDesc = toItem?.widgetInstance?.exposedSlots?.[toSlot] || toSlot || "—"

            return `
Источник:
Название: ${fromName}
ID: ${fromId}
Сигнал: ${fromSignal}
Описание:
    ${fromSignalDesc}

Приемник:
Название: ${toName}
ID: ${toId}
Слот: ${toSlot}
Описание:
    ${toSlotDesc}`
        }

        implicitWidth: 350
        implicitHeight: contentItem.implicitHeight + 20

        background: Rectangle {
            color: "#333333"
            radius: 5
            border.color: root.baseLineColor
            border.width: 1
            width: parent.width
            height: parent.height
        }

        contentItem: Text {
            text: connectionToolTip.text
            color: "white"
            font.pixelSize: 11
            font.family: "Segoe UI"
            wrapMode: Text.Wrap
            width: connectionToolTip.implicitWidth - 20
            verticalAlignment: Text.AlignTop
            leftPadding: 10
            rightPadding: 10
            topPadding: 10
            bottomPadding: 10
        }
    }

    // =====================================================
    // КОНТЕКСТНОЕ МЕНЮ
    // =====================================================

    Menu {
        id: contextMenu
        MenuItem {
            text: "ℹ️ Информация"
            onTriggered: {
                contextMenu.close()
                connectionToolTip.visible = true
                connectionToolTip.timeout = 10000
            }
        }
        MenuItem {
            text: "🗑️ Удалить связь"
            onTriggered: {
                contextMenu.close()
                if (connectionManager &&
                    fromItem?.widgetInstance?.id_widget &&
                    toItem?.widgetInstance?.id_widget) {
                    connectionManager.removeConnection(
                        fromItem.widgetInstance.id_widget,
                        toItem.widgetInstance.id_widget,
                        fromSignal,
                        toSlot
                    )
                }
            }
        }
    }

    // =====================================================
    // ✅ ОТРИСОВКА: ДВА КОНТУРА
    // =====================================================

    Shape {
        anchors.fill: parent
        antialiasing: true
        visible: fromItem && toItem

        ShapePath {
            strokeColor: root.lineColor
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            joinStyle: ShapePath.MiterJoin
            capStyle: Qt.RoundCap

            PathPolyline {
                path: routePoints.map(function(p) {
                    return Qt.point(
                        p.x - bounds.minX + 20,
                        p.y - bounds.minY + 20
                    )
                })
            }
        }
    }
}
