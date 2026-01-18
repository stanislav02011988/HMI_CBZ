import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Windows
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"

Item {
    id: m_S7_300_331_7KB02_0AB0
    width: 100
    height: 324

    property string mod_led_sf: "blink"

    property string mod_led_right_1_0: "blink"
    property string mod_led_right_1_1: "blink"
    property string mod_led_right_1_2: "blink"
    property string mod_led_right_1_3: "blink"
    property string mod_led_right_1_4: "blink"
    property string mod_led_right_1_5: "blink"
    property string mod_led_right_1_6: "blink"
    property string mod_led_right_1_7: "blink"

    property string mod_led_right_2_0: "blink"
    property string mod_led_right_2_1: "blink"
    property string mod_led_right_2_2: "blink"
    property string mod_led_right_2_3: "blink"
    property string mod_led_right_2_4: "blink"
    property string mod_led_right_2_5: "blink"
    property string mod_led_right_2_6: "blink"
    property string mod_led_right_2_7: "blink"

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

    // Центральная накладка
    Rectangle{
        id: center_content
        x: 0
        width: 70
        color: "transparent"
        anchors.top: label1.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 0
        anchors.bottomMargin: 14

        // Верхняя надпись SIEMENS и DI 32xDC

        // Центральная накладка

        // Нижняя маркировка

        Rectangle {
            id: rectangle_name_module
            height: 19
            color: "transparent"
            border.color: "#555125"
            anchors.left: rectangle_number_module.right
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_7.bottom
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
            id: rectangle_number_module
            width: 25
            height: 19
            color: "#00121212"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.top: rectangle_name_cont_1_7.bottom
            anchors.leftMargin: 6
            anchors.topMargin: 4

            Label {
                id: label_number_module
                color: "#a09866"
                text: m_S7_300_331_7KB02_0AB0.number_module
                anchors.fill: parent
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_0
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit18
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_1
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_0.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit19
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_2
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_1.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit20
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_3
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_2.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit21
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_4
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_3.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit22
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_5
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_4.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit23
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_6
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_5.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit24
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_1_7
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_1_6.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
            TextEdit {
                id: textEdit25
                color: "#a09866"
                text: qsTr("")
                anchors.fill: parent
                anchors.leftMargin: 0
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: rectangle_name_cont_2_0
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_module.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_1
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_0.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_2
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_1.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_3
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_2.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_4
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_3.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_5
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_4.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_6
            height: 14
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_5.bottom
            anchors.leftMargin: 6
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
            id: rectangle_name_cont_2_7
            height: 16
            color: "#2a2a2a"
            border.color: "#555555"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle_name_cont_2_6.bottom
            anchors.leftMargin: 6
            anchors.rightMargin: 0
            anchors.topMargin: 2
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

    // Диод SF

    LedIndicator {
        id: led_sf
        height: 12
        mode: m_S7_300_331_7KB02_0AB0.mod_led_sf
        border.color: "#555555"
        anchors.left: label_sf.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 14
        onColor: "#84b38c"
        glowEdge: "#00ff24"

    }

    Label {
        id: label_sf
        color: "#a09866"
        text: qsTr("SF")
        anchors.left: label1.right
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 14
        font.pixelSize: 8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Светодиоды слева колодка № 1
    Column {
        id: leds_Right_1
        x: 101
        width: 25
        height: 124
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 4
        anchors.topMargin: 30
        spacing: 2

        LedIndicator {
            id: led_right_1_0
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_0
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 2
            anchors.topMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_1
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_1
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_0.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_2
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_2
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_1.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_3
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_3
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_2.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_4
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_4
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_3.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_5
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_5
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_4.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_6
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_6
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_5.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_1_7
            width: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_1_7
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_1_6.bottom
            anchors.bottom: parent.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            anchors.bottomMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        Label {
            id: label_1_0
            color: "#a09866"
            text: qsTr("")
            anchors.left: parent.left
            anchors.right: led_right_1_0.left
            anchors.top: parent.top
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 0
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_1_1
            color: "#a09866"
            text: qsTr("")
            anchors.left: parent.left
            anchors.right: led_right_1_1.left
            anchors.top: label_1_0.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_1_2
            color: "#a09866"
            text: qsTr("")
            anchors.left: parent.left
            anchors.right: led_right_1_2.left
            anchors.top: label_1_1.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_1_3
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_1_3.left
            anchors.top: label_1_2.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_1_4
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_1_4.left
            anchors.top: label_1_3.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_1_5
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_1_5.left
            anchors.top: label_1_4.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_1_6
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_1_6.left
            anchors.top: label_1_5.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_1_7
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_1_7.left
            anchors.top: label_1_6.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 4
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

    }

    // Светодиоды слева колодка № 2
    Column {
        id: leds_Right_2
        x: 101
        width: 25
        height: 124
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 4
        anchors.bottomMargin: 17
        spacing: 2

        LedIndicator {
            id: led_right_2_0
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_0
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 2
            anchors.topMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_1
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_1
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_0.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_2
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_2
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_1.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_3
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_3
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_2.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_4
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_4
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_3.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_5
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_5
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_4.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_6
            width: 12
            height: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_6
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_5.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        LedIndicator {
            id: led_right_2_7
            width: 12
            mode: m_S7_300_331_7KB02_0AB0.mod_led_right_2_7
            border.color: "#555555"
            anchors.right: parent.right
            anchors.top: led_right_2_6.bottom
            anchors.bottom: parent.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            anchors.bottomMargin: 0
            onColor: "#84b38c"
            glowEdge: "#00ff24"

        }

        Label {
            id: label_reght_2_0
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_0.left
            anchors.top: parent.top
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 0
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_2_1
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_1.left
            anchors.top: label_reght_2_0.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_2_2
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_2.left
            anchors.top: label_reght_2_1.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_reght_2_3
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_3.left
            anchors.top: label_reght_2_2.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
        }

        Label {
            id: label_reght_2_4
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_4.left
            anchors.top: label_reght_2_3.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_2_5
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_5.left
            anchors.top: label_reght_2_4.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_2_6
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_6.left
            anchors.top: label_reght_2_5.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 8
            anchors.topMargin: 5
            font.pixelSize: 8
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: label_reght_2_7
            color: "#a09866"
            anchors.left: parent.left
            anchors.right: led_right_2_7.left
            anchors.top: label_reght_2_6.bottom
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
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 6
        anchors.topMargin: 3

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
        y: 24
        color: "#a09866"
        text: qsTr("AI 2 x 12 BIT")
        anchors.left: parent.left
        anchors.top: logo_siemens.bottom
        anchors.leftMargin: 12
        anchors.topMargin: 2
        font.pixelSize: 8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Times New Roman"
    }

    Label {
        id: label_type_module
        x: 5
        y: 311
        color: "#a09866"
        text: qsTr("331-7KB02-0AB0")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        font.pixelSize: 8
        anchors.horizontalCenter: parent.horizontalCenter
    }



}
