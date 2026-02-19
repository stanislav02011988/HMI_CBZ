// qml.content.main_window.main_window_widgets.center_widget.modes.edit_mode.dialog_add_elements.element_parameters/ParametersPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Сигналы
    signal closeRequested()
    signal addRequested(var dataList)

    property var sceneController: null
    property var listIdScane: []

    // Статус
    property string statusMessage: ""
    property bool isSaving: false

    property bool isVisible: false
    property string selectedSubtypeId: ""

    // Итоговые данные с параметрами
    property var dataList: ({
        subtypeId: "",
        id_widget: "", // ID пользователь сам присвоит уникальные данные
        name_widget: "",     // Name - пользователь сам присвоит уникальные данные
        componentGroupe: "", // Добавляется после присвоения из списка ComboBox
    })

    visible: root.isVisible

    Connections {
        id: sceneControllerConnections
        target: sceneController
        function onSignalListIdScene(items) {
            root.listIdScane = items
        }
    }

    Label {
        text: "Параметры элемента"
        font.bold: true
        font.pixelSize: 16
        color: "white"
        Layout.topMargin: 5
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            Layout.topMargin: 10

            // ГРУППА
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label { text: "Группа элемента *"; color: "#bbbbbb"; font.pixelSize: 13 }
                ComboBox {
                    id: comboGroup
                    Layout.fillWidth: true
                    model: ["Блок цемента", "Блок воды", "Блок химии", "Блок смесителя", "Прочие"]
                    currentIndex: -1
                    font.pixelSize: 14
                    font.family: "Arial"
                    background: Rectangle {
                        radius: 6; color: "#2d2d2d"
                        border.color: activeFocus ? "#2196F3" : "#555555"
                        border.width: 1
                    }
                }
            }

            // НАЗВАНИЕ
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label { text: "Название элемента *"; color: "#bbbbbb"; font.pixelSize: 13 }
                TextField {
                    id: textFieldName
                    Layout.fillWidth: true
                    placeholderText: "Введите название"
                    color: "white"
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 6; color: "#2d2d2d"
                        border.color: activeFocus ? "#2196F3" : "#555555"
                        border.width: 1
                    }
                }
            }

            // ID ЭЛЕМЕНТА
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Label { text: "Уникальный ID *"; color: "#bbbbbb"; font.pixelSize: 13 }
                TextField {
                    id: textFieldID
                    Layout.fillWidth: true
                    placeholderText: "Например: silos.cement.1"
                    color: "white"
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 6; color: "#2d2d2d"
                        border.color: activeFocus ? "#2196F3" : "#555555"
                        border.width: 1
                    }
                }
                Text {
                    text: "Используется для связи с ПЛК и конфигурации"
                    color: "#777777"
                    font.pixelSize: 11
                }
            }

            // КНОПКИ
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 15
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: "Отмена"
                    onClicked: root.closeRequested()
                    background: Rectangle { radius: 5; color: "#555555" }
                    contentItem: Text {
                        text: parent.text; color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Добавить на сцену"
                    enabled: !root.isSaving
                    onClicked: root.validateAndSubmit()
                    background: Rectangle { radius: 5; color: enabled ? "#2196F3" : "#555555" }
                    contentItem: Text {
                        text: parent.text; color: "white"; font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // СТАТУС
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                text: root.statusMessage
                color: root.statusMessage.startsWith("✗") ? "#F44336" : "#4CAF50"
                font.pixelSize: 13
                font.bold: true
                visible: root.statusMessage !== ""
            }
        }
    }

    // === МЕТОДЫ ===
    function validateAndSubmit() {
        if (root.isSaving) return

        // Валидация
        if (comboGroup.currentIndex === -1) {
            root.statusMessage = "✗ Выберите группу"
            return
        }
        if (!textFieldName.text.trim()) {
            root.statusMessage = "✗ Укажите название"
            return
        }
        if (!textFieldID.text.trim()) {
            root.statusMessage = "✗ Укажите ID"
            return
        }

        // Проверка уникальности ID
        for (var i = 0; i < root.listIdScane.length; i++) {
            var id = root.listIdScane[i]
            if (id === textFieldID.text.trim()) {
                root.statusMessage = "✗ ID уже существует: " + textFieldID.text
                return
            }
        }

        root.isSaving = true
        root.statusMessage = "Добавление..."

        // 🔑 Карта: отображаемое имя → внутренний ключ
        var groupMap = {
            0: "GroupeCement",
            1: "GroupeWater",
            2: "GroupeChemistry",
            3: "GroupeMixer",
            4: "GroupeOther"
        }

        // Формируем dataList
        root.dataList = {
            subtypeId: root.selectedSubtypeId,
            id_widget: textFieldID.text.trim(),
            name_widget: textFieldName.text.trim(),
            componentGroupe: groupMap[comboGroup.currentIndex]
        }
        root.addRequested(root.dataList)
    }

    function resetParametersPanel() {
        comboGroup.currentIndex = -1
        textFieldName.text = ""
        textFieldID.text = ""
        root.dataList = {
            subtypeId: "",
            id_widget: "", // ID пользователь сам присвоит уникальные данные
            name_widget: "",     // Name - пользователь сам присвоит уникальные данные
            componentGroupe: "", // Добавляется после присвоения из списка ComboBox
        }
        root.isSaving = false
        root.statusMessage = ""
    }

    Component.onDestruction: {
        sceneControllerConnections.target = null
    }
}
