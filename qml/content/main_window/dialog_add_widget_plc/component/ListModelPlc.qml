import QtQuick
import QtQuick.Controls

ListModel {
    id: listModel

    // === Bekhoff ===
    ListElement { type: "group"; name: "Bekhoff"; key: "beckhoff"; parent: ""; expanded: false; visible: true }

    ListElement { type: "subgroup"; name: "Controllers"; key: "beckhoff_controllers"; parent: "beckhoff"; expanded: false; visible: false }
    ListElement { type: "item"; name: "BC3120"; key: "bc3120"; parent: "beckhoff_controllers"; visible: false }
    ListElement { type: "item"; name: "BK3100"; key: "bk3100"; parent: "beckhoff_controllers"; visible: false }

    ListElement { type: "subgroup"; name: "Modules"; key: "beckhoff_modules"; parent: "beckhoff"; expanded: false; visible: false }
    ListElement { type: "item"; name: "KL3044"; key: "kl3044"; parent: "beckhoff_modules"; visible: false }
    ListElement { type: "item"; name: "KL3064"; key: "kl3064"; parent: "beckhoff_modules"; visible: false }
    ListElement { type: "item"; name: "KL3403"; key: "kl3403"; parent: "beckhoff_modules"; visible: false }

    // === Siemens (пример расширения) ===
    ListElement { type: "group"; name: "Siemens"; key: "siemens"; parent: ""; expanded: false; visible: true }
    ListElement { type: "subgroup"; name: "IO Modules"; key: "siemens_io"; parent: "siemens"; expanded: false; visible: false }
    ListElement { type: "item"; name: "6ES7_153..."; key: "6es7_1"; parent: "siemens_io"; visible: false }
}
