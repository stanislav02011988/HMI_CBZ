import QtQuick
import QtQuick.Layouts


Item{
    id: root
    visible: false

    property alias pumpPreview: pumpPreview

    Component {
        id: pumpPreview
        Rectangle {
            anchors.fill: parent
            color: "#2196F3"
            Text {
                anchors.centerIn: parent
                text: root.pipesSubtypesModel.get(root.selectedSubtypeIndex).name
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
        }
    }
}
