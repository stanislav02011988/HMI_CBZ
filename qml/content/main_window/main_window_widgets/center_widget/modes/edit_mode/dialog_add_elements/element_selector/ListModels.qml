// element_selector/ListModels.qml
import QtQuick

import "models_element"

Item {
    id: modelsRoot
    visible: false

    property alias elementTypesModel: elementTypesModel

    property alias silosSubtypesModel: silosSubtypesModel
    property alias screwSubtypesModel: screwSubtypesModel
    property alias scalesSubtypesModel: scalesSubtypesModel
    property alias pumpSubtypesModel: pumpSubtypesModel

    ListModel {
        id: elementTypesModel
        ListElement { typeId: "silos"; name_type: "Силосы"; icon: "\uf0ad"; description: "Хранение сыпучих материалов" }
        ListElement { typeId: "screw"; name_type: "Шнеки"; icon: "\uf24e"; description: "Транспортировка сыпучих материалов" }
        ListElement { typeId: "scales"; name_type: "Весы"; icon: "\uf24e"; description: "Взвешивание материалов" }
        ListElement { typeId: "pump"; name_type: "Трубы"; icon: "\uf7b6"; description: "Транспортировка материалов" }
    }

    SilosSubtypes { id: silosSubtypesModel }

    ScrewSubtypes { id: screwSubtypesModel }

    ScalesSubtypes { id: scalesSubtypesModel }

    PumpSubtypes { id: pumpSubtypesModel }


}
