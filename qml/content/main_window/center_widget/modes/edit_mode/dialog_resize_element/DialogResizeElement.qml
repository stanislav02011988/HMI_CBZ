
// module qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_resize_element
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material

Popup {
    id: root

    // =========================================================
    // ДАННЫЕ
    // =========================================================
    property Item targetElement: null
    property var sizeProperties: []

    property real panelWidth: 550
    property real minWidth: 280
    property real maxWidth: 700

    readonly property Item container: parent

    // =========================================================
    // ПОЗИЦИЯ СПРАВА
    // =========================================================
    property real hiddenX: container ? container.width : 0
    property real visibleX: container ? container.width - width : 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0
    Overlay.modal: Rectangle {
        color: "transparent"
    }

    // background: Rectangle {
    //     color: "transparent"
    //     radius: 6
    // }

    width: panelWidth
    height: container.height

    x: opened ? visibleX : hiddenX
    y: 0

    property bool isResizing: false
    Behavior on x {
        enabled: !root.isResizing
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // =========================================================
    // RESIZE СЛЕВА
    // =========================================================
    Rectangle {
        width: 6
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "transparent"
        z: 1000

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor

            property real startMouseX
            property real startWidth

            onPressed: (mouse) => {
                root.isResizing = true
                startMouseX = mouse.x
                startWidth = mouse.y
            }

            onReleased: {
                root.isResizing = false  // <-- Выключаем флаг
            }

            onPositionChanged: (mouse) => {
                if (!pressed) return

                var delta = startMouseX - mouse.x
                var newWidth = startWidth + delta

                newWidth = Math.max(root.minWidth,
                           Math.min(root.maxWidth, newWidth))

                root.panelWidth = newWidth
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        width: parent.width
        anchors.margins: 12

        ColumnLayout {
            id: contentItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 8

            // ===================== Заголовок =====================
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: "#2c3e50"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: targetElement && targetElement.widget
                        ? `Изменение размеров: ${targetElement.widget.name_widget} [${targetElement.widget.id_widget}]`
                        : "Изменение размеров"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                }

                // MouseArea {
                //     anchors.fill: parent
                //     cursorShape: Qt.SizeAllCursor
                //     property point dragStart
                //     onPressed: (mouse) => dragStart = Qt.point(mouse.x, mouse.y)
                //     onPositionChanged: (mouse) => {
                //         if (pressed) {
                //             root.x += mouse.x - dragStart.x
                //             root.y += mouse.y - dragStart.y
                //         }
                //     }
                // }
            }

            // ===================== Контейнерные размеры =====================
            GroupBox {
                title: "Изменение размеров контейнера"
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 6

                    // Ширина контейнера
                    RowLayout {
                        spacing: 8
                        Text { text: "Ширина:"; width: 70 }

                        Slider {
                            id: widthSlider
                            Layout.fillWidth: true
                            from: 0.05
                            to: 0.95
                            stepSize: 0.01
                            value: targetElement ? targetElement.relW : 0.2

                            onValueChanged: {
                                if (targetElement)
                                    targetElement.relW = value

                                widthField.text = (Math.round(value * 100)).toString()
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                                onWheel: (wheel) => {
                                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                    widthSlider.value =
                                        Math.max(widthSlider.from,
                                        Math.min(widthSlider.to, widthSlider.value + delta))
                                }
                            }
                        }

                        TextField {
                            id: widthField
                            width: 50
                            horizontalAlignment: Text.AlignRight

                            text: Math.round(widthSlider.value * 100).toString()

                            onEditingFinished: {
                                var v = parseFloat(text)
                                if (!isNaN(v)) {
                                    v = Math.max(widthSlider.from * 100,
                                                 Math.min(widthSlider.to * 100, v))

                                    widthSlider.value = v / 100
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton

                                onWheel: function(wheel) {

                                    var step = 1   // шаг 1%
                                    var current = parseFloat(widthField.text)

                                    if (isNaN(current))
                                        current = widthSlider.value * 100

                                    if (wheel.angleDelta.y > 0)
                                        current += step
                                    else
                                        current -= step

                                    // Ограничение диапазона
                                    current = Math.max(widthSlider.from * 100,
                                                       Math.min(widthSlider.to * 100, current))

                                    widthSlider.value = current / 100
                                }
                            }
                        }
                    }

                    // Высота контейнера
                    RowLayout {
                        spacing: 8
                        Text { text: "Высота:"; width: 70 }

                        Slider {
                            id: heightSlider
                            Layout.fillWidth: true
                            from: 0.05
                            to: 0.95
                            stepSize: 0.01
                            value: targetElement ? targetElement.relH : 0.2

                            onValueChanged: {
                                if (targetElement)
                                    targetElement.relH = value

                                heightField.text = (Math.round(value * 100)).toString()
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                                onWheel: function(wheel) {
                                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                    heightSlider.value =
                                        Math.max(heightSlider.from,
                                        Math.min(heightSlider.to, heightSlider.value + delta))
                                }
                            }
                        }

                        TextField {
                            id: heightField
                            width: 50
                            horizontalAlignment: Text.AlignRight

                            text: Math.round(heightSlider.value * 100).toString()

                            onEditingFinished: {
                                var v = parseFloat(text)
                                if (!isNaN(v)) {
                                    v = Math.max(heightSlider.from * 100,
                                                 Math.min(heightSlider.to * 100, v))

                                    heightSlider.value = v / 100
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton

                                onWheel: function(wheel) {

                                    var step = 1   // шаг 1%
                                    var current = parseFloat(heightField.text)

                                    if (isNaN(current))
                                        current = heightSlider.value * 100

                                    if (wheel.angleDelta.y > 0)
                                        current += step
                                    else
                                        current -= step

                                    // Ограничение диапазона
                                    current = Math.max(heightSlider.from * 100,
                                                       Math.min(heightSlider.to * 100, current))

                                    heightSlider.value = current / 100
                                }
                            }
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
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            // Название свойства
                            Text {
                                text: modelData.label
                                width: 140
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            // Слайдер
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
                                    }
                                }
                            }

                            // Цифровое поле
                            TextField {
                                text: Math.round(modelData.value * 10)/10
                                width: 50
                                horizontalAlignment: Text.AlignRight

                                onEditingFinished: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v)) {
                                        modelData.value = Math.max(modelData.min, Math.min(modelData.max, v))
                                        if (targetElement && targetElement.widget)
                                            targetElement.widget.setPropertySize(modelData.name, modelData.value)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                    onWheel: (wheel) => {
                                        var delta = wheel.angleDelta.y > 0 ? modelData.step : -modelData.step
                                        var v = parseFloat(text) + delta
                                        v = Math.max(modelData.min, Math.min(modelData.max, v))
                                        text = Math.round(v*10)/10
                                        modelData.value = v
                                        if (targetElement && targetElement.widget)
                                            targetElement.widget.setPropertySize(modelData.name, modelData.value)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ===================== Применить =====================
            Button {
                Layout.fillWidth: true
                text: "Применить"
                onClicked: root.close()
            }
            Button {
                Layout.fillWidth: true
                text: "Отменить"
                onClicked: root.close()
            }
        }
    }



    // ===================== Инициализация =====================
    onOpened: {
        if (!targetElement || !targetElement.widget) {
            console.warn("[DialogResize] Нет виджета для редактирования")
            sizeProperties = []
            return
        }

        // Загружаем свойства виджета
        if (typeof targetElement.widget.getPropertiesSize === "function") {
            sizeProperties = targetElement.widget.getPropertiesSize()
        } else {
            sizeProperties = []
        }

        // Обновляем слайдеры контейнера
        widthSlider.value = targetElement.relW
        heightSlider.value = targetElement.relH
        widthField.text = Math.round(widthSlider.value*100)
        heightField.text = Math.round(heightSlider.value*100)
    }
}
