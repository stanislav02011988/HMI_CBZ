// qml/managers/QmlSceneManager.qml
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
    property var projectManager: QmlProjectManager

    // =====================================================
    // Появление кнопки для редактирования главной сцены в файле CenterWidget.qml
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

    // =====================================================
    // LOAD
    // =====================================================
    function loadScene() {
        clearScene()
        if (!projectManager)
            return

        const sceneData = projectManager.dataElementScaene
        if (!sceneData)
            return
        for (let group in sceneData) {
            for (let subtype in sceneData[group]) {
                for (let id in sceneData[group][subtype]) {
                    createObject(sceneData[group][subtype][id])
                }
            }
        }

        loadCamera(sceneData["Camera_Settings"])
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
    // SAVE
    // =====================================================
    function saveScene() {
        if (!componentRegister || !projectManager)
            return

        const data = componentRegister.exportSceneData()
        projectManager.saveSceneElements(data)
        saveCamera()
    }

    // =====================================================
    // SAVE One Element
    // =====================================================
    function updateOneElement(id_widget) {
        if (!componentRegister || !projectManager)
            return

        const data = componentRegister.exportElementData(id_widget)
        projectManager.updateSceneOneElement(id_widget, data)
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

        // Вычисляем геометрию с учётом камеры
        const geometry = computeGeometry(
            widget,
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
    function computeGeometry(widget, data, viewport, zoom, offsetX, offsetY) {
        // Защита от невалидных данных
        if (!viewport || viewport.width <= 0 || viewport.height <= 0) {
            console.error("[ERR] computeGeometry: invalid viewport")
            return { relX: 0.1, relY: 0.1, relW: 0.1, relH: 0.1 }
        }

        if (zoom <= 0) {
            console.error("[ERR] computeGeometry: invalid zoom")
            zoom = 1.0
        }

        // Значения по умолчанию
        let relW = 0.01
        let relH = 0.01

        if (widget && widget.implicitWidth > 0 && widget.implicitHeight > 0) {

            relW = widget.implicitWidth / viewport.width
            relH = widget.implicitHeight / viewport.height
        }

        // =========================================
        // Центр viewport
        // =========================================

        const centerScreenX = viewport.width / 2
        const centerScreenY = viewport.height / 2

        // =========================================
        // Перевод в координаты мира
        // =========================================

        const worldX = (centerScreenX - offsetX - 800) / zoom
        const worldY = (centerScreenY - offsetY - 200) / zoom

        return {
            relX: worldX / viewport.width,
            relY: worldY / viewport.height,
            relW: relW,
            relH: relH
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
        if (!sceneController || !projectManager)
            return

        projectManager.saveCameraParams({
            zoom: sceneController.zoom,
            offsetX: sceneController.offsetX,
            offsetY: sceneController.offsetY
        })
    }

    // =========================================================================
    // Загрузка настроек камеры
    // =========================================================================
    function loadCamera(dataCamera) {
        if (!sceneController || !projectManager)
            return

        // const cam = projectManager.loadCameraParams()
        if (!dataCamera)
            return

        sceneController.zoom    = dataCamera.zoom
        sceneController.offsetX = dataCamera.offsetX
        sceneController.offsetY = dataCamera.offsetY
    }
}
