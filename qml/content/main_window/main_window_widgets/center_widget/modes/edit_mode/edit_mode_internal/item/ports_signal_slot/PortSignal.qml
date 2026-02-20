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

    property int signalCount: {
        if (!widgetInstance || typeof widgetInstance.exposedSignals !== 'object') return 0
        return Object.keys(widgetInstance.exposedSignals).length
    }

    Repeater {
        model: editMode ? signalCount : 0
        delegate: Rectangle {
            width: 18; height: 18
            color: "#4CAF50"; radius: 4
            z: 300
            property string signalKey: Object.keys(widgetInstance.exposedSignals)[index]
            property string signalDesc: widgetInstance.exposedSignals[signalKey] || signalKey
            x: isWide ?
                (parent.width - width) / 2 + (index - (root.signalCount - 1) / 2) * 26 :
                -22
            y: isWide ?
                -22 :
                (parent.height - height) / 2 + (index - (root.signalCount - 1) / 2) * 26
            MouseArea {
                id: signalMouseArea
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                hoverEnabled: true
                propagateComposedEvents: false
                acceptedButtons: Qt.LeftButton

                onEntered: {
                    if (sceneController?.isDragging) {
                        sceneController.setInvalidTarget()
                    }
                }

                onExited: {
                    if (sceneController?.isDragging) {
                        sceneController.clearInvalidTarget()
                    }
                }

                ToolTip {
                    id: signalTooltip
                    text: signalDesc
                    visible: signalMouseArea.containsMouse && signalDesc.length > 0
                    delay: 300
                }

                onPressed: (mouse) => {
                    if (sceneController && sceneController.managerLine) {
                        sceneController.managerLine.startDrag(
                            widgetInstance.id_widget,
                            signalKey,
                            mapToItem(sceneContainer, mouse.x, mouse.y)
                        )
                    }

                    mouse.accepted = true
                }
            }
            Rectangle {
                anchors.fill: parent
                color: "white"
                opacity: signalMouseArea.containsMouse ? 0.4 : 0
                radius: 4
                enabled: false
            }
            Text {
                anchors.centerIn: parent
                text: signalKey.substring(0, 2).toUpperCase()
                color: "white"
                font.pixelSize: 9
                font.bold: true
                font.family: "Courier New"
                rotation: isWide ? 0 : -90
            }
        }
    }
}
