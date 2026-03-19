// qml/content/logic_window/edit_logic/component/left_panel/panels/scene_list_element_panel/SceneElementsModel.qml
import QtQuick
import QtQuick.Controls
import qml.registers

QtObject {
    id: root

    // =================================================
    // DATA
    // =================================================
    property var treeData: []          // иерархическая структура групп и виджетов
    property var flatModel: []         // "виртуальный" плоский список для ListView
    property string searchText: ""     // текст поиска
    property var selectedElement: null // выбранный элемент
    property int countElementsScene: backend.count

    readonly property var backend: QmlRegisterComponentObject
    property var nodeMap: ({})           // карта id → node для O(1) поиска

    signal elementClicked(var elementData)
    signal modelChanged()

    // =================================================
    // SEARCH TIMER (debounce)
    // =================================================
    property Timer searchTimer: Timer {
        id: searchTimer
        interval: 120
        repeat: false
        onTriggered: rebuildFlatModel()
    }

    // =================================================
    // INIT
    // =================================================
    Component.onCompleted: {
        refreshModel()

        if (backend && backend.registryChanged)
            backend.registryChanged.connect(refreshModel)
    }

    // =================================================
    // REFRESH MODEL
    // =================================================
    function refreshModel() {
        treeData = buildTreeData()
        rebuildNodeMap(treeData) // строим карту id → node для быстрого поиска
        rebuildFlatModel()
    }

    // =================================================
    // SEARCH
    // =================================================
    function setSearch(text) {
        var newText = text.toLowerCase()
        if (newText === searchText)
            return

        searchText = newText
        searchTimer.restart()
    }

    // =================================================
    // SELECT
    // =================================================
    function selectElement(elementData) {
        selectedElement = elementData
        elementClicked(elementData)
    }

    // =================================================
    // EXPAND / COLLAPSE
    // =================================================
    function toggleExpand(index) {
        var item = flatModel[index]
        if (!item || !item.hasChildren)
            return

        var node = nodeMap[item.id] // быстрый поиск через map
        if (!node)
            return

        node.expanded = !node.expanded
        rebuildFlatModel()
    }

    function expandAll() {
        setExpanded(treeData, true)
        rebuildFlatModel()
    }

    function collapseAll() {
        setExpanded(treeData, false)
        rebuildFlatModel()
    }

    // =================================================
    // BUILD TREE
    // =================================================
    function buildTreeData() {
        var result = []
        var ids = backend.getAllIds()
        var groups = {}

        for (var i = 0; i < ids.length; i++) {
            var id = ids[i]
            var record = backend.getElementById(id)
            if (!record || !record.widgetRef)
                continue

            var widget = record.widgetRef
            var wrapper = record.wrapperRef
            var groupName = widget.componentGroupe || "Default"

            if (!groups[groupName])
                groups[groupName] = []

            groups[groupName].push(createWidgetNode(
                id,
                widget.name_widget || id,
                widget.subtype || "unknown",
                widget,
                wrapper
            ))
        }

        for (var groupName in groups) {
            result.push(createGroupNode(groupName, groups[groupName]))
        }

        return result
    }

    // =================================================
    // NODE FACTORIES
    // =================================================
    function createGroupNode(name, children) {
        return {
            name: name,
            id: "group_" + name,
            type: "group",
            level: 0,
            expanded: false,
            children: children,
            hasChildren: children.length > 0,
            icon: "📁",
            color: "#ffffff",
            bold: true
        }
    }

    function createWidgetNode(id, name, subtype, widgetRef, wrapperRef) {
        return {
            name: name,
            id: id,  // это id записи в реестре
            type: "widget",
            subtype: subtype,
            level: 1,
            expanded: false,
            children: [],
            hasChildren: false,
            icon: "🧩",
            color: "#dddddd",
            bold: false,

            // 🔥 Ссылки на оригинальные объекты
            widgetRef: widgetRef,
            wrapperRef: wrapperRef,

            // 🔥 Копируем нужные поля для createObject()
            // Из widgetRef:
            id_widget: widgetRef?.id_widget || id,
            name_widget: widgetRef?.name_widget || name,
            componentGroupe: widgetRef?.componentGroupe || "",

            // Из wrapperRef (геометрия):
            geometry: wrapperRef ? {
                relX: wrapperRef.relX || 0.1,
                relY: wrapperRef.relY || 0.1,
                relW: wrapperRef.relW || 0.2,
                relH: wrapperRef.relH || 0.2
            } : { relX: 0.1, relY: 0.1, relW: 0.2, relH: 0.2 },

            // Свойства размера:
            sizeProperties: widgetRef?.sizeProperties || {}
        }
    }

    // =================================================
    // REBUILD NODE MAP (для быстрого поиска по id)
    // =================================================
    function rebuildNodeMap(nodes) {
        nodeMap = {}

        function walk(nodelist) {
            for (var i = 0; i < nodelist.length; i++) {
                var node = nodelist[i]
                nodeMap[node.id] = node
                if (node.children.length > 0)
                    walk(node.children)
            }
        }

        walk(nodes)
    }

    // =================================================
    // REBUILD FLAT MODEL (виртуализация)
    // =================================================
    function rebuildFlatModel() {
        var result = []
        var search = searchText

        function walk(nodes) {
            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i]
                var nameLower = node.name.toLowerCase()
                var match = search === "" || nameLower.indexOf(search) !== -1

                if (node.type === "group") {
                    result.push(node)
                    if (node.expanded || search !== "")
                        walk(node.children)
                } else {
                    if (match)
                        result.push(node)
                }
            }
        }

        walk(treeData)
        flatModel = result
        modelChanged()
    }

    // =================================================
    // UTILS
    // =================================================
    function setExpanded(nodes, state) {
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i]
            node.expanded = state
            if (node.children.length > 0)
                setExpanded(node.children, state)
        }
    }

    function findNode(nodes, id) {
        return nodeMap[id] || null
    }
}
