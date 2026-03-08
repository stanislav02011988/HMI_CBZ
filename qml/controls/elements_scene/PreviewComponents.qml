// element_preview/PreviewComponents.qml
import QtQuick
import QtQuick.Layouts

import "elements_preview"

Item {
    id: root
    visible: false

    // Компоненты
    Component {
        id: emptyPreview
        Rectangle {
            color: "transparent"
            anchors.fill: parent
            Text {
                anchors.centerIn: parent
                text: "Выберите подтип"
                color: "#666666"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                font.italic: true
            }
        }
    }

    PreviewSilos { id: previewSilos }
    PreviewScrew { id: previewScrew }
    PreviewScales { id: previewScales }
    PreviewPump { id: previewPump }
    PreviewShutter { id: previewShutter }
    PreviewValve { id: previewValve }
    PreviewTubing { id: previewTubing }

    function getPreviewComponent(selectedSubtypeId) {
        // console.log("PreviewComponents.qml", selectedSubtypeId)
        if (!selectedSubtypeId) return emptyPreview

        // Проверяем, какой тип подтипа
        // Превью Силосов
        if (selectedSubtypeId === "silos_vertical") return previewSilos.silos_vertical

        // Превью шнеков
        if (selectedSubtypeId === "screw") return previewScrew.screw

        // Превью Весов
        if (selectedSubtypeId === "scales") return previewScales.scales

        // Превью насосов
        if (selectedSubtypeId === "pump") return previewPump.pumpPreview

        // Превью затвора
        if (selectedSubtypeId === "shutter") return previewShutter.shutter

        // Превью Клапанов
        if (selectedSubtypeId === "valve_air") return previewValve.valve_air

        // Превью Труб
        if (selectedSubtypeId === "tubing_vertical") return previewTubing.tubingVertical
        if (selectedSubtypeId === "tubing_horizontal") return previewTubing.tubingHorizontal

        return emptyPreview
    }
}
