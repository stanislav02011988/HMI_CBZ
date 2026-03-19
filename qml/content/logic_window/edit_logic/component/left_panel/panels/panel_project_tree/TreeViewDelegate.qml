import QtQuick
import QtQuick.Controls

Item {

    id: root

    implicitHeight: 28
    implicitWidth: treeView ? treeView.width : 200

    // =========================
    // REQUIRED (TreeView)
    // =========================

    required property TreeView treeView
    required property bool isTreeNode
    required property bool expanded
    required property bool hasChildren
    required property int depth
    required property int row
    required property int column
    required property bool current

    // =========================
    // MODEL ROLES
    // =========================

    property string nodeType: model.type
    property string nodeName: model.name

    property bool isProject: nodeType === "project"
    property bool isProgram: nodeType === "program"

    // =========================
    // STYLE
    // =========================

    property int indent: 20
    property int padding: 6

    property string bgNormal: "#3a3d42"
    property string bgHover: "#40444a"
    property string bgSelected: "#2f6fff"
    property string bgProgramExpanded: "#3c4b5f"

    property string textProject: "#ffffff"
    property string textProgram: "#4a9eff"
    property string textNormal: "#cccccc"

    property string lineColor: "#555"
    property string lineActive: "#4a9eff"

    property bool hovered: false

    // =========================
    // BACKGROUND
    // =========================

    Rectangle {
        anchors.fill: parent
        radius: 4

        color: {
            if (current)
                return bgSelected

            if (hovered)
                return bgHover

            if (isProgram && expanded)
                return bgProgramExpanded

            return bgNormal
        }
    }

    // =========================
    // TREE LINES (VERTICAL)
    // =========================

    Repeater {

        model: depth

        Rectangle {

            width: 1
            height: parent.height

            x: padding + index * indent + indent / 2

            color: expanded ? lineActive : lineColor
            opacity: 0.6
        }
    }

    // =========================
    // TREE LINE (HORIZONTAL)
    // =========================

    Rectangle {

        visible: depth > 0

        width: indent / 2
        height: 1

        x: padding + depth * indent
        y: parent.height / 2

        color: expanded ? lineActive : lineColor
    }

    // =========================
    // EXPAND INDICATOR
    // =========================

    Text {

        id: indicator

        visible: hasChildren && !isProject

        x: padding + depth * indent - 8
        anchors.verticalCenter: parent.verticalCenter

        text: "▶"

        rotation: expanded ? 90 : 0

        color: expanded ? "#4a9eff" : "#aaaaaa"

        font.pixelSize: 12

        Behavior on rotation {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }

        TapHandler {

            onTapped: {

                if (isProject)
                    return

                let index = treeView.index(row, column)

                treeView.toggleExpanded(index)
            }
        }
    }

    // =========================
    // ICON
    // =========================

    Text {

        x: padding + (depth + 1) * indent
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: 16

        text: {

            switch(nodeType) {

            case "project": return "📁"
            case "program": return "📄"
            case "folder": return "⚙"
            default: return "📄"
            }
        }
    }

    // =========================
    // LABEL
    // =========================

    Text {

        id: label

        x: padding + (depth + 3) * indent
        anchors.verticalCenter: parent.verticalCenter

        width: parent.width - x - padding

        text: nodeName

        elide: Text.ElideRight

        font.pixelSize: 13
        font.bold: isProject

        color: {

            if (isProject)
                return textProject

            if (isProgram)
                return textProgram

            return textNormal
        }
    }

    // =========================
    // MOUSE / SELECTION
    // =========================

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    TapHandler {

        onTapped: {

            let index = treeView.index(row, column)

            treeView.selectionModel.setCurrentIndex(
                index,
                ItemSelectionModel.ClearAndSelect
            )
        }
    }
}
