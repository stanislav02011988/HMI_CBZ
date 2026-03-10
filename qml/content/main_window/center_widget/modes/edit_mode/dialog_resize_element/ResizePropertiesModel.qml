import QtQuick

QtObject {

    id: root

    property var targetElement: null

    property var treeData: []
    property var flatModel: []
    property var backupProperties: []

    property real backupRelW: 0.2
    property real backupRelH: 0.2

    signal modelChanged()


    // ======================================================
    // INIT
    // ======================================================
    function init(element) {
        targetElement = element

        if (!targetElement || !targetElement.widget)
            return

        // Сохраняем бэкап геометрии
        backupRelW = targetElement.relW
        backupRelH = targetElement.relH

        var props = targetElement.widget.getPropertiesSize()

        backupProperties = JSON.parse(JSON.stringify(props))

        // Строим дерево
        treeData = buildTree(props)

        // Добавляем группу "Размеры контейнера" вручную
        var containerGroup = {
            id: "group_container",
            name: "Размеры контейнера",
            type: "group",
            expanded: false,
            level: 0,
            children: [
                {
                    id: "container_width",
                    name: "Ширина",
                    type: "property",
                    level: 1,
                    hasChildren: false,
                    value: targetElement.relW,
                    propName: "relW",
                    min: 0,
                    max: 1,
                    step: 0.01
                },
                {
                    id: "container_height",
                    name: "Высота",
                    type: "property",
                    level: 1,
                    hasChildren: false,
                    value: targetElement.relH,
                    propName: "relH",
                    min: 0,
                    max: 1,
                    step: 0.01
                }
            ],
            hasChildren: true
        }

        treeData.unshift(containerGroup)

        flatModel = buildFlat(treeData)

        modelChanged()
    }

    // ======================================================
    // BUILD TREE
    // ======================================================
    function buildTree(props) {
        var groups = {}

        for (var i = 0; i < props.length; i++) {

            var p = props[i]

            if (!groups[p.idGroupeProperty]) {
                groups[p.idGroupeProperty] = {
                    id: "group_" + p.idGroupeProperty,
                    name: p.nameGroupeProperty,
                    type: "group",
                    expanded: false,
                    level: 0,
                    children: [],
                    hasChildren: true
                }
            }

            groups[p.idGroupeProperty].children.push({
                id: p.name,
                name: p.label,
                type: "property",
                level: 1,
                hasChildren: false,

                min: p.min,
                max: p.max,
                step: p.step,

                value: p.value,
                propName: p.name
            })
        }

        var result = []

        for (var g in groups)
            result.push(groups[g])

        return result
    }

    // ======================================================
    // BUILD FLAT
    // ======================================================
    function buildFlat(tree){
        var result = []

        function walk(nodes){

            for (var i=0;i<nodes.length;i++){

                var node = nodes[i]

                result.push(node)

                if(node.expanded && node.children)
                    walk(node.children)
            }
        }

        walk(tree)

        return result
    }

    // ======================================================
    // EXPAND
    // ======================================================
    function toggleExpand(index){
        var item = flatModel[index]

        if(!item || item.type !== "group")
            return

        var node = findNode(treeData,item.id)

        node.expanded = !node.expanded

        flatModel = buildFlat(treeData)

        modelChanged()
    }

    function findNode(nodes,id){
        for(var i=0;i<nodes.length;i++){

            var node = nodes[i]

            if(node.id===id)
                return node

            if(node.children){

                var f = findNode(node.children,id)

                if(f)
                    return f
            }
        }

        return null
    }

    // ======================================================
    // UPDATE PROPERTY
    // ======================================================
    function setProperty(name,value){
        if(!targetElement || !targetElement.widget)
            return

        targetElement.widget.setPropertySize(name,value)
    }

    // ======================================================
    // UPDATE VALUE
    // ======================================================
    function updateValue(index, value) {
        if (!flatModel)
            return

        if (index < 0 || index >= flatModel.length)
            return

        flatModel[index].value = value
    }
    // ======================================================
    // RESTORE
    // ======================================================
    function restore(){
        if(!targetElement || !targetElement.widget)
            return

        var obj = {}

        for(var i=0;i<backupProperties.length;i++)
            obj[backupProperties[i].name] =
                    backupProperties[i].value

        targetElement.widget.importProperties(obj)
        if ("relW" in targetElement) targetElement.relW = backupRelW
        if ("relH" in targetElement) targetElement.relH = backupRelH
    }

}
