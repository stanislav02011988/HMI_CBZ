// module qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_resize_element
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button
import qml.settings.menager_theme
import qml.managers

Popup {
    id: root

    // =========================================================
    // ДАННЫЕ
    // =========================================================
    property Item targetElement: null
    property var sizeProperties: []
    property real backupRelW: 0.2
    property real backupRelH: 0.2
    property var backupSizeProperties: []
    property bool wasApplied: false

    readonly property Item container: parent

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0
    Overlay.modal: Rectangle { color: "transparent" }
    background: null

    // === ИСПРАВЛЕНО: фиксированная ширина для лучшего отображения ===
    width: 445
    height: Math.min(600, Screen.height * 0.8)  // Не больше 80% высоты экрана

    // Позиционирование по центру экрана
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2

    // =========================================================
    // ФОН С ОТСТУПАМИ
    // =========================================================
    Rectangle {
        id: bgPopup
        anchors.fill: parent
        color: "white"
        border.color: "#444"
        radius: 8
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#60000000"
            radius: 10
            samples: 20
            verticalOffset: 4
        }

        // =====================================================
        // ЗАГОЛОВОК С ДРАГ-ОБЛАСТЬЮ
        // =====================================================
        Rectangle {
            id: header
            height: 36
            color: "#2c3e50"
            radius: 6
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor
                property point dragStart
                onPressed: dragStart = Qt.point(mouseX, mouseY)
                onPositionChanged: (mouse) => {
                    if (mouse.buttons & Qt.LeftButton) {
                        root.x += mouseX - dragStart.x
                        root.y += mouseY - dragStart.y
                        // Ограничение в пределах экрана
                        root.x = Math.max(0, Math.min(Screen.width - root.width, root.x))
                        root.y = Math.max(0, Math.min(Screen.height - root.height, root.y))
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Text {
                    text: targetElement && targetElement.widget
                        ? `Изменение размеров: ${targetElement.widget.name_widget} [${targetElement.widget.id_widget}]`
                        : "Изменение размеров"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                CustomButton {
                    id: closeBtn
                    text: "✕"
                    m_width: 30
                    m_height: 30
                    Layout.alignment: Qt.AlignCenter
                    Layout.rightMargin: 8

                    m_background_color: QmlMenagerTheme.reg_win_cBtnClose_background
                    m_color_hovered: QmlMenagerTheme.reg_win_cBtnClose_color_hovered
                    m_borderColor: QmlMenagerTheme.reg_win_cBtnClose_borderColor
                    m_colorText: QmlMenagerTheme.reg_win_cBtnClose_colorText
                    m_colorTextHovered: QmlMenagerTheme.reg_win_cBtnClose_colorTextHovered

                    onClicked: {
                        root.wasApplied = false
                        root._restoreFromBackup()
                        root.close()
                    }
                }
            }
        }

        // =====================================================
        // СКРОЛЛИРУЕМОЕ СОДЕРЖИМОЕ (ИСПРАВЛЕНО!)
        // =====================================================
        ScrollView {
            id: scrollView
            anchors.top: header.bottom
            anchors.bottom: buttonsRow.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            clip: true

            ColumnLayout {
                id: scrollContent
                width: scrollView.width
                spacing: 10

                // ===================== Контейнерные размеры =====================
                GroupBox {
                    title: "Изменение размеров контейнера"
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 8

                        // Ширина контейнера
                        RowLayout {
                            spacing: 8
                            Text { text: "Ширина:"; width: 70 }

                            Slider {
                                id: widthSlider
                                Layout.fillWidth: true
                                from: 0.001
                                to: 0.95
                                stepSize: 0.001
                                value: targetElement ? targetElement.relW : 0.2

                                onValueChanged: {
                                    if (targetElement)
                                        targetElement.relW = value
                                    widthField.text = Math.round(value * 1000).toString()
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                    onWheel: (wheel) => {
                                        var delta = wheel.angleDelta.y > 0 ? 0.001 : -0.001
                                        widthSlider.value =
                                            Math.max(widthSlider.from,
                                            Math.min(widthSlider.to, widthSlider.value + delta))
                                    }
                                }
                            }

                            TextField {
                                id: widthField
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                text: Math.round(widthSlider.value * 100).toString()
                            }
                        }

                        // Высота контейнера
                        RowLayout {
                            spacing: 8
                            Text { text: "Высота:"; width: 70 }

                            Slider {
                                id: heightSlider
                                Layout.fillWidth: true
                                from: 0.001
                                to: 0.95
                                stepSize: 0.001
                                value: targetElement ? targetElement.relH : 0.2

                                onValueChanged: {
                                    if (targetElement)
                                        targetElement.relH = value
                                    heightField.text = Math.round(value * 1000).toString()
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                    onWheel: function(wheel) {
                                        var delta = wheel.angleDelta.y > 0 ? 0.001 : -0.001
                                        heightSlider.value =
                                            Math.max(heightSlider.from,
                                            Math.min(heightSlider.to, heightSlider.value + delta))
                                    }
                                }
                            }

                            TextField {
                                id: heightField
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                text: Math.round(heightSlider.value * 100).toString()
                            }
                        }
                    }
                }

                // ===================== Внутренние размеры виджета =====================
                GroupBox {
                    title: "Изменение размеров компонентов элемента"
                    Layout.fillWidth: true
                    visible: sizeProperties.length > 0

                    ColumnLayout {
                        spacing: 6

                        Repeater {
                            model: sizeProperties
                            delegate: GroupBox {
                                title: modelData.description
                                Layout.fillWidth: true
                                visible: sizeProperties.length > 0

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: modelData.label
                                        width: 140
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }

                                    Slider {
                                        id: slaiderProperty
                                        Layout.fillWidth: true
                                        from: modelData.min
                                        to: modelData.max
                                        stepSize: modelData.step
                                        value: modelData.value

                                        onValueChanged: {
                                            modelData.value = value
                                            if (targetElement && targetElement.widget)
                                                targetElement.widget.setPropertySize(modelData.name, value)
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.NoButton
                                            onWheel: (wheel) => {
                                                slaiderProperty.value += (wheel.angleDelta.y > 0 ? modelData.step : -modelData.step)
                                                slaiderProperty.value = Math.max(
                                                    slaiderProperty.from,
                                                    Math.min(slaiderProperty.to, slaiderProperty.value)
                                                )
                                            }
                                        }
                                    }

                                    TextField {
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 30
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        horizontalAlignment: Text.AlignRight
                                        text: (Math.round(modelData.value * 10) / 10).toString()
                                    }
                                }
                            }
                        }
                    }
                }

                // Заполнитель для отступа снизу
                Item { Layout.preferredHeight: 20 }
            }
        }

        // ===================== КНОПКИ =====================
        RowLayout {
            id: buttonsRow
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 10

            Button {
                Layout.fillWidth: true
                text: "Отменить"
                background: Rectangle {
                    color: "#e74c3c"
                    radius: 4
                }
                onClicked: {
                    root.wasApplied = false
                    root._restoreFromBackup()
                    root.close()
                }
            }

            Button {
                Layout.fillWidth: true
                text: "Применить"
                background: Rectangle {
                    color: "#27ae60"
                    radius: 4
                }
                onClicked: {
                    root.wasApplied = true
                    if (typeof QmlSceneManager !== 'undefined' && targetElement?.widget?.id_widget) {
                        QmlSceneManager.saveOneElement(targetElement.widget.id_widget)
                    }
                    root.close()
                }
            }
        }
    }

    // =========================================================
    // ВОССТАНОВЛЕНИЕ ИЗ БЭКАПА
    // =========================================================
    function _restoreFromBackup() {
        if (!targetElement || !targetElement.widget) {
            console.warn("[DialogResize] Невозможно восстановить: нет целевого элемента")
            return
        }

        // Восстанавливаем геометрию контейнера
        targetElement.relW = backupRelW
        targetElement.relH = backupRelH

        // Восстанавливаем свойства виджета
        if (typeof targetElement.widget.importProperties === "function" &&
            backupSizeProperties.length > 0) {

            const restoreObject = {}
            for (let i = 0; i < backupSizeProperties.length; i++) {
                restoreObject[backupSizeProperties[i].name] = backupSizeProperties[i].value
            }
            targetElement.widget.importProperties(restoreObject)
        }

        // Синхронизируем модель слайдеров
        if (typeof targetElement.widget.getPropertiesSize === "function") {
            const freshProps = targetElement.widget.getPropertiesSize()
            sizeProperties = []
            for (let i = 0; i < freshProps.length; i++) {
                sizeProperties.push({
                    name: freshProps[i].name,
                    label: freshProps[i].label,
                    value: freshProps[i].value,
                    min: freshProps[i].min,
                    max: freshProps[i].max,
                    step: freshProps[i].step,
                    description: freshProps[i].description || ""
                })
            }
        }

        // Синхронизируем слайдеры
        widthSlider.value = backupRelW
        heightSlider.value = backupRelH
        widthField.text = Math.round(backupRelW * 100).toString()
        heightField.text = Math.round(backupRelH * 100).toString()
    }

    // =========================================================
    // ИНИЦИАЛИЗАЦИЯ
    // =========================================================
    onOpened: {
        if (!targetElement || !targetElement.widget) {
            console.warn("[DialogResize] Нет виджета для редактирования")
            sizeProperties = []
            backupSizeProperties = []
            return
        }

        // Очищаем массивы перед заполнением
        sizeProperties = []
        backupSizeProperties = []

        // Сохраняем бэкап геометрии
        backupRelW = targetElement.relW
        backupRelH = targetElement.relH

        // Загружаем свойства и создаём бэкап
        if (typeof targetElement.widget.getPropertiesSize === "function") {
            sizeProperties = targetElement.widget.getPropertiesSize()

            for (let i = 0; i < sizeProperties.length; i++) {
                backupSizeProperties.push({
                    name: sizeProperties[i].name,
                    label: sizeProperties[i].label,
                    value: sizeProperties[i].value,
                    min: sizeProperties[i].min,
                    max: sizeProperties[i].max,
                    step: sizeProperties[i].step,
                    description: sizeProperties[i].description || ""
                })
            }
        }

        // Инициализируем слайдеры
        widthSlider.value = backupRelW
        heightSlider.value = backupRelH
        widthField.text = Math.round(backupRelW * 100).toString()
        heightField.text = Math.round(backupRelH * 100).toString()

        wasApplied = false
    }

    onAboutToHide: {
        if (!wasApplied && targetElement && targetElement.widget) {
            root._restoreFromBackup()
        }
    }
}
