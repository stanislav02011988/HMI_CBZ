// qml/content/logic_window/edit_logic/component/left_panel/panels/scene_list_element_panel/SceneListElementPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: root
    radius: 6
    color: "#2d2f33"

    SceneElementsModel {
        id: sceneModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Заголовок
        Text {
            Layout.fillWidth: true
            text: "Scene Elements"
            color: "#ffffff"
            font.bold: true
            font.pixelSize: 14
            padding: 4
        }

        Text {
            Layout.fillWidth: true
            text: "Количество элементов главной сцены: " + sceneModel.countElementsScene
            color: "#00ff00"
            font.pixelSize: 10
            padding: 4
        }

        // Кнопки управления
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Button {
                Layout.fillWidth: true
                text: "Expand All"
                font.pixelSize: 10
                padding: 4
                background: Rectangle { color: "#3a3d42"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#aaa"; font: parent.font; horizontalAlignment: Text.AlignHCenter }
                onClicked: sceneModel.expandAll()
            }

            Button {
                Layout.fillWidth: true
                text: "Collapse All"
                font.pixelSize: 10
                padding: 4
                background: Rectangle { color: "#3a3d42"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#aaa"; font: parent.font; horizontalAlignment: Text.AlignHCenter }
                onClicked: sceneModel.collapseAll()
            }
        }

        // Скролл для дерева
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Item {
                id: contentItem
                width: scrollView.width
                height: childrenRect.height

                ColumnLayout {
                    id: treeColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: 0

                    Repeater {
                        id: treeRepeater
                        model: sceneModel.flatModel

                        delegate: Rectangle {
                            id: delegateRect
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            width: treeColumn.width
                            height: 30
                            color: "#3a3d42"

                            // Component.onCompleted: {
                            //     console.log("[DELEGATE] Created index:", index,
                            //               "name:", modelData ? modelData.name : "NULL",
                            //               "hasChildren:", modelData ? modelData.hasChildren : false)
                            // }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: (modelData && modelData.level !== undefined) ? modelData.level * 20 : 0
                                spacing: 5

                                // === ИСПРАВЛЕНО: Кнопка раскрытия на ВСЮ высоту ===
                                MouseArea {
                                    id: expandArea
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 30
                                    cursorShape: Qt.PointingHandCursor
                                    visible: modelData ? modelData.hasChildren : false

                                    onClicked: {
                                        // console.log("[EXPAND] Clicked on index:", index, "name:", modelData ? modelData.name : "NULL")
                                        if (sceneModel && index >= 0) {
                                            sceneModel.toggleExpand(index)
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData && modelData.expanded) ? "▼" : "▶"
                                        color: "#888"
                                        font.pixelSize: 18
                                    }
                                }

                                // Иконка
                                Text {
                                    text: (modelData && modelData.icon) ? modelData.icon : ""
                                    font.pixelSize: 14
                                }

                                // Название + выделение
                                Text {
                                    Layout.fillWidth: true
                                    text: (modelData && modelData.name) ? modelData.name : ""
                                    color: (modelData && modelData.color) ? modelData.color : "#aaa"
                                    font.bold: (modelData && modelData.bold) ? modelData.bold : false
                                    font.pixelSize: 12
                                    elide: Text.ElideRight

                                    // === Выделение на тексте ===
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onEntered: delegateRect.color = "#4a4d52"
                                        onExited: delegateRect.color = "#3a3d42"

                                        onClicked: {
                                            if (sceneModel && modelData) {
                                                sceneModel.selectElement(modelData)
                                                // console.log("[SELECT] Selected:", modelData.name)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        onCountChanged: {
                            // console.log("[REPEATER] Count:", count)
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: sceneModel
        function onModelChanged() {
            // console.log("[SceneListElementPanel] modelChanged - count:", sceneModel.flatModel.length)
            treeRepeater.model = null
            treeRepeater.model = sceneModel.flatModel
        }
        function onElementClicked(elementData) {
            // console.log("Element clicked:", elementData ? elementData.name : "NULL")
        }
        function onModelRefreshed() {
            // console.log("Model refreshed, count:", sceneModel.flatModel.length)
        }
    }
}
