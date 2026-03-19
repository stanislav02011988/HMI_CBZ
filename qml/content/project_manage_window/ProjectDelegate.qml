// qml/delegates/ProjectDelegate.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ================================
    // STAGED STATE
    // ================================
    property bool stagedAutoLoad: check_auto_load
    property bool changed: false

    // ================================
    // ВХОДНЫЕ СВОЙСТВА ИЗ GRIDVIEW
    // ================================
    property string selectedId: ""
    property string activeAutoLoadId: ""
    property bool activeAutoLoadIntendedValue: false  //  НОВОЕ

    //  Вычисляемые свойства
    property bool isSelected: selectedId === id_uuic
    property bool isAutoLoadActive: activeAutoLoadId === id_uuic

    // ================================
    // Состояние наведения
    // ================================
    property bool hovered: false

    // ================================
    // Сигналы
    // ================================
    signal signalOpenProject(string idUuic, string projectFilePath)
    signal signalDeleteProject(string idUuic)
    signal selected(bool isSelected)
    signal autoLoadActivated(string idUuic, bool intendedValue)  // Передаём намеренное значение
    signal autoLoadSaveRequested(string idUuic, bool value)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        radius: 8
        border.width: 3

        border.color: {
            if (root.isSelected) return "#4CAF50"
            if (root.hovered) return "#66BB6A"
            if (isActivateProject) return "red"
            return "#555"
        }

        color: root.isSelected ? "#4a4d52" : "#3a3d42"

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#60000000"
            radius: 10
            samples: 20
            verticalOffset: 4
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { if (!root.isSelected) root.hovered = true }
            onExited: { if (!root.isSelected) root.hovered = false }

            onClicked: (mouse) => {
                mouse.accepted = true

                if (root.isSelected) {
                    root.selected(false)
                } else {
                    root.selected(true)
                }

                root.hovered = false
            }
        }

        ColumnLayout {
            anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true

            // ================================
            // HEADER
            // ================================
            Rectangle {
                color: "transparent"
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        color: "#00ffffff"
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Text {
                            text: nameProject
                            font.bold: true
                            font.pixelSize: 16
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            anchors.fill: parent
                        }
                    }

                    // ================================
                    //  AUTOLOAD BLOCK (ИСПРАВЛЕННЫЙ)
                    // ================================
                    Rectangle {
                        color: "#00ffffff"
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        RowLayout {
                            anchors.fill: parent
                            spacing: 6

                            CheckBox {
                                id: checkBox
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                text: qsTr("Автозагрузка проекта")
                                font.family: "Times New Roman"
                                font.pointSize: 10

                                //  ИСПРАВЛЕННАЯ логика отображения чекбокса:
                                checked: {
                                    if (root.isAutoLoadActive) {
                                        // Эта карточка редактируется → показываем локальное staged
                                        return root.stagedAutoLoad
                                    } else if (root.activeAutoLoadId !== "" && root.activeAutoLoadIntendedValue === true) {
                                        // ДРУГАЯ карточка активна и хочет быть ON → эта должна выглядеть как OFF
                                        return false
                                    } else {
                                        // Обычный режим → показываем значение из модели
                                        return check_auto_load
                                    }
                                }

                                onToggled: {
                                    root.stagedAutoLoad = checked
                                    root.changed = (root.stagedAutoLoad !== check_auto_load)
                                    if (!root.isAutoLoadActive) {
                                        root.autoLoadActivated(id_uuic, checked)
                                    }
                                }
                            }

                            Button {
                                text: qsTr("Сохранить")
                                visible: root.isAutoLoadActive && root.changed
                                Layout.fillHeight: true

                                onClicked: {
                                    root.autoLoadSaveRequested(id_uuic, root.stagedAutoLoad)
                                }
                            }
                        }
                    }
                }
            }

            // ================================
            // IMAGE / DATES / BUTTONS (без изменений)
            // ================================
            Rectangle {
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true

                Image {
                    anchors.fill: parent
                    source: previewInstallation && previewInstallation !== ""
                            ? previewInstallation
                            : ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onDoubleClicked: { signalOpenProject(id_uuic, project_file) }
                    onClicked: (mouse) => { mouse.accepted = false }
                }
            }

            Rectangle {
                color: "transparent"
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Создан: " + (created || ""); font.pixelSize: 10; color: "lightgray"; Layout.fillWidth: true }
                    Text { text: "Последнее: " + (last_saved || ""); font.pixelSize: 10; color: "lightgray"; Layout.fillWidth: true }
                }
            }

            Rectangle {
                color: "transparent"
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                visible: root.isSelected
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Button {
                        text: "Открыть"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: signalOpenProject(id_uuic, project_file)
                    }
                    Button {
                        text: "Удалить"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: signalDeleteProject(id_uuic)
                    }
                }
            }
        }
    }
}
