// edit_mode_internal/dialog_confirm_connection/DialogConfirmConnection.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.settings.menager_theme
import qml.controls.button

Popup {
    id: root
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    // === СИГНАЛЫ ===
    signal connectionConfirmed()
    signal connectionRejected()

    // 🔑 НОВОЕ: Флаг подтверждения (чтобы отличать закрытие от отмены)
    property bool wasConfirmed: false

    // === ДАННЫЕ СВЯЗИ ===
    property string sourceId: ""
    property string sourceName: ""
    property string signalName: ""
    property string signalDesc: ""
    property string targetId: ""
    property string targetName: ""
    property string slotName: ""
    property string slotDesc: ""

    // === МЕНЕДЖЕРЫ ===
    property var connectionManager: null
    property var componentRegister: null

    // === УСТАНОВКА ДАННЫХ ===
    function setConnectionData(srcId, srcName, sigName, tgtId, tgtName, sltName) {
        sourceId = srcId
        sourceName = srcName
        signalName = sigName
        targetId = tgtId
        targetName = tgtName
        slotName = sltName

        const srcElem = componentRegister?.getElementById(srcId)
        const tgtElem = componentRegister?.getElementById(tgtId)

        signalDesc = srcElem?.widgetRef?.exposedSignals?.[sigName] || "Без описания"
        slotDesc = tgtElem?.widgetRef?.exposedSlots?.[sltName] || "Без описания"

        updateDisplay()
        wasConfirmed = false  // Сбрасываем флаг при открытии
    }

    function updateDisplay() {
        sourceNameLabel.text = sourceName || sourceId
        sourceIdLabel.text = `ID: ${sourceId}`
        signalNameLabel.text = signalName
        signalDescLabel.text = signalDesc || "—"

        targetNameLabel.text = targetName || targetId
        targetIdLabel.text = `ID: ${targetId}`
        slotNameLabel.text = slotName
        slotDescLabel.text = slotDesc || "—"
    }

    implicitWidth: Math.max(450, contentLayout.implicitWidth + 40)
    implicitHeight: contentLayout.implicitHeight + 40

    background: Rectangle {
        color: "white"
        radius: 12
        border.color: "#333"
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 15
            samples: 30
            color: "#50000000"
            verticalOffset: 5
            horizontalOffset: 0
        }
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // === ЗАГОЛОВОК ===
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
                    text: "Подтверждение создания связи"
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

                    onClicked: {
                        connectionRejected()
                        root.close()
                    }
                }
            }
        }

        // === КОНТЕНТ (3 СТОЛБЦА) ===
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 25
            Layout.alignment: Qt.AlignVCenter

            // 🔵 ЛЕВЫЙ СТОЛБЕЦ: ИСТОЧНИК
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                Layout.alignment: Qt.AlignTop

                Text {
                    text: "Источник"
                    color: "#2196F3"
                    font.bold: true
                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "#2196F3"
                    radius: 1
                    Layout.topMargin: 3
                    Layout.bottomMargin: 8
                }

                Text {
                    id: sourceNameLabel
                    text: "—"
                    font.bold: true
                    color: "#2c3e50"
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 180
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    id: sourceIdLabel
                    text: "ID: —"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#ecf0f1"
                    Layout.topMargin: 10
                    Layout.bottomMargin: 8
                }

                Text {
                    text: "Сигнал:"
                    color: "#34495e"
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    id: signalNameLabel
                    text: "—"
                    color: "#2196F3"
                    font.bold: true
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 180
                }

                Text {
                    id: signalDescLabel
                    text: "—"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 180
                }
            }

            // ➡️ ЦЕНТРАЛЬНЫЙ СТОЛБЕЦ: СТРЕЛКА
            ColumnLayout {
                Layout.alignment: Qt.AlignCenter
                spacing: 0

                Rectangle {
                    width: 40
                    height: 40
                    color: "transparent"
                    radius: 20
                    border.color: "#3498db"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "→"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#3498db"
                    }
                }

                Text {
                    text: "создать связь"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    font.italic: true
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // 🟢 ПРАВЫЙ СТОЛБЕЦ: ПРИЁМНИК
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                Layout.alignment: Qt.AlignTop

                Text {
                    text: "Приёмник"
                    color: "#4CAF50"
                    font.bold: true
                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "#4CAF50"
                    radius: 1
                    Layout.topMargin: 3
                    Layout.bottomMargin: 8
                }

                Text {
                    id: targetNameLabel
                    text: "—"
                    font.bold: true
                    color: "#2c3e50"
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 180
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    id: targetIdLabel
                    text: "ID: —"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#ecf0f1"
                    Layout.topMargin: 10
                    Layout.bottomMargin: 8
                }

                Text {
                    text: "Слот:"
                    color: "#34495e"
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    id: slotNameLabel
                    text: "—"
                    color: "#4CAF50"
                    font.bold: true
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 180
                }

                Text {
                    id: slotDescLabel
                    text: "—"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 180
                }
            }
        }

        // === КНОПКИ ===
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 15
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: "Отмена"
                onClicked: {
                    connectionRejected()
                    root.close()
                }
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                background: Rectangle {
                    color: "#ecf0f1"
                    radius: 6
                    border.color: "#bdc3c7"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "#2c3e50"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
            }

            Button {
                text: "Создать связь"
                onClicked: {
                        // 🔑 ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ПЕРЕД СОЗДАНИЕМ
                        if (!connectionManager) {
                            console.error(" ConnectionManager = NULL в кнопке диалога!")
                            console.log(`   root.connectionManager: ${root.connectionManager ? "OK" : "NULL"}`)
                            root.close()
                            return
                        }

                        wasConfirmed = true
                        connectionConfirmed()
                        root.close()
                    }
                Layout.preferredWidth: 160
                Layout.preferredHeight: 40
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 6
                    border.color: "#43A047"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.pixelSize: 14
                }
            }
        }
    }

    onAboutToShow: {
        const screen = root.parent || Qt.application
        root.x = (screen.width - root.width) / 2
        root.y = (screen.height - root.height) / 2
        wasConfirmed = false  // 🔑 Сброс при каждом открытии
    }

    // 🔑 ИСПРАВЛЕНИЕ: Отправляем rejected ТОЛЬКО если не было подтверждения
    onClosed: {
        if (!wasConfirmed) {
            console.log(" Диалог закрыт без подтверждения → connectionRejected()")
            connectionRejected()
        } else {
            console.log(" Диалог закрыт после подтверждения → НЕ отправляем rejected")
        }
    }
}
