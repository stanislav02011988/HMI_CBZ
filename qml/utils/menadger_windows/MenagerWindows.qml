pragma Singleton
import QtQuick

QtObject {
    id: root
    property var currentWindow: null

    function show(windowComponentUrl, dialog) {
        if (root.currentWindow) {
            root.currentWindow.close()
            root.currentWindow.destroy()
        }
        var comp = Qt.createComponent(windowComponentUrl)
        if (comp.status === Component.Ready) {
            root.currentWindow = comp.createObject(null)
            if (root.currentWindow) {
                if (windowComponentUrl === "qrc:/qml_files/qml/content/main_window/MainWindow.qml"){ root.currentWindow.showMaximized() }
                else { root.currentWindow.show() }
            }
        }  else {
            if (dialog) {
                dialog.close()
                dialog.showDialog("error", "[WindowManager.qml] : 13", "Ошибка загрузки окна", "Файл отсутствует или повреждён:\n" + windowComponentUrl + "\n" + comp.errorString())
            } else {
                console.warn("Нет диалога для отображения ошибки!")
            }
        }
    }

    function showWindow(windowComponentUrl){
        var obj = Qt.createComponent(windowComponentUrl)
        if (obj.status === Component.Ready) {
            obj.createObject(null)
        } else {
            console.log(obj.errorString())
        }
    }
}
