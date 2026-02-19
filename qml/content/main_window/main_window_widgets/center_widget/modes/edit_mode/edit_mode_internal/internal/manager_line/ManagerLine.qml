// edit_mode_internal/internal/ConnectionArrowManager.qml
import QtQuick
import QtQuick.Controls
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.internal.manager_line.line
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.internal.manager_line.dialog_confirm_connection

Item {
    id: root
    anchors.fill: parent

    // === МЕНЕДЖЕРЫ ===
    property var rulesArray: []
    property var componentRegister: null
    property var connectionManager: null
    property Item sceneLayer: null

    // === СОСТОЯНИЕ DRAG ===
    property int dragState: 0
    property string dragSourceId: ""
    property string dragSignalName: ""
    property point dragStartPoint: Qt.point(0, 0)
    property string dragTargetId: ""
    property string dragTargetSlot: ""
    property bool isValidDrop: false
    property bool isInvalidTarget: false

    // === КОМПОНЕНТЫ ===
    property var dragLine: null
    property var confirmDialog: null
    property var connectionIndices: []
    property int hoveredArrowIndex: -1

    // === СИГНАЛЫ ===
    signal dragStarted(string sourceId, string signalName)
    signal dragEnded()
    signal connectionCreated(string fromId, string signal, string toId, string slot)
    signal connectionRejected()

    // =====================================================
    // ИНИЦИАЛИЗАЦИЯ
    // =====================================================
    Component.onCompleted: {
        console.log(` [ArrowManager] Инициализация...`)
        console.log(`   sceneLayer: ${sceneLayer}`)
        console.log(`   connectionManager: ${connectionManager}`)

        if (connectionManager && Array.isArray(connectionManager.rules)) {
            rulesArray = connectionManager.rules.slice()
            calculateConnectionIndices()
        }
        initializeDialog()
    }

    Connections {
        target: connectionManager
        function onSignalRules() {
            if (connectionManager && Array.isArray(connectionManager.rules)) {
                rulesArray = connectionManager.rules.slice()
                calculateConnectionIndices()
            }
        }
    }

    // =====================================================
    // ДИАЛОГ
    // =====================================================
    function initializeDialog() {
        if (!confirmDialog) {
            confirmDialog = confirmDialogComponent.createObject(root)
            if (confirmDialog) {
                confirmDialog.connectionManager = root.connectionManager
                confirmDialog.componentRegister = root.componentRegister
                confirmDialog.connectionConfirmed.connect(onConnectionConfirmed)
                confirmDialog.connectionRejected.connect(onConnectionRejected)
            }
        }
    }

    function showConnectionDialog() {
        if (dragState !== 1 || !isValidDrop) {
            cleanupDrag()
            return
        }

        if (!root.connectionManager || !root.componentRegister) {
            console.error(" Менеджеры NULL!")
            cleanupDrag()
            return
        }

        const sourceElem = componentRegister?.getElementById(dragSourceId)
        const targetElem = componentRegister?.getElementById(dragTargetId)

        if (!sourceElem || !targetElem) {
            cleanupDrag()
            return
        }

        confirmDialog.connectionManager = root.connectionManager
        confirmDialog.componentRegister = root.componentRegister

        confirmDialog.setConnectionData(
            dragSourceId,
            sourceElem.config?.name_widget || dragSourceId,
            dragSignalName,
            dragTargetId,
            targetElem.config?.name_widget || dragTargetId,
            dragTargetSlot
        )

        dragState = 2
        confirmDialog.open()
    }

    function onConnectionConfirmed() {
        root.connectionManager.createConnection(
            dragSourceId, dragSignalName, dragTargetId, dragTargetSlot
        )
        connectionCreated(dragSourceId, dragSignalName, dragTargetId, dragTargetSlot)
        cleanupDrag()
    }

    function onConnectionRejected() {
        connectionRejected()
        cleanupDrag()
    }

    // =====================================================
    // DRAG УПРАВЛЕНИЕ (ИСПРАВЛЕНО!)
    // =====================================================
    function startDrag(sourceId, signalName, startPos) {
        cleanupDrag()

        dragState = 1
        dragSourceId = sourceId
        dragSignalName = signalName
        dragStartPoint = startPos

        if (!sceneLayer) {
            console.error(" sceneLayer = NULL!")
            return
        }

        dragLine = dragLineComponent.createObject(root, {
            startPoint: startPos,
            currentPoint: startPos,
            sceneContainer: sceneLayer,
            z: 1000
        })

        if (!dragLine) {
            console.error(" dragLine НЕ создан!")
            return
        }

        console.log(` DragLine создан`)
        hoverMouseArea.enabled = false
        dragMouseArea.enabled = true
        console.log(`   dragMouseArea.enabled = ${dragMouseArea.enabled}`)

        dragStarted(sourceId, signalName)
    }

    function updateDrag(currentPos) {
        if (dragState !== 1 || !dragLine) return

        console.log(`️ [updateDrag] (${currentPos.x}, ${currentPos.y})`)

        dragLine.currentPoint = currentPos
        checkTarget(currentPos.x, currentPos.y)
    }

    function endDrag(currentPos) {
        if (dragState !== 1) return
        checkTarget(currentPos.x, currentPos.y)
        if (isValidDrop) {
            showConnectionDialog()
        } else {
            cleanupDrag()
        }
    }

    function cleanupDrag() {
        if (dragLine) {
            dragLine.destroy()
            dragLine = null
        }
        dragState = 0
        dragSourceId = ""
        dragSignalName = ""
        dragTargetId = ""
        dragTargetSlot = ""
        isValidDrop = false
        isInvalidTarget = false
        dragMouseArea.enabled = false
        hoverMouseArea.enabled = true
        dragEnded()
    }

    // =====================================================
    // ✅ DragMouseArea (ИСПРАВЛЕНО: mouseX/mouseY)
    // =====================================================
    MouseArea {
        id: dragMouseArea
        anchors.fill: parent
        enabled: false
        hoverEnabled: true
        propagateComposedEvents: false

        onPositionChanged: {
            if (dragState === 1) {
                // ✅ ИСПОЛЬЗУЕМ mouseX/mouseY (не mouse.x/mouse.y!)
                updateDrag(Qt.point(mouseX, mouseY))
            }
        }

        onReleased: {
            if (dragState === 1) {
                endDrag(Qt.point(mouseX, mouseY))
            }
        }
    }

    // =====================================================
    // ✅ HoverMouseArea
    // =====================================================
    MouseArea {
        id: hoverMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true

        onPositionChanged: {
            if (dragState === 1) return

            const globalMouseX = mouseX + root.x
            const globalMouseY = mouseY + root.y

            let foundIndex = -1
            let foundDistance = Infinity

            for (let i = 0; i < arrowsRepeater.count; i++) {
                const arrow = arrowsRepeater.itemAt(i)
                if (arrow && arrow.visible) {
                    const dist = distanceToLine(arrow, globalMouseX, globalMouseY)
                    if (dist < 8 && dist < foundDistance) {
                        foundIndex = i
                        foundDistance = dist
                    }
                }
            }

            if (foundIndex !== hoveredArrowIndex) {
                hoveredArrowIndex = foundIndex
                for (let i = 0; i < arrowsRepeater.count; i++) {
                    const arrow = arrowsRepeater.itemAt(i)
                    if (arrow) arrow.isHovered = (i === foundIndex)
                }
            }
        }

        onExited: {
            if (dragState !== 1) {
                hoveredArrowIndex = -1
                for (let i = 0; i < arrowsRepeater.count; i++) {
                    const arrow = arrowsRepeater.itemAt(i)
                    if (arrow) arrow.isHovered = false
                }
            }
        }

        onClicked: (mouse) => {
            if (dragState === 1) return

            // ✅ ОТКРЫВАЕМ МЕНЮ У КОНКРЕТНОЙ СТРЕЛКИ (не у менеджера!)
            if (mouse.button === Qt.RightButton && hoveredArrowIndex >= 0) {
                const arrow = arrowsRepeater.itemAt(hoveredArrowIndex)
                if (arrow && arrow.contextMenu) {
                    // ✅ Преобразуем координаты в глобальные для меню
                    arrow.contextMenu.x = mouse.x
                    arrow.contextMenu.y = mouse.y
                    arrow.contextMenu.popup()
                    mouse.accepted = true
                }
            }
        }
    }

    // =====================================================
    // УПРАВЛЕНИЕ ЦЕЛЯМИ
    // =====================================================
    function setDragTarget(targetId, slotKey) {
        if (dragState !== 1 || !dragLine) return
        isInvalidTarget = false
        isValidDrop = true
        dragTargetId = targetId
        dragTargetSlot = slotKey
        dragLine.isValidTarget = true
        dragLine.isInvalidTarget = false
    }

    function clearDragTarget() {
        if (dragState !== 1 || !dragLine) return
        isValidDrop = false
        dragTargetId = ""
        dragTargetSlot = ""
        dragLine.isValidTarget = false
    }

    function setInvalidTarget() {
        if (dragState !== 1 || !dragLine) return
        isInvalidTarget = true
        isValidDrop = false
        dragLine.isInvalidTarget = true
        dragLine.isValidTarget = false
    }

    function clearInvalidTarget() {
        if (dragState !== 1 || !dragLine) return
        isInvalidTarget = false
        dragLine.isInvalidTarget = false
    }

    function checkTarget(x, y) {
        isValidDrop = false
        dragTargetId = ""
        dragTargetSlot = ""
        if (dragLine) dragLine.isValidTarget = false

        const layer = sceneLayer || root
        if (!layer) return false

        for (let i = 0; i < layer.children.length; i++) {
            const child = layer.children[i]
            if (child === root || child === dragLine) continue
            if (!child.hasOwnProperty("widgetInstance")) continue
            if (typeof child.isPointOverSlotArea !== 'function') continue
            if (typeof child.getSlotAtPoint !== 'function') continue

            const localPoint = child.mapFromItem(layer, x, y)
            if (child.isPointOverSlotArea(localPoint.x, localPoint.y)) {
                const slotInfo = child.getSlotAtPoint(localPoint.x, localPoint.y)
                if (slotInfo) {
                    isValidDrop = true
                    dragTargetId = child.widgetInstance.id_widget
                    dragTargetSlot = slotInfo.slotKey
                    if (dragLine) {
                        dragLine.isValidTarget = true
                        dragLine.targetId = dragTargetId
                    }
                    return true
                }
            }
        }
        return false
    }

    // =====================================================
    // ИНДЕКСЫ
    // =====================================================
    function calculateConnectionIndices() {
        const indices = []
        const connectionGroups = {}
        for (let i = 0; i < rulesArray.length; i++) {
            const conn = rulesArray[i]
            const key = `${conn.fromId}__${conn.toId}`
            if (!connectionGroups[key]) connectionGroups[key] = []
            connectionGroups[key].push(i)
        }
        for (const key in connectionGroups) {
            const groupIndices = connectionGroups[key]
            for (let j = 0; j < groupIndices.length; j++) {
                indices[groupIndices[j]] = j
            }
        }
        connectionIndices = indices
    }

    function refreshConnectionIndices() {
        calculateConnectionIndices()
    }

    function findWrapperById(id) {
        const elem = componentRegister?.getElementById(id)
        return elem ? elem.wrapper : null
    }

    function distanceToSegment(px, py, x1, y1, x2, y2) {
        const dx = x2 - x1
        const dy = y2 - y1
        if (dx === 0 && dy === 0) return Math.hypot(px - x1, py - y1)
        const t = ((px - x1) * dx + (py - y1) * dy) / (dx*dx + dy*dy)
        const clampedT = Math.max(0, Math.min(1, t))
        return Math.hypot(px - (x1 + clampedT * dx), py - (y1 + clampedT * dy))
    }

    function distanceToLine(arrow, globalMouseX, globalMouseY) {
        if (!arrow || !arrow.routePoints || arrow.routePoints.length < 2) return Infinity
        let minDist = Infinity
        for (let i = 0; i < arrow.routePoints.length - 1; i++) {
            const p1 = arrow.routePoints[i]
            const p2 = arrow.routePoints[i + 1]
            const dist = distanceToSegment(globalMouseX, globalMouseY, p1.x, p1.y, p2.x, p2.y)
            if (dist < minDist) minDist = dist
        }
        return minDist
    }

    // =====================================================
    // КОМПОНЕНТЫ
    // =====================================================
    Component {
        id: dragLineComponent
        DragLine {}
    }

    Component {
        id: confirmDialogComponent
        DialogConfirmConnection {}
    }

    // =====================================================
    // ОТРИСОВКА
    // =====================================================
    Repeater {
        id: arrowsRepeater
        model: root.rulesArray
        delegate: CommunicationLine {
            fromSignal: modelData.signal
            toSlot: modelData.slot
            connectionIndex: connectionIndices[index] !== undefined ? connectionIndices[index] : 0
            connectionManager: root.connectionManager
            componentRegister: root.componentRegister
            fromItem: {
                const elem = componentRegister?.getElementById(modelData.fromId)
                return elem ? elem.wrapper : null
            }
            toItem: {
                const elem = componentRegister?.getElementById(modelData.toId)
                return elem ? elem.wrapper : null
            }
            visible: fromItem && toItem
        }
    }
}
