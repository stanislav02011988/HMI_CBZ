import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"
Item {
    id: kl3202
    width: 43
    height: 340

    property var global_dialog_manager

    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"

    property string type_module: "kl3202"
    property string module_title: "KL3202"
    property string module_description: "Шинный терминал, 2-канальный аналоговый вход, измерение температуры, RTD (Pt100), 16 бит"
    property string module_long_description: "Клемма аналогового входа KL3202 позволяет подключать датчики сопротивления напрямую. Схема клеммной колодки позволяет подключать датчики с помощью двухпроводного или трехпроводного соединения. Линеаризация во всем диапазоне температур осуществляется с помощью микропроцессора. Температурный диапазон можно выбрать произвольно."
    property string module_features: "Стандартная настройка клеммной колодки: разрешение 0,1 °C в диапазоне температур датчиков Pt100 при трехпроводном соединении. Светодиодные индикаторы хода показывают, что происходит обмен данными с шинным соединителем. Светодиодные индикаторы ошибок указывают на неисправности датчика (например, обрыв провода)."

    property string led_circle_start_1_mod: "on"
    property string led_circle_start_2_mod: "blink"
    property string led_circle_error_1_mod: "blink"
    property string led_circle_error_2_mod: "blink"

    Rectangle {
        id: bg
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
            source: "../../../../../src/bekchoff/images_modules/kl3202.jpg"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: rectangle1
            height: 29
            color: "#e3e2df"
            border.color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.rightMargin: 1
            anchors.topMargin: 0

            Text {
                id: text1
                text: qsTr("AE4")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Times New Roman"
                font.bold: true
            }
        }

        LedIndicator {
            id: led_circle_start_1
            x: 2
            y: 31
            width: 15
            height: 15
            radius: 8
            glowEdge: "#00c700"
            mode: led_circle_start_1_mod
        }

        LedIndicator {
            id: led_circle_start_2
            x: 20
            y: 31
            width: 15
            height: 15
            radius: 8
            glowEdge: "#00c700"
            mode: led_circle_start_2_mod
        }

        LedIndicator {
            id: led_circle_error_1
            x: 2
            y: 49
            width: 15
            height: 15
            radius: 8
            border.color: "#450000"
            onColor: "#dc0000"
            mode: led_circle_error_1_mod
            actualEnabled: false
            glowEdge: "#ff0000"
        }

        LedIndicator {
            id: led_circle_error_2
            x: 20
            y: 49
            width: 15
            height: 15
            radius: 8
            border.color: "#450000"
            onColor: "#dc0000"
            mode: led_circle_error_2_mod
            actualEnabled: false
            glowEdge: "#ff0000"
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
                                kl3202.path_source_qml_file_electric_scheme_module,
                                "electric_scheme",
                                kl3202.x,
                                kl3202.y,
                                kl3202.type_module
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
                                kl3202.path_source_qml_file_decriton_module,
                                "decription",
                                kl3202.x,
                                kl3202.y,
                                kl3202.type_module,
                                kl3202.module_title,
                                kl3202.module_description,
                                kl3202.module_long_description,
                                kl3202.module_features
                                )
                }
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }

}
