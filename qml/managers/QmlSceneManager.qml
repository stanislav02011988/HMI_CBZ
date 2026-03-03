pragma Singleton
import QtQuick

import qml.managers
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
            sceneContainer: sceneContainer
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
    }

    // =====================================================
    // SAVE
    // =====================================================
    function saveScene() {

        if (!componentRegister || !projectSettings)
            return

        const data = componentRegister.exportSceneData()
        projectSettings.saveBlockGraphics(data)
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
        const wrapper = wrapperComponent.createObject(sceneContainer, {
            geometry: computeGeometry(data),
            sceneContainer: sceneContainer,
            sceneController: sceneController
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

        wrapper.requestSelect.connect((toggle) => selectItem(wrapper, toggle))
        wrapper.requestDelete.connect(() => removeItem(wrapper))
        return true
    }
}
