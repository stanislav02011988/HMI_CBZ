import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"

Item {
    id: bk3120
    width: 174
    height: 340

    property var global_dialog_manager

    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"

    property string type_module: "bk3120"

    property string name_module: qsTr("S11")
    property string text_address_x1: qsTr("1")
    property string text_address_x10: qsTr("8")

    property string module_title: "BK3120"
    property string module_description: "PROFIBUS Economy plus Bus Coupler"
    property string module_long_description: "Версия Economy plus расширяет возможности существующей ПРОФИБУС серии шинных соединителей BK3xx0. Технология расширения K-bus позволяет подключать до 255 пространственно распределенных шинных терминалов к одному шинному соединителю."
    property string module_features: "Модель BK3120 разработана с учетом требований к автоматизации. В протоколах PROFIBUS не используется функция FMS, чтобы можно было передавать больше пользовательских данных в режиме DP, который для этого типа Bus Coupler может поддерживать 128-байтовые входы и 128-байтовые выходы. В BK3120 реализованы сервисы PROFIBUS DP V1. Эти сервисы обеспечивают прямой доступ к регистру Bus Coupler и сложным терминалам шины, например, для изменения параметров или установки/корректировки предельных значений для аналоговых терминалов шины. Устройство сопряжения с шиной автоматически распознаёт скорость передачи данных до 12 Мбит/с, что позволяет адаптировать скорость передачи к потребностям конкретного технического процесса."

    property string led_circle_run_mode: "blink"
    property string led_cicle_bf_mod: "blink"
    property string led_circle_dia_mod: "blink"
    property string led_circle_mod: "blink"
    property string led_circle_io_run_mod: "blink"
    property string led_cirle_io_err_mod: "blink"
    property string led_circle_x0_mod: "blink"
    property string led_circle_x00_mod: "on"

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
            source: "../../../../../src/bekchoff/images_controllers/bk3120.jpg"
            fillMode: Image.PreserveAspectFit
        }

        LedIndicator {
            id: led_circle_run
            x: 78
            y: 27
            width: 12
            height: 12
            radius: 6
            border.color: "#006400"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 79
            anchors.topMargin: 27
            bottomLeftRadius: 6
            onColor: "#00ff00"
            blinkInterval: 250
            glowEdge: "#00c700"
            actualEnabled: false
            mode: led_circle_run_mode
        }

        LedIndicator {
            id: led_cicle_bf
            x: 79
            y: 45
            width: 12
            height: 12
            radius: 6
            border.color: "#643939"
            anchors.left: parent.left
            anchors.top: led_circle_run.bottom
            anchors.leftMargin: 78
            anchors.topMargin: 6
            onColor: "#a97777"
            glowEdge: "#ff0000"
            mode: led_cicle_bf_mod
            actualEnabled: false
        }

        LedIndicator {
            id: led_circle_dia
            x: 78
            y: 64
            radius: 6
            border.color: "#643939"
            anchors.left: parent.left
            anchors.top: led_cicle_bf.bottom
            anchors.leftMargin: 78
            anchors.topMargin: 7
            onColor: "#a97777"
            glowEdge: "#ff0000"
            mode: led_circle_dia_mod
            actualEnabled: false
        }

        LedIndicator {
            id: led_circle
            x: 78
            y: 83
            width: 12
            height: 12
            radius: 6
            border.color: "#643939"
            anchors.left: parent.left
            anchors.top: led_circle_dia.bottom
            anchors.leftMargin: 78
            anchors.topMargin: 7
            actualEnabled: false
            onColor: "#a97777"
            glowEdge: "#ff0000"
            mode: led_circle_mod
        }

        LedIndicator {
            id: led_circle_io_run
            x: 78
            y: 120
            radius: 6
            border.color: "#006400"
            anchors.left: parent.left
            anchors.top: led_circle.bottom
            anchors.leftMargin: 78
            anchors.topMargin: 25
            onColor: "#00ff00"
            blinkInterval: 250
            actualEnabled: false
            glowEdge: "#00c700"
            mode: led_circle_io_run_mod
        }

        LedIndicator {
            id: led_cirle_io_err
            x: 78
            y: 139
            radius: 6
            border.color: "#643939"
            anchors.left: parent.left
            anchors.top: led_circle_io_run.bottom
            anchors.leftMargin: 78
            anchors.topMargin: 7
            onColor: "#a97777"
            actualEnabled: false
            glowEdge: "#ff0000"
            mode: led_cirle_io_err_mod
        }

        LedIndicator {
            id: led_circle_x0
            x: 132
            y: 30
            width: 16
            height: 16
            radius: 8
            anchors.left: parent.left
            anchors.top: rect_name_module.bottom
            anchors.leftMargin: 132
            anchors.topMargin: 0
            mode: led_circle_x0_mod
            onColor: "#00ff04"
            glowEdge: "#00c700"
            actualEnabled: false
        }

        LedIndicator {
            id: led_circle_x00
            x: 150
            y: 30
            height: 16
            radius: 8
            anchors.left: led_circle_x0.right
            anchors.right: parent.right
            anchors.top: rect_name_module.bottom
            anchors.leftMargin: 2
            anchors.rightMargin: 8
            anchors.topMargin: 0
            mode: led_circle_x00_mod
            glowEdge: "#00c700"
            actualEnabled: false
        }

        Rectangle {
            id: rec_x10
            x: 15
            y: 284
            width: 41
            color: "#d3d4d6"
            border.color: "#7b7978"
            border.width: 2
            anchors.left: parent.left
            anchors.top: rec_x1.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 15
            anchors.topMargin: 34
            anchors.bottomMargin: 15
            Text {
                id: text_x10
                color: "#a09a9a"
                text: bk3120.text_address_x10
                anchors.fill: parent
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                lineHeight: 2.2
                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#282828"
                    radius: 2
                    verticalOffset: 1
                    spread: 0.2
                    samples: 0
                    horizontalOffset: 1.2
                }
                font.family: "Times New Roman"
                font.bold: true
            }
        }

        Rectangle {
            id: rec_x1
            x: 15
            y: 209
            width: 41
            height: 41
            color: "#d3d4d6"
            border.color: "#7b7978"
            border.width: 2
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 15
            anchors.bottomMargin: 90

            Text {
                id: text_x1
                color: "#a09a9a"
                text: bk3120.text_address_x1
                anchors.fill: parent
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                lineHeight: 2.2
                font.bold: true
                font.family: "Times New Roman"

                // Объём через тень
                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#282828"
                    radius: 2
                    spread: 0.2
                    samples: 0
                    horizontalOffset: 1.2
                    verticalOffset: 1
                }
            }
        }

        Rectangle {
            id: rect_name_module
            y: 0
            height: 29
            color: "#e3e3e3"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 130
            anchors.rightMargin: 1
            anchors.topMargin: 1

            Text {
                id: text1
                text: bk3120.name_module
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.family: "Times New Roman"
            }
        }

        Rectangle {
            id: rect_column_profibus
            x: 70
            y: 0
            width: 60
            height: 340
            color: "#00ffffff"
            border.color: "#7b7978"
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: rect_mouse_area_decription
            height: 90
            color: hovered ? "#93939393" : "#00ffffff"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 78
            anchors.rightMargin: 52
            anchors.bottomMargin: 76

            property bool hovered: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                hoverEnabled: true
                onEntered: rect_mouse_area_decription.hovered = true
                onExited: rect_mouse_area_decription.hovered = false

                onClicked: {
                    global_dialog_manager.openPopup(
                                bk3120.path_source_qml_file_decriton_module,
                                "decription",
                                bk3120.x,
                                bk3120.y,
                                bk3120.type_module,
                                bk3120.module_title,
                                bk3120.module_description,
                                bk3120.module_long_description,
                                bk3120.module_features
                                )
                }
            }            
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
        }
    }
    
    
}


