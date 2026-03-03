// EditableItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import qml.content.main_window.center_widget.modes.edit_mode.dialog_resize_element

Item {
    id: wrapper

    // =====================================================
    // ОТНОСИТЕЛЬНАЯ ГЕОМЕТРИЯ (ЕДИНСТВЕННЫЙ ИСТОЧНИК ИСТИНЫ)
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
    property Item sceneContainer: null
    property var sceneController: null

    // =====================================================
    // СИГНАЛЫ
    // =====================================================

    signal requestDelete()
    signal requestSelect(bool toggle)

    // =====================================================
    // ПЕРЕВОД RELATIVE
    // =====================================================

    x: sceneContainer ? relX * sceneContainer.width : 0
    y: sceneContainer ? relY * sceneContainer.height : 0
    width: sceneContainer ? relW * sceneContainer.width : 0
    height: sceneContainer ? relH * sceneContainer.height : 0

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
        for (let i = contentItem.children.length - 1; i >= 0; i--) {
            contentItem.children[i].destroy()
        }

        if (!widget) {
            console.error("[EditableItem] setWidget: widget is null")
            return false
        }

        widget.parent = contentItem
        widget.anchors.fill = contentItem

        return true
    }

    Component.onDestruction: {
        for (let i = contentItem.children.length - 1; i >= 0; i--) {
            contentItem.children[i].destroy()
        }
    }

    // =====================================================
    // РАМКА ВЫДЕЛЕНИЯ
    // =====================================================
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: editMode && (isSelected || hoverArea.containsMouse) ? 2 : 0
        border.color: isSelected ? "dodgerblue"
                                 : (hoverArea.containsMouse ? "gray" : "transparent")
        visible: editMode
        z: 100
    }

    // =====================================================
    // ОБЛАСТЬ ВЫДЕЛЕНИЯ
    // =====================================================
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        propagateComposedEvents: true

        cursorShape: (editMode && isSelected) ? Qt.SizeAllCursor : Qt.ArrowCursor

        onClicked: (mouse) => {

            if (!editMode)
                return

            if (mouse.button === Qt.LeftButton) {
                const toggle = mouse.modifiers & Qt.ControlModifier
                wrapper.requestSelect(toggle)
                mouse.accepted = true
            }

            if (mouse.button === Qt.RightButton) {
                contextMenu.popup()
                mouse.accepted = true
            }
        }
    }

    // =====================================================
    // ПЕРЕТАСКИВАНИЕ
    // =====================================================
    MouseArea {
        anchors.fill: parent
        enabled: editMode && isSelected
        propagateComposedEvents: false
        cursorShape: (editMode && isSelected) ? Qt.SizeAllCursor : Qt.ArrowCursor

        property real dragOffsetX: 0
        property real dragOffsetY: 0

        onPressed: (mouse) => {
            dragOffsetX = mouse.x
            dragOffsetY = mouse.y
        }

        onPositionChanged: (mouse) => {

            if (!pressed || !sceneContainer)
                return

            let newX = wrapper.x + mouse.x - dragOffsetX
            let newY = wrapper.y + mouse.y - dragOffsetY

            // ограничение внутри сцены
            newX = Math.max(0, Math.min(sceneContainer.width  - wrapper.width,  newX))
            newY = Math.max(0, Math.min(sceneContainer.height - wrapper.height, newY))

            relX = newX / sceneContainer.width
            relY = newY / sceneContainer.height
        }
    }

    // =====================================================
    // КЛАВИАТУРНОЕ УПРАВЛЕНИЕ
    // =====================================================
    focus: isSelected

    Keys.onPressed: (event) => {

        if (!editMode || !isSelected || !sceneContainer)
            return

        const step = 0.01
        let changed = false

        switch (event.key) {
        case Qt.Key_Left:  relX -= step; changed = true; break
        case Qt.Key_Right: relX += step; changed = true; break
        case Qt.Key_Up:    relY -= step; changed = true; break
        case Qt.Key_Down:  relY += step; changed = true; break
        case Qt.Key_Delete:
            requestDelete()
            changed = true
            break
        }

        if (changed) {

            relX = Math.max(0, Math.min(1 - relW, relX))
            relY = Math.max(0, Math.min(1 - relH, relY))

            event.accepted = true
        }
    }

    // =====================================================
    // КОНТЕКСТНОЕ МЕНЮ
    // =====================================================
    Menu {
        id: contextMenu

        MenuItem {
            text: "Удалить"
            onTriggered: wrapper.requestDelete()
        }

        MenuItem {
            text: "Изменить размеры..."
            onTriggered: resizeDialog.open()
        }
    }

    // =====================================================
    // ДИАЛОГ ИЗМЕНЕНИЯ РАЗМЕРОВ
    // =====================================================
    DialogResizeElement {
        id: resizeDialog
        targetElement: wrapper
    }
}
