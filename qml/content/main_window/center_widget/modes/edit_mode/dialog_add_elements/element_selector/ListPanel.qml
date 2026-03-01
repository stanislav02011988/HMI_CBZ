// module qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_selector/ListPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ColumnLayout {
    id: root
    Layout.preferredWidth: 280
    Layout.fillHeight: true

    // === МОДЕЛЬ (из файла) ===
    ListModels { id: listModel }

    // === СОСТОЯНИЕ ===
    property string selectedType: ""
    property string selectedSubtype: ""
    property int selectedTypeIndex: -1
    property int selectedSubtypeIndex: -1
    property bool showSubtypes: false

    // === СИГНАЛЫ ===
    signal signalSelectedSubtype(string subtypeId)
    signal selectionCleared()
    signal addRequested()

    // === ОСНОВНОЙ КОНТЕНТ ===

    // Навигация
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        ToolButton {
            visible: root.showSubtypes
            text: "← Назад"
            onClicked: {
                root.showSubtypes = false
                root.selectedSubtype = ""
                root.selectedSubtypeIndex = -1
                root.selectionCleared()
            }
            background: Rectangle { radius: 4; color: "#333333" }
            contentItem: Text {
                text: parent.text
                color: "#2196F3"
                font.pixelSize: 13
            }
        }

        Label {
            text: root.showSubtypes ? "Выберите вид элемента" : "Выберите тип элемента"
            font.bold: true
            font.pixelSize: 16
            color: "white"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Типы
    TypeSelector {
        visible: !root.showSubtypes
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: listModel.elementTypesModel
        selectedIndex: root.selectedTypeIndex
        onTypeSelected: (index, typeId) => {
            root.selectedTypeIndex = index
            root.selectedType = typeId
            root.selectedSubtype = ""
            root.selectedSubtypeIndex = -1
            root.showSubtypes = true
        }
    }

    // Подтипы
    SubtypeSelector {
        visible: root.showSubtypes
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: root.selectedType === "silos" ? listModel.silosSubtypesModel :
                root.selectedType === "screw" ? listModel.screwSubtypesModel :
               root.selectedType === "scales" ? listModel.scalesSubtypesModel :
               root.selectedType === "pipes" ? listModel.pipesSubtypesModel : null
        selectedIndex: root.selectedSubtypeIndex
        selectedType: root.selectedType
        onSubtypeSelected: (index, subtypeId) => {
            root.selectedSubtypeIndex = index
            root.selectedSubtype = subtypeId
            root.signalSelectedSubtype(subtypeId)
        }
    }

    // Инфо, статус
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: "#444444"
        Layout.topMargin: 10
        Layout.bottomMargin: 10
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        Text { text: "Выбрано:"; color: "#aaaaaa"; font.pixelSize: 12 }
        Text {
            text: !root.selectedSubtype ? "Не выбран элемент" : root.selectedSubtype
            color: root.selectedSubtype ? "#2196F3" : "#ff9800"
            font.pixelSize: 14
            font.bold: true
            wrapMode: Text.Wrap
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    function resetListPanel(){
        root.selectedType = ""
        root.selectedSubtype = ""
        root.selectedTypeIndex = -1
        root.selectedSubtypeIndex = -1
        root.showSubtypes = false
    }
}
