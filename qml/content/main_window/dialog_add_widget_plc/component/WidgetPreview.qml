
import QtQuick 2.15
import QtQuick.Controls 2.15

import qml.modules.bekchoff.modules 1.0
// import qml.modules.siemens.modules 1.0

Rectangle {
    id: preview
    color: "#f8f8f8"
    border.color: "#ccc"

    property string selectedType: ""

    // === ВНУТРЕННИЙ componentMap ===
    readonly property var componentMap: ({
        "kl3044": Qt.createComponent("qrc:/qml_files/bekchoff/qml/modules/bekchoff/modules/KL3044.qml"),
        "kl3064": Qt.createComponent("qrc:/qml_files/bekchoff/qml/modules/bekchoff/modules/KL3064.qml"),
        "kl3403": Qt.createComponent("qrc:/qml_files/bekchoff/qml/modules/bekchoff/modules/KL3202.qml"),
        "bc3120": Qt.createComponent("BC3120"),
        "bk3100": Qt.createComponent("BK3100")
        // ... остальные ...
    })

    Loader {
        anchors.centerIn: parent
        active: preview.selectedType !== ""
        sourceComponent: {
            const comp = preview.componentMap[preview.selectedType]
            return (comp && comp.status === Component.Ready) ? comp : null
        }
    }
}
