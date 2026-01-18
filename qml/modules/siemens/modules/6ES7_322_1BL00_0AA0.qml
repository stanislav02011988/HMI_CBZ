import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Windows
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"

Item {
    id: m_S7_300_322_1BL00_0AA0
    width: 134
    height: 324

    property string mod_led_left_1_0: "blink"
    property string mod_led_left_1_1: "blink"
    property string mod_led_left_1_2: "blink"
    property string mod_led_left_1_3: "blink"
    property string mod_led_left_1_4: "blink"
    property string mod_led_left_1_5: "blink"
    property string mod_led_left_1_6: "blink"
    property string mod_led_left_1_7: "blink"

    property string mod_led_left_2_0: "blink"
    property string mod_led_left_2_1: "blink"
    property string mod_led_left_2_2: "blink"
    property string mod_led_left_2_3: "blink"
    property string mod_led_left_2_4: "blink"
    property string mod_led_left_2_5: "blink"
    property string mod_led_left_2_6: "blink"
    property string mod_led_left_2_7: "blink"

    property string mod_led_right_3_0: "blink"
    property string mod_led_right_3_1: "blink"
    property string mod_led_right_3_2: "blink"
    property string mod_led_right_3_3: "blink"
    property string mod_led_right_3_4: "blink"
    property string mod_led_right_3_5: "blink"
    property string mod_led_right_3_6: "blink"
    property string mod_led_right_3_7: "blink"

    property string mod_led_right_4_0: "blink"
    property string mod_led_right_4_1: "blink"
    property string mod_led_right_4_2: "blink"
    property string mod_led_right_4_3: "blink"
    property string mod_led_right_4_4: "blink"
    property string mod_led_right_4_5: "blink"
    property string mod_led_right_4_6: "blink"
    property string mod_led_right_4_7: "blink"

    property string number_module: qsTr("1")

    Rectangle {
        id: body
        anchors.fill: parent
        color: "#3c3c3c"
        radius: 0
        border.color: "#5a5a5a"
        border.width: 1
    }

    DropShadow {
        id: dropShadow
        anchors.fill: body
        source: body
        color: "#80000000"
        radius: 8
        samples: 16
        horizontalOffset: 0
        verticalOffset: 3
        visible: true
    }

    // Светодиоды слева колодка № 1
    Column {
        id: leds_left_1
        width: 25
        height: 124
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 4
        anchors.topMargin: 30
        spacing: 2

        LedIndicator {
            id: led_left_1_0
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_0
            border.color: "#555555"
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_1
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_1
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: led_left_1_0.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 4
            onColor: "#74e584"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_2
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_2
            border.color: "#555555"
            anchors.top: led_left_1_1.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_3
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_3
            border.color: "#555555"
            anchors.top: led_left_1_2.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_4
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_4
            border.color: "#555555"
            anchors.top: led_left_1_3.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_5
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_5
            border.color: "#555555"
            anchors.top: led_left_1_4.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_6
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_6
            border.color: "#555555"
            anchors.top: led_left_1_5.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_1_7
            width: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_1_7
            border.color: "#555555"
            anchors.top: led_left_1_6.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 4
            anchors.bottomMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        Label {
            id: label_left_1_0
            color: "#a09866"
            text: qsTr("0")
            anchors.left: led_left_1_0.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 0
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_1_1
            color: "#a09866"
            text: qsTr("1")
            anchors.left: led_left_1_1.right
            anchors.right: parent.right
            anchors.top: label_left_1_0.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 4
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_1_2
            color: "#a09866"
            text: qsTr("2")
            anchors.left: led_left_1_2.right
            anchors.right: parent.right
            anchors.top: label_left_1_1.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_left_1_3
            color: "#a09866"
            text: qsTr("3")
            anchors.left: led_left_1_3.right
            anchors.right: parent.right
            anchors.top: label_left_1_2.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_left_1_4
            color: "#a09866"
            text: qsTr("4")
            anchors.left: led_left_1_4.right
            anchors.right: parent.right
            anchors.top: label_left_1_3.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_1_5
            color: "#a09866"
            text: qsTr("5")
            anchors.left: led_left_1_5.right
            anchors.right: parent.right
            anchors.top: label_left_1_4.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_1_6
            color: "#a09866"
            text: qsTr("6")
            anchors.left: led_left_1_6.right
            anchors.right: parent.right
            anchors.top: label_left_1_5.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_1_7
            color: "#a09866"
            text: qsTr("7")
            anchors.left: led_left_1_7.right
            anchors.right: parent.right
            anchors.top: label_left_1_6.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Светодиоды слева колодка № 2
    Column {
        id: leds_left_2
        width: 25
        height: 124
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 17
        spacing: 2

        LedIndicator {
            id: led_left_2_0
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_0
            border.color: "#555555"
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_1
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_1
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: led_left_2_0.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_2
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_2
            border.color: "#555555"
            anchors.top: led_left_2_1.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_3
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_3
            border.color: "#555555"
            anchors.top: led_left_2_2.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_4
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_4
            border.color: "#555555"
            anchors.top: led_left_2_3.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_5
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_5
            border.color: "#555555"
            anchors.top: led_left_2_4.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_6
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_6
            border.color: "#555555"
            anchors.top: led_left_2_5.bottom
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_left_2_7
            width: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_left_2_7
            border.color: "#555555"
            anchors.top: led_left_2_6.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 4
            anchors.bottomMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        Label {
            id: label_left_2_0
            color: "#a09866"
            text: qsTr("0")
            anchors.left: led_left_2_0.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 0
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_2_1
            color: "#a09866"
            text: qsTr("1")
            anchors.left: led_left_2_1.right
            anchors.right: parent.right
            anchors.top: label_left_2_0.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 4
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_2_2
            color: "#a09866"
            text: qsTr("2")
            anchors.left: led_left_2_2.right
            anchors.right: parent.right
            anchors.top: label_left_2_1.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_left_2_3
            color: "#a09866"
            text: qsTr("3")
            anchors.left: led_left_2_3.right
            anchors.right: parent.right
            anchors.top: label_left_2_2.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_left_2_4
            color: "#a09866"
            text: qsTr("4")
            anchors.left: led_left_2_4.right
            anchors.right: parent.right
            anchors.top: label_left_2_3.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_2_5
            color: "#a09866"
            text: qsTr("5")
            anchors.left: led_left_2_5.right
            anchors.right: parent.right
            anchors.top: label_left_2_4.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_2_6
            color: "#a09866"
            text: qsTr("6")
            anchors.left: led_left_2_6.right
            anchors.right: parent.right
            anchors.top: label_left_2_5.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_left_2_7
            color: "#a09866"
            text: qsTr("7")
            anchors.left: led_left_2_7.right
            anchors.right: parent.right
            anchors.top: label_left_2_6.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 1
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }
    }


    // Центральная накладка
    Rectangle{
        id: center_content
        width: 70
        color: "transparent"
        anchors.top: label1.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter

        // Верхняя надпись SIEMENS и DI 32xDC

        // Центральная накладка
        Rectangle {
            id: rectangle_name_cont_1_0
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.topMargin: 2

            TextEdit {
                id: textEdit
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Нижняя маркировка

        Rectangle {
            id: rectangle_name_cont_1_1
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_0.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit1
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_2
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_1.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit2
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_3
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_2.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit3
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_4
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_3.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit4
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_5
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_4.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit5
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_6
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_5.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit6
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_7
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_6.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit7
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_module
            height: 19
            color: "transparent"
            border.color: "#555555"
            anchors.left: rectangle_number_module.right
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_7.bottom
            anchors.leftMargin: 3
            anchors.rightMargin: 0
            anchors.topMargin: 4

            TextEdit {
                id: textEdit8
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_0
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_module.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 4
            TextEdit {
                id: textEdit9
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_1
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_0.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit10
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_2
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_1.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit11
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_3
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_2.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit12
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_4
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_3.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit13
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_5
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_4.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit14
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_6
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_5.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit15
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_7
            width: 35
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_2_6.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 2
            anchors.bottomMargin: 16
            TextEdit {
                id: textEdit16
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Label {
            id: label_type_module
            color: "#a09866"
            text: qsTr("322-1BL00-0AA0")
            anchors.top: rectangle_name_cont_2_7.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 3
            anchors.bottomMargin: 2
            font.pixelSize: 8
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: rectangle_number_module
            width: 25
            height: 19
            color: "#00121212"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_7.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 4

            Label {
                id: label_number_module
                color: "#a09866"
                text: m_S7_300_322_1BL00_0AA0.number_module
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_0
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit18
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_1
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_0.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit19
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_2
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_1.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit20
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_3
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_2.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit21
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_4
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_3.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit22
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_5
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_4.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit23
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_6
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_5.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit24
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_3_7
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_3_6.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit25
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_0
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_module.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            TextEdit {
                id: textEdit26
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_1
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_0.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit27
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_2
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_1.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit28
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_3
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_2.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit29
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_4
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_3.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit30
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_5
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_4.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit31
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_6
            width: 35
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_5.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit32
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_4_7
            width: 35
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_4_6.bottom
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 2
            anchors.bottomMargin: 16
            TextEdit {
                id: textEdit33
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

    }


    // Светодиоды слева колодка № 3
    Column {
        id: leds_Right_3
        x: 101
        width: 25
        height: 124
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 4
        anchors.topMargin: 30
        spacing: 2

        LedIndicator {
            id: led_right_3_0
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_0
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.topMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_1
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_1
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_0.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_2
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_2
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_1.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_3
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_3
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_2.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_4
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_4
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_3.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_5
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_5
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_4.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_6
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_6
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_5.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_3_7
            width: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_3_7
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_3_6.bottom
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            anchors.bottomMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        Label {
            id: label_3_0
            color: "#a09866"
            text: qsTr("0")
            anchors.left: parent.left
            anchors.right: led_right_3_0.left
            anchors.top: parent.top
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 0
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_3_1
            color: "#a09866"
            text: qsTr("1")
            anchors.left: parent.left
            anchors.right: led_right_3_1.left
            anchors.top: label_3_0.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_3_2
            color: "#a09866"
            text: qsTr("2")
            anchors.left: parent.left
            anchors.right: led_right_3_2.left
            anchors.top: label_3_1.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_3_3
            color: "#a09866"
            text: qsTr("3")
            anchors.left: parent.left
            anchors.right: led_right_3_3.left
            anchors.top: label_3_2.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_3_4
            color: "#a09866"
            text: qsTr("4")
            anchors.left: parent.left
            anchors.right: led_right_3_4.left
            anchors.top: label_3_3.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_3_5
            color: "#a09866"
            text: qsTr("5")
            anchors.left: parent.left
            anchors.right: led_right_3_5.left
            anchors.top: label_3_4.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_3_6
            color: "#a09866"
            text: qsTr("6")
            anchors.left: parent.left
            anchors.right: led_right_3_6.left
            anchors.top: label_3_5.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_3_7
            color: "#a09866"
            text: qsTr("7")
            anchors.left: parent.left
            anchors.right: led_right_3_7.left
            anchors.top: label_3_6.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

    }

    // Светодиоды слева колодка № 4
    Column {
        id: leds_Right_4
        x: 101
        width: 25
        height: 124
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 4
        anchors.bottomMargin: 17
        spacing: 2

        LedIndicator {
            id: led_right_4_0
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_0
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.topMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_1
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_1
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_0.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_2
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_2
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_1.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_3
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_3
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_2.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_4
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_4
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_3.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_5
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_5
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_4.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_6
            width: 12
            height: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_6
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_5.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_4_7
            width: 12
            mode: m_S7_300_322_1BL00_0AA0.mod_led_right_4_7
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_4_6.bottom
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.topMargin: 4
            anchors.bottomMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        Label {
            id: label_reght_4_0
            color: "#a09866"
            text: qsTr("0")
            anchors.left: parent.left
            anchors.right: led_right_4_0.left
            anchors.top: parent.top
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 0
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_4_1
            color: "#a09866"
            text: qsTr("1")
            anchors.left: parent.left
            anchors.right: led_right_4_1.left
            anchors.top: label_reght_4_0.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_4_2
            color: "#a09866"
            text: qsTr("2")
            anchors.left: parent.left
            anchors.right: led_right_4_2.left
            anchors.top: label_reght_4_1.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_reght_4_3
            color: "#a09866"
            text: qsTr("3")
            anchors.left: parent.left
            anchors.right: led_right_4_3.left
            anchors.top: label_reght_4_2.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_reght_4_4
            color: "#a09866"
            text: qsTr("4")
            anchors.left: parent.left
            anchors.right: led_right_4_4.left
            anchors.top: label_reght_4_3.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_4_5
            color: "#a09866"
            text: qsTr("5")
            anchors.left: parent.left
            anchors.right: led_right_4_5.left
            anchors.top: label_reght_4_4.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_4_6
            color: "#a09866"
            text: qsTr("6")
            anchors.left: parent.left
            anchors.right: led_right_4_6.left
            anchors.top: label_reght_4_5.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_4_7
            color: "#a09866"
            text: qsTr("7")
            anchors.left: parent.left
            anchors.right: led_right_4_7.left
            anchors.top: label_reght_4_6.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

    }

    Rectangle {
        id: logo_siemens
        y: 3
        width: 59
        height: 13
        color: "#a09866"
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            text: "SIEMENS"
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Times New Roman"
            color: "#3b3b3b"
            font.bold: true
        }
    }

    Label {
        id: label1
        x: 43
        y: 24
        color: "#a09866"
        text: qsTr("DO 32 x DC 24V")
        anchors.top: logo_siemens.bottom
        anchors.topMargin: 2
        font.pixelSize: 8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Times New Roman"
        anchors.horizontalCenter: parent.horizontalCenter
    }



}
