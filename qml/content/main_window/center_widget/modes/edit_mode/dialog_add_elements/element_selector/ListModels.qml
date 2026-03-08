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
    property alias shutterSubtypesModel: shutterSubtypesModel
    property alias valveSubtypesModel: valveSubtypesModel
    property alias tubingSubtypesModel: tubingSubtypesModel

    ListModel {
        id: elementTypesModel
        ListElement { typeId: "scales"; name_type: "Весы"; icon: "\uf24e"; description: "Взвешивание материалов" }
        ListElement { typeId: "silos"; name_type: "Силосы"; icon: "\uf0ad"; description: "Хранение сыпучих материалов" }
        ListElement { typeId: "screw"; name_type: "Шнеки"; icon: "\uf24e"; description: "Транспортировка сыпучих материалов" }        
        ListElement { typeId: "pump"; name_type: "Насосы"; icon: "\uf7b6"; description: "Транспортировка жидких материалов" }
        ListElement { typeId: "shutter"; name_type: "Затворы"; icon: "\uf7b6"; description: "Элементы удержания материалов" }
        ListElement { typeId: "valve"; name_type: "Клапаны"; icon: "\uf7b6"; description: "Электромагнитные клапана" }
        ListElement { typeId: "tubing"; name_type: "Трубы"; icon: "\uf7b6"; description: "Элементы перемещение материалов" }
    }

    SilosSubtypes { id: silosSubtypesModel }
    ScrewSubtypes { id: screwSubtypesModel }
    ScalesSubtypes { id: scalesSubtypesModel }
    PumpSubtypes { id: pumpSubtypesModel }
    ShutterSubtypes { id: shutterSubtypesModel }
    ValveSubtypes { id: valveSubtypesModel }
    TubingSubtypes { id: tubingSubtypesModel }

}
