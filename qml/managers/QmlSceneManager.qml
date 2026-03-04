// qml/managers/QmlSceneLogicManager.qml
pragma Singleton
import QtQuick

import qml.managers
import qml.registers
import qml.settings.project_settings

QtObject {
    id: manager

    // =====================================================
    // РЕЖИМ
    // =====================================================
    property bool editMode: false

    // =====================================================
    // ВНЕДРЯЕМЫЕ ЗАВИСИМОСТИ
    // =====================================================
    property var componentRegister: QmlRegisterComponentObject
    property var projectSettings: QmlProjectSettings

    // =====================================================
    // Появление кнопки для редактирования главной сцены
    // =====================================================
    property bool isActivateEditMode: false
    function activateEditMode() {
        const newMode = !isActivateEditMode
        isActivateEditMode = newMode
    }

    property var sceneController: null
    property Item sceneContainer: null
    property Component wrapperComponent: null
    property var previewComponents: null

    // =====================================================
    // ВНУТРЕННЕЕ СОСТОЯНИЕ
    // =====================================================
    property var selectedItems: []

    // =====================================================
    // КОНФИГУРАЦИЯ
    // =====================================================
    function configure(cfg) {
        sceneController = cfg.sceneController || null
        sceneContainer    = cfg.sceneContainer || null
        wrapperComponent  = cfg.wrapperComponent || null
        previewComponents = cfg.previewComponents || null
        editMode          = cfg.editMode || false
    }

    // =====================================================
    // СОЗДАНИЕ ЭЛЕМЕНТА
    // =====================================================
    function createObject(data) {
        if (!sceneContainer || !wrapperComponent || !previewComponents)
            return

        if (!data || !data.geometry)
            return

        const component = previewComponents.getPreviewComponent(data.subtype)
        if (!component)
            return

        const widget = component.createObject(null, {
            id_widget: data.id_widget,
            name_widget: data.name_widget,
            componentGroupe: data.componentGroupe,
            subtype: data.subtype
        })

        if (!widget)
            return

        const wrapper = wrapperComponent.createObject(sceneContainer, {
            relX: data.geometry.relX,
            relY: data.geometry.relY,
            relW: data.geometry.relW,
            relH: data.geometry.relH,
            sceneContainer: sceneContainer,
            sceneController: sceneController
        })

        if (!wrapper) {
            widget.destroy()
            return
        }

        wrapper.setWidget(widget)

        if (componentRegister)
            componentRegister.registerElement(wrapper, widget)

        // Подключаем сигналы ТОЛЬКО в editMode
        if (editMode) {
            wrapper.requestSelect.connect((toggle) => selectItem(wrapper, toggle))
            wrapper.requestDelete.connect(() => removeItem(wrapper))
        }
    }

    // =====================================================
    // УДАЛЕНИЕ
    // =====================================================
    function removeItem(wrapper) {

        if (!wrapper)
            return

        if (componentRegister)
            componentRegister.unregisterElement(wrapper)

        const index = selectedItems.indexOf(wrapper)
        if (index !== -1)
            selectedItems.splice(index, 1)

        wrapper.destroy()
    }

    // =====================================================
    // LOAD
    // =====================================================
    function loadScene() {
        clearScene()

        if (!projectSettings)
            return

        const sceneData = projectSettings.loadBlockGraphics()
        if (!sceneData)
            return

        for (let group in sceneData) {
            for (let subtype in sceneData[group]) {
                for (let id in sceneData[group][subtype]) {
                    createObject(sceneData[group][subtype][id])
                }
            }
        }

        loadCamera()
    }

    // =====================================================
    // SAVE
    // =====================================================
    function saveScene() {
        if (!componentRegister || !projectSettings)
            return

        const data = componentRegister.exportSceneData()
        projectSettings.saveBlockGraphics(data)
        saveCamera()
    }

    // =====================================================
    // CLEAR
    // =====================================================
    function clearScene() {
        deselectAll()

        if (componentRegister)
            componentRegister.clear()

        if (!sceneContainer)
            return

        for (let i = sceneContainer.children.length - 1; i >= 0; i--) {
            sceneContainer.children[i].destroy()
        }
    }

    // =====================================================
    // ВЫДЕЛЕНИЕ
    // =====================================================
    function deselectAll() {
        if (!selectedItems || selectedItems.length === 0)
            return

        for (let i = 0; i < selectedItems.length; i++) {
            if (selectedItems[i])
                selectedItems[i].isSelected = false
        }

        selectedItems = []
    }

    function selectItem(wrapper, toggle) {
        if (!wrapper)
            return

        if (!selectedItems)
            selectedItems = []

        toggle = toggle || false

        if (toggle && selectedItems.indexOf(wrapper) !== -1) {
            wrapper.isSelected = false
            selectedItems.splice(selectedItems.indexOf(wrapper), 1)

        } else if (toggle) {
            wrapper.isSelected = true
            selectedItems.push(wrapper)
        } else {
            deselectAll()
            wrapper.isSelected = true
            selectedItems.push(wrapper)
        }

        if (wrapper.forceActiveFocus)
            wrapper.forceActiveFocus()
    }

    // =========================================================================
    // ДОБАВЛЕНИЕ ЭЛЕМЕНТА
    // =========================================================================
    function addItemToScene(data) {
        console.log("[DEBUG] sceneController:", sceneController)
        console.log("[DEBUG] viewport:", sceneController?.viewport)
        console.log("[DEBUG] viewport.width:", sceneController?.viewport?.width)
        console.log("[DEBUG] viewport.height:", sceneController?.viewport?.height)
        console.log("[DEBUG] zoom:", sceneController?.zoom)
        console.log("[DEBUG] offsetX:", sceneController?.offsetX)
        console.log("[DEBUG] offsetY:", sceneController?.offsetY)

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

        // Вычисляем геометрию с учётом камеры
        const geometry = computeGeometry(
            data,
            sceneController.viewport,    // viewport.width/height
            sceneController.zoom,        // зум
            sceneController.offsetX,     // смещение X
            sceneController.offsetY      // смещение Y
        )

        // Создаём обёртку
        const wrapper = wrapperComponent.createObject(sceneContainer, {
            geometry: geometry,
            sceneContainer: sceneContainer,
            sceneController: sceneController,
            editMode: editMode
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

    // Фабрика для создания виджетов
    function createWidget(type, data) {
        const component = previewComponents.getPreviewComponent(type)
        if (!component) {
            console.error(`[ERR] Компонент не найден: ${type}`)
            return null
        }
        return component.createObject(null, data)
    }

    // =========================================================================
    // ВЫЧИСЛЕНИЕ ГЕОМЕТРИИ
    // =========================================================================
    function computeGeometry(data, viewport, zoom, offsetX, offsetY) {
        // Защита от невалидных данных
        if (!viewport || viewport.width <= 0 || viewport.height <= 0) {
            console.error("[ERR] computeGeometry: invalid viewport")
            return { relX: 0.1, relY: 0.1, relW: 0.1, relH: 0.1 }
        }

        if (zoom <= 0) {
            console.error("[ERR] computeGeometry: invalid zoom")
            zoom = 1.0
        }

        const isSilos = data.subtype === "silos_vertical"
        const relW = isSilos ? 0.05 : 0.1
        const relH = isSilos ? 0.25 : 0.1

        // Смещение для каскадного размещения
        const offset = (componentRegister?.count || 0) * 0.15

        // === 1. Позиция в координатах viewport (экрана) ===
        const screenX = viewport.width * Math.min(0.7, 0.1 + (offset % 0.6))
        const screenY = viewport.height * Math.min(0.7, 0.15 + ((offset * 0.5) % 0.6))

        // === 2. Относительные координаты (0.0–1.0) ОТНОСИТЕЛЬНО VIEWPORT ===
        // НЕ конвертируем в мировые! Храним как есть.
        return {
            relX: screenX / viewport.width,      // ~0.1–0.7
            relY: screenY / viewport.height,     // ~0.15–0.7
            relW: relW,                           // 0.05 или 0.1
            relH: relH                            // 0.25 или 0.1
        }
    }

    // =========================================================================
    // Регистрация обёртки и подключение сигналов
    // =========================================================================
    function registerWrapper(wrapper, widget) {
        if (!componentRegister) return true
        if (!componentRegister.registerElement(wrapper, widget)) {
            console.warn(`[WARN] Не удалось зарегистрировать: ${widget.id_widget}`)
            wrapper.destroy()
            return false
        }

        wrapper.requestSelect.connect((toggle) => selectItem(wrapper, toggle))
        wrapper.requestDelete.connect(() => removeItem(wrapper))
        return true
    }

    // =========================================================================
    // Сохранение настроек камеры
    // =========================================================================
    function saveCamera() {
        if (!sceneController || !projectSettings)
            return

        projectSettings.saveCameraParams({
            zoom: sceneController.zoom,
            offsetX: sceneController.offsetX,
            offsetY: sceneController.offsetY
        })
    }

    // =========================================================================
    // Загрузка настроек камеры
    // =========================================================================
    function loadCamera() {

        if (!sceneController || !projectSettings)
            return

        const cam = projectSettings.loadCameraParams()

        if (!cam)
            return

        sceneController.zoom    = cam.zoom
        sceneController.offsetX = cam.offsetX
        sceneController.offsetY = cam.offsetY
    }
}
