// edit_mode_internal/EditableItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.item.dialog_resize_element

Item {
    id: wrapper
    property Item widgetInstance: null
    property string type: ""
    property real relX: 0.1
    property real relY: 0.1
    property real relW: 0.2
    property real relH: 0.2
    property bool isSelected: false
    property bool editMode: false
    property Item sceneContainer: null
    property var sceneController: null
    property Component widgetComponent: null
    property var widgetConfig: ({})

    // === ГЛОБАЛЬНЫЕ МЕНЕДЖЕРЫ ===
    property var connectionManager: null
    property var componentRegister: null

    property var sceneBus: null
    property var tooltip: null

    signal requestDelete()
    signal requestSelect(bool toggle)

    // === ГЕОМЕТРИЯ (ЗАВИСИТ ОТ sceneContainer) ===
    x: sceneContainer ? (relX * sceneContainer.width) : 0
    y: sceneContainer ? (relY * sceneContainer.height) : 0
    width: sceneContainer ? (relW * sceneContainer.width) : 0
    height: sceneContainer ? (relH * sceneContainer.height) : 0

    // === СВОЙСТВО ОРИЕНТАЦИИ ЭЛЕМЕНТА ===
    property bool isWide: width > height  // true = горизонтальный, false = вертикальный

    // === УСТАНОВКА ФОКУСА ПРИ ВЫДЕЛЕНИИ ===
    onIsSelectedChanged: {
        if (isSelected && editMode) {
            wrapper.forceActiveFocus()
        }
    }

    // === КОНТЕЙНЕР ДЛЯ ВИДЖЕТА ===
    Item {
        id: contentItem
        anchors.fill: parent
    }

    // === СОЗДАНИЕ ВИДЖЕТА ===
    Component.onCompleted: {
        if (!widgetComponent) {
            console.error("widgetComponent НЕ ПЕРЕДАН!")
            return
        }
        widgetInstance = widgetComponent.createObject(contentItem, widgetConfig)
        if (widgetInstance) {
            widgetInstance.anchors.fill = contentItem
            // 🔑 ДОБАВЛЯЕМ ПРОВЕРКУ И КОРРЕКЦИЮ ТИПА
            if (!widgetInstance.exposedSignals || typeof widgetInstance.exposedSignals !== 'object') {
                widgetInstance.exposedSignals = { "handModeActivated": "Ручной режим активирован" }
                console.warn("️ exposedSignals сброшен на объект по умолчанию")
            }
            if (!widgetInstance.exposedSlots || typeof widgetInstance.exposedSlots !== 'object') {
                widgetInstance.exposedSlots = { "setEnabled": "Включить", "setVisible": "Показать" }
                console.warn("️ exposedSlots сброшен на объект по умолчанию")
            }
        } else {
            console.error("Ошибка создания виджета из компонента")
        }
    }

    // === ОЧИСТКА РЕСУРСОВ ===
    Component.onDestruction: {
        if (widgetInstance) {
            if (widgetConfig.sceneBus?.unsubscribeAll && widgetConfig.id_widget) {
                widgetConfig.sceneBus.unsubscribeAll(widgetConfig.id_widget)
            }
            widgetInstance.destroy()
            widgetInstance = null
        }
        // if (connectionDialog?.visible) connectionDialog.close()
    }

    // === УМНАЯ РАМКА ===
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: editMode && (isSelected || hoverArea.containsMouse) ? 2 : 0
        border.color: isSelected ? "dodgerblue" : (hoverArea.containsMouse ? "gray" : "transparent")
        visible: editMode
        z: 100
    }

    // === ВЗАИМОДЕЙСТВИЕ ===
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

    // === ПЕРЕТАСКИВАНИЕ (ЗАВИСИТ ОТ sceneContainer) ===
    MouseArea {
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
            // 🔑 СИГНАЛ ОБНОВЛЕНИЯ ПОЗИЦИЙ УЖЕ СРАБОТАЕТ ЧЕРЕЗ onXChanged/onYChanged
        }
    }

    // === КЛАВИАТУРА ===
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

    // === КОНТЕКСТНОЕ МЕНЮ ===
    Menu {
        id: contextMenu
        MenuItem { text: "Удалить"; onTriggered: wrapper.requestDelete() }
        MenuItem { text: "Изменить размеры..."; onTriggered: resizeDialog.open() }
        MenuItem {
            text: "Связь"
            onTriggered: {
                if (connectionDialog) {
                    connectionDialog.setSourceWrapper(wrapper)
                    connectionDialog.open()
                } else {
                    console.error("DialogConnection не инициализирован!")
                }
            }
            enabled: connectionManager && componentRegister
        }
    }

    // === ДИАЛОГИ ===
    DialogResizeElement { id: resizeDialog; targetElement: wrapper }
    // DialogConnection {
    //     id: connectionDialog
    //     connectionManager: wrapper.connectionManager
    //     componentRegister: wrapper.componentRegister
    //     sceneBus: wrapper.sceneBus
    //     onOpened: {
    //         if (!sourceWrapper || sourceWrapper !== wrapper) {
    //             setSourceWrapper(wrapper)
    //         }
    //     }
    // }

    // === 🔑 ВЫЧИСЛЕНИЕ КОЛИЧЕСТВА КЛЮЧЕЙ В ОБЪЕКТАХ ===
    property int signalCount: {
        if (!widgetInstance || typeof widgetInstance.exposedSignals !== 'object') return 0
        return Object.keys(widgetInstance.exposedSignals).length
    }
    property int slotCount: {
        if (!widgetInstance || typeof widgetInstance.exposedSlots !== 'object') return 0
        return Object.keys(widgetInstance.exposedSlots).length
    }

    // 🟢 СИГНАЛЫ (зелёные) — АДАПТИВНОЕ РАСПОЛОЖЕНИЕ
    Repeater {
        id: signalsRepeater
        model: editMode ? signalCount : 0
        delegate: Rectangle {
            width: 18; height: 18
            color: "#4CAF50"; radius: 4
            z: 300
            property string signalKey: Object.keys(widgetInstance.exposedSignals)[index]
            property string signalDesc: widgetInstance.exposedSignals[signalKey] || signalKey
            x: wrapper.isWide ?
                (parent.width - width) / 2 + (index - (wrapper.signalCount - 1) / 2) * 26 :
                -22
            y: wrapper.isWide ?
                -22 :
                (parent.height - height) / 2 + (index - (wrapper.signalCount - 1) / 2) * 26
            MouseArea {
                id: signalMouseArea
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                hoverEnabled: true
                propagateComposedEvents: false
                acceptedButtons: Qt.LeftButton
                onEntered: {
                    if (wrapper.sceneController?.isDragging) {
                        wrapper.sceneController.setInvalidTarget()
                    }
                }
                onExited: {
                    if (wrapper.sceneController?.isDragging) {
                        wrapper.sceneController.clearInvalidTarget()
                    }
                }
                ToolTip {
                    id: signalTooltip
                    text: signalDesc
                    visible: signalMouseArea.containsMouse && signalDesc.length > 0
                    delay: 300
                }
                onPressed: (mouse) => {
                    if (sceneController && sceneController.managerLine) {
                        sceneController.managerLine.startDrag(
                            widgetInstance.id_widget,
                            signalKey,
                            mapToItem(sceneContainer, mouse.x, mouse.y)
                        )
                    }

                    mouse.accepted = true
                }
            }
            Rectangle {
                anchors.fill: parent
                color: "white"
                opacity: signalMouseArea.containsMouse ? 0.4 : 0
                radius: 4
                enabled: false
            }
            Text {
                anchors.centerIn: parent
                text: signalKey.substring(0, 2).toUpperCase()
                color: "white"
                font.pixelSize: 9
                font.bold: true
                font.family: "Courier New"
                rotation: wrapper.isWide ? 0 : -90
            }
        }
    }

    // 🟡 СЛОТЫ (жёлтые) — АДАПТИВНОЕ РАСПОЛОЖЕНИЕ
    Repeater {
        id: slotsRepeater
        model: editMode ? slotCount : 0
        delegate: Rectangle {
            width: 18; height: 18
            color: "#FFC107"; radius: 4
            z: 300
            property string slotKey: Object.keys(widgetInstance.exposedSlots)[index]
            property string slotDesc: widgetInstance.exposedSlots[slotKey] || slotKey
            x: wrapper.isWide ?
                (parent.width - width) / 2 + (index - (wrapper.slotCount - 1) / 2) * 26 :
                parent.width + 8
            y: wrapper.isWide ?
                parent.height + 8 :
                (parent.height - height) / 2 + (index - (wrapper.slotCount - 1) / 2) * 26
            MouseArea {
                id: slotMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                propagateComposedEvents: false
                acceptedButtons: Qt.LeftButton
                ToolTip {
                    id: slotTooltip
                    text: slotDesc
                    visible: slotMouseArea.containsMouse && slotDesc.length > 0
                    delay: 300
                }
                onEntered: {
                    if (sceneController.managerLine?.setDragTarget) {
                        sceneController.managerLine.setDragTarget(
                            widgetInstance.id_widget,
                            slotKey
                        )
                    }
                }

                onExited: {
                    if (sceneController.managerLine?.clearDragTarget) {
                        sceneController.managerLine.clearDragTarget()
                    }
                }

                onClicked: (mouse) => {
                    if (sceneController.managerLine?.endDrag) {
                        const pos = mapToItem(sceneContainer, mouse.x, mouse.y)
                        sceneController.managerLine.endDrag(pos)
                    }
                    mouse.accepted = true
                }
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: slotMouseArea.containsMouse ? 0.3 : 0
                radius: 4
                enabled: false
            }
            Text {
                anchors.centerIn: parent
                text: slotKey.substring(0, 2).toUpperCase()
                color: "black"
                font.pixelSize: 9
                font.bold: true
                font.family: "Courier New"
                rotation: wrapper.isWide ? 0 : -90
            }
        }
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
