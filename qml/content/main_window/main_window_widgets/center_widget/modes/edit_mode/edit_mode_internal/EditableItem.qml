// edit_mode_internal/EditableItem.qml
// ============================================================================
// ОБЁРТКА ДЛЯ ВИДЖЕТА НА СЦЕНЕ
// ============================================================================
// Отвечает за:
// - Отображение виджета
// - Сигнальные порты (зелёные)
// - Слотовые порты (жёлтые)
// - Выделение и перетаскивание
// ============================================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.item.dialog_resize_element
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.item.ports_signal_slot
Item {
    id: wrapper
    // =========================================================================
    // СВОЙСТВА
    // =========================================================================

    // ─── ГЕОМЕТРИЯ ──────────────────────────────────────────────────────────
    property var geometry: ({
        relX: 0.1,
        relY: 0.1,
        relW: 0.2,
        relH: 0.2
    })
    property real relX: geometry.relX
    property real relY: geometry.relY
    property real relW: geometry.relW
    property real relH: geometry.relH

    // ─── ДАННЫЕ ВИДЖЕТА ─────────────────────────────────────────────────────
    property var widgetData: ({
        type: "",
        id_widget: "",
        name_widget: "",
        component: null
    })

    // ─── СОСТОЯНИЕ ──────────────────────────────────────────────────────────
    property var state: ({
        isSelected: false,
        editMode: false
    })
    property bool isSelected: state.isSelected
    property bool editMode: state.editMode

    // ─── МЕНЕДЖЕРЫ ──────────────────────────────────────────────────────────
    property var managers: ({
        signalBus: null,
        connectionManager: null,
        componentRegister: null
    })
    property var signalBus: managers.signalBus
    property var connectionManager: managers.connectionManager
    property var componentRegister: managers.componentRegister


    property Item widgetInstance: null
    property Item sceneContainer: null
    property var sceneController: null

    property var tooltip: null

    signal requestDelete()
    signal requestSelect(bool toggle)

    // =========================================================================
    // ГЕОМЕТРИЯ
    // =========================================================================
    x: sceneContainer ? (relX * sceneContainer.width) : 0
    y: sceneContainer ? (relY * sceneContainer.height) : 0
    width: sceneContainer ? (relW * sceneContainer.width) : 0
    height: sceneContainer ? (relH * sceneContainer.height) : 0

    // === СВОЙСТВО ОРИЕНТАЦИИ ЭЛЕМЕНТА ===
    property bool isWide: width > height  // true = горизонтальный, false = вертикальный

    // =========================================================================
    // ФОКУС ПРИ ВЫДЕЛЕНИИ
    // =========================================================================
    onIsSelectedChanged: {
        if (isSelected && editMode) {
            wrapper.forceActiveFocus()
        }
    }

    // =========================================================================
    // КОНТЕЙНЕР ВИДЖЕТА
    // =========================================================================
    Item {
        id: contentItem
        anchors.fill: parent
    }

    // =========================================================================
    // СОЗДАНИЕ ВИДЖЕТА
    // =========================================================================
    Component.onCompleted: {
        if (!widgetData.component) {
            console.error("ERROR: widgetComponent НЕ ПЕРЕДАН!")
            return
        }

        widgetInstance = widgetData.component.createObject(contentItem, {
            signalBus: managers.signalBus,
            id_widget: widgetData.id_widget,
            name_widget: widgetData.name_widget
        })

        if (widgetInstance) {
            widgetInstance.anchors.fill = contentItem

            // ПРОВЕРКА exposedSignals
            if (!widgetInstance.exposedSignals || typeof widgetInstance.exposedSignals !== 'object') {
                console.warn("WARNING: exposedSignals отсутствует: " + (widgetData.name_widget || widgetData.id_widget))
            }

            // ПРОВЕРКА exposedSlots
            if (!widgetInstance.exposedSlots || typeof widgetInstance.exposedSlots !== 'object') {
                console.warn("WARNING: exposedSlots отсутствует: " + (widgetData.name_widget || widgetData.id_widget))
            }

            console.log("INFO: Виджет создан: " + widgetData.id_widget)

        } else {
            console.error("ERROR: Ошибка создания виджета из компонента")
        }
    }

    // =========================================================================
    // ОЧИСТКА
    // =========================================================================
    Component.onDestruction: {
        if (widgetInstance) {
            if (signalBus?.unsubscribeAll && widgetData.id_widget) {
                signalBus.unsubscribeAll(widgetData.id_widget)
            }
            widgetInstance.destroy()
            widgetInstance = null
        }
    }

    // =========================================================================
    // РАМКА ВЫДЕЛЕНИЯ
    // =========================================================================
    Rectangle {
        id: borderRect
        anchors.fill: parent
        color: "transparent"
        border.width: editMode && (isSelected || hoverArea.containsMouse) ? 2 : 0
        border.color: isSelected ? "dodgerblue" : (hoverArea.containsMouse ? "gray" : "transparent")
        visible: editMode
        z: 100
    }

    // =========================================================================
    // МЫШЬ (ВЫДЕЛЕНИЕ)
    // =========================================================================
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: (editMode && isSelected) ? Qt.SizeAllCursor : Qt.ArrowCursor
        propagateComposedEvents: true
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton && editMode) {
                const toggle = mouse.modifiers & Qt.ControlModifier
                wrapper.requestSelect(toggle)
                mouse.accepted = true
            } else if (mouse.button === Qt.RightButton && editMode) {
                contextMenu.popup()
                mouse.accepted = true
            }
        }
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    // =========================================================================
    // ПЕРЕТАСКИВАНИЕ
    // =========================================================================
    MouseArea {
        id: mouseAreaDradElement
        anchors.fill: parent
        enabled: editMode && isSelected
        cursorShape: Qt.SizeAllCursor
        propagateComposedEvents: false
        property real dragOffsetX: 0
        property real dragOffsetY: 0
        onPressed: (mouse) => {
            dragOffsetX = mouse.x
            dragOffsetY = mouse.y
        }
        onPositionChanged: (mouse) => {
            if (!pressed || !sceneContainer) return
            var globalX = wrapper.x + mouse.x
            var globalY = wrapper.y + mouse.y
            var newX = globalX - dragOffsetX
            var newY = globalY - dragOffsetY
            newX = Math.max(0, Math.min(sceneContainer.width - wrapper.width, newX))
            newY = Math.max(0, Math.min(sceneContainer.height - wrapper.height, newY))
            wrapper.relX = newX / sceneContainer.width
            wrapper.relY = newY / sceneContainer.height
        }
    }

    // =========================================================================
    // КЛАВИАТУРА
    // =========================================================================
    Keys.onPressed: (event) => {
        if (!editMode || !isSelected || !sceneContainer) {
            return
        }
        let changed = false
        const step = 0.01
        switch (event.key) {
            case Qt.Key_Left:  relX -= step; changed = true; break
            case Qt.Key_Right: relX += step; changed = true; break
            case Qt.Key_Up:    relY -= step; changed = true; break
            case Qt.Key_Down:  relY += step; changed = true; break
            case Qt.Key_Delete: requestDelete(); changed = true; break
        }
        if (changed) {
            event.accepted = true
            relX = Math.max(0, Math.min(1 - relW, relX))
            relY = Math.max(0, Math.min(1 - relH, relY))
        }
    }

    // =========================================================================
    // КОНТЕКСТНОЕ МЕНЮ
    // =========================================================================
    Menu {
        id: contextMenu
        MenuItem { text: "Удалить"; onTriggered: wrapper.requestDelete() }
        MenuItem { text: "Изменить размеры..."; onTriggered: resizeDialog.open() }
    }

    // === ДИАЛОГИ ===
    DialogResizeElement { id: resizeDialog; targetElement: wrapper }

    // =========================================================================
    // ПОРТЫ СИГНАЛОВ (ЗЕЛЁНЫЕ)
    // =========================================================================
    PortSignal {
        id: signalsRepeater
        widgetInstance: wrapper.widgetInstance
        sceneContainer: wrapper.sceneContainer
        sceneController: wrapper.sceneController
        isWide: wrapper.isWide
        editMode: wrapper.editMode
    }
    // =========================================================================
    // ПОРТЫ СЛОТОВ (ЖЁЛТЫЕ)
    // =========================================================================
    PortSlot {
        id: slotsRepeater
        widgetInstance: wrapper.widgetInstance
        sceneContainer: wrapper.sceneContainer
        sceneController: wrapper.sceneController
        isWide: wrapper.isWide
        editMode: wrapper.editMode
    }

    /**
     * Возвращает объект с позициями всех сигналов
     * @return object { signalKey: point, ... }
     */
    function getSignalPortPositions() {
        var positions = {}
        if (!widgetInstance || !editMode) return positions
        const signals = Object.keys(widgetInstance.exposedSignals)
        for (let i = 0; i < signals.length; i++) {
            const key = signals[i]
            positions[key] = getSignalPortPosition(key)
        }
        return positions
    }

    /**
     * Возвращает объект с позициями всех слотов
     * @return object { slotKey: point, ... }
     */
    function getSlotPortPositions() {
        var positions = {}
        if (!widgetInstance || !editMode) return positions
        const slots = Object.keys(widgetInstance.exposedSlots)
        for (let i = 0; i < slots.length; i++) {
            const key = slots[i]
            positions[key] = getSlotPortPosition(key)
        }
        return positions
    }

    /**
     * Проверяет, находится ли точка в области слотов
     * @param localX - X в локальных координатах обёртки
     * @param localY - Y в локальных координатах обёртки
     * @return true если в области слотов
     */
    function isPointOverSlotArea(localX, localY) {
        if (!widgetInstance || !editMode) return false
        if (isWide) {
            return (localY > height - 30 && localY < height + 30)
        } else {
            return (localX > width - 30 && localX < width + 30)
        }
    }

    /**
     * Возвращает информацию о слоте в заданной точке
     * @param localX - X в локальных координатах обёртки
     * @param localY - Y в локальных координатах обёртки
     * @return { slotKey: string, slotDesc: string } или null
     */
    function getSlotAtPoint(localX, localY) {
        if (!widgetInstance || !editMode) return null
        const slotKeys = Object.keys(widgetInstance.exposedSlots)
        const slotCount = slotKeys.length
        if (slotCount === 0) return null
        if (isWide) {
            const centerY = height + 14
            const slotWidth = 26
            for (let i = 0; i < slotCount; i++) {
                const slotCenterX = (width / 2) + (i - (slotCount - 1) / 2) * slotWidth
                const left = slotCenterX - 9
                const right = slotCenterX + 9
                const top = centerY - 9
                const bottom = centerY + 9
                if (localX >= left && localX <= right && localY >= top && localY <= bottom) {
                    const key = slotKeys[i]
                    return {
                        slotKey: key,
                        slotDesc: widgetInstance.exposedSlots[key] || key
                    }
                }
            }
        } else {
            const centerX = width + 14
            const slotHeight = 26
            for (let i = 0; i < slotCount; i++) {
                const slotCenterY = (height / 2) + (i - (slotCount - 1) / 2) * slotHeight
                const left = centerX - 9
                const right = centerX + 9
                const top = slotCenterY - 9
                const bottom = slotCenterY + 9
                if (localX >= left && localX <= right && localY >= top && localY <= bottom) {
                    const key = slotKeys[i]
                    return {
                        slotKey: key,
                        slotDesc: widgetInstance.exposedSlots[key] || key
                    }
                }
            }
        }
        return null
    }
}
