import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.controls.flip_clock
import qml.controls.button

import qml.settings.project_settings

Rectangle {
    id: dataUser
    color: "#00ffffff"
    radius: 4
    border.color: "#666565"
    border.width: 1
    Layout.margins: 0
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
    Layout.fillHeight: true
    implicitWidth: userFieldsRow.implicitWidth + 12

    RowLayout {
        id: userFieldsRow
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: 4
        spacing: 5

        // Функция для создания поля
        function createField(labelText, valueText) {
            var component = Qt.createComponent("ModelUser.qml");
            var item = component.createObject(userFieldsRow, {
                "fieldLabel": labelText,
                "fieldValue": valueText
            });
            return item;
        }

        // Но проще — использовать Repeater с моделью
        Repeater {
            model: [
                { label: qsTr("Фамилия"), value: QmlProjectSettings.last_name },
                { label: qsTr("Имя"), value: QmlProjectSettings.first_name },
                { label: qsTr("Отчество"), value: QmlProjectSettings.second_name },
                { label: qsTr("Должность"), value: QmlProjectSettings.position_users },
                { label: qsTr("Уровень доступа"), value: QmlProjectSettings.access_group }
            ]

            ModelUser {
                fieldLabel: modelData.label
                fieldValue: modelData.value
                Layout.fillHeight: true
            }
        }
    }
}
