// qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements DialogAddElements.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.settings.menager_theme
import qml.controls.button

import qml.content.main_window.center_widget.modes.edit_mode.dialog_add_elements.element_selector
import "./element_preview"
import "./element_parameters"

Popup {
    id: root

    width: contentItem.implicitWidth
    height: contentItem.implicitHeight

    property real popupX: 100
    property real popupY: 100
    x: popupX; y: popupY

    z: 999
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose
    background: null

    property var sceneController: null

    // === СОСТОЯНИЕ ===
    property bool isVisibleParamentrsElement: false

    signal signalAddElement(var data)

    Item {
        id: contentItem
        anchors.fill: parent
        implicitWidth: mainLayout.implicitWidth + 40
        implicitHeight: mainLayout.implicitHeight + 40

        Rectangle {
            id: bgPopup
            anchors.fill: parent
            color: "#1e1e1e"
            border.color: "#444"
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                color: "#60000000"
                radius: 10
                samples: 20
                verticalOffset: 4
            }

            ColumnLayout {
                id: mainLayout
                anchors.centerIn: parent
                spacing: 0

                // === ЗАГОЛОВОК С ПЕРЕТАСКИВАНИЕМ ===

                Header {}

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 15
                    Layout.margins: 15

                    // === СТОЛБЕЦ 1: ВЫБОР ===
                    ListPanel {
                        id: listPanel
                        Layout.preferredWidth: 280
                        Layout.fillHeight: true

                        onSignalSelectedSubtype: (subtypeId) => {
                            previewPanel.selectedSubtypeId = subtypeId
                            paramsPanel.selectedSubtypeId = subtypeId
                            root.isVisibleParamentrsElement = true
                        }
                        onSelectionCleared: () => {
                            root.isVisibleParamentrsElement = false
                        }
                        onAddRequested: root.addElementToScene(paramsPanel.dataList)
                    }

                    // === СТОЛБЕЦ 2: ПРЕВЬЮ ===
                    PreviewPanel {
                        id: previewPanel
                        Layout.preferredWidth: 300
                        Layout.fillHeight: true
                        isVisible: root.isVisibleParamentrsElement
                    }

                    // === СТОЛБЕЦ 3: ПАРАМЕТРЫ ===
                    ParametersPanel {
                        id: paramsPanel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        isVisible: root.isVisibleParamentrsElement
                        sceneController: root.sceneController

                        onAddRequested: (dataList) => {
                                            root.addElementToScene(dataList)
                                            root.resetForm()
                                        }
                        onCloseRequested: {
                            root.close()
                            root.resetForm()
                        }
                    }
                }
            }
        }
    }

    // === МЕТОДЫ ===
    function addElementToScene(dataList) {
        // Собираем конфиг для отправки
        var elementConfig = {
            subtype: dataList.subtypeId,
            id_widget: dataList.id_widget,
            name_widget: dataList.name_widget,
            componentGroupe: dataList.componentGroupe
        }

        if (sceneController) {
            // sceneController.addItemToScene(elementConfig)
            signalAddElement(elementConfig)
            paramsPanel.statusMessage = "✓ Элемент добавлен на сцену"
            Qt.callLater(() => {
                root.close()
                root.resetForm()
            }, 2000)
        } else {
            paramsPanel.statusMessage = "✗ Контроллер сцены не найден"
            paramsPanel.isSaving = false
            Qt.callLater(() => paramsPanel.statusMessage = "", 3000)
        }
    }

    function resetForm(){
        listPanel.resetListPanel()
        previewPanel.resetPreviewPanel()
        paramsPanel.resetParametersPanel()
        root.isVisibleParamentrsElement = false
    }

    onOpened: root.resetForm()
}
