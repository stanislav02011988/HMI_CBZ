// qml\managers\QmlLogicMapScene.qml
pragma Singleton
import QtQuick

import qml.managers
import qml.registers
import qml.settings.project_settings

QtObject {
    id: managerLogicMapScene

    // =====================================================
    // АКТИВНАЯ ПРОГРАММА
    // =====================================================
    property string openedProgramId: ""
    property string openedProgramName: ""
    property bool isLoadFilePrograms: false

    // =====================================================
    // РЕЖИМ FALSE - RUN MODE TRUE - EDIT MODE
    // =====================================================
    property bool editMode: false

    // =====================================================
    // ВНЕДРЯЕМЫЕ ЗАВИСИМОСТИ
    // =====================================================
    property var componentRegister: QmlRegisterComponentObject
    property var componentLogicMapRegister: QmlRegisterComponentLogicMap
    property var projectSettings: QmlProjectSettings
    property var projectManager: QmlProjectManager

    property var sceneController: null
    property Item sceneContainer: null
    property Component wrapperComponent: null
    property var previewComponents: null
    property rect panelRect: Qt.rect(0,0,0,0)

    property real zoomLogicScene: sceneContainer ? sceneContainer.scale : 0

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
        panelRect = cfg.panelRect || Qt.rect(0,0,0,0)
        editMode          = cfg.editMode || false
    }

    // =========================================================================
    // ДОБАВЛЕНИЕ ЭЛЕМЕНТА
    // =========================================================================
    function addElemntsToSceneLogicMap(data) {
        if (!projectManager) return

        if (!data) return
        createObject(data)
    }

    // =====================================================
    // LOAD
    // =====================================================
    function loadPrograms(namePrograms) {
        if (!projectManager)
            return

        const dataPrograms = projectManager.getDataProgramsProject(namePrograms)
        const sceneData = dataPrograms.scene

        if (dataPrograms){
            clearScene()
            for (let group in sceneData) {
                for (let subtype in sceneData[group]) {
                    for (let id in sceneData[group][subtype]) {
                        createObject(sceneData[group][subtype][id])
                    }
                }
            }

            loadCamera(dataPrograms.scene_camera_settings)
            managerLogicMapScene.isLoadFilePrograms = true
            managerLogicMapScene.openedProgramName = namePrograms
            // console.log(JSON.stringify(dataPrograms, null, 2))
        }else {
            console.log("ДАнные нет")
            managerLogicMapScene.isLoadFilePrograms = false
            return
        }
    }

    // =====================================================
    // СОЗДАНИЕ ЭЛЕМЕНТА
    // =====================================================
    function createObject(data) {
        if (!sceneContainer || !wrapperComponent || !previewComponents)
            return
        // console.log(JSON.stringify(data, null, 2))
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

        widget.importProperties(data.sizeProperties)

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

        if (componentLogicMapRegister)
            componentLogicMapRegister.registerElement(wrapper, widget)

        // Подключаем сигналы ТОЛЬКО в editMode
        if (editMode) {
            wrapper.requestSelect.connect((toggle) => selectItem(wrapper, toggle))
            wrapper.requestDelete.connect(() => removeItem(wrapper))
        }
    }

    // =========================================================================
    // Загрузка настроек камеры
    // =========================================================================
    function loadCamera(dataCamera) {
        if (!sceneController || !projectManager)
            return

        if (!dataCamera)
            return

        sceneController.zoom    = dataCamera.zoom ? dataCamera.zoom : 1
        sceneController.offsetX = dataCamera.offsetX ? dataCamera.offsetX : 0
        sceneController.offsetY = dataCamera.offsetY ? dataCamera.offsetY : 0
    }

    // =====================================================
    // SAVE
    // =====================================================
    function saveScene() {
        if (!componentLogicMapRegister || !projectManager)
            return

        const data = componentLogicMapRegister.exportSceneData()
        projectManager.saveElementSceneLogicMap(managerLogicMapScene.openedProgramName, data)
        saveCamera()
    }

    // =====================================================
    // SAVE One Element
    // =====================================================
    function updateOneElement(id_widget) {
        if (!componentLogicMapRegister || !projectManager)
            return

        const data = componentLogicMapRegister.exportElementData(id_widget)
        projectManager.updateSceneOneElementLogicMap(managerLogicMapScene.nameFileProject, id_widget, data)
    }

    // =========================================================================
    // Сохранение настроек камеры
    // =========================================================================
    function saveCamera() {
        if (!sceneController || !projectManager)
            return

        projectManager.saveCameraParamsSceneLogicMap(managerLogicMapScene.openedProgramName, {
            zoom: sceneController.zoom,
            offsetX: sceneController.offsetX,
            offsetY: sceneController.offsetY
        })
    }

    // =====================================================
    // УДАЛЕНИЕ
    // =====================================================
    function removeItem(wrapper) {
        if (!wrapper)
            return

        if (componentLogicMapRegister)
            componentLogicMapRegister.unregisterElement(wrapper)

        const index = selectedItems.indexOf(wrapper)
        if (index !== -1)
            selectedItems.splice(index, 1)

        wrapper.destroy()
    }

    // =====================================================
    // CLEAR
    // =====================================================
    function clearScene() {
        deselectAll()
        managerLogicMapScene.isLoadFilePrograms = false
        if (componentLogicMapRegister)
            componentLogicMapRegister.clear()

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

        const wasSelected = selectedItems.indexOf(wrapper) !== -1

        if (toggle) {
            // Shift/Ctrl + клик → переключаем состояние элемента
            if (wasSelected) {
                // Снимаем выделение
                wrapper.isSelected = false
                selectedItems.splice(selectedItems.indexOf(wrapper), 1)
            } else {
                // Добавляем к выделению
                wrapper.isSelected = true
                selectedItems.push(wrapper)
            }
        } else {
            // Обычный клик → только этот элемент выделен
            if (!wasSelected) {
                deselectAll()
                wrapper.isSelected = true
                selectedItems.push(wrapper)
            }
            // Если уже выделен — оставляем как есть (не снимаем!)
        }

        if (wrapper.forceActiveFocus)
            wrapper.forceActiveFocus()
    }
}
