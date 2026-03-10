// qml\content\logic_window\edit_logic\component\left_panel\LogicLeftPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "panels"
import "panels/scene_list_element_panel"

Item {
    id: root

    property int minSizeBg: 45

    ListModel {
        id: modelBlocks
        ListElement { type: "project"; title: "Project Tree"; minHeight: 45; stretch: 1 }
        ListElement { type: "blocks"; title: "Standard Blocks"; minHeight: 45; stretch: 1 }
        ListElement { type: "scene"; title: "Scene Elements"; minHeight: 45; stretch: 2 }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#81848c"

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 6
            clip: true
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds

            model: modelBlocks

            reuseItems: true           // Повторное использование делегатов
            cacheBuffer: 300           // Буфер 300px за пределами видимости
            displayMarginBeginning: 50 // Предзагрузка делегатов сверху
            displayMarginEnd: 50       // Предзагрузка делегатов снизу

            delegate: Rectangle {
                id: panelDelegate
                width: ListView.view.width

                height: {
                    if (!panelLoader.item) return root.minSizeBg
                    if (panelLoader.item.collapsed) return root.minSizeBg
                    if (ListView.view.height <= 0) return minHeight
                    var totalStretch = 4
                    var calculated = ListView.view.height * stretch / totalStretch
                    return Math.max(minHeight, calculated)
                }

                radius: 6
                color: "transparent"
                border.color: "#666"
                border.width: 1

                Loader {
                    id: panelLoader
                    anchors.fill: parent
                    anchors.margins: 4

                    property string panelType: model.type
                    property string panelTitle: model.title

                    sourceComponent: {
                        switch(panelType) {
                        case "project": return projectPanelComponent
                        case "blocks": return blocksPanelComponent
                        case "scene": return scenePanelComponent
                        default: return null
                        }
                    }

                    // 🔥 Когда панель загрузилась — обновляем высоту делегата
                    onLoaded: {
                        if (item && item.collapsed !== undefined) {
                            listView.model = listView.model
                        }
                        if (item) {
                            item.collapsedChangedExternal.connect(function() {
                                listView.model = listView.model
                            })
                        }
                    }
                }
            }
        }
    }

    Component {
        id: projectPanelComponent
        ProjectTreePanel { anchors.fill: parent }
    }
    Component {
        id: blocksPanelComponent
        StandardBlocksPanel { anchors.fill: parent }
    }
    Component {
        id: scenePanelComponent
        SceneListElementPanel { anchors.fill: parent }
    }
}
