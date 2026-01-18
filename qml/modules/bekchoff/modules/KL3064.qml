import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../controls/led_indicator"
Item {
    id: kl3064
    width: 43
    height: 340

    property var global_dialog_manager

    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"

    property string type_module: "kl3064"
    property string module_title: "KL3064"
    property string module_description: "Шинный терминал, 4-канальный аналоговый вход, ток, 0–20 мА, 12 бит, несимметричный"
    property string module_long_description: "Аналоговый входной терминал KL3044 предназначен для передачи аналоговых измерительных сигналов с электрической изоляцией на устройство автоматизации."
    property string module_features: "Вводная электроника не зависит от напряжения питания силовых контактов. Заземление является опорным потенциалом для входов. Светодиоды ошибки указывают на перегрузку. KL3044 объединяет четыре канала в одном корпусе."

    property string led_cirle_start_1_mod: "on"
    property string led_cirle_start_2_mod: "blink"
    property string led_cirle_start_3_mod: "blink"
    property string led_cirle_start_4_mod: "blink"

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
            source: "../../../../res/image/bekchoff/images_modules/kl3064.jpg"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: rectangle
            height: 29
            color: "#e3e2df"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.rightMargin: 1
            anchors.topMargin: 0

            Text {
                id: text1
                text: qsTr("AE3")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.family: "Times New Roman"
            }
        }

        LedIndicator {
            id: led_cirle_start_1
            x: 3
            y: 31
            width: 15
            height: 15
            radius: 8
            glowEdge: "#00c700"
            mode: led_cirle_start_1_mod
            actualEnabled: false
        }

        LedIndicator {
            id: led_cirle_start_2
            x: 20
            y: 31
            width: 15
            height: 15
            radius: 7
            glowEdge: "#00c700"
            mode: led_cirle_start_2_mod
            actualEnabled: false
        }

        LedIndicator {
            id: led_cirle_start_3
            x: 20
            y: 49
            width: 15
            height: 15
            radius: 8
            glowEdge: "#00c700"
            mode: led_cirle_start_3_mod
            actualEnabled: false
        }

        LedIndicator {
            id: led_cirle_start_4
            x: 3
            y: 49
            width: 15
            height: 15
            radius: 8
            glowEdge: "#00c700"
            mode: led_cirle_start_4_mod
            actualEnabled: false
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
                                kl3064.path_source_qml_file_decriton_module,
                                "decription",
                                kl3064.x,
                                kl3064.y,
                                kl3064.type_module,
                                kl3064.module_title,
                                kl3064.module_description,
                                kl3064.module_long_description,
                                kl3064.module_features
                                )
                }
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }        
    }

    Rectangle {
        id: rec_mouse_area_click_open_dialog_electric_scheme_module
        height: 29
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.rightMargin: 0
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
                                kl3064.path_source_qml_file_electric_scheme_module,
                                "electric_scheme",
                                kl3064.x,
                                kl3064.y,
                                kl3064.type_module
                                )
                }
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }
}

