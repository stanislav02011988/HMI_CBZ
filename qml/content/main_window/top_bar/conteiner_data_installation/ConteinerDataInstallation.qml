import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.controls.flip_clock
import qml.controls.button
import qml.managers
import qml.settings.project_settings

Rectangle {
    id: dataUser

    // Функция для проверки, является ли значение "непустым"
    function isNotEmpty(val) {
        return val !== undefined && val !== null && val.toString().trim() !== "";
    }

    // Массив исходных данных
    readonly property var rawData: [
        { label: qsTr("Название Установки"), value: QmlProjectManager.installationName },
        { label: qsTr("Тип установки"), value: QmlProjectManager.typeInstallation },
        { label: qsTr("Инв.№"), value: QmlProjectManager.numberINF },
        { label: qsTr("Зав.№"), value: QmlProjectManager.numberInstallation },
        { label: qsTr("Год выпуска"), value: QmlProjectManager.yearInstallation }
    ]

    // Отфильтрованная модель: только непустые значения
    readonly property var filteredModel: {
        var result = [];
        for (var i = 0; i < dataUser.rawData.length; i++) {
            var item = dataUser.rawData[i];
            if (dataUser.isNotEmpty(item.value)) {
                result.push(item);
            }
        }
        return result;
    }

    // Скрываем весь блок, если нет ни одного непустого поля
    visible: filteredModel.length > 0

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

        Repeater {
            model: dataUser.filteredModel  // используем отфильтрованную модель

            ModelUser {
                fieldLabel: modelData.label
                fieldValue: modelData.value
                Layout.fillHeight: true
            }
        }
    }
}
