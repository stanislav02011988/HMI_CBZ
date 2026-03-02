// module qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_resize_element DialogResizeElement.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Shapes

Popup {
    id: root

    property Item targetElement: null

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    ColumnLayout {
        width: 260
        spacing: 0

        // ЗАГОЛОВОК
        Rectangle {
            id: dialogHeader
            Layout.fillWidth: true
            height: 32
            color: "#3498db"
            radius: [4, 4, 0, 0]

            Text {
                anchors.centerIn: parent
                text: "Размеры: " + (targetElement ? targetElement.type : "—")
                color: "white"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor
                property point dragStart
                onPressed: (mouse) => {
                    dragStart = Qt.point(mouse.x, mouse.y)
                    root.z = 9999
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        root.x += mouse.x - dragStart.x
                        root.y += mouse.y - dragStart.y
                    }
                }
            }
        }

        // ================= CONTENT =================

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 12
            spacing: 12

            // ================= WIDTH =================

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Ширина:"
                    Layout.preferredWidth: 70
                }

                Slider {
                    id: widthSlider
                    Layout.fillWidth: true

                    from: 0.05
                    to: 0.9

                    // ⚠ ВАЖНО: работаем в RELATIVE
                    value: targetElement ? targetElement.relW : 0.2

                    onMoved: {
                        if (!targetElement)
                            return

                        const newRelW = value

                        if (targetElement.relX + newRelW <= 1.0)
                            targetElement.relW = newRelW
                    }
                }

                Text {
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                    text: targetElement && targetElement.sceneContainer
                          ? Math.round(targetElement.relW *
                                       targetElement.sceneContainer.width) + " px"
                          : "—"
                }
            }

            // ================= HEIGHT =================

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Высота:"
                    Layout.preferredWidth: 70
                }

                Slider {
                    id: heightSlider
                    Layout.fillWidth: true

                    from: 0.05
                    to: 0.9

                    value: targetElement ? targetElement.relH : 0.2

                    onMoved: {
                        if (!targetElement)
                            return

                        const newRelH = value

                        if (targetElement.relY + newRelH <= 1.0)
                            targetElement.relH = newRelH
                    }
                }

                Text {
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                    text: targetElement && targetElement.sceneContainer
                          ? Math.round(targetElement.relH *
                                       targetElement.sceneContainer.height) + " px"
                          : "—"
                }
            }

            // ================= BUTTON =================

            Button {
                Layout.fillWidth: true
                text: "Готово"
                onClicked: root.close()
            }
        }
    }

    // ==================================================
    // СИНХРОНИЗАЦИЯ ПРИ ОТКРЫТИИ
    // ==================================================

    onOpened: {
        if (!targetElement)
            return

        widthSlider.value  = targetElement.relW
        heightSlider.value = targetElement.relH
    }
}
