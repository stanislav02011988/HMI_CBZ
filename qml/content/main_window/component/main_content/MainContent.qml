import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.settings.project_settings

import qml.content.main_window.dialog_add_widget_plc

import qml.modules.bekchoff.modules

Item {
    id: root

    readonly property var checkAccess: {
        if (QmlProjectSettings.access_group === "admin") {
            return true
        }else { return false }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        border.color: "red"
        border.width: 1
        radius: 4        

        Rectangle {
            id: dropArea
            width: 400; height: 300
            color: "lightgray"
            anchors.centerIn: parent
            Text { text: "Кликни, чтобы добавить виджет"; anchors.centerIn: parent }

            MouseArea {
                anchors.fill: parent
                onClicked: customDialog.open()
            }
        }

        // Диалог
        DialogAddWidgetPlc {
            id: customDialog
            onWidgetSelected: function(type) {
                console.log("Выбран тип:", type)
            }
            onWidgetAdded: {
                let comp = null;
                const type = customDialog.selectedType;
                if (type === "kl3044") comp = Qt.createComponent("qrc:/qml_files/bekchoff/qml/modules/bekchoff/modules/KL3044.qml");
                else if (type === "kl3064") comp = Qt.createComponent("qrc:/qml_files/bekchoff/qml/modules/bekchoff/modules/KL3064.qml");
                else if (type === "kl3403") comp = Qt.createComponent("qrc:/qml_files/bekchoff/qml/modules/bekchoff/modules/KL3403.qml");

                if (!comp || comp.status !== Component.Ready) {
                    console.warn("Не удалось загрузить компонент:", comp ? comp.errorString() : "null");
                    close();
                    return;
                }

                // 1. Создаём без позиции
                let obj = comp.createObject(dropArea);
                if (!obj) {
                    console.warn("Не удалось создать объект");
                    close();
                    return;
                }

                // 2. Получаем размеры (используем implicit* если доступны, иначе width/height)
                const w = obj.implicitWidth > 0 ? obj.implicitWidth : (obj.width > 0 ? obj.width : 100);
                const h = obj.implicitHeight > 0 ? obj.implicitHeight : (obj.height > 0 ? obj.height : 100);

                // 3. Устанавливаем позицию по центру dropArea
                obj.x = (dropArea.width - w) / 2;
                obj.y = (dropArea.height - h) / 2;

                // Опционально: можно задать явные width/height, если компонент их не имеет
                // obj.width = w; obj.height = h;

                close();
            }
        }
    }
}
