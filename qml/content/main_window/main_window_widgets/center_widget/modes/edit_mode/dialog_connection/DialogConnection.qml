// edit_mode_internal/DialogConnection.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt5Compat.GraphicalEffects 1.15
import qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_preview

Popup {
    id: root
    width: 650  // Увеличим ширину для описаний
    height: 450
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    // 🔑 КРИТИЧЕСКИЕ СВОЙСТВА МЕНЕДЖЕРОВ
    property var connectionManager: null
    property var componentRegister: null
    property var sceneBus: null
    property var sourceWrapper: null

    property string selectedTargetId: ""
    property string selectedSourceSignal: ""  // Ключ сигнала
    property string selectedTargetSlot: ""    // Ключ слота

    function setSourceWrapper(wrapper) {
        sourceWrapper = wrapper
        updateTargetList()
        // Сбрасываем выбор при смене источника
        selectedTargetId = ""
        selectedSourceSignal = ""
        selectedTargetSlot = ""
    }

    function updateTargetList() {
        if (!componentRegister || !sourceWrapper?.widgetInstance) {
            targetModel.clear()
            return
        }

        const sourceId = sourceWrapper.widgetInstance.id_widget
        targetModel.clear()

        componentRegister.elements.forEach(elem => {
            if (!elem.config?.id_widget || elem.config.id_widget === sourceId) return
            targetModel.append({
                id: elem.config.id_widget,
                name: elem.config.name_widget || elem.config.id_widget,
                type: elem.wrapper.type
            })
        })
        console.log(`🎯 Найдено ${targetModel.count} доступных целей`)
    }

    function findElementById(id) {
        return componentRegister?.getElementById(id)
    }

    PreviewComponents { id: previewComponents }

    background: Rectangle {
        color: "white"
        radius: 8
        border.color: "#444"
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 10; samples: 20; color: "#60000000"; verticalOffset: 4
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15

        Text {
            text: "Создание связи"
            font.bold: true
            font.pixelSize: 18
            color: "#333"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#2196F3"
            Layout.topMargin: 5
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // === ИСТОЧНИК ===
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: "Источник";
                    color: "#2196F3";
                    font.bold: true;
                    font.pixelSize: 14
                }
                Text {
                    text: sourceWrapper?.widgetInstance?.name_widget || "—"
                    color: "#555"
                    font.pixelSize: 13
                }
                Loader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    active: sourceWrapper !== null
                    sourceComponent: sourceWrapper ? previewComponents.getPreviewComponent(sourceWrapper.type) : null
                    onLoaded: {
                        if (item && sourceWrapper?.widgetInstance) {
                            if (item.hasOwnProperty("id_widget")) item.id_widget = sourceWrapper.widgetInstance.id_widget;
                            if (item.hasOwnProperty("name_widget")) item.name_widget = sourceWrapper.widgetInstance.name_widget;
                        }
                    }
                }
                Label { text: "Сигнал:"; color: "#333"; font.bold: true }
                ComboBox {
                    Layout.fillWidth: true
                    // 🔑 ОБРАБОТКА ОБЪЕКТА ВМЕСТО МАССИВА
                    model: {
                        if (!sourceWrapper?.widgetInstance) return []
                        const w = sourceWrapper.widgetInstance
                        if (typeof w.exposedSignals === 'object' && !Array.isArray(w.exposedSignals)) {
                            return Object.keys(w.exposedSignals).map(key => {
                                return { key: key, display: `${key} — ${w.exposedSignals[key]}` }
                            })
                        }
                        // Обратная совместимость со старым форматом
                        if (Array.isArray(w.exposedSignals)) {
                            return w.exposedSignals.map(signal => {
                                return { key: signal, display: signal }
                            })
                        }
                        return []
                    }
                    textRole: "display"
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < model.length) {
                            root.selectedSourceSignal = model[currentIndex].key
                        } else {
                            root.selectedSourceSignal = ""
                        }
                    }
                }
            }

            // === ЦЕЛЬ ===
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: "Цель";
                    color: "#4CAF50";
                    font.bold: true;
                    font.pixelSize: 14
                }
                ComboBox {
                    id: targetSelector
                    Layout.fillWidth: true
                    model: targetModel
                    textRole: "name"
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0) {
                            const item = targetModel.get(currentIndex)
                            root.selectedTargetId = item.id
                            // Сбрасываем выбор слота при смене цели
                            root.selectedTargetSlot = ""
                        } else {
                            root.selectedTargetId = ""
                            root.selectedTargetSlot = ""
                        }
                    }
                }
                Loader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    active: root.selectedTargetId !== ""
                    sourceComponent: {
                        if (!root.selectedTargetId) return null
                        const elem = findElementById(root.selectedTargetId)
                        return elem ? previewComponents.getPreviewComponent(elem.wrapper.type) : null
                    }
                    onLoaded: {
                        if (item && root.selectedTargetId) {
                            const elem = findElementById(root.selectedTargetId)
                            if (elem?.widgetRef) {
                                if (item.hasOwnProperty("sceneBus")) item.sceneBus = root.sceneBus;
                                if (item.hasOwnProperty("name_widget")) item.name_widget = elem.widgetRef.name_widget;
                            }
                        }
                    }
                }
                Label { text: "Слот:"; color: "#333"; font.bold: true }
                ComboBox {
                    Layout.fillWidth: true
                    // 🔑 ОБРАБОТКА ОБЪЕКТА ВМЕСТО МАССИВА
                    model: {
                        if (!root.selectedTargetId) return []
                        const elem = findElementById(root.selectedTargetId)
                        if (!elem?.widgetRef?.exposedSlots) return []

                        const slots = elem.widgetRef.exposedSlots
                        if (typeof slots === 'object' && !Array.isArray(slots)) {
                            return Object.keys(slots).map(key => {
                                return { key: key, display: `${key} — ${slots[key]}` }
                            })
                        }
                        // Обратная совместимость
                        if (Array.isArray(slots)) {
                            return slots.map(slot => {
                                return { key: slot, display: slot }
                            })
                        }
                        return []
                    }
                    textRole: "display"
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < model.length) {
                            root.selectedTargetSlot = model[currentIndex].key
                        } else {
                            root.selectedTargetSlot = ""
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 10
            Button {
                Layout.fillWidth: true
                text: "Отмена"
                onClicked: root.close()
                background: Rectangle {
                    color: "#f5f5f5";
                    radius: 4
                    border.color: "#ddd"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                Layout.fillWidth: true
                text: "Создать связь"
                enabled: root.selectedSourceSignal && root.selectedTargetId && root.selectedTargetSlot
                onClicked: {
                    if (!sourceWrapper?.widgetInstance || !connectionManager) {
                        console.error("❌ Невозможно создать связь: отсутствуют данные")
                        return
                    }

                    const fromId = sourceWrapper.widgetInstance.id_widget
                    console.log(`🔗 Создание связи: ${fromId}.${root.selectedSourceSignal} → ${root.selectedTargetId}.${root.selectedTargetSlot}`)

                    connectionManager.createConnection(
                        fromId,
                        root.selectedSourceSignal,  // Ключ сигнала
                        root.selectedTargetId,
                        root.selectedTargetSlot      // Ключ слота
                    )
                    root.close()
                }
                background: Rectangle {
                    color: enabled ? "#4CAF50" : "#ccc";
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }
        }
    }

    ListModel { id: targetModel }

    onOpened: {
        if (sourceWrapper) updateTargetList()
    }
}
