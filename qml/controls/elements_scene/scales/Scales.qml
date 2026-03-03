//module qml.content.main_window.main_window_widgets.center_widget.component.scales
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button.toggle_button
import qml.controls.button.shutter
import qml.controls.truncated_cone
import qml.controls.triangle
import qml.controls.progress_bar
import qml.controls.tool_tip

import qml.settings.project_settings

import qml.utils.controllers_signals

Item {
    id: root

    // +++++++
    // === ОБЯЗАТЕЛЬНЫЕ СВОЙСТВА ДЛЯ СВЯЗЕЙ ===
    property string subtype: ""
    property string componentGroupe: ""

    property string id_widget: ""
    property string name_widget: ""

    // === СОСТОЯНИЕ РУЧНОГО РЕЖИМА ===
    property bool manualModeEnabled: false

    property int id_user: QmlProjectSettings.idUser
    property bool visibleBtnShutterLeft: true
    property bool visibleBtnShutterRight: true

    // === СОСТОЯНИЯ СИСТЕМЫ ===         // Ручной режим (активируется кнопкой hand)
    property bool systemInEmergency: false          // Аварийное состояние системы
    property bool isZeroingInProgress: false        // Флаг выполнения операции обнуления

    // === КОЭФФИЦИЕНТ МАСШТАБИРОВАНИЯ ТРЕУГОЛЬНИКОВ ===
    property real triangleScale: 0.25

    // === РАЗДЕЛЁННЫЕ БАЗОВЫЕ ЕДИНИЦЫ ДЛЯ ШИРИНЫ И ВЫСОТЫ ===
    readonly property real baseUnitW: root.width / 246
    readonly property real baseUnitH: root.height / 120

    // Адаптивные размеры кнопок
    readonly property real buttonSizeW:  20
    readonly property real buttonSizeH:  20

    // Отступы
    readonly property real spacingUnitW: baseUnitW * 1
    readonly property real marginUnitW: baseUnitW * 2
    readonly property real spacingUnitH: baseUnitH * 1
    readonly property real marginUnitH: baseUnitH * 2

    // Вычисляем доступную высоту для треугольников
    readonly property real triangleMaxHeight: (height * 0.25) * triangleScale

    // === ТЕНЬ ЧЕРЕЗ ОТДЕЛЬНЫЙ ЭЛЕМЕНТ ===
    Item {
        anchors.fill: parent

        DropShadow {
            anchors.fill: contentRect
            source: contentRect
            radius: 6
            samples: 16
            color: "#60000000"
            horizontalOffset: 2
            verticalOffset: 2
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
                    Layout.preferredHeight: root.height * 0.5
                    color: "transparent"
                    border.color: "#777777"
                    border.width: Math.max(2, Math.min(root.baseUnitW, root.baseUnitH) * 0.5)
                    topLeftRadius: Math.min(root.baseUnitW, root.baseUnitH) * 4
                    topRightRadius: Math.min(root.baseUnitW, root.baseUnitH) * 4

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: root.spacingUnitH * 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: parent.height * 0.65
                            spacing: 0
                            Layout.leftMargin: root.marginUnitW * 2
                            Layout.rightMargin: root.marginUnitW * 2
                            Layout.topMargin: root.marginUnitH * 1

                            // === КНОПКА РУЧНОГО РЕЖИМА (HAND) ===
                            CustomToggleButtonIcon {
                                id: btnHand
                                Layout.preferredWidth: root.baseUnitW * root.buttonSizeW
                                Layout.preferredHeight: root.baseUnitH * root.buttonSizeH
                                iconSource: checked
                                    ? "qrc:/svg_icon_btn/res/svg/svg_image_btn/hand/hand-point-right.svg"
                                    : "qrc:/svg_icon_btn/res/svg/svg_image_btn/hand/hand.svg"
                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"
                                checkable: true

                                // При нажатии включаем/выключаем ручной режим
                                onCheckedChanged: {
                                    // Локальное обновление состояния
                                    root.manualModeEnabled = checked

                                    if (!checked) {
                                        btnZeroing.checked = false
                                        root.isZeroingInProgress = false
                                    }
                                }

                                CustomToolTip {
                                    id: toolTipBtnHand
                                    target: btnHand
                                    customText: root.name_scales + "\n" + "Ручной режим управления."
                                    customDelay: 1000
                                    showOnDisabledOnly: false
                                    backgroundColor: root.systemInEmergency ? "#e74c3c" : "#2c3e50"
                                    borderColor: root.systemInEmergency ? "#c0392b" : "#3498db"
                                    fontSize: 13
                                }
                            }

                            Item {
                                Layout.preferredWidth: root.spacingUnitW * 3
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА СБРОСА АВАРИИ (RESET) ===
                            CustomToggleButtonIcon {
                                id: btnReset
                                Layout.preferredWidth: root.baseUnitW * root.buttonSizeW
                                Layout.preferredHeight: root.baseUnitH * root.buttonSizeH
                                iconSource: "qrc:/svg_icon_btn/res/svg/svg_image_btn/reset/reset_a.svg"
                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"

                                // Доступна ТОЛЬКО в ручном режиме
                                enabled: root.manualModeEnabled

                                // При нажатии сбрасываем аварийное состояние
                                onClicked: {
                                    if (root.systemInEmergency) {
                                        resetFeedbackTimer.start()
                                    }
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

                                    customDelay: 300
                                    backgroundColor: root.systemInEmergency ? "#e74c3c" : "#2c3e50"
                                    borderColor: root.systemInEmergency ? "#c0392b" : "#3498db"
                                    fontSize: 13
                                }


                                // === ИНДИКАТОР АВАРИИ В ПРАВОМ ВЕРХНЕМ УГЛУ КНОПКИ RESET ===
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    width: Math.max(8, root.baseUnitW * 4)   // Очень компактный: 8-12px
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
                                Layout.preferredWidth: root.spacingUnitW * 3
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА ОБНУЛЕНИЯ (ZEROING) ===
                            CustomToggleButtonIcon {
                                id: btnZeroing
                                Layout.preferredWidth: root.baseUnitW * root.buttonSizeW
                                Layout.preferredHeight: root.baseUnitH * root.buttonSizeH
                                iconSource: checked
                                    ? "qrc:/svg_icon_btn/res/svg/svg_image_btn/zeroing/zeroing_out_a.svg"
                                    : "qrc:/svg_icon_btn/res/svg/svg_image_btn/zeroing/zeroing_out_init.svg"
                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"

                                // Доступна ТОЛЬКО в ручном режиме И при отсутствии аварии И без активной операции
                                enabled: root.manualModeEnabled && !root.systemInEmergency && !root.isZeroingInProgress

                                // Логика автоматического отжатия
                                onCheckedChanged: {
                                    if (checked && enabled) {
                                        root.isZeroingInProgress = true
                                        autoReleaseTimer.restart()
                                    } else {
                                        autoReleaseTimer.stop()
                                        if (!checked) {
                                            root.isZeroingInProgress = false
                                        }
                                    }
                                }

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
                                            return root.name_scales + " " + "обнулить"
                                        } else if (root.systemInEmergency) {
                                            return root.name_scales + "\n" + "Есть ошибка!\nСначала сбросьте ошибку кнопкой Reset"
                                        } else if (root.isZeroingInProgress) {
                                            return "Операция обнуления уже выполняется..."
                                        }
                                        return "Кнопка обнуления весов"  // Пустой текст = подсказка не показывается
                                    }
                                    customDelay: 300
                                    showOnDisabledOnly: false
                                    backgroundColor: root.systemInEmergency ? "#e74c3c" : "#2c3e50"
                                    borderColor: root.systemInEmergency ? "#c0392b" : "#3498db"
                                    fontSize: 13
                                }
                            }

                            Item {
                                Layout.preferredWidth: root.spacingUnitW * 35
                                Layout.preferredHeight: 1
                            }

                            // === ДИСПЛЕЙ ВЕСОВ ===
                            Rectangle {
                                Layout.preferredWidth: root.baseUnitW * 30
                                Layout.fillHeight: true
                                color: "transparent"
                                radius: Math.min(root.baseUnitW, root.baseUnitH) * 1.2
                                border.color: "#777777"
                                border.width: Math.max(1, Math.min(root.baseUnitW, root.baseUnitH) * 0.4)

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        border.color: "#777777"
                                        border.width: Math.max(1, Math.min(root.baseUnitW, root.baseUnitH) * 0.3)
                                        radius: Math.min(root.baseUnitW, root.baseUnitH) * 0.8
                                        anchors.margins: Math.min(root.baseUnitW, root.baseUnitH) * 0.4

                                        Text {
                                            text: "1546.8"
                                            anchors.centerIn: parent
                                            font.pixelSize: Math.max(6, root.baseUnitW * 9)
                                            font.family: "Times New Roman"
                                            color: "#333333"
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#e0e0e0"
                                        radius: Math.min(root.baseUnitW, root.baseUnitH) * 1.0
                                        border.color: "#777777"
                                        border.width: Math.max(1, Math.min(root.baseUnitW, root.baseUnitH) * 0.3)
                                        topRightRadius: 0
                                        topLeftRadius: 0
                                        anchors.margins: Math.min(root.baseUnitW, root.baseUnitH) * 0.4

                                        Text {
                                            text: "380.8"
                                            anchors.centerIn: parent
                                            font.pixelSize: Math.max(6, root.baseUnitW * 9)
                                            font.family: "Times New Roman"
                                            color: "#333333"
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.preferredWidth: root.spacingUnitW * 80
                                Layout.preferredHeight: 1
                            }

                            // === КНОПКА НАСТРОЕК ===
                            CustomToggleButtonIcon {
                                id: btnSettings
                                Layout.preferredWidth: root.baseUnitW * root.buttonSizeW
                                Layout.preferredHeight: root.baseUnitH * root.buttonSizeH
                                iconSource: "qrc:/svg_icon_btn/res/svg/svg_image_btn/setting/setting_d.svg"
                                m_background_color: "transparent"
                                m_color_hovered: "#888"
                                m_color_checked: "#666666"

                                iconColor: "#666666"
                                iconColorHovered: "white"
                                iconColorChecked: "white"
                                iconColorCheckedHovered: "white"
                                checkable: true

                                CustomToolTip {
                                    target: btnSettings
                                    customText: "Настройки весов"
                                    customDelay: 300
                                    showOnDisabledOnly: false
                                    backgroundColor: "#3498db"
                                    borderColor: "#2980b9"
                                    fontSize: 13
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Rectangle {
                                Layout.preferredWidth: root.baseUnitW * root.buttonSizeW
                                Layout.preferredHeight: root.baseUnitH * root.buttonSizeH
                                color: "transparent"
                                border.color: "#777777"
                                border.width: Math.max(1, Math.min(root.baseUnitW, root.baseUnitH) * 0.6)
                                radius: Math.min(root.baseUnitW, root.baseUnitH) * 4
                                Layout.margins: root.marginUnitH * 2

                                Text {
                                    text: "1"
                                    anchors.centerIn: parent
                                    font.pixelSize: Math.max(12, root.baseUnitW * 5)
                                    font.family: "Times New Roman"
                                    color: "#333333"
                                }
                            }

                            CustomProgressBar {
                                id: customProgressBarScales
                                Layout.fillWidth: true
                                Layout.preferredHeight: root.baseUnitH * root.buttonSizeH
                                visible_border_progress: true
                                blockSpacing: -5
                                padding: 4
                                textPosition: "none"
                                blockCount: 1
                                value: 0.8
                            }

                            Item {
                                Layout.preferredWidth: root.spacingUnitW
                                Layout.preferredHeight: 1
                            }
                        }
                    }
                }

                // === Усечённый конус ===
                TruncatedCone {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.height * 0.35
                    borderWidth: Math.max(2, Math.min(root.baseUnitW, root.baseUnitH) * 0.5)
                    borderColor: "#777777"
                    liquidColor: "#d55f6d7a"
                    fillColor: "#00e6e6e6"
                    level: 0.5

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.min(root.baseUnitW, root.baseUnitH) * 1.2

                        Text {
                            text: "1560.78"
                            font.pixelSize: Math.max(18, root.baseUnitW * 9)
                            font.family: "Times New Roman"
                            color: "#222222"
                        }

                        Text {
                            text: "кг"
                            font.pixelSize: Math.max(13, root.baseUnitW * 6)
                            font.family: "Times New Roman"
                            color: "#555555"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // === Кнопки шторок ===
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.height * 0.1
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: root.marginUnitH * 0.6
                    spacing: Math.min(root.baseUnitW, root.baseUnitH) * 6

                    BtnShutter {
                        visible: root.visibleBtnShutterLeft
                        Layout.fillHeight: true
                        Layout.preferredWidth: root.width * 0.43
                    }

                    BtnShutter {
                        visible: root.visibleBtnShutterRight
                        Layout.fillHeight: true
                        Layout.preferredWidth: root.width * 0.43
                    }
                }
            }
        }
    }
}
