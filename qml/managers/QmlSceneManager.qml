pragma Singleton
import QtQuick

import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements.element_preview

QtObject {
    id: manager

    // =====================================================
    // РЕЖИМ
    // =====================================================

    property bool editMode: false

    // =====================================================
    // ВНЕДРЯЕМЫЕ ЗАВИСИМОСТИ
    // =====================================================

    property var componentRegister: null
    property var projectSettings: null
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

        componentRegister = cfg.componentRegister || null
        projectSettings   = cfg.projectSettings || null
        sceneContainer    = cfg.sceneContainer || null
        wrapperComponent  = cfg.wrapperComponent || null
        previewComponents = cfg.previewComponents || null
        editMode          = cfg.editMode || false
        selectedItems = cfg.selectedItems || []
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
}
