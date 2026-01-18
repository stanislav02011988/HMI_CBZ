import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../controls/led_indicator"

Item {
    id: kl3403
    width: 43
    height: 340
    
    property var global_dialog_manager
    
    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"
    
    property string type_module: "kl3403"
    property string module_title: "KL3403"
    property string module_description: "Шина, 3-канальный аналоговый вход, измерение мощности, 500 В переменного тока, 1 А, 16 бит"
    property string module_long_description: "Шина KL3403 позволяет измерять все необходимые электрические параметры сети питания. Напряжение измеряется напрямую через L1, L2, L3 и N. Ток в трёх фазах L1, L2 и L3 подаётся через простые трансформаторы тока. Все измеренные значения тока и напряжения представлены в виде среднеквадратичных значений. В версии KL3403 рассчитываются активная мощность и энергопотребление для каждой фазы. Зная среднеквадратичные значения напряжения U * силы тока I и эффективной мощности P, можно получить всю остальную информацию, например о полной мощности S или угле сдвига фаз cos φ. Для каждой полевой шины KL3403 обеспечивает комплексный анализ сети и возможность управления энергопотреблением."
    property string module_features: "Шинный терминал KL3403 можно заказать для работы с другими диапазонами тока и напряжения, например 5 А, 20 мА или 333 мВ. Обзор различных версий можно найти в разделе «Информация для заказа»."

    property string led_circle_start_1_mod: "on"
    property string led_circle_error_1_mod: "blink"
    property string led_circle_error_2_mod: "blink"
    property string led_circle_error_3_mod: "blink"

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
            source: "../../../../res/image/bekchoff/images_modules/kl3403.jpg"
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
                text: qsTr("AE5")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.family: "Times New Roman"
            }
        }
        
        LedIndicator {
            id: led_circle_start_1
            x: 3
            y: 31
            width: 15
            height: 15
            radius: 8
            mode: led_circle_start_1_mod
            actualEnabled: false
            onColor: "#00c700"
            glowEdge: "#00ff00"
        }
        
        LedIndicator {
            id: led_circle_error_1
            x: 20
            y: 31
            width: 15
            height: 15
            radius: 8
            border.color: "#450000"
            mode: led_circle_error_1_mod
            onColor: "#dc0000"
            actualEnabled: false
            glowEdge: "#dc0000"
        }
        
        LedIndicator {
            id: led_circle_error_2
            x: 3
            y: 49
            width: 15
            height: 15
            radius: 8
            border.color: "#450000"
            mode: led_circle_error_2_mod
            onColor: "#dc0000"
            glowEdge: "#dc0000"
            actualEnabled: false
        }

        LedIndicator {
            id: led_circle_error_3
            x: 20
            y: 49
            width: 15
            height: 15
            radius: 8
            border.color: "#450000"
            onColor: "#dc0000"
            glowEdge: "#dc0000"
            mode: led_circle_error_3_mod
            actualEnabled: false
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
                                kl3403.path_source_qml_file_electric_scheme_module,
                                "electric_scheme",
                                kl3403.x,
                                kl3403.y,
                                kl3403.type_module
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
                                kl3403.path_source_qml_file_decriton_module,
                                "decription",
                                kl3403.x,
                                kl3403.y,
                                kl3403.type_module,
                                kl3403.module_title,
                                kl3403.module_description,
                                kl3403.module_long_description,
                                kl3403.module_features
                                )
                }
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }
}
