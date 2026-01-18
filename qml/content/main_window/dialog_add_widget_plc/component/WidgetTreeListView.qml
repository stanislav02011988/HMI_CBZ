// WidgetTreeListView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

ListView {
    id: treeView
    clip: true

    // Внешние свойства
    property string selectedType: ""
    signal itemSelected(string key)

    // === ВНУТРЕННЯЯ МОДЕЛЬ ===
    ListModelPlc { id: internalModel }

    // === Карта ключей ===
    property var keyToIndex: ({})
    function buildKeyMap() {
        keyToIndex = {}
        for (let i = 0; i < internalModel.count; i++) {
            let item = internalModel.get(i)
            keyToIndex[item.key] = i
        }
    }

    // === Авто-видимость ===
    function updateVisibility() {
        for (let i = 0; i < internalModel.count; i++) {
            let item = internalModel.get(i)
            let visible = true
            if (item.type !== "group") {
                let p = item.parent
                while (p !== "" && p !== undefined) {
                    let idx = keyToIndex[p]
                    if (idx === undefined || !internalModel.get(idx).expanded) {
                        visible = false
                        break
                    }
                    p = internalModel.get(idx).parent
                }
            }
            internalModel.setProperty(i, "visible", visible)
        }
    }

    Component.onCompleted: {
        buildKeyMap()
        updateVisibility()
    }

    // === Привязка модели ===
    model: internalModel

    // === Делегат ===
    delegate: ItemDelegate {
        width: ListView.view.width
        height: (model.visible || model.type === "group") ? 36 : 0
        visible: model.visible || model.type === "group"
        leftPadding: model.type === "group" ? 8 : (model.type === "subgroup" ? 20 : 36)

        contentItem: Row {
            spacing: 8
            Label {
                text: model.type === "group" ? "📁" :
                      (model.type === "subgroup" ? "📂" : "●")
                font.pixelSize: 14
            }
            Label {
                text: model.name
                font.bold: model.type === "group"
                font.italic: model.type === "subgroup"
                color: treeView.selectedType === model.key ? "#0000ff" : "#000"
            }
        }

        background: Rectangle {
            color: treeView.selectedType === model.key ? "#e0e0ff" :
                   (model.type === "group" ? "#e8e8e8" :
                   (model.type === "subgroup" ? "#f5f5f5" : "transparent"))
            radius: 2
        }

        onClicked: {
            if (model.type === "group" || model.type === "subgroup") {
                internalModel.setProperty(index, "expanded", !model.expanded)
                treeView.updateVisibility()
            } else if (model.type === "item") {
                treeView.selectedType = model.key
                treeView.itemSelected(model.key)
            }
        }
    }
}
