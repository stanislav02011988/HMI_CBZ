// qml\content\logic_window\edit_logic\component\scene\LogicScene.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.managers
import qml.controls.elements_scene

import "panel_btn"
import "grid_layer"

Item {
    id: root

    // =====================================================
    // Статус открытия окна режима редактирования логики
    // =====================================================
    property bool stateWindow: false

    // =====================================================
    // РЕЖИМ FALSE - RUN MODE TRUE - EDIT MODE
    // =====================================================
    property bool editMode: false
    // =====================================================
    // Флаг произошла ли загрузка сцены выбранного файла
    // =====================================================
    property bool isLoadFilePrograms: QmlLogicMapScene.isLoadFilePrograms

    // ============================================================
    // СВОЙСТВА ДОСТУПНЫЕ ИЗ ВНЕ
    // ============================================================
    property alias viewport: viewport
    property alias world: world

    // ==============================
    // Параметры ВЫДЕЛЕНИЯ
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

    Rectangle {
        id: bg
        color: "white"
        radius: 6
        anchors.fill: parent
        anchors.margins: 6

        // --------------------------------------------------------
        // СЕТКА
        // --------------------------------------------------------
        GridLayer { id: gridLayer }

        Rectangle {
            id: emptyPreview
            anchors.fill: parent
            color: "transparent"
            visible: !isLoadFilePrograms
            radius: 6
            Text {
                anchors.fill: parent
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Данные отсутствуют или вы не выбрали файл")
            }
        }

        // ==============================
        // VIEWPORT
        // ==============================
        Item {
            id: viewport
            anchors.fill: parent
            clip: true

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
        }

        // ==========================
        // РАМКА МНОЖЕСТВЕННОГО ВЫДЕЛЕНИЯ
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
            hoverEnabled: false
            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true

            property point lastPos
            property bool panning: false

            cursorShape: panning
                         ? Qt.ClosedHandCursor
                         : Qt.ArrowCursor

            onPressed: (mouse) => {

                const ctrl = mouse.modifiers & Qt.ControlModifier

                // Ctrl + ЛКМ → панорама
                if (ctrl && mouse.button === Qt.LeftButton) {
                    panning = true
                    lastPos = Qt.point(mouse.x, mouse.y)
                    mouse.accepted = true
                    return
                }

                // ЛКМ без Ctrl → пока НЕ принимаем
                mouse.accepted = false
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.LeftButton)
                    panning = false
            }

            onPositionChanged: (mouse) => {

                if (!panning)
                    return

                let dx = mouse.x - lastPos.x
                let dy = mouse.y - lastPos.y

                root.offsetX += dx
                root.offsetY += dy

                lastPos = Qt.point(mouse.x, mouse.y)
            }

            onWheel: (wheel) => {

                if (!(wheel.modifiers & Qt.ControlModifier))
                    return

                wheel.accepted = true

                let oldZoom = root.zoom
                let factor = 1.15

                if (wheel.angleDelta.y > 0)
                    root.zoom *= factor
                else
                    root.zoom /= factor

                root.zoom = Math.max(root.minZoom,
                                     Math.min(root.maxZoom, root.zoom))

                let mouseX = wheel.x
                let mouseY = wheel.y

                let worldX = (mouseX - root.offsetX) / oldZoom
                let worldY = (mouseY - root.offsetY) / oldZoom

                root.offsetX = mouseX - worldX * root.zoom
                root.offsetY = mouseY - worldY * root.zoom
            }

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton &&
                    !(mouse.modifiers & Qt.ControlModifier)) {
                    QmlLogicMapScene.deselectAll()
                }
            }
        }
    }

    // ============================================================
    // КОМПОНЕНТ-ОБЁРТКА
    // ============================================================
    Component {
        id: wrapperComponent
        ItemLogicScene {
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
        QmlLogicMapScene.configure({
            sceneController: root,
            sceneContainer: world,
            wrapperComponent: wrapperComponent,
            previewComponents: previewComponents,
            panelRect: root.panelRect,
            editMode: root.editMode
        })
        QmlLogicMapScene.loadPrograms("main")
    }

    // ============================================================
    // ПРЕВЬЮ КОМПОНЕНТОВ
    // ============================================================
    PreviewComponents { id: previewComponents }

    // ==========================
    // КОНТЕКСТНОЕ МЕНЮ СЦЕНЫ
    // ==========================
    Menu {
        id: sceneContextMenu

        MenuItem {
            text: "Добавить элемент..."
            onTriggered: console.log("Вызов диалогового окна добаления элементов")
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
                QmlLogicMapScene.selectItem(wrapper, true)  // toggle=true для множественного выбора
                anySelected = true
            }
        }

        // Если ничего не выделено — снимаем все выделения
        if (!anySelected) {
            QmlLogicMapScene.deselectAll()
        }
    }

    // ============================================================
    // КЛАВИАТУРА
    // ============================================================
    focus: true
    Keys.onPressed: (event) => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
            QmlLogicMapScene.saveScene()
            event.accepted = true
        }
    }

    // ==========================
    // Панель Кнопок
    // ==========================
    property rect panelRect: Qt.rect(
        panelBtn.x,
        panelBtn.y,
        panelBtn.width,
        panelBtn.height
    )

    PanelBauttons {
        id: panelBtn
        width: 60
        height: 100
        anchors.top: bg.top
        anchors.right: bg.right
        anchors.topMargin: 10
        anchors.rightMargin: 10

        editMode: root.editMode
        onSignalActivateGridLayer: (check) => gridLayer.toggleGrid(check)
        onSignalActivateEditeMode: (check) => root.editMode = check
        onSignalSaveSceneLogicMap: QmlLogicMapScene.saveScene()
    }
}
