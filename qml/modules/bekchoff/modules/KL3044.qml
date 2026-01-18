import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import qml.controls.led_indicator

Item {
    id: kl3044
    width: 43
    height: 340

    property var global_dialog_manager

    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"


    property string type_module: "kl3044"
    property string name_module: qsTr("AE1")

    property string module_title: "KL3044"
    property string module_description: "Шинный терминал, 4-канальный аналоговый вход, ток, 0–20 мА, 12 бит, несимметричный"
    property string module_long_description: "Аналоговый входной терминал KL3044 предназначен для передачи аналоговых измерительных сигналов с электрической изоляцией на устройство автоматизации."
    property string module_features: "Вводная электроника не зависит от напряжения питания силовых контактов. Заземление является опорным потенциалом для входов. Светодиоды ошибки указывают на перегрузку. KL3044 объединяет четыре канала в одном корпусе."

    property string led_circle_error_1_mod: "on"
    property string led_circle_error_2_mod: "blink"
    property string led_circle_error_3_mod: "blink"
    property string led_circle_error_4_mod: "blink"



    Rectangle {
        id: body
        color: "#00ffffff"
        border.color: "#7b7978"
        anchors.fill: parent

        // Тень
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#80000000"
            radius: 4
            horizontalOffset: 2
            samples: 16
            verticalOffset: 2
        }

        Image {
            id: image
            anchors.fill: parent
            source: "qrc:/image/bekchoff/modules/res/image/bekchoff/images_modules/kl3044.jpg"
            fillMode: Image.PreserveAspectFit
        }


        LedIndicator {
            id: led_circle_error_1
            x: 2
            y: 31
            width: 15
            height: 15
            radius: 7
            border.color: "#6a0000"
            onColor: "#b90000"
            mode: led_circle_error_1_mod
            actualEnabled: false
            glowEdge: "#ff0000"
        }

        LedIndicator {
            id: led_circle_error_2
            x: 20
            y: 31
            width: 15
            height: 15
            radius: 7
            border.color: "#6a0000"
            onColor: "#b90000"
            mode: led_circle_error_2_mod
            glowEdge: "#ff0000"
            actualEnabled: false
        }

        LedIndicator {
            id: led_circle_error_3
            x: 2
            y: 49
            width: 15
            height: 15
            radius: 7
            border.color: "#6a0000"
            onColor: "#b90000"
            mode: led_circle_error_3_mod
            glowEdge: "#ff0000"
            actualEnabled: false
        }

        LedIndicator {
            id: led_circle_error_4
            x: 20
            y: 49
            width: 15
            height: 15
            radius: 7
            border.color: "#6a0000"
            onColor: "#b90000"
            mode: led_circle_error_4_mod
            glowEdge: "#ff0000"
            actualEnabled: false
        }

        Rectangle {
            id: rectangle
            height: 29
            color: "#e3e2df"
            radius: 0
            border.color: "#007b7978"
            border.width: 1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.rightMargin: 1
            anchors.topMargin: 0

            Text {
                id: text1
                text: kl3044.name_module
                anchors.fill: parent
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.family: "Times New Roman"
            }
        }
    }

    Rectangle {
        id: rec_mouse_area_click_open_dialog_electric_scheme_module
        height: 29
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 1
        anchors.topMargin: 0

        color: hovered ? "#93939393" : "#00ffffff"

        property bool hovered: false

        MouseArea {
            id: click_open_dialog_electric_scheme_module
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            hoverEnabled: true
            onEntered: rec_mouse_area_click_open_dialog_electric_scheme_module.hovered = true
            onExited: rec_mouse_area_click_open_dialog_electric_scheme_module.hovered = false

            onClicked: {
                if (global_dialog_manager && global_dialog_manager.openPopup){
                    global_dialog_manager.openPopup(
                                kl3044.path_source_qml_file_electric_scheme_module,
                                "electric_scheme",
                                kl3044.x,
                                kl3044.y,
                                kl3044.type_module
                                )
                }
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }

    Rectangle {
        id: rec_mouse_area_click_open_dialog_decription
        height: 29
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 0

        color: hovered ? "#93939393" : "#00ffffff"

        property bool hovered: false

        MouseArea {
            id: click_open_dialog_decription_module
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            hoverEnabled: true
            onEntered: rec_mouse_area_click_open_dialog_decription.hovered = true
            onExited: rec_mouse_area_click_open_dialog_decription.hovered = false

            onClicked: {
                if (global_dialog_manager && global_dialog_manager.openPopup){
                    global_dialog_manager.openPopup(
                                kl3044.path_source_qml_file_decriton_module,
                                "decription",
                                kl3044.x,
                                kl3044.y,
                                kl3044.type_module,
                                kl3044.module_title,
                                kl3044.module_description,
                                kl3044.module_long_description,
                                kl3044.module_features
                                )
                }
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }
}
