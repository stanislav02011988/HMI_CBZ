// ResizePropertyDelegate.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root

    property var elementData
    property int elementIndex
    property var modelController

    width: parent ? parent.width : 300
    height: elementData && elementData.type === "group" ? 40 : 52
    clip: true

    Behavior on height {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: elementData && elementData.type === "group" ? groupDelegate : propertyDelegate
    }

    // =====================================================
    // GROUP
    // =====================================================

    Component {
        id: groupDelegate

        Rectangle {
            color: "#2c3e50"
            radius: 4
            border.color: "#1a252f"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                spacing: 10

                Text {
                    text: elementData.expanded ? "▼" : "▶"
                    color: "#3498db"
                    font.pixelSize: 14

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    rotation: elementData.expanded ? 0 : -90
                }

                Text {
                    text: elementData.name
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: elementData.children ? `(${elementData.children.length})` : ""
                    color: "#7f8c8d"
                    font.pixelSize: 12
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: elementData.expanded
                    width: 8
                    height: 8
                    radius: 4
                    color: "#27ae60"
                    Layout.rightMargin: 12
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (modelController && modelController.toggleExpand)
                        modelController.toggleExpand(elementIndex)
                }
            }
        }
    }

    // =====================================================
    // PROPERTY
    // =====================================================

    Component {
        id: propertyDelegate

        Rectangle {
            color: "white"
            radius: 4
            border.color: "#777"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 36
                anchors.rightMargin: 12
                spacing: 12

                // =====================================
                // NAME
                // =====================================

                Text {
                    text: elementData.name
                    width: 140
                    font.pixelSize: 13
                    color: "#2c3e50"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                // =====================================
                // SLIDER
                // =====================================

                Slider {
                    id: slider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    from: elementData.min ?? 0
                    to: elementData.max ?? 100
                    stepSize: elementData.step ?? 1

                    value: elementData.value ?? 0

                    onMoved: {
                        applyValue(value)
                    }

                    // колесо мыши
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton

                        onWheel: (wheel) => {
                            const step = elementData.step ?? 1
                            if (wheel.angleDelta.y > 0) slider.value += step
                            else slider.value -= step
                            slider.applyValue(slider.value)
                        }
                    }

                    function applyValue(v) {
                        if (!modelController)
                            return

                        // сохраняем значение в модели
                        if (typeof modelController.updateValue === "function") {
                            modelController.updateValue(elementIndex, v)
                        }

                        elementData.value = v

                        // контейнер
                        if (elementData.propName === "relW" || elementData.propName === "relH") {
                            if ("relW" in modelController.targetElement && "relH" in modelController.targetElement) { modelController.targetElement[elementData.propName] = v }
                        }
                        else { if (typeof modelController.setProperty === "function") { modelController.setProperty(elementData.propName, v) }}
                    }
                }

                // =====================================
                // TEXT FIELD
                // =====================================

                TextField {
                    id: valueField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 30
                    horizontalAlignment: Text.AlignRight

                    text: Number(slider.value).toFixed(1)

                    onEditingFinished: {
                        const v = Number(text)
                        if (isNaN(v))
                            return
                        slider.value = v
                    }

                    Connections {
                        target: slider
                        function onValueChanged() {
                            valueField.text = Number(slider.value).toFixed(2)
                        }
                    }
                }
            }
        }
    }
}
