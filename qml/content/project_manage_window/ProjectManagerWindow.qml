// qml/windows/ProjectManagerWindow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button
import qml.settings.project_settings
import qml.settings.menager_theme
import qml.managers
import "./dialog_new_project"

Popup {
    id: root

    x: Math.round((Overlay.overlay.width - width) / 2)
    y: Math.round((Overlay.overlay.height - height) / 2)

    width: 900
    height: Math.min(600, Screen.height * 0.9)

    modal: true
    focus: true
    padding: 0

    background: null
    Overlay.modal: Rectangle {
        color: "transparent"
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "white"
        border.color: "#444"
        radius: 8

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#60000000"
            radius: 10
            samples: 20
            verticalOffset: 4
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 5

            // =====================================================
            // HEADER (DRAG AREA)
            // =====================================================
            Rectangle {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: "#2c3e50"
                radius: 6
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor

                    property point dragStart

                    onPressed: dragStart = Qt.point(mouseX, mouseY)

                    onPositionChanged: (mouse) => {
                        if (mouse.buttons & Qt.LeftButton) {
                            root.x += mouseX - dragStart.x
                            root.y += mouseY - dragStart.y

                            root.x = Math.max(0, Math.min(Screen.width - root.width, root.x))
                            root.y = Math.max(0, Math.min(Screen.height - root.height, root.y))
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8

                    Text {
                        Layout.fillWidth: true
                        text: "Менеджер проектов"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Times New Roman"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        elide: Text.ElideRight
                    }

                    CustomButton {
                        text: "✕"
                        m_width: 30
                        m_height: 30
                        m_background_color: QmlMenagerTheme.reg_win_cBtnClose_background
                        m_color_hovered: QmlMenagerTheme.reg_win_cBtnClose_color_hovered
                        m_borderColor: QmlMenagerTheme.reg_win_cBtnClose_borderColor
                        m_colorText: QmlMenagerTheme.reg_win_cBtnClose_colorText
                        m_colorTextHovered: QmlMenagerTheme.reg_win_cBtnClose_colorTextHovered
                        onClicked: {
                            root.close()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.margins: 10
                spacing: 8

                Button {
                    text: "Новый проект"
                    onClicked: dialogNewProject.open()
                }
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Поиск..."
                    onTextChanged: {
                        searchDelay.restart()
                    }
                }
            }

            // =====================================================
            // GRIDVIEW С АДАПТИВНЫМИ КОЛОНКАМИ
            // =====================================================
            GridView {
                id: gridProjects
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10
                model: QmlProjectSettings.model
                clip: true
                cacheBuffer: 800

                // Адаптивные колонки
                property int columns: {
                    if (width < 650) return 1
                    if (width < 1100) return 2
                    return 3
                }
                property real cellSpacing: 20
                cellWidth: (width - (columns - 1) * cellSpacing) / columns
                cellHeight: 350

                // Выделение карточки
                property string selectedId: ""
                function deselectAll() { selectedId = "" }

                //  Активная карточка для редактирования автозагрузки
                property string activeAutoLoadId: ""
                //  НОВОЕ: Намеренное значение автозагрузки для активной карточки
                property bool activeAutoLoadIntendedValue: false

                function deactivateAutoLoad() {
                    activeAutoLoadId = ""
                    activeAutoLoadIntendedValue = false
                }

                delegate: ProjectDelegate {
                    width: gridProjects.cellWidth
                    height: gridProjects.cellHeight

                    //  Передаём ВСЕ необходимые свойства
                    selectedId: gridProjects.selectedId
                    activeAutoLoadId: gridProjects.activeAutoLoadId
                    activeAutoLoadIntendedValue: gridProjects.activeAutoLoadIntendedValue

                    // Выделение карточки
                    onSelected: (isSelected) => {
                        if (isSelected) {
                            gridProjects.selectedId = id_uuic
                        } else if (gridProjects.selectedId === id_uuic) {
                            gridProjects.selectedId = ""
                        }
                    }

                    //  Активация чекбокса для редактирования
                    onAutoLoadActivated: (idUuic, intendedValue) => {
                        gridProjects.activeAutoLoadId = idUuic
                        gridProjects.activeAutoLoadIntendedValue = intendedValue
                    }

                    // Запрос на сохранение
                    onAutoLoadSaveRequested: (idUuic, value) => {
                        QmlProjectSettings.model.setAutoLoad(idUuic, value)
                    }

                    onSignalOpenProject: (id_uuic, projectFilePath) => root.openProject(id_uuic, projectFilePath)

                    onSignalDeleteProject: (id_uuic) => {
                        QmlProjectSettings.model.removeProject(id_uuic)
                        if (gridProjects.selectedId === id_uuic) gridProjects.deselectAll()
                        if (gridProjects.activeAutoLoadId === id_uuic) gridProjects.deactivateAutoLoad()
                    }
                }
            }
        }
    }

    Timer {
        id: searchDelay
        interval: 200
        repeat: false
        onTriggered: projectModel.search(searchField.text)
    }

    DialogNewProject {
        id: dialogNewProject
        modal: true
    }

    function openProject(id_uuic, projectFilePath) {
        QmlProjectManager.loadProject(id_uuic, projectFilePath)
        root.close()
    }
}
