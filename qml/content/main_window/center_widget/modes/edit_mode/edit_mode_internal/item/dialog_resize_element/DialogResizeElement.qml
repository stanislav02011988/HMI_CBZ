// module qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_resize_element DialogResizeElement.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Shapes

Popup {
    id: root

    property Item targetElement: null  // ← ссылка на EditableItem
    property var parentWindow: null

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Позиционирование по центру родительского окна
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

        // СОДЕРЖИМОЕ
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            Layout.margins: 12

            // ШИРИНА
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text { text: "Ширина:"; Layout.preferredWidth: 70; verticalAlignment: Text.AlignVCenter }

                // ОБЁРТКА ДЛЯ СЛАЙДЕРА С ПОДДЕРЖКОЙ КОЛЕСА
                Item {
                    Layout.fillWidth: true
                    height: 24

                    Slider {
                        id: widthSlider
                        anchors.fill: parent
                        from: 30
                        to: targetElement && targetElement.sceneContainer ? targetElement.sceneContainer.width * 0.9 : 800
                        value: targetElement ? targetElement.width : 0
                        onValueChanged: {
                            if (targetElement && targetElement.sceneContainer) {
                                var newRelW = widthSlider.value / targetElement.sceneContainer.width
                                if (targetElement.relX + newRelW <= 1.0) {
                                    targetElement.relW = Math.max(30 / targetElement.sceneContainer.width, newRelW)
                                }
                            }
                        }
                    }

                    //
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton  // важно: не перехватывать клики!
                        onWheel: (wheel) => {
                            var range = widthSlider.to - widthSlider.from
                            var step = range > 0 ? range * 0.02 : 10
                            var delta = wheel.angleDelta.y > 0 ? step : -step
                            var newValue = widthSlider.value + delta
                            widthSlider.value = Math.max(widthSlider.from, Math.min(widthSlider.to, newValue))
                            wheel.accepted = true
                        }
                    }
                }

                Text {
                    text: targetElement ? Math.round(targetElement.width) + " px" : "—"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }
            }

            // ВЫСОТА
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text { text: "Высота:"; Layout.preferredWidth: 70; verticalAlignment: Text.AlignVCenter }

                Item {
                    Layout.fillWidth: true
                    height: 24

                    Slider {
                        id: heightSlider
                        anchors.fill: parent
                        from: 30
                        to: targetElement && targetElement.sceneContainer ? targetElement.sceneContainer.height * 0.9 : 800
                        value: targetElement ? targetElement.height : 0
                        onValueChanged: {
                            if (targetElement && targetElement.sceneContainer) {
                                var newRelH = heightSlider.value / targetElement.sceneContainer.height
                                if (targetElement.relY + newRelH <= 1.0) {
                                    targetElement.relH = Math.max(30 / targetElement.sceneContainer.height, newRelH)
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        onWheel: (wheel) => {
                            var range = heightSlider.to - heightSlider.from
                            var step = range > 0 ? range * 0.02 : 10
                            var delta = wheel.angleDelta.y > 0 ? step : -step
                            var newValue = heightSlider.value + delta
                            heightSlider.value = Math.max(heightSlider.from, Math.min(heightSlider.to, newValue))
                            wheel.accepted = true
                        }
                    }
                }

                Text {
                    text: targetElement ? Math.round(targetElement.height) + " px" : "—"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }
            }

            Text {
                text: "💡 Совет: колесо мыши над элементом изменяет размер"
                font.italic: true
                color: "#7f8c8d"
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: 11
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                Button {
                    Layout.fillWidth: true
                    text: "Готово"
                    onClicked: root.close()
                    background: Rectangle { color: "#2ecc71"; radius: 4 }
                }
            }
        }
    }

    onOpened: {
        if (targetElement && targetElement.sceneContainer) {
            widthSlider.to = targetElement.sceneContainer.width * 0.9
            heightSlider.to = targetElement.sceneContainer.height * 0.9
        }
        widthSlider.value = targetElement ? targetElement.width : 0
        heightSlider.value = targetElement ? targetElement.height : 0
    }
}
