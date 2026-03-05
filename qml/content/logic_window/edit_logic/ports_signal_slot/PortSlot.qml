import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Item{
    id: root
    anchors.fill: parent

    property Item widgetInstance: null
    property Item sceneContainer: null
    property var sceneController: null

    property bool editMode: false
    property bool isWide

    property int slotCount: {
        if (!widgetInstance || typeof widgetInstance.exposedSlots !== 'object') return 0
        return Object.keys(widgetInstance.exposedSlots).length
    }

    Repeater {
        id: slotsRepeater
        model: editMode ? slotCount : 0
        delegate: Rectangle {
            width: 18; height: 18
            color: "#FFC107"; radius: 4
            z: 300
            property string slotKey: Object.keys(widgetInstance.exposedSlots)[index]
            property string slotDesc: widgetInstance.exposedSlots[slotKey] || slotKey
            x: isWide ?
                (parent.width - width) / 2 + (index - (slotCount - 1) / 2) * 26 :
                parent.width + 8
            y: isWide ?
                parent.height + 8 :
                (parent.height - height) / 2 + (index - (slotCount - 1) / 2) * 26
            MouseArea {
                id: slotMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                propagateComposedEvents: false
                acceptedButtons: Qt.LeftButton

                ToolTip {
                    id: slotTooltip
                    text: slotDesc
                    visible: slotMouseArea.containsMouse && slotDesc.length > 0
                    delay: 300
                }

                onEntered: {
                    if (sceneController.managerLine?.setDragTarget) {
                        sceneController.managerLine.setDragTarget(
                            widgetInstance.id_widget,
                            slotKey
                        )
                    }
                }

                onExited: {
                    if (sceneController.managerLine?.clearDragTarget) {
                        sceneController.managerLine.clearDragTarget()
                    }
                }

                onClicked: (mouse) => {
                    if (sceneController.managerLine?.endDrag) {
                        const pos = mapToItem(sceneContainer, mouse.x, mouse.y)
                        sceneController.managerLine.endDrag(pos)
                    }
                    mouse.accepted = true
                }
            }
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: slotMouseArea.containsMouse ? 0.3 : 0
                radius: 4
                enabled: false
            }
            Text {
                anchors.centerIn: parent
                text: slotKey.substring(0, 2).toUpperCase()
                color: "black"
                font.pixelSize: 9
                font.bold: true
                font.family: "Courier New"
                rotation: isWide ? 0 : -90
            }
        }
    }
}
