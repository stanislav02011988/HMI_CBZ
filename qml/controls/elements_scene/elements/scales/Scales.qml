//module qml.content.main_window.main_window_widgets.center_widget.component.scales
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.busManager
import qml.controls.button.toggle_button
import qml.controls.truncated_cone
import qml.controls.triangle
import qml.controls.progress_bar
import qml.controls.tool_tip

import qml.settings.project_settings

import "../shutter"

Item {
    id: root

    // ==========================================================
    // INTERNAL ELEMENT ALIAS (ДЛЯ РЕДАКТОРА)
    // ==========================================================
    property alias el_btnHand: btnHand
    property alias el_btnReset: btnReset
    property alias el_btnZeroing: btnZeroing
    property alias el_btnSettings: btnSettings
    property alias el_progress: customProgressBarScales

    // ==========================================================
    // 🔵 1. SIGNAL SOURCES (СОБЫТИЯ)
    // ==========================================================
    function getSignalSources() {
        return [
            {
                elementId: "btnHand",
                object: el_btnHand,
                signals: [
                    { name: "clicked", params: [] },
                    { name: "checkedChanged", params: [{ name: "checked", type: "bool" }] }
                ]
            },
            {
                elementId: "btnReset",
                object: el_btnReset,
                signals: [
                    { name: "clicked", params: [] }
                ]
            },
            {
                elementId: "btnZeroing",
                object: el_btnZeroing,
                signals: [
                    { name: "checkedChanged", params: [{ name: "checked", type: "bool" }] }
                ]
            },
            {
                elementId: "btnSettings",
                object: el_btnSettings,
                signals: [
                    { name: "clicked", params: [] }
                ]
            }
        ]
    }

    // ==========================================================
    // 🟢 2. SLOT TARGETS (ДЕЙСТВИЯ)
    // ==========================================================
    function getSlotTargets() {
        return [
            {
                elementId: "progressBar",
                object: el_progress,
                slots: [{ name: "setValue", params: [{ name: "value", type: "real" }] }]
            },
            {
                elementId: "btnHand",
                object: el_btnHand,
                slots: [{ name: "setChecked", params: [{ name: "checked", type: "bool" }] }]
            },
            {
                elementId: "btnReset",
                object: el_btnReset,
                slots: [{ name: "setChecked", params: [{ name: "checked", type: "bool" }] }]
            },
            {
                elementId: "btnZeroing",
                object: el_btnZeroing,
                slots: [{ name: "setChecked", params: [{ name: "checked", type: "bool" }] }]
            }
        ]
    }

    // ==========================================================
    // 🔴 3. APPLY SLOT (ИСПОЛНЕНИЕ)
    // ==========================================================
    function applySlot(elementId, slotName, params) {
        const targets = getSlotTargets()
        for (let i = 0; i < targets.length; i++) {

            const t = targets[i]

            if (t.elementId !== elementId)
                continue

            const obj = t.object

            if (slotName === "setValue") {
                obj.value = params.value
            }

            if (slotName === "setChecked") {
                obj.checked = params.checked
            }
        }
    }

    // ==========================================================
    // EVENT EMIT (ЕДИНАЯ ТОЧКА)
    // ==========================================================
    function emitSignal(elementId, signalName, payload) {
        QmlBusManager.publish(
            root.id_widget + "." + elementId,
            signalName,
            payload
        )
    }

    // ==========================================================
    // Синхронизация (ЕДИНАЯ ТОЧКА)
    // ==========================================================
    ReactiveElement {
        id:syncManager
        widgetId: root.id_widget
        slotTargets: root.getSlotTargets()
        syncFn: root.syncElement
    }

    Component.onCompleted: syncManager.start()

    function syncElement(event, payload, target) {
        switch(target.elementId) {

            case "btnHand":
                if(event === "checkedChanged") {
                    target.object.checked = payload.checked
                    root.manualModeEnabled = payload.checked
                }
                break

            case "btnZeroing":
                if(event === "checkedChanged") {
                    target.object.checked = payload.checked
                    if (payload.checked && enabled) {
                        root.isZeroingInProgress = payload.checked
                        autoReleaseTimer.restart()
                    } else {
                        autoReleaseTimer.stop()
                        if (!payload.checked) {
                            root.isZeroingInProgress = payload.checked
                        }
                    }
                }
                break

            case "btnReset":
                if(event === "clicked") {
                    if(payload.hasOwnProperty("checked"))
                        target.object.checked = payload.checked
                    if(payload.hasOwnProperty("systemInEmergency"))
                        root.systemInEmergency = payload.systemInEmergency
                }
                break

            case "btnSettings":
                if(event === "clicked") {
                    if(payload.hasOwnProperty("checked"))
                        target.object.checked = payload.checked
                }
                break

            case "progressBar":
                if(event === "setValue") {
                    target.object.value = payload.value
                }
                break

            default:
                console.warn("Unknown elementId in syncElement:", target.elementId)
                break
        }
    }

    // ==========================================================
    // 1. ЭТАЛОН
    // ==========================================================
    property real referenceWidth: 240
    property real referenceHeight: 150

    implicitWidth: referenceWidth
    implicitHeight: referenceHeight

    // ==========================================================
    // 2. КОЭФФИЦИЕНТЫ (ВМЕСТО SCALE)
    // ==========================================================
    property real kx: width  / referenceWidth
    property real ky: height / referenceHeight

    // ==========================================================
    // 3. КОНФИГУРАЦИЯ РАЗМЕРОВ
    // ==========================================================
    property int containerRadius: 6
    property real borderWidth: 2

    property real shadowRadius: 6
    property real shadowOffsetX: 2
    property real shadowOffsetY: 2

    property real spacing: 2
    property real margin: 4

    property real heightTopPanelBtn: 100

    property int heightTruncatedCone: 30
    property int borderWidthTrancatedCone: 2
    property int sizeTextTrancatedCone: 20
    property int sizeText2TrancatedCone: 14
    property real levelTrancatedCone: 0.5

    property int buttonSize: 25
    property int borderWidthBtn: 1
    property int spacingBtn: 4
    property int radiusBtn: 4
    property real iconScale: 0.5

    property real sizePanelTextWidth: 30
    property real sizePanelTextHeight: 30
    property int sizePanelText1: 10
    property int sizePanelText2: 8
    property int panelTextBorderWidth: 1
    property int paddingPanelLeft: 40
    property int paddingPanelRight: 40
    property int radiusPanel: 4

    property int widthProgressBar: 180
    property int heightProgressBar: 25
    property int borderWidthProgressBar: 2
    property int borderRadiusProgressBar: 4

    property int state_width_and_height: 25
    property int state_size_text: 10
    property int stateRadius: 4
    property int stateBorderWidth: 1

    property real widthShutter: 50
    property real heightShutter: 10

    property real spacingShutter: 1

    // ==========================================================
    // 4. БИЗНЕС СВОЙСТВА
    // ==========================================================
    property string subtype: ""
    property string componentGroupe: ""

    property string id_widget: ""
    property string name_widget: ""

    property bool manualModeEnabled: false
    property bool systemInEmergency: false
    property bool isZeroingInProgress: false

    // ==========================================================
    // 5. ОСНОВНОЙ КОНТЕЙНЕР
    // ==========================================================
    layer.enabled: true
    layer.effect: DropShadow {
        color: "#60000000"
        radius: shadowRadius
        horizontalOffset: shadowOffsetX * kx
        verticalOffset: shadowOffsetY * ky
    }


    Rectangle {
        id: contentRect
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // === Верхняя панель с кнопками и дисплеем ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: heightTopPanelBtn * ky
                color: "transparent"
                border.color: "#777777"
                border.width: borderWidth * kx
                topLeftRadius: containerRadius * kx
                topRightRadius: containerRadius * kx

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.margins: 5 * kx * ky
                        color: "transparent"

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            Item {
                                Layout.preferredWidth: spacingBtn * kx
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА РУЧНОГО РЕЖИМА (HAND) ===
                            CustomToggleButtonIcon {
                                id: btnHand
                                Layout.preferredWidth: buttonSize * kx
                                Layout.preferredHeight: buttonSize * ky
                                iconScale: iconScale
                                iconSource: checked
                                    ? "qrc:/svg_icon_btn/res/svg/svg_image_btn/hand/hand-point-right.svg"
                                    : "qrc:/svg_icon_btn/res/svg/svg_image_btn/hand/hand.svg"
                                m_borderWidth: borderWidthBtn * kx
                                m_radius: radiusBtn * kx
                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"
                                checkable: true

                                // onClicked: {
                                //     emitSignal("btnHand", "checkedChanged", {
                                //         checked: checked
                                //     })
                                // }

                                onCheckedChanged: {
                                    emitSignal("btnHand", "checkedChanged", {
                                        checked: checked
                                    })
                                }

                                CustomToolTip {
                                    id: toolTipBtnHand
                                    target: btnHand
                                    customText: root.name_widget + "\n" + "Ручной режим управления."
                                    customDelay: 2000
                                    showOnDisabledOnly: false
                                    backgroundColor: root.systemInEmergency ? "#e74c3c" : "#2c3e50"
                                    borderColor: root.systemInEmergency ? "#c0392b" : "#3498db"
                                    fontSize: 13
                                }
                            }

                            Item {
                                Layout.preferredWidth: spacingBtn * kx
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА СБРОСА АВАРИИ (RESET) ===
                            CustomToggleButtonIcon {
                                id: btnReset
                                Layout.preferredWidth: buttonSize * kx
                                Layout.preferredHeight: buttonSize * ky
                                iconSource: "qrc:/svg_icon_btn/res/svg/svg_image_btn/reset/reset_a.svg"
                                m_borderWidth: borderWidthBtn * kx
                                m_radius: radiusBtn * kx

                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"
                                checkable: true
                                // Доступна ТОЛЬКО в ручном режиме
                                enabled: root.manualModeEnabled

                                // При нажатии сбрасываем аварийное состояние
                                onClicked: {
                                    emitSignal("btnReset", "clicked", {})
                                }

                                // Таймер для визуальной обратной связи сброса
                                Timer {
                                    id: resetFeedbackTimer
                                    interval: 2000
                                    onTriggered: {
                                        btnReset.checked = true
                                        root.systemInEmergency = false
                                        btnReset.checked = false
                                    }
                                }

                                CustomToolTip {
                                    id: toolTipBtnReset
                                    target: btnReset
                                    customText: {
                                        if (root.systemInEmergency) {
                                            showOnDisabledOnly = true
                                            return "Система в аварийном состоянии! Сначала сбросьте аварию кнопкой Reset"
                                        } else {
                                            showOnDisabledOnly = false
                                            return "Кнопка Сброса ошибок.\nВ данный момент ошибок нет."
                                        }
                                    }

                                    customDelay: 2000
                                    backgroundColor: root.systemInEmergency ? "#e74c3c" : "#2c3e50"
                                    borderColor: root.systemInEmergency ? "#c0392b" : "#3498db"
                                    fontSize: 13
                                }


                                // === ИНДИКАТОР АВАРИИ В ПРАВОМ ВЕРХНЕМ УГЛУ КНОПКИ RESET ===
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    width: Math.max(8, kx * 4)   // Очень компактный: 8-12px
                                    height: width
                                    radius: width / 2
                                    color: "#ff3333"
                                    border.color: "white"
                                    border.width: 1
                                    visible: root.systemInEmergency  // Появляется ТОЛЬКО при аварии

                                    // Интенсивное мигание для привлечения внимания
                                    SequentialAnimation on opacity {
                                        running: root.systemInEmergency
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.0; duration: 400 }
                                        NumberAnimation { to: 0.4; duration: 400 }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "!"
                                        font.pixelSize: Math.max(6, width * 0.8)
                                        font.bold: true
                                        color: "white"
                                    }
                                }
                            }

                            Item {
                                Layout.preferredWidth: spacingBtn * kx
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА ОБНУЛЕНИЯ (ZEROING) ===
                            CustomToggleButtonIcon {
                                id: btnZeroing
                                Layout.preferredWidth: buttonSize * kx
                                Layout.preferredHeight: buttonSize * ky
                                iconSource: checked
                                    ? "qrc:/svg_icon_btn/res/svg/svg_image_btn/zeroing/zeroing_out_a.svg"
                                    : "qrc:/svg_icon_btn/res/svg/svg_image_btn/zeroing/zeroing_out_init.svg"
                                m_borderWidth: borderWidthBtn * kx
                                m_radius: radiusBtn * kx

                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"

                                // Доступна ТОЛЬКО в ручном режиме И при отсутствии аварии И без активной операции
                                enabled: root.manualModeEnabled && !root.systemInEmergency && !root.isZeroingInProgress

                                onClicked: {
                                    emitSignal("btnZeroing", "checkedChanged", {
                                        checked: checked
                                    })
                                }

                                // onCheckedChanged: {
                                //     if (checked && enabled) {
                                //         root.isZeroingInProgress = true
                                //         autoReleaseTimer.restart()
                                //     } else {
                                //         autoReleaseTimer.stop()
                                //         if (!checked) {
                                //             root.isZeroingInProgress = false
                                //         }
                                //     }
                                // }

                                // Таймер автоматического отжатия (2 секунды)
                                Timer {
                                    id: autoReleaseTimer
                                    interval: 2000
                                    repeat: false
                                    onTriggered: {
                                        btnZeroing.checked = false
                                        root.isZeroingInProgress = false
                                    }
                                }

                                CustomToolTip {
                                    id: toolTipBtnZeroing
                                    target: btnZeroing
                                    customText: {
                                        if (!root.manualModeEnabled) {
                                            return root.name_widget + " " + "обнулить"
                                        } else if (root.systemInEmergency) {
                                            return root.name_widget + "\n" + "Есть ошибка!\nСначала сбросьте ошибку кнопкой Reset"
                                        } else if (root.isZeroingInProgress) {
                                            return "Операция обнуления уже выполняется..."
                                        }
                                        return "Кнопка обнуления весов"  // Пустой текст = подсказка не показывается
                                    }
                                    customDelay: 2000
                                    showOnDisabledOnly: false
                                    backgroundColor: root.systemInEmergency ? "#e74c3c" : "#2c3e50"
                                    borderColor: root.systemInEmergency ? "#c0392b" : "#3498db"
                                    fontSize: 13
                                }
                            }

                            Item {
                                Layout.preferredWidth: paddingPanelLeft * kx
                                Layout.preferredHeight: 1
                            }

                            // === ДИСПЛЕЙ ВЕСОВ ===
                            Rectangle {
                                Layout.preferredWidth: sizePanelTextWidth * kx
                                Layout.preferredHeight: sizePanelTextHeight * ky
                                color: "transparent"
                                radius: radiusPanel * ky
                                border.color: "#777777"
                                border.width: panelTextBorderWidth * ky

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        border.color: "#777777"
                                        border.width: panelTextBorderWidth * ky
                                        radius: radiusPanel * ky
                                        bottomLeftRadius: 0
                                        bottomRightRadius: 0
                                        anchors.margins: radiusPanel * ky

                                        Text {
                                            text: "1546.8"
                                            anchors.centerIn: parent
                                            font.pixelSize: sizePanelText1 * ky
                                            font.family: "Times New Roman"
                                            color: "#333333"
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#e0e0e0"
                                        radius: radiusPanel * ky
                                        border.color: "#777777"
                                        border.width: panelTextBorderWidth * ky
                                        topRightRadius: 0
                                        topLeftRadius: 0
                                        anchors.margins: radiusPanel * ky

                                        Text {
                                            text: "380.8"
                                            anchors.centerIn: parent
                                            font.pixelSize: sizePanelText2 * ky
                                            font.family: "Times New Roman"
                                            color: "#333333"
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.preferredWidth: paddingPanelRight * kx
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА НАСТРОЕК ===
                            CustomToggleButtonIcon {
                                id: btnSettings
                                Layout.preferredWidth: buttonSize * kx
                                Layout.preferredHeight: buttonSize * ky
                                iconSource: "qrc:/svg_icon_btn/res/svg/svg_image_btn/setting/setting_d.svg"
                                m_borderWidth: borderWidthBtn * kx
                                m_radius: radiusBtn * kx

                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"
                                checkable: true

                                onClicked: {
                                    emitSignal("btnSettings", "clicked", {})
                                }

                                CustomToolTip {
                                    target: btnSettings
                                    customText: "Настройки весов" + " " + name_widget
                                    customDelay: 300
                                    showOnDisabledOnly: false
                                    backgroundColor: "#3498db"
                                    borderColor: "#2980b9"
                                    fontSize: 13
                                }
                            }

                            Item {
                                Layout.preferredWidth: spacing * kx
                                Layout.preferredHeight: 1
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.margins: 5 * kx * ky
                        color: "transparent"

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: root.spacing * kx * ky

                            Rectangle {
                                Layout.preferredWidth: state_width_and_height * kx
                                Layout.preferredHeight: state_width_and_height * ky
                                color: "transparent"
                                border.color: "#777777"
                                border.width: stateBorderWidth * ky
                                radius: stateRadius * ky
                                Layout.margins: margin * 2

                                Text {
                                    text: "1"
                                    anchors.centerIn: parent
                                    font.pixelSize: state_size_text * ky
                                    font.family: "Times New Roman"
                                    color: "#333333"
                                }
                            }

                            CustomProgressBar {
                                id: customProgressBarScales
                                Layout.preferredWidth: widthProgressBar * kx
                                Layout.preferredHeight: heightProgressBar * ky
                                visible_border_progress: true
                                borderRadius: borderRadiusProgressBar * ky
                                borderWidth: borderWidthProgressBar * ky
                                blockSpacing: -5
                                padding: 4
                                textPosition: "none"
                                blockCount: 1
                                value: 0.8
                            }
                        }
                    }
                }
            }

            // === Усечённый конус ===
            TruncatedCone {
                Layout.fillWidth: true
                Layout.preferredHeight: heightTruncatedCone * ky
                borderWidth: borderWidthTrancatedCone * ky
                borderColor: "#777777"
                liquidColor: "#d55f6d7a"
                fillColor: "#00e6e6e6"
                level: levelTrancatedCone

                RowLayout {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: root.spacing * ky

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }

                    Text {
                        text: "1560.78"
                        font.pixelSize: sizeTextTrancatedCone * ky
                        font.family: "Times New Roman"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "#222222"
                    }

                    Text {
                        text: "кг"
                        font.pixelSize: sizeText2TrancatedCone * ky
                        font.family: "Times New Roman"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "#555555"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: spacingShutter * kx
                }

                Shutter {
                    id: shutterLeft
                    Layout.preferredWidth: widthShutter * kx
                    Layout.preferredHeight: heightShutter * ky
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: spacingShutter * kx
                }

                Shutter {
                    id: shutterRight
                    Layout.preferredWidth: widthShutter * kx
                    Layout.preferredHeight: heightShutter * ky
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: spacingShutter * kx
                }
            }
        }
    }
    // ==========================================================
    // 6. API РЕДАКТОРА Размеры элементов
    // ==========================================================
    function getPropertiesSize() {
        return [
            {
                idGroupeProperty: "box",
                nameGroupeProperty: "Свойства линий",
                name: "containerRadius",
                value: containerRadius,
                min: 0,
                max: 100,
                step: 1,
                label: "Радиус"
            },
            {
                idGroupeProperty: "box",
                nameGroupeProperty: "Свойства линий",
                name: "borderWidth",
                value: borderWidth,
                min: 0,
                max: 100,
                step: 0.1,
                label: "Толщина линии"
            },

            // Группа: Дисплей панели
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "heightTopPanelBtn",
                value: heightTopPanelBtn,
                min: 10,
                max: 500,
                step: 1,
                label: "Высота верхней панели кнопок"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "sizePanelTextWidth",
                value: sizePanelTextWidth,
                min: 10,
                max: 500,
                step: 1,
                label: "Ширина текстовой панели"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "sizePanelTextHeight",
                value: sizePanelTextHeight,
                min: 10,
                max: 500,
                step: 1,
                label: "Высота текстовой панели"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "panelTextBorderWidth",
                value: panelTextBorderWidth,
                min: 0,
                max: 50,
                step: 1,
                label: "Толщина линии панели"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "radiusPanel",
                value: radiusPanel,
                min: 0,
                max: 50,
                step: 1,
                label: "Радиус панели"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "paddingPanelLeft",
                value: paddingPanelLeft,
                min: 0,
                max: 500,
                step: 1,
                label: "Отступ панели с лева"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "paddingPanelRight",
                value: paddingPanelRight,
                min: 0,
                max: 500,
                step: 1,
                label: "Отступ панели с права"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "sizePanelText1",
                value: sizePanelText1,
                min: 4,
                max: 50,
                step: 1,
                label: "Размер шрифта 1 текстовой панели"
            },
            {
                idGroupeProperty: "tublo",
                nameGroupeProperty: "Свойства дисплей-панели",
                name: "sizePanelText2",
                value: sizePanelText2,
                min: 4,
                max: 50,
                step: 1,
                label: "Размер шрифта 2 текстовой панели"
            },
                    // Кнопки управления
            {
                idGroupeProperty: "button_control",
                nameGroupeProperty: "Свойства кнопок управления",
                name: "buttonSize",
                value: buttonSize,
                min: 10,
                max: 500,
                step: 1,
                label: "Размер кнопок управления"
            },
            {
                idGroupeProperty: "button_control",
                nameGroupeProperty: "Свойства кнопок управления",
                name: "borderWidthBtn",
                value: borderWidthBtn,
                min: 0,
                max: 50,
                step: 1,
                label: "Толщина линии"
            },
            {
                idGroupeProperty: "button_control",
                nameGroupeProperty: "Свойства кнопок управления",
                name: "radiusBtn",
                value: radiusBtn,
                min: 0,
                max: 500,
                step: 1,
                label: "Радиус закругления углов"
            },
            {
                idGroupeProperty: "button_control",
                nameGroupeProperty: "Свойства кнопок управления",
                name: "spacingBtn",
                value: spacingBtn,
                min: 0,
                max: 500,
                step: 1,
                label: "Зазор между кнопками"
            },

            // Группа: Прогресс-бар
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "widthProgressBar",
                value: widthProgressBar,
                min: 1,
                max: 500,
                step: 1,
                label: "Ширина"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "heightProgressBar",
                value: heightProgressBar,
                min: 1,
                max: 500,
                step: 1,
                label: "Высота"
            },
            {
                idGroupeProperty: "progressBar",
                nameGroupeProperty: "Свойства прогресс-бара",
                name: "borderRadiusProgressBar",
                value: borderRadiusProgressBar,
                min: 0,
                max: 100,
                step: 1,
                label: "Радиус прогресс бара"
            },

                    // Панель Стадии выполнения
            {
                idGroupeProperty: "stateWark",
                nameGroupeProperty: "Свойства стадии выполенения",
                name: "state_width_and_height",
                value: state_width_and_height,
                min: 0,
                max: 100,
                step: 1,
                label: "Размер контура стадии выполнения"
            },
            {
                idGroupeProperty: "stateWark",
                nameGroupeProperty: "Свойства стадии выполенения",
                name: "state_size_text",
                value: state_size_text,
                min: 0,
                max: 100,
                step: 1,
                label: "Размер текста"
            },
            {
                idGroupeProperty: "stateWark",
                nameGroupeProperty: "Свойства стадии выполенения",
                name: "stateBorderWidth",
                value: stateBorderWidth,
                min: 0,
                max: 100,
                step: 1,
                label: "Толщина линии контура стадии выполенения"
            },
            {
                idGroupeProperty: "stateWark",
                nameGroupeProperty: "Свойства стадии выполенения",
                name: "stateRadius",
                value: stateRadius,
                min: 0,
                max: 100,
                step: 1,
                label: "Радиус контура стадии"
            },

                    // Усеченый конус
            {
                idGroupeProperty: "trancatedcone",
                nameGroupeProperty: "Свойства усеченного конуса",
                name: "heightTruncatedCone",
                value: heightTruncatedCone,
                min: 0,
                max: 100,
                step: 1,
                label: "Высота конуса"
            },
            {
                idGroupeProperty: "trancatedcone",
                nameGroupeProperty: "Свойства усеченного конуса",
                name: "borderWidthTrancatedCone",
                value: borderWidthTrancatedCone,
                min: 0,
                max: 100,
                step: 1,
                label: "Толщина линии контура"
            },
            {
                idGroupeProperty: "trancatedcone",
                nameGroupeProperty: "Свойства усеченного конуса",
                name: "sizeTextTrancatedCone",
                value: sizeTextTrancatedCone,
                min: 0,
                max: 100,
                step: 1,
                label: "Размер шрифта первого текста"
            },
            {
                idGroupeProperty: "trancatedcone",
                nameGroupeProperty: "Свойства усеченного конуса",
                name: "sizeText2TrancatedCone",
                value: sizeText2TrancatedCone,
                min: 0,
                max: 100,
                step: 1,
                label: "Размер шрифта второго текста"
            },
                    // Настройка размеров затворов весов
            {
                idGroupeProperty: "Shutter",
                nameGroupeProperty: "Размеры затворов",
                name: "widthShutter",
                value: widthShutter,
                min: 0,
                max: 200,
                step: 0.1,
                label: "Ширина левого затвора"
            },
            {
                idGroupeProperty: "Shutter",
                nameGroupeProperty: "Размеры затворов",
                name: "heightShutter",
                value: heightShutter,
                min: 0,
                max: 200,
                step: 0.1,
                label: "Высота левого затвора"
            },
            {
                idGroupeProperty: "Shutter",
                nameGroupeProperty: "Размеры затворов",
                name: "spacingShutter",
                value: spacingShutter,
                min: 0,
                max: 100,
                step: 0.1,
                label: "Растояние между затворами"
            }
        ];
    }

    function setPropertySize(name, value) {
        if (root.hasOwnProperty(name)) {
            root[name] = value
        }
    }
        // EXPORT / IMPORT
    function exportPropertiesSize() {
        var props = getPropertiesSize()
        var result = {}

        for (var i = 0; i < props.length; i++) {

            var p = props[i]
            result[p.name] = root[p.name]
        }

        return result
    }

    function importProperties(data) {
        if (!data)
            return

        for (let key in data) {

            if (root.hasOwnProperty(key))
                root[key] = data[key]
        }
    }

    // ==========================================================
    // 7. API Бизнес Свйоства
    // ==========================================================
}

