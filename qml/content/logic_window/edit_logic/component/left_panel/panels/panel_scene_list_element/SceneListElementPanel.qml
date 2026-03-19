// qml/content/logic_window/edit_logic/component/left_panel/panels/scene_list_element_panel/SceneListElementPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qml.managers

Item {
    id: root

    property bool collapsed: true

    SceneElementsModel { id: sceneModel }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // Заголовок
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: "#3a3d42"
            radius: 6

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.collapsed = !root.collapsed
                onEntered: header.color = "#4a4d52"
                onExited: header.color = "#3a3d42"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Text { text: root.collapsed ? "▶" : "▼"; color: "#888"; font.pixelSize: 12 }
                Text { Layout.fillWidth: true; text: "Scene Elements"; color: "white"; font.bold: true; font.pixelSize: 13; elide: Text.ElideRight }
                Text { text: sceneModel.countElementsScene; color: "#00ff00"; font.pixelSize: 11; font.bold: true }
            }
        }

        // Контент
        Rectangle {
            id: content
            visible: !root.collapsed
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            radius: 6
            color: "#2d2f33"

            Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                // Поиск
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Search..."
                    font.pixelSize: 11
                    onTextChanged: sceneModel.setSearch(text)
                }

                // ListView с виртуализацией
                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: sceneModel.flatModel
                    clip: true
                    reuseItems: true
                    cacheBuffer: 2000
                    interactive: !root.collapsed
                    visible: !root.collapsed

                    delegate: SceneElementDelegate {
                        width: listView.width
                        elementData: modelData
                        elementIndex: index
                        modelController: sceneModel

                        onSignalAddElementToScene: (elementObject) => {
                            QmlLogicMapScene.addElemntsToSceneLogicMap(elementObject)
                        }
                    }
                }
            }
        }
    }
}
