// EditableItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.managers
import qml.content.main_window.center_widget.modes.edit_mode.dialog_resize_element

Item {
    id: wrapper

    property var widget: null

    // =====================================================
    // ОТНОСИТЕЛЬНАЯ ГЕОМЕТРИЯ
    // =====================================================
    property var geometry: ({ relX: 0.1, relY: 0.1, relW: 0.2, relH: 0.2 })
    property real relX: geometry.relX
    property real relY: geometry.relY
    property real relW: geometry.relW
    property real relH: geometry.relH

    // =====================================================
    // СОСТОЯНИЕ
    // =====================================================
    property var state: ({ isSelected: false, editMode: false })
    property bool isSelected: state.isSelected
    property bool editMode: state.editMode

    // =====================================================
    // СЦЕНА
    // =====================================================
    property Item scene: null
    property Item sceneContainer: null
    property var sceneController: null

    // =====================================================
    // СИГНАЛЫ
    // =====================================================
    signal requestDelete()
    signal requestSelect(bool toggle)

    // =====================================================
    // ПЕРЕВОД В ПИКСЕЛИ
    // =====================================================
    x: sceneController?.viewport ? relX * sceneController.viewport.width : 0
    y: sceneController?.viewport ? relY * sceneController.viewport.height : 0
    width: sceneController?.viewport ? relW * sceneController.viewport.width : 0
    height: sceneController?.viewport ? relH * sceneController.viewport.height : 0

    // =====================================================
    // КОНТЕЙНЕР ДЛЯ ВИДЖЕТА
    // =====================================================
    Item {
        id: contentItem
        anchors.fill: parent
    }

    // =====================================================
    // УСТАНОВКА ВИДЖЕТА
    // =====================================================
    function setWidget(widget) {
        // удаляем старый
        wrapper.widget = null
        for (let i = contentItem.children.length - 1; i >= 0; i--) {
            contentItem.children[i].destroy()
        }

        if (!widget) {
            wrapper.widget = null
            console.error("[EditableItem] setWidget: widget is null")
            return false
        }

        widget.parent = contentItem
        widget.anchors.fill = contentItem
        wrapper.widget = widget
        return true
    }

    // =====================================================
    // РАМКА ВЫДЕЛЕНИЯ
    // =====================================================
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: editMode && (isSelected || hoverArea.containsMouse) ? 2 : 0
        border.color: isSelected ? "dodgerblue" : (hoverArea.containsMouse ? "gray" : "transparent")
        visible: editMode && isSelected
        z: 100
    }

    // =====================================================
    // ОБЛАСТЬ ВЫДЕЛЕНИЯ (множественное выделение и добавление выделения или снятие выделение элемента Shift+клик)
    // =====================================================

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        visible: editMode
        enabled: editMode
        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: isSelected ? Qt.SizeAllCursor : Qt.ArrowCursor

        property real dragOffsetX: 0
        property real dragOffsetY: 0
        property bool dragging: false

        onPressed: (mouse) => {

            if (mouse.button !== Qt.LeftButton)
                return

            dragOffsetX = mouse.x
            dragOffsetY = mouse.y
            dragging = false

            const shift = mouse.modifiers & Qt.ShiftModifier

            if (shift) {
                const toggle = mouse.modifiers & Qt.ShiftModifier
                wrapper.requestSelect(toggle)
                mouse.accepted = true
            }
        }

        onClicked: (mouse) => {

            if (mouse.button === Qt.RightButton && QmlSceneManager.selectedItems.length < 2) {
                contextMenu.popup()
                mouse.accepted = true
                return
            }
        }

        onPositionChanged: (mouse) => {

            if (!(mouse.buttons & Qt.LeftButton))
                return

            if (!sceneController || !sceneController.viewport)
                return

            const deltaX = mouse.x - dragOffsetX
            const deltaY = mouse.y - dragOffsetY

            if (!dragging) {
                if (Math.abs(deltaX) < 2 && Math.abs(deltaY) < 2)
                    return
                dragging = true
            }

            const itemsToMove = QmlSceneManager.selectedItems.length > 1 ? QmlSceneManager.selectedItems.slice() : [wrapper]

            for (let i = 0; i < itemsToMove.length; i++) {

                const item = itemsToMove[i]
                if (!item || !item.sceneController || !item.sceneController.viewport)
                    continue

                   const viewport = item.sceneController.viewport

                   let newX = item.x + deltaX
                   let newY = item.y + deltaY

                   item.relX = newX / viewport.width
                   item.relY = newY / viewport.height
            }
        }

        onReleased: () => {
            dragging = false
        }
    }

    // =====================================================
    // КЛАВИАТУРНОЕ УПРАВЛЕНИЕ
    // =====================================================
    focus: isSelected

    Keys.onPressed: (event) => {
            if (!editMode || !isSelected || !sceneContainer || !sceneController?.viewport)
                return

            const step = 0.01
            let changed = false

            // Определяем, какие элементы перемещать: все выделенные или только текущий
            const itemsToMove = QmlSceneManager.selectedItems.length > 1
                              ? QmlSceneManager.selectedItems.slice()
                              : [wrapper]

            switch (event.key) {
            case Qt.Key_Left:
                itemsToMove.forEach(item => {
                    item.relX = Math.max(0, item.relX - step)
                })
                changed = true
                break
            case Qt.Key_Right:
                itemsToMove.forEach(item => {
                    item.relX = Math.min(1 - item.relW, item.relX + step)
                })
                changed = true
                break
            case Qt.Key_Up:
                itemsToMove.forEach(item => {
                    item.relY = Math.max(0, item.relY - step)
                })
                changed = true
                break
            case Qt.Key_Down:
                itemsToMove.forEach(item => {
                    item.relY = Math.min(1 - item.relH, item.relY + step)
                })
                changed = true
                break
            case Qt.Key_Delete:
                // Удаляем ТОЛЬКО текущий элемент (как в проводнике Windows)
                requestDelete()
                changed = true
                break
            }

            if (changed) {
                event.accepted = true
            }
        }

    // =====================================================
    // КОНТЕКСТНОЕ МЕНЮ
    // =====================================================
    Menu {
        id: contextMenu

        MenuItem {
            text: "Изменить размеры..."
            onTriggered: resizeDialog.open()
        }

        MenuItem {
            text: "Удалить"
            onTriggered: wrapper.requestDelete()
        }
    }

    // =====================================================
    // ДИАЛОГ ИЗМЕНЕНИЯ РАЗМЕРОВ
    // =====================================================
    DialogResizeElement {
        id: resizeDialog
        targetElement: wrapper
        parent: wrapper.scene
    }
}
