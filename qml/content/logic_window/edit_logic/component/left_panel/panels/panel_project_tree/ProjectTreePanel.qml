import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qml.managers

Item {
    id: root

    property bool collapsed: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // HEADER
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            color: "#3a3d42"
            radius: 6
            border.color: root.collapsed ? "#555" : "transparent"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: root.collapsed = !root.collapsed

                // onEntered: if (!root.collapsed) header.color = "#4a9eff"
                // onExited: if (!root.collapsed) header.color = "#3a3d42"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Text {
                    Layout.preferredWidth: 16
                    horizontalAlignment: Text.AlignHCenter
                    text: root.collapsed ? "▶" : "▼"
                    color: "#888"
                    font.pixelSize: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: "Древо проекта"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }
        }

        // CONTENT
        Rectangle {
            id: content
            Layout.fillWidth: true
            Layout.preferredHeight: root.collapsed ? 0 : root.height - 60

            clip: true
            color: "#2b2e33"
            radius: 6

            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            TreeView {
                id: treeView

                anchors.fill: parent
                anchors.margins: 10
                clip: true

                model: QmlProjectManager.treeViewModel

                selectionModel: ItemSelectionModel {
                    model: treeView.model
                }

                delegate: Item {

                    id: delegateRoot

                    implicitWidth: content.width
                    implicitHeight: isProject ? 44 : 32

                    readonly property int indent: 24
                    readonly property int padding: 10
                    readonly property int iconSize: 18

                    required property TreeView treeView
                    required property int depth
                    required property bool expanded
                    required property bool hasChildren
                    required property int row
                    required property int column
                    required property bool current

                    property bool isProgram: model.type === "program"
                    property bool isProject: model.type === "project"

                    property int branchMask: model.branchMask || 0
                    property bool isLast: model.isLast || false

                    property bool branchActive: QmlLogicMapScene.openedProgramName !== ""
                    property bool isOpenedProgram: model.type === "program" && QmlLogicMapScene.openedProgramName === model.name
                    property color lineColor: {
                        if (isOpenedProgram)
                            return "#2ecc71"

                        return "#555"
                    }

                    Component.onCompleted: {
                        if (treeView.model) {
                            let rootIndex = treeView.index(0, 0)

                            if (rootIndex.valid)
                                treeView.expand(rootIndex)
                        }
                    }

                    Rectangle {
                        id: bg
                        anchors.fill: parent
                        radius: 4
                        border.width: isProject ? 2 : 0
                        border.color: isProject ? "red" : "transparent"
                        color: {
                            if (isOpenedProgram)
                                return "#1e3d2a"

                            if (current)
                                return "#2f6fff"

                            if (isProgram && expanded)
                                return "#3c4b5f"

                            return "transparent"
                        }
                    }

                    // линии предков
                    Repeater {
                        model: depth

                        Rectangle {
                            visible: (branchMask & (1 << index)) !== 0
                            width: 1
                            height: parent.height
                            x: padding + index * indent + indent/2
                            color: {
                                if (branchActive && isOpenedProgram && (branchMask & (1 << index)))
                                    return "#2ecc71"

                                return lineColor
                            }
                        }
                    }

                    // линия текущего элемента
                    Rectangle {
                        visible: depth > 0
                        width: 1
                        height: isLast ? parent.height/2 : parent.height
                        x: padding + (depth-1)*indent + indent/2
                        color: {
                            if (isLast && branchActive && isOpenedProgram)
                                return "#2ecc71"

                            return lineColor
                        }
                    }

                    // горизонтальная ветка
                    Rectangle {
                        visible: depth > 0
                        width: indent/2
                        height: 1
                        x: padding + depth*indent - indent/2
                        y: parent.height/2
                        color: lineColor
                    }

                    Label {
                        id: indicator
                        visible: hasChildren && model.type !== "project"

                        x: padding + depth * indent - 8
                        anchors.verticalCenter: parent.verticalCenter

                        text: expanded ? "▼" : "▶"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        font.bold: true
                        color: expanded ? "red" : "#aaaaaa"

                        TapHandler {
                            onSingleTapped: {
                                let index = treeView.index(row, column)
                                treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                                treeView.toggleExpanded(row)
                            }
                        }
                    }

                    Text {
                        x: padding + depth * indent + 8
                        anchors.verticalCenter: parent.verticalCenter

                        width: iconSize
                        height: iconSize

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        text: {
                            switch(model.type) {
                                case "project": return "📁"
                                case "program": return "📄"
                                case "folder":  return "⚙"
                                case "group": return "📦"
                                case "subtype": return "📁"
                                case "element": return "🔹"
                                default: return "❓"
                            }
                        }

                        font.pixelSize: 0
                    }

                    Text {
                        x: padding + depth * indent + iconSize + 12
                        y: 6
                        width: parent.width - x - 10

                        text: model.name
                        wrapMode: Text.WordWrap
                        maximumLineCount: isProject ? 2 : 1

                        elide: isProject ? Text.ElideNone : Text.ElideRight

                        color: {

                            if (isOpenedProgram)
                                return "#2ecc71"

                            if (current)
                                return "white"

                            if (isProject)
                                return "#ffffff"

                            if (isProgram)
                                return "#4a9eff"

                            return "#cccccc"
                        }

                        font.bold: isProject || current
                        font.pixelSize: 13
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onDoubleTapped: {
                            let index = treeView.index(row, column)
                            let node = treeView.model.getNodeData(index)

                            if (node.type !== "program")
                                return

                            QmlLogicMapScene.loadPrograms(node.name)

                            treeView.collapseRecursively()
                            treeView.expand(index)
                        }

                        onTapped: {
                            let index = treeView.index(row, column)
                            treeView.selectionModel.setCurrentIndex(
                                index,
                                ItemSelectionModel.ClearAndSelect
                            )
                        }
                    }
                }
            }
        }
    }
}
