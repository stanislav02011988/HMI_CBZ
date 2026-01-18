// CustomWidgetDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import qml.content.main_window.dialog_add_widget_plc.component

Dialog {
    id: dialog
    title: "Добавить виджет"
    modal: true
    width: 800
    height: 600

    signal widgetAdded()
    signal widgetSelected(string type)
    property alias selectedType: preview.selectedType

    RowLayout {
        anchors.fill: parent
        spacing: 10

        WidgetTreeListView {
            id: treeList
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            onItemSelected: (key) => {
                preview.selectedType = key
            }
        }

        WidgetPreview {
            id: preview
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Button {
        text: "Добавить"
        enabled: preview.selectedType !== ""
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        onClicked: widgetAdded()
    }
}
