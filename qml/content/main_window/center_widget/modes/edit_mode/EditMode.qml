// EditMode.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import qml.managers
import qml.controls.elements_scene
import qml.content.main_window.center_widget.modes.edit_mode.panel_button_edit_mode
import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements

import "status_bar"

Item {
    id: root
    anchors.fill: parent

    // ============================================================
    // ОСНОВНЫЕ СВОЙСТВА
    // ============================================================
    property bool editMode: true

    // ============================================================
    // СВОЙСТВА ДОСТУПНЫЕ ИЗ ВНЕ
    // ============================================================
    property alias viewport: viewport
    property alias world: world

    // ==============================
    // Параметры ВЫДЕЛЕНИЯ (НОВОЕ!)
    // ==============================
    property bool selecting: false
    property point selectStart: Qt.point(0, 0)
    property point selectEnd: Qt.point(0, 0)

    // ==============================
    // Параметры камеры
    // ==============================
    property real zoom: 1.0
    property real minZoom: 0.2
    property real maxZoom: 5.0

    property real offsetX: 0
    property real offsetY: 0

    // ============================================================
    // НАСТРОЙКИ СЕТКИ
    // ============================================================
    property bool gridEnabled: false
    property int gridSpacing: 20
    property string gridColor: "#1a1a2e"
    property real gridOpacity: 0.3

    // ==============================
    // VIEWPORT
    // ==============================
    Item {
        id: viewport
        anchors.fill: parent
        clip: true

        // --------------------------------------------------------
        // СЕТКА
        // --------------------------------------------------------
        Item {
            id: gridLayer
            anchors.fill: parent
            z: 1

            Repeater {
                id: verticalRepeater
                model: root.gridEnabled
                       ? Math.ceil(gridLayer.width / root.gridSpacing)
                       : 0

                Rectangle {
                    x: index * root.gridSpacing
                    width: 1
                    height: gridLayer.height
                    color: root.gridColor
                    opacity: root.gridOpacity
                }
            }

            Repeater {
                id: horizontalRepeater
                model: root.gridEnabled
                       ? Math.ceil(gridLayer.height / root.gridSpacing)
                       : 0

                Rectangle {
                    y: index * root.gridSpacing
                    height: 1
                    width: gridLayer.width
                    color: root.gridColor
                    opacity: root.gridOpacity
                }
            }
        }

        // ==========================
        // WORLD
        // ==========================
        Item {
            id: world
            x: root.offsetX
            y: root.offsetY
            width: viewport.width
            height: viewport.height
            scale: root.zoom
            transformOrigin: Item.TopLeft
        }

        // ==========================
        // РАМКА МНОЖЕСТВЕННОГО ВЫДЕЛЕНИЯ (ОБЯЗАТЕЛЬНО ДОБАВИТЬ!)
        // ==========================
        Rectangle {
            id: selectionRect
            visible: root.selecting && editMode
            x: Math.min(root.selectStart.x, root.selectEnd.x)
            y: Math.min(root.selectStart.y, root.selectEnd.y)
            width: Math.abs(root.selectStart.x - root.selectEnd.x)
            height: Math.abs(root.selectStart.y - root.selectEnd.y)
            color: "#4088bbff"
            border.color: "#88bbff"
            border.width: 1
            radius: 2
            z: 999
        }

        // ==========================
        // УПРАВЛЕНИЕ МЫШЬЮ
        // ==========================
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            propagateComposedEvents: true

            property point lastPos: Qt.point(0, 0)
            property bool panning: false

            cursorShape: panning
                         ? Qt.ClosedHandCursor
                         : (root.selecting ? Qt.CrossCursor : Qt.ArrowCursor)

            // Поиск элемента под курсором
            function findElementAt(screenX, screenY) {
                const worldX = (screenX - root.offsetX) / root.zoom
                const worldY = (screenY - root.offsetY) / root.zoom

                for (let i = world.children.length - 1; i >= 0; i--) {
                    const child = world.children[i]
                    if (child && child.hasOwnProperty("relX") && child.hasOwnProperty("setWidget")) {
                        if (worldX >= child.x && worldX <= child.x + child.width &&
                            worldY >= child.y && worldY <= child.y + child.height) {
                            return child
                        }
                    }
                }
                return null
            }

            onPressed: (mouse) => {
                // Ctrl + ЛКМ → панорама
                if (mouse.modifiers & Qt.ControlModifier && mouse.button === Qt.LeftButton) {
                    panning = true
                    lastPos = Qt.point(mouse.x, mouse.y)
                    mouse.accepted = true
                    return
                }

                // Правая кнопка → контекстное меню сцены (только на пустом месте)
                if (mouse.button === Qt.RightButton) {
                    if (!findElementAt(mouse.x, mouse.y)) {
                        sceneContextMenu.popup(mouse.x, mouse.y)
                        mouse.accepted = true
                    }
                    return
                }

                // Левая кнопка на пустом месте → начинаем прямоугольное выделение
                if (mouse.button === Qt.LeftButton) {
                    const element = findElementAt(mouse.x, mouse.y)

                   if (!element) {
                       // пустое место
                       QmlSceneManager.deselectAll()

                       root.selecting = true
                       root.selectStart = Qt.point(mouse.x, mouse.y)
                       root.selectEnd = Qt.point(mouse.x, mouse.y)

                       mouse.accepted = true
                   } else {
                       // элемент сам обработает событие
                       mouse.accepted = false
                   }
                }
            }

            onPositionChanged: (mouse) => {
                // Панорама
                if (panning) {
                    let dx = mouse.x - lastPos.x
                    let dy = mouse.y - lastPos.y
                    root.offsetX += dx
                    root.offsetY += dy
                    lastPos = Qt.point(mouse.x, mouse.y)
                    return
                }

                // Прямоугольное выделение
                if (root.selecting) {
                    root.selectEnd = Qt.point(mouse.x, mouse.y)
                    mouse.accepted = true
                }
            }

            onReleased: (mouse) => {

                if (mouse.button === Qt.LeftButton)
                    panning = false

                if (!root.selecting)
                    return

                root.selecting = false

                const rectWidth = Math.abs(root.selectStart.x - root.selectEnd.x)
                const rectHeight = Math.abs(root.selectStart.y - root.selectEnd.y)

                if (rectWidth > 5 || rectHeight > 5) {

                    selectElementsInRect(
                        Math.min(root.selectStart.x, root.selectEnd.x),
                        Math.min(root.selectStart.y, root.selectEnd.y),
                        rectWidth,
                        rectHeight
                    )
                }

                root.selectStart = Qt.point(0,0)
                root.selectEnd = Qt.point(0,0)
            }


            onWheel: (wheel) => {
                if (!(wheel.modifiers & Qt.ControlModifier))
                    return

                wheel.accepted = true
                let oldZoom = root.zoom
                let factor = 1.15
                root.zoom = (wheel.angleDelta.y > 0)
                    ? Math.min(root.maxZoom, root.zoom * factor)
                    : Math.max(root.minZoom, root.zoom / factor)

                let worldX = (wheel.x - root.offsetX) / oldZoom
                let worldY = (wheel.y - root.offsetY) / oldZoom
                root.offsetX = wheel.x - worldX * root.zoom
                root.offsetY = wheel.y - worldY * root.zoom
            }
        }
    }

    // ==========================
    // КОНТЕКСТНОЕ МЕНЮ СЦЕНЫ
    // ==========================
    Menu {
        id: sceneContextMenu

        MenuItem {
            text: "Добавить элемент..."
            onTriggered: dialogAddElement.open()
        }
    }

    // ============================================================
    // ВЫДЕЛЕНИЕ ЭЛЕМЕНТОВ В ПРЯМОУГОЛЬНИКЕ
    // ============================================================
    function selectElementsInRect(x, y, width, height) {
        if (!world || !QmlSceneManager) return

        // Преобразуем экранные координаты в мировые
        const worldRect = {
            x: (x - root.offsetX) / root.zoom,
            y: (y - root.offsetY) / root.zoom,
            width: width / root.zoom,
            height: height / root.zoom
        }

        let anySelected = false

        // Проходим по всем обёрткам в обратном порядке (сверху вниз)
        for (let i = world.children.length - 1; i >= 0; i--) {
            const wrapper = world.children[i]

            // Проверяем, что это обёртка элемента сцены
            if (!wrapper || !wrapper.hasOwnProperty("relX") || !wrapper.hasOwnProperty("setWidget"))
                continue

            // Мировые координаты элемента
            const elemX = wrapper.x
            const elemY = wrapper.y
            const elemW = wrapper.width
            const elemH = wrapper.height

            // Проверка пересечения прямоугольников
            const intersects = !(
                elemX + elemW < worldRect.x ||
                elemX > worldRect.x + worldRect.width ||
                elemY + elemH < worldRect.y ||
                elemY > worldRect.y + worldRect.height
            )

            if (intersects) {
                QmlSceneManager.selectItem(wrapper, true)  // toggle=true для множественного выбора
                anySelected = true
            }
        }

        // Если ничего не выделено — снимаем все выделения
        if (!anySelected) {
            QmlSceneManager.deselectAll()
        }
    }

    // ============================================================
    // КЛАВИАТУРА
    // ============================================================
    focus: true
    Keys.onPressed: (event) => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
            QmlSceneManager.saveScene()
            event.accepted = true
        }
    }

    // ============================================================
    // ПРЕВЬЮ КОМПОНЕНТОВ
    // ============================================================
    PreviewComponents { id: previewComponents }

    // ============================================================
    // КОМПОНЕНТ-ОБЁРТКА
    // ============================================================
    Component {
        id: wrapperComponent
        EditableItem {
            editMode: root.editMode
            sceneContainer: world
            scene: viewport
            sceneController: root
        }
    }

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================
    Component.onCompleted: {
        QmlSceneManager.configure({
            sceneController: root,
            sceneContainer: world,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,
            panelRect: root.panelRect,
            editMode: root.editMode
        })

        QmlSceneManager.loadScene()
    }

    // ============================================================
    // ДИАЛОГ ДОБАВЛЕНИЯ ЭЛЕМЕНТА
    // ============================================================
    DialogAddElements {
        id: dialogAddElement
        sceneController: root
        onSignalAddElement: (data) => {
            QmlSceneManager.addItemToScene(data)
        }
    }

    // ============================================================
    // ПАНЕЛЬ УПРАВЛЕНИЯ
    // ============================================================
    property rect panelRect: Qt.rect(
        panelButtons.x,
        panelButtons.y,
        panelButtons.width,
        panelButtons.height
    )
    PanelButtonEditMode {
        id: panelButtons
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 15

        onSignalGridEnable: (check) => { toggleGrid(check) }
        onSignalClearScenes: QmlSceneManager.clearScene()
        onAddElementRequested: dialogAddElement.open()
        onSignalSave: QmlSceneManager.saveScene()
    }

    // =========================================================================
    // ИЗМЕНЕНИЕ НАСТРОЕК СЕТКИ
    // =========================================================================
    function toggleGrid(enabled) {
        root.gridEnabled = enabled
    }

    function setGridSpacing(spacing) {
        root.gridSpacing = Math.max(10, Math.min(100, spacing))
    }

    // ============================================================
    // РАМКА РЕЖИМА (для визуального отличия edit режима)
    // ============================================================
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "green"
        border.width: 2
        radius: 4
        z: 1000
    }

    // ============================================================
    // Статус бар
    // ============================================================
    StatusBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        zoomScene: root.zoom
    }
}
