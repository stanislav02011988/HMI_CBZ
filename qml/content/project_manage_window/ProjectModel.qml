// qml/models/ProjectModel.qml
import QtQuick
import QtQml

QtObject {
    id: projectModelRoot

    property var projects: []       // весь массив проектов
    property var visibleProjects: [] // виртуальная модель для GridView
    property int batchSize: 200     // сколько элементов грузить за раз

    signal dataChanged()

    // =====================================
    // Инициализация из внешнего источника
    // =====================================
    function loadFromPython(projectsArray) {
        if (!projectsArray) return
        projects = []
        for (var i = 0; i < projectsArray.length; i++) {
            projects.push(projectsArray[i])
        }
        refreshVisible()
    }

    // =====================================
    // Обновление виртуальной модели (GridView)
    // =====================================
    function refreshVisible() {
        visibleProjects = projects.slice(0, projects.length)
        dataChanged()
    }

    // =====================================
    // Добавление проектов
    // =====================================
    function appendProjects(newProjects) {
        if (!newProjects) return
        projects = projects.concat(newProjects)
        refreshVisible()
    }

    // =====================================
    // Очистка
    // =====================================
    function clear() {
        projects = []
        visibleProjects = []
        dataChanged()
    }

    // =====================================
    // Поиск
    // =====================================
    function search(text) {
        if (!text) {
            refreshVisible()
            return
        }
        var lowerText = text.toLowerCase()
        visibleProjects = projects.filter(function(p) {
            return (p.installationName || "").toLowerCase().indexOf(lowerText) !== -1
        })
        dataChanged()
    }

    // =====================================
    // Добавление одного проекта через Python
    // =====================================
    function addProject(projectDict) {
        projects.push(projectDict)
        refreshVisible()
    }

    // =====================================
    // Удаление по id
    // =====================================
    function removeProjectById(id) {
        projects = projects.filter(function(p) { return p.id_uuic !== id })
        refreshVisible()
    }

    // =====================================
    // Обновление карточки проекта
    // projectDict должен содержать id_uuic
    // =====================================
    function updateProject(projectDict) {
        for (var i = 0; i < projects.length; i++) {
            if (projects[i].id_uuic === projectDict.id_uuic) {
                projects[i] = projectDict
                break
            }
        }
        refreshVisible()
    }
}
