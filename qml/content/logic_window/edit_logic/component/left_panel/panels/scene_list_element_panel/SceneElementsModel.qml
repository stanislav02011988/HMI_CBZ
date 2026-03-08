// qml/content/logic_window/edit_logic/component/left_panel/SceneElementsModel.qml
import QtQuick
import qml.registers

QtObject {
    id: root

    // =========================================================================
    // PUBLIC PROPERTIES
    // =========================================================================
    property var flatModel: []          // Плоский список видимых элементов
    property var treeData: []           // Полная структура дерева
    property var selectedElement: null
    property int countElementsScene: QmlRegisterComponentObject.count

    // Сигналы
    signal elementClicked(var elementData)
    signal modelRefreshed()
    signal modelChanged()

    // =========================================================================
    // BACKEND LINK
    // =========================================================================
    readonly property var backend: QmlRegisterComponentObject

    // =========================================================================
    // INITIALIZATION
    // =========================================================================
    Component.onCompleted: {
        // console.log("[SceneElementsModel] Component.onCompleted")
        refreshModel()
        backend.registryChanged.connect(refreshModel)
    }

    // =========================================================================
    // PUBLIC METHODS
    // =========================================================================
    function refreshModel() {
        // console.log("[SceneElementsModel] refreshModel()")
        treeData = buildTreeData()
        flatModel = buildFlatModel(treeData)
        // console.log("[SceneElementsModel] flatModel.length:", flatModel.length)
        modelRefreshed()
        modelChanged()
    }

    function selectElement(elementData) {
        selectedElement = elementData
        elementClicked(elementData)
    }

    function toggleExpand(index) {
        if (index < 0 || index >= flatModel.length) {
            // console.log("[toggleExpand] Invalid index:", index, "flatModel.length:", flatModel.length)
            return
        }

        var flatItem = flatModel[index]
        // console.log("[toggleExpand] Flat item:", flatItem.name, "hasChildren:", flatItem.hasChildren)

        if (flatItem.hasChildren) {
            var treeNode = findNodeInTree(treeData, flatItem.id)
            if (treeNode) {
                treeNode.expanded = !treeNode.expanded
                // console.log("[toggleExpand] Tree node:", treeNode.name, "expanded:", treeNode.expanded)
            }

            flatModel = buildFlatModel(treeData)
            modelChanged()
        }
    }

    function expandAll() {
        setExpanded(treeData, true)
        flatModel = buildFlatModel(treeData)
        modelChanged()
    }

    function collapseAll() {
        setExpanded(treeData, false)
        flatModel = buildFlatModel(treeData)
        modelChanged()
    }

    // =========================================================================
    // FIND NODE IN TREE
    // =========================================================================
    function findNodeInTree(nodeList, targetId) {
        for (var i = 0; i < nodeList.length; i++) {
            var node = nodeList[i]
            if (node.id === targetId) {
                return node
            }
            if (node.children && node.children.length > 0) {
                var found = findNodeInTree(node.children, targetId)
                if (found) return found
            }
        }
        return null
    }

    // =========================================================================
    // BUILD TREE DATA (2 уровня: Группа → Виджет)
    // =========================================================================
    function buildTreeData() {
        var result = []
        var allIds = backend.getAllIds()
        var groups = {}

        // console.log("[buildTreeData] Processing", allIds.length, "widgets")

        for (var i = 0; i < allIds.length; i++) {
            var id = allIds[i]
            var record = backend.getElementById(id)

            if (!record || !record.widgetRef) {
                console.log("[buildTreeData] Skip id:", id)
                continue
            }

            var widget = record.widgetRef
            var wrapper = record.wrapperRef

            var groupName = widget.componentGroupe || "DefaultGroup"
            var widgetName = widget.name_widget || id
            var subType = widget.subtype || "unknown"

            // console.log("[buildTreeData] Widget:", id, "group:", groupName, "subtype:", subType)

            if (!groups[groupName]) {
                groups[groupName] = []
            }

            var widgetNode = createWidgetNode(id, widgetName, subType, widget, wrapper)
            groups[groupName].push(widgetNode)
        }

        for (var groupName in groups) {
            result.push(createGroupNode(groupName, groups[groupName]))
        }

        result.sort(function(a, b) { return a.name.localeCompare(b.name) })
        return result
    }

    // =========================================================================
    // CREATE NODES
    // =========================================================================
    function createGroupNode(groupName, children) {
        return {
            "name": groupName,
            "id": "group_" + groupName,
            "type": "group",
            "level": 0,
            "expanded": false,
            "children": children,
            "icon": "📁",
            "color": "#ffffff",
            "bold": true,
            "visible": true
        }
    }

    // =========================================================================
    // TODO: 3-й уровень (внутренние элементы виджета)
    // =========================================================================
    /*
    ============================================================================
    3-й УРОВЕНЬ ДЕРЕВА: ВНУТРЕННИЕ ЭЛЕМЕНТЫ ВИДЖЕТА
    ============================================================================

    Структура:
      Уровень 0: Группа (📁 GroupeCement)
      Уровень 1: Виджет (🧩 Valve_01)
      Уровень 2: Элементы виджета (🔹 Body, 🔹 Status LED, 🔹 Progress Bar)

    Для реализации 3-го уровня необходимо:

    1. В каждом виджете добавить свойство internalElements:
       ```qml
       property var internalElements: [
           { "name": "Body", "id": id_widget + "_body" },
           { "name": "Status LED", "id": id_widget + "_led" },
           { "name": "Progress Bar", "id": id_widget + "_progress" }
       ]
       ```

    2. Раскомментировать функцию getInternalElements() ниже

    3. В createWidgetNode() заменить:
       var internalElements = []
       на:
       var internalElements = getInternalElements(id, widgetName, subType, widgetRef, wrapperRef)

    4. В SceneListElementPanel.qml добавить отступ для уровня 2:
       anchors.leftMargin: (modelData && modelData.level !== undefined) ? modelData.level * 20 : 0
       (уже работает, level=2 даст отступ 40px)

    5. Добавить иконку для элементов (🔹)

    ============================================================================
    */

    function createWidgetNode(id, widgetName, subType, widgetRef, wrapperRef) {
        // === TODO: Раскомментировать для 3-го уровня ===
        // var internalElements = getInternalElements(id, widgetName, subType, widgetRef, wrapperRef)

        var internalElements = []  // Пока пусто (2 уровня)

        return {
            "name": widgetName,
            "id": id,
            "type": "widget",
            "subtype": subType,
            "level": 1,
            "expanded": false,
            "children": internalElements,
            "icon": "🧩",
            "color": "#dddddd",
            "bold": false,
            "visible": true,
            "widgetRef": widgetRef,
            "wrapperRef": wrapperRef
        }
    }

    // =========================================================================
    // TODO: Функция для получения внутренних элементов виджета
    // =========================================================================
    /*
    function getInternalElements(widgetId, widgetName, subType, widgetRef, wrapperRef) {
        var elements = []

        // 1. Попытка получить internalElements из виджета
        if (widgetRef && widgetRef.internalElements) {
            var internalList = widgetRef.internalElements
            for (var i = 0; i < internalList.length; i++) {
                var elem = internalList[i]
                elements.push(createElementNode(
                    elem.id || (widgetId + "_elem_" + i),
                    elem.name || ("Element " + (i + 1)),
                    widgetId,
                    widgetRef,
                    wrapperRef
                ))
            }
        }

        // 2. Заглушки для демонстрации (если нет internalElements)
        if (elements.length === 0) {
            elements.push(createElementNode(widgetId + "_body", "Body", widgetId, widgetRef, wrapperRef))
            elements.push(createElementNode(widgetId + "_status", "Status", widgetId, widgetRef, wrapperRef))

            if (wrapperRef) {
                elements.push(createElementNode(
                    widgetId + "_geometry",
                    "Geometry (X:" + wrapperRef.relX + ", Y:" + wrapperRef.relY + ")",
                    widgetId,
                    widgetRef,
                    wrapperRef
                ))
            }
        }

        return elements
    }

    function createElementNode(id, name, parentWidgetId, widgetRef, wrapperRef) {
        return {
            "name": name,
            "id": id,
            "type": "element",
            "level": 2,
            "expanded": false,
            "children": [],
            "icon": "🔹",
            "color": "#aaaaaa",
            "bold": false,
            "visible": true,
            "parentWidgetId": parentWidgetId,
            "widgetRef": widgetRef,
            "wrapperRef": wrapperRef
        }
    }
    */

    // =========================================================================
    // FLATTEN TREE TO LIST
    // =========================================================================
    function buildFlatModel(treeNodes, visibleParent) {
        var flat = []
        if (visibleParent === undefined) visibleParent = true

        for (var i = 0; i < treeNodes.length; i++) {
            var node = treeNodes[i]

            var flatNode = {}
            for (var key in node) {
                if (key !== "children") {
                    flatNode[key] = node[key]
                }
            }

            flatNode.hasChildren = node.children && node.children.length > 0
            flatNode.visible = visibleParent
            flatNode.index = flat.length

            flat.push(flatNode)

            if (node.children && node.children.length > 0 && node.expanded && visibleParent) {
                // console.log("[buildFlatModel] Expanding:", node.name, "adding", node.children.length, "children")
                var childrenFlat = buildFlatModel(node.children, true)
                for (var j = 0; j < childrenFlat.length; j++) {
                    flat.push(childrenFlat[j])
                }
            }
        }

        return flat
    }

    function setExpanded(nodeList, expanded) {
        for (var i = 0; i < nodeList.length; i++) {
            nodeList[i].expanded = expanded
            if (nodeList[i].children && nodeList[i].children.length > 0) {
                setExpanded(nodeList[i].children, expanded)
            }
        }
    }
}
