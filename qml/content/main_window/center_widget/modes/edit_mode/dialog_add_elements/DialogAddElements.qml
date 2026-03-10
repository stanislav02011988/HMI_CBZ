// qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements DialogAddElements.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.settings.menager_theme
import qml.controls.button

import "./element_selector"
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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#2a2a2a"
                    radius: 6

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeAllCursor
                        property point dragStart
                        onPressed: dragStart = Qt.point(mouseX, mouseY)
                        onPositionChanged: (mouse) => {
                            if (mouse.buttons & Qt.LeftButton) {
                                root.x += mouseX - dragStart.x
                                root.y += mouseY - dragStart.y
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Text {
                            text: "Добавить элемент в схему"
                            font.bold: true
                            font.pixelSize: 16
                            color: "white"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        CustomButton {
                            id: closeBtn
                            text: "✕"
                            m_width: 30
                            m_height: 30
                            Layout.alignment: Qt.AlignCenter
                            Layout.rightMargin: 10

                            m_background_color: QmlMenagerTheme.reg_win_cBtnClose_background
                            m_color_hovered: QmlMenagerTheme.reg_win_cBtnClose_color_hovered
                            m_borderColor: QmlMenagerTheme.reg_win_cBtnClose_borderColor

                            m_colorText: QmlMenagerTheme.reg_win_cBtnClose_colorText
                            m_colorTextHovered: QmlMenagerTheme.reg_win_cBtnClose_colorTextHovered

                            onClicked: { root.close() }
                        }
                    }
                }

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
                            root.resetForm()
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

                        onAddRequested: (dataList) => { root.addElementToScene(dataList); root.resetForm() }
                        onCloseRequested: { root.close() }
                        onNameElementChanged: { previewPanel.elementName = nameElement }
                        onLevelPreSilosChanged: {previewPanel.levelSilos = levelPreSilos}
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
    onClosed: root.resetForm()
}
