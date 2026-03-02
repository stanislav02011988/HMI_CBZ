// ============================================================================
// EditMode.qml
// Режим редактирования сцены
// Полностью самодостаточная версия без EditModeInternal
// ============================================================================

import QtQuick
import QtQuick.Controls

import qml.settings.project_settings
import qml.managers
import "edit_mode_internal"

import qml.content.main_window.center_widget.modes.edit_mode.panel_button_edit_mode
import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements
import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements.element_preview

Item {
    id: root
    anchors.fill: parent

    // ============================================================
    // ОСНОВНЫЕ СВОЙСТВА
    // ============================================================

    property bool editMode: true

    property var componentRegister: QmlRegisterComponentObject
    property var projectSettings: QmlProjectSettings

    // список выбранных элементов (используется менеджером)
    property var selectedItems: []

    // ============================================================
    // НАСТРОЙКИ СЕТКИ
    // ============================================================
    property bool gridEnabled: false
    property int gridSpacing: 20
    property string gridColor: "#1a1a2e"
    property real gridOpacity: 0.3

    // ============================================================
    // КОРНЕВОЙ КОНТЕЙНЕР СЦЕНЫ
    // ============================================================
    // ВАЖНО:
    // Мы разделяем сцену на слои:
    // 1) backgroundLayer
    // 2) gridLayer
    // 3) elementsLayer
    // Это предотвращает перекрытие MouseArea и проблем с drag
    // ============================================================

    Item {
        id: sceneRoot
        anchors.fill: parent
        clip: true

        // --------------------------------------------------------
        // СЕТКА (рисуется поверх фона)
        // --------------------------------------------------------
        Item {
            id: gridLayer
            anchors.fill: parent
            z: 1

            // Вертикальные линии
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

            // Горизонтальные линии
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

        // --------------------------------------------------------
        // СЛОЙ ЭЛЕМЕНТОВ (ВСЕ EditableItem создаются здесь)
        // --------------------------------------------------------
        Item {
            id: elementsLayer
            anchors.fill: parent
            z: 5
        }

        // --------------------------------------------------------
        // КЛИК ПО ФОНУ (СБРОС ВЫДЕЛЕНИЯ)
        // --------------------------------------------------------
        MouseArea {
            anchors.fill: parent
            z: 0
            propagateComposedEvents: true

            onClicked: {
                QmlSceneManager.deselectAll()
            }
        }
    }

    // ============================================================
    // КЛАВИАТУРА
    // ============================================================
    focus: true
    Keys.onPressed: (event) => {
        // Ctrl + S — сохранение сцены
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
            QmlSceneManager.saveScene()
            event.accepted = true
        }
    }

    // ============================================================
    // ПРЕВЬЮ КОМПОНЕНТОВ (фабрика виджетов)
    // ============================================================
    PreviewComponents { id: previewComponents }

    // ============================================================
    // КОМПОНЕНТ-ОБЁРТКА
    // ============================================================
    // Каждый элемент сцены создаётся через этот Component
    // ============================================================

    Component {
        id: editableWrapperComponent
        EditableItem {
            editMode: root.editMode
            sceneContainer: elementsLayer
        }
    }

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================

    Component.onCompleted: {

        QmlSceneManager.configure({
            componentRegister: componentRegister,
            projectSettings: projectSettings,
            sceneContainer: elementsLayer,
            wrapperComponent: editableWrapperComponent,
            previewComponents: previewComponents,
            editModeRoot: root,
            editMode: root.editMode
        })

        QmlSceneManager.loadScene()
    }

    // =========================================================================
    // ИЗМЕНЕНИЕ НАСТРОЕК СЕТКИ
    // =========================================================================
    function toggleGrid(enabled) {
        root.gridEnabled = enabled
        // console.log(` Сетка: ${enabled ? "включена" : "выключена"}`)
    }

    function setGridSpacing(spacing) {
        root.gridSpacing = Math.max(10, Math.min(100, spacing))
    }

    // ============================================================
    // ДИАЛОГ ДОБАВЛЕНИЯ ЭЛЕМЕНТА
    // ============================================================

    DialogAddElements {
        id: dialogAddElement
        sceneController: root

        onSignalAddElement: (data) => {
            addItemToScene(data)
        }
    }

    // ============================================================
    // ПАНЕЛЬ УПРАВЛЕНИЯ
    // ============================================================

    PanelButtonEditMode {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 15

        onSignalGridEnable: (check) => { toggleGrid(check) }
        onSignalClearScenes: QmlSceneManager.clearScene()
        onAddElementRequested: dialogAddElement.open()
        onSignalSave: QmlSceneManager.saveScene()
    }

    // ============================================================
    // РАМКА РЕЖИМА (для визуального отличия edit режима)
    // ============================================================

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "green"
        border.width: 2
        z: 1000
    }

    // =========================================================================
    // ДОБАВЛЕНИЕ ЭЛЕМЕНТА
    // =========================================================================
    // Фабрика для создания виджетов
    function createWidget(type, data) {
        const component = previewComponents.getPreviewComponent(type)
        if (!component) {
            console.error(`[ERR] Компонент не найден: ${type}`)
            return null
        }
        return component.createObject(null, data)
    }

    // Вычисление геометрии
    function computeGeometry(data) {
        const isSilos = data.subtype === "silos_vertical"
        const relW = isSilos ? 0.05 : 0.1
        const relH = isSilos ? 0.25 : 0.1
        const offset = (componentRegister?.count || 0) * 0.15
        return {
            relX: Math.min(0.7, 0.1 + (offset % 0.6)),
            relY: Math.min(0.7, 0.15 + ((offset * 0.5) % 0.6)),
            relW, relH
        }
    }

    // Регистрация обёртки и подключение сигналов
    function registerWrapper(wrapper, widget) {
        if (!componentRegister) return true
        if (!componentRegister.registerElement(wrapper, widget)) {
            console.warn(`[WARN] Не удалось зарегистрировать: ${widget.id_widget}`)
            wrapper.destroy()
            return false
        }

        wrapper.requestSelect.connect((toggle) => QmlSceneManager.selectItem(wrapper, toggle))
        wrapper.requestDelete.connect(() => QmlSceneManager.removeItem(wrapper))
        return true
    }

    // Основная функция добавления
    function addItemToScene(data) {
        if (!data?.subtype) {
            console.error("[ERR] Некорректные данные элемента")
            return null
        }

        // Создаём виджет заранее
        const widget = createWidget(data.subtype, {
            id_widget: data.id_widget,
            name_widget: data.name_widget,
            componentGroupe: data.componentGroupe,
            subtype: data.subtype
        })
        if (!widget) return null

        // Создаём обёртку
        const wrapper = editableWrapperComponent.createObject(elementsLayer, {
            geometry: computeGeometry(data),
            sceneContainer: elementsLayer,
            sceneController: root
        })

        if (!wrapper) {
            console.error("[ERR] Не удалось создать EditableItem")
            widget.destroy()
            return null
        }

        // Устанавливаем виджет внутрь обёртки
        wrapper.setWidget(widget)

        // Регистрация и подключение сигналов
        if (!registerWrapper(wrapper, widget)) return null

        console.log(`[OK] Элемент добавлен: ${data.id_widget} (${data.subtype})`)
        return wrapper
    }
}
