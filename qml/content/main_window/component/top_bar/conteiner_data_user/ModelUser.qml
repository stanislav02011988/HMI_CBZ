// ModelUser.qml
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string fieldLabel: ""
    property string fieldValue: ""

    spacing: 2
    Layout.alignment: Qt.AlignTop
    Layout.fillHeight: true

    // Пересчитываем implicitWidth при изменении данных
    implicitWidth: conteinerItem.implicitWidth

    Item {
        id: conteinerItem
        Layout.fillHeight: true
        implicitWidth: {
            labelTM.text = fieldLabel;
            valueTM.text = fieldValue;
            return Math.max(labelTM.width, valueTM.width) + 10;
        }

        TextMetrics {
            id: labelTM
            font.pixelSize: 12
            font.bold: true
            text: root.fieldLabel  // ← прямая привязка
        }

        TextMetrics {
            id: valueTM
            font.pixelSize: 12
            text: root.fieldValue  // ← прямая привязка
        }

        Text {
            id: labelTxt
            width: labelTM.width
            height: labelTM.height
            text: fieldLabel
            font.pixelSize: 12
            font.bold: true
            color: "#333"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
        }

        // Значение — снизу
        Rectangle {
            id: valueRect
            color: "transparent"
            radius: 2
            width: valueTM.width
            height: valueTM.height
            anchors.top: labelTxt.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 4
            anchors.rightMargin: 4

            Text {
                text: fieldValue
                font.pixelSize: 12
                color: "#000"
                anchors.centerIn: parent
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
        }
    }
}
