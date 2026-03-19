// qml\content\logic_window\edit_logic\component\scene\dialog_resize_element_logic_map\DialogResizeElementLogicMap.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.controls.button
import qml.settings.menager_theme
import qml.managers

Popup {
    id: root

    property Item targetElement: null
    property bool wasApplied: false

    x: Math.round((Overlay.overlay.width - width) / 2)
    y: Math.round((Overlay.overlay.height - height) / 2)

    width: 450
    height: Math.min(600, Screen.height * 0.9)

    closePolicy: Popup.CloseOnEscape | Popup.NoAutoClose

    modal: true
    focus: true
    padding: 0

    background: null
    Overlay.modal: Rectangle {
        color: "transparent"
    }

    onOpened: {
        resizeModel.init(targetElement)
    }

    onAboutToHide: {
        if (!wasApplied)
            resizeModel.restore()
    }

    ResizePropertiesModelLogicMap {
        id: resizeModel
    }

    // =====================================================
    // BACKGROUND
    // =====================================================
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
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            // =====================================================
            // HEADER (DRAG AREA)
            // =====================================================
            Rectangle {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: "#2c3e50"
                radius: 6

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor

                    property point dragStart

                    onPressed: dragStart = Qt.point(mouseX, mouseY)

                    onPositionChanged: (mouse)=>{
                        if(mouse.buttons & Qt.LeftButton){
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
                        text: targetElement && targetElement.widget
                            ? `Изменение размеров: ${targetElement.widget.name_widget} [${targetElement.widget.id_widget}]`
                            : "Изменение размеров"

                        color: "white"
                        font.bold: true
                        font.pixelSize: 14

                        verticalAlignment: Text.AlignVCenter
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
                            root.wasApplied = false
                            resizeModel.restore()
                            root.close()
                        }
                    }
                }
            }

            // =====================================================
            // BG LISTVIEW СВОЙСТВ
            // =====================================================
            Rectangle {
                id: bgListView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                clip: true

                // =====================================================
                // LISTVIEW СВОЙСТВ
                // =====================================================
                ListView {
                    id: propertyList
                    anchors.fill: parent
                    spacing: 2

                    reuseItems: true
                    cacheBuffer: 2000
                    displayMarginBeginning: 50 // Предзагрузка делегатов сверху
                    displayMarginEnd: 50       // Предзагрузка делегатов снизу

                    model: resizeModel.flatModel

                    delegate: ResizePropertyDelegateLogicMap {
                        width: propertyList.width
                        elementData: modelData
                        elementIndex: index
                        modelController: resizeModel
                    }
                }
            }

            // =====================================================
            // BUTTONS
            // =====================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: "Отменить"
                    background: Rectangle {
                        color: "#e74c3c"
                        radius: 4
                    }
                    onClicked: {
                        root.wasApplied = false
                        resizeModel.restore()
                        root.close()
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Применить"
                    background: Rectangle {
                        color: "#27ae60"
                        radius: 4
                    }
                    onClicked: {
                        root.wasApplied = true
                        if(typeof QmlSceneManager !== 'undefined' && targetElement?.widget?.id_widget){ QmlSceneManager.updateOneElement(targetElement.widget.id_widget) }
                        root.close()
                    }
                }
            }
        }
    }
}
