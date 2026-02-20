// edit_mode_internal/EditModeInternal.qml
// ============================================================================
// ГЛАВНЫЙ КОНТЕЙНЕР РЕЖИМА РЕДАКТИРОВАНИЯ
// ============================================================================
// Координирует все менеджеры и элементы сцены
// Оптимизировано для 2000+ правил с группировкой по назначению
// ============================================================================

import QtQuick
import QtQuick.Controls

// === КОМПОНЕНТЫ ===
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_preview
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.edit_mode_internal.internal.manager_line

Item {
    id: root
    anchors.fill: parent

    // =========================================================================
    // ГРУППИРОВАННЫЕ СВОЙСТВА (ВАРИАНТ A)
    // =========================================================================

    // ─── МЕНЕДЖЕРЫ ──────────────────────────────────────────────────────────
    // Передаются из главного окна, используются всеми компонентами сцены
    property var managers: ({
        signalBus: null,
        componentRegister: null,
        connectionManager: null
    })

    // ─── ГЕОМЕТРИЯ СЕТКИ ────────────────────────────────────────────────────
    // Настройки отображения фоновой сетки
    property var grid: ({
        enabled: false,
        spacing: 20,
        color: "#1a1a2e",
        opacity: 0.3
    })

    // ─── СОСТОЯНИЕ СЦЕНЫ ────────────────────────────────────────────────────
    // Текущее состояние редактора
    property var state: ({
        isModified: false,
        selectedItems: [],
        rulesArray: []
    })

    // ─── ДЛЯ ОБРАТНОЙ СОВМЕСТИМОСТИ (алиасы к группированным свойствам) ───
    // Можно удалить после полного перехода на новую структуру
    property var signalBus: managers.signalBus
    property var componentRegister: managers.componentRegister
    property var connectionManager: managers.connectionManager
    property var selectedItems: state.selectedItems
    property var rulesArray: state.rulesArray
    property bool isModified: state.isModified
    property bool gridEnabled: grid.enabled
    property int gridSpacing: grid.spacing
    property color gridColor: grid.color

    // =========================================================================
    // ССЫЛКИ НА КОМПОНЕНТЫ
    // =========================================================================
    property alias managerLine: managerLine
    property alias previewComponents: previewComponents

    // =========================================================================
    // СИГНАЛЫ
    // =========================================================================
    signal itemAdded(var item)
    signal itemRemoved(var item)
    signal sceneSaveRequested(var data)
    signal signalListIdScene(var list)

    // =========================================================================
    // СЛОЙ СЦЕНЫ
    // =========================================================================
    Item {
        id: sceneLayer
        anchors.fill: parent
        clip: true

        // --- СЕТКА ---
        Repeater {
            model: grid.enabled ? Math.ceil(sceneLayer.width / grid.spacing) : 0
            Rectangle {
                x: index * grid.spacing
                width: 1
                height: sceneLayer.height
                color: grid.color
                opacity: grid.opacity
            }
        }
        Repeater {
            model: grid.enabled ? Math.ceil(sceneLayer.height / grid.spacing) : 0
            Rectangle {
                y: index * grid.spacing
                height: 1
                width: sceneLayer.width
                color: grid.color
                opacity: grid.opacity
            }
        }

        // --- ФОН (сброс выделения) ---
        MouseArea {
            id: backgroundMouseArea
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
            onClicked: (mouse) => {
                deselectAll()
                mouse.accepted = true
            }
        }

        // --- МЕНЕДЖЕР СТРЕЛОК ---
        ManagerLine {
            id: managerLine
            anchors.fill: parent
            rulesArray: root.rulesArray
            componentRegister: root.componentRegister
            connectionManager: root.connectionManager
            sceneLayer: sceneLayer
        }
    }

    // =========================================================================
    // КЛАВИАТУРА
    // =========================================================================
    Keys.onPressed: (event) => {
        // Escape — отмена операции
        if (event.key === Qt.Key_Escape) {
            if (managerLine.dragState === 1) {
                managerLine.cleanupDrag()
            } else if (managerLine.dragState === 2 && managerLine.confirmDialog?.visible) {
                managerLine.confirmDialog.close()
                managerLine.cleanupDrag()
            }
            event.accepted = true
        }
        // Ctrl+S — сохранение
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
            saveSceneToFile()
            event.accepted = true
        }
    }

    // =========================================================================
    // ПРЕВЬЮ КОМПОНЕНТОВ
    // =========================================================================
    PreviewComponents { id: previewComponents }

    // =========================================================================
    // КОМПОНЕНТ ОБЁРТКИ
    // =========================================================================
    Component {
        id: editableWrapperComponent
        EditableItem {
            editMode: true
            sceneContainer: sceneLayer
            sceneController: root

            // === ПЕРЕДАЧА МЕНЕДЖЕРОВ (ГРУППИРОВАННО) ===
            signalBus: root.signalBus
            connectionManager: root.connectionManager
            componentRegister: root.componentRegister
        }
    }

    // =========================================================================
    // ИНИЦИАЛИЗАЦИЯ
    // =========================================================================
    Component.onCompleted: {
        console.log(" EditModeInternal инициализирован")

        if (connectionManager && Array.isArray(connectionManager.rules)) {
            state.rulesArray = connectionManager.rules.slice()
            console.log(` rulesArray инициализирован: ${state.rulesArray.length} связей`)
        }
    }

    // =========================================================================
    // СЛЕЖЕНИЕ ЗА ИЗМЕНЕНИЯМИ ПРАВИЛ
    // =========================================================================
    Connections {
        target: managers.connectionManager
        function onSignalRules() {
            if (connectionManager && Array.isArray(connectionManager.rules)) {
                state.rulesArray = connectionManager.rules.slice()
            } else {
                state.rulesArray = []
            }
        }
    }

    // =========================================================================
    // ДОБАВЛЕНИЕ ЭЛЕМЕНТА
    // =========================================================================
    function addItemToScene(data) {
        // === ПРОВЕРКА ДАННЫХ ===
        if (!data || !data.subtype) {
            console.error(" Некорректные данные элемента")
            return null
        }

        // === ПОЛУЧЕНИЕ КОМПОНЕНТА ===
        const component = previewComponents.getPreviewComponent(data.subtype)
        if (!component) {
            console.error(` Компонент не найден: ${data.subtype}`)
            return null
        }

        // === РАСЧЁТ РАЗМЕРОВ ===
        const isSilos = (data.subtype === "silos_vertical")
        const geometry = {
            relW: isSilos ? 0.05 : 0.1,
            relH: isSilos ? 0.25 : 0.1
        }
        const offset = (componentRegister?.elements.length || 0) * 0.15

        // === СОЗДАНИЕ ОБЁРТКИ (С ГРУППИРОВАННЫМИ СВОЙСТВАМИ) ===
        const wrapper = editableWrapperComponent.createObject(sceneLayer, {
            geometry: {
                relX: Math.min(0.7, 0.1 + (offset % 0.6)),
                relY: Math.min(0.7, 0.15 + (offset * 0.5) % 0.6),
                relW: geometry.relW,
                relH: geometry.relH
            },
            widgetData: {
                type: data.subtype,
                id_widget: data.id_widget,      // ← СОХРАНЯЕМ id_widget
                name_widget: data.name_widget,  // ← СОХРАНЯЕМ name_widget
                component: component
            },
            state: {
                isSelected: false,
                editMode: true
            },
            managers: {
                signalBus: root.signalBus,
                connectionManager: root.connectionManager,
                componentRegister: root.componentRegister
            }

        })

        // === ПРОВЕРКА СОЗДАНИЯ ===
        if (!wrapper || !wrapper.widgetInstance) {
            console.error(` Ошибка создания обёртки или виджета: ${data.id_widget}`)
            if (wrapper) wrapper.destroy()
            return null
        }

        // === РЕГИСТРАЦИЯ ===
        if (componentRegister) {
            if (!componentRegister.registerElement(wrapper, data, wrapper.widgetInstance)) {
                console.warn(`️ Не удалось зарегистрировать элемент: ${data.id_widget}`)
                wrapper.destroy()
                return null
            }
        }

        // === ПОДКЛЮЧЕНИЕ СИГНАЛОВ ===
        wrapper.requestSelect.connect((toggle) => selectItem(wrapper, toggle))
        wrapper.requestDelete.connect(() => removeItem(wrapper))

        // === ОБНОВЛЕНИЕ СОСТОЯНИЯ ===
        state.isModified = true
        itemAdded(wrapper)
        signalListIdScene(componentRegister?.getAllIds() || [])

        console.log(` Элемент добавлен: ${data.id_widget} (${data.subtype})`)
        console.log(`   Всего элементов: ${componentRegister?.elements.length || 0}`)

        return wrapper
    }

    // =========================================================================
    // УДАЛЕНИЕ ЭЛЕМЕНТА
    // =========================================================================
    function removeItem(wrapper) {
        if (!wrapper || !componentRegister) {
            console.warn("️ removeItem: wrapper или componentRegister не инициализированы")
            return
        }

        const widget = wrapper.widgetInstance
        const elementId = widget?.id_widget

        console.log(`️ Удаление элемента: ${elementId || "unknown"}`)

        // === УДАЛЕНИЕ СВЯЗЕЙ ===
        if (elementId && connectionManager) {
            connectionManager.removeConnectionsForElement(elementId)
        }

        // === УДАЛЕНИЕ ИЗ РЕГИСТРА ===
        componentRegister.unregisterElement(wrapper)

        // === УНИЧТОЖЕНИЕ ===
        wrapper.destroy()

        // === ОБНОВЛЕНИЕ СОСТОЯНИЯ ===
        itemRemoved(wrapper)
        state.isModified = true
        signalListIdScene(componentRegister.getAllIds())

        console.log(` Элемент удалён: ${elementId || "unknown"}`)
    }

    // =========================================================================
    // ВЫДЕЛЕНИЕ
    // =========================================================================
    function deselectAll() {
        for (let i = 0; i < state.selectedItems.length; i++) {
            state.selectedItems[i].isSelected = false
        }
        state.selectedItems = []
    }

    function selectItem(wrapper, toggle = false) {
        if (toggle && state.selectedItems.includes(wrapper)) {
            wrapper.isSelected = false
            state.selectedItems.splice(state.selectedItems.indexOf(wrapper), 1)
        } else if (toggle) {
            wrapper.isSelected = true
            state.selectedItems.push(wrapper)
        } else {
            deselectAll()
            wrapper.isSelected = true
            state.selectedItems.push(wrapper)
        }

        if (wrapper && wrapper.forceActiveFocus) {
            wrapper.forceActiveFocus()
        }
    }

    // =========================================================================
    // ОЧИСТКА СЦЕНЫ
    // =========================================================================
    function clearScene() {
        console.log(" Очистка сцены")

        if (componentRegister) componentRegister.clear()
        if (connectionManager) connectionManager.clear()

        for (let i = sceneLayer.children.length - 1; i >= 0; i--) {
            const child = sceneLayer.children[i]
            if (child.hasOwnProperty("requestDelete")) {
                child.destroy()
            }
        }

        state.isModified = false
        state.selectedItems = []
        state.rulesArray = []
        signalListIdScene([])

        console.log(" Сцена очищена")
    }

    // =========================================================================
    // СОХРАНЕНИЕ
    // =========================================================================
    function saveSceneToFile() {
        if (!state.isModified || !componentRegister) {
            console.log("️ Нет изменений для сохранения")
            return
        }

        const sceneData = componentRegister.exportSceneData()
        const connectionData = connectionManager.rules.slice()

        sceneSaveRequested({
            elements: sceneData,
            connections: connectionData,
            timestamp: new Date().toISOString()
        })

        state.isModified = false

        console.log(` Сцена сохранена: ${sceneData.length} элементов, ${connectionData.length} связей`)
    }

    // =========================================================================
    // СТАТИСТИКА
    // =========================================================================
    function getSceneStats() {
        return {
            elements: componentRegister?.getCount() || 0,
            connections: connectionManager?.rules?.length || 0,
            subscriptions: signalBus?.subscriptionCount || 0,
            modified: state.isModified
        }
    }

    // =========================================================================
    // ИЗМЕНЕНИЕ НАСТРОЕК СЕТКИ
    // =========================================================================
    function toggleGrid(enabled) {
        grid.enabled = enabled
        console.log(` Сетка: ${enabled ? "включена" : "выключена"}`)
    }

    function setGridSpacing(spacing) {
        grid.spacing = Math.max(10, Math.min(100, spacing))
    }

    // =========================================================================
    // ИЗМЕНЕНИЕ СОСТОЯНИЯ
    // =========================================================================
    function setModified(modified) {
        state.isModified = modified
    }
}
