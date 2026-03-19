pragma Singleton

import QtQuick
import QtQuick.Window

QtObject {

    id: manager

    // ===============================
    // хранилище окон
    // ===============================
    property var windows: ({})

    // ===============================
    // открыть окно
    // ===============================
    function openWindow(id, componentUrl, props) {
        var win = windows[id]

        // =================================================
        // если окно уже существует
        // =================================================
        if (win) {
            // применяем новые свойства если передали
            if (props) {
                for (var key in props) {
                    win[key] = props[key]
                }
            }

            // особая логика для главного окна
            if (id === "main_window") {
                win.show()
                win.visibility = Window.Maximized
            } else {
                win.show()
            }

            win.raise()
            win.requestActivate()

            return win
        }

        // =================================================
        // создаём компонент
        // =================================================
        var component = Qt.createComponent(componentUrl)

        if (component.status !== Component.Ready) {
            console.warn("Window load error:", component.errorString())
            return null
        }

        // =================================================
        // создаём окно
        // =================================================
        win = component.createObject(null, props ? props : {})

        if (!win) {
            console.warn("Window creation failed")
            return null
        }

        // =================================================
        // сохраняем
        // =================================================
        windows[id] = win

        // =================================================
        // удаляем при закрытии
        // =================================================
        win.closing.connect(function() {
            delete windows[id]
        })

        // =================================================
        // открываем окно
        // =================================================
        if (id === "main_window") {
            win.showMaximized()
        } else {
            win.show()
        }

        return win
    }

    // ===============================
    // закрыть окно
    // ===============================
    function closeWindow(id) {
        var win = windows[id]

        if (!win)
            return

        win.close()
        delete windows[id]
    }

    // ===============================
    // проверить существует ли окно
    // ===============================
    function exists(id) {
        return windows[id] !== undefined
    }

}
