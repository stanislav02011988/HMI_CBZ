import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Windows
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"

Item {
    id: simatic_et200m_153_1

    width: 134
    height: 324

    property string ledOnMod: "blink"
    property string ledSFMod: "blink"
    property string ledBFMod: "blink"
    property string led1Mod: "off"
    property string led2Mod: "off"
    property string led3Mod: "off"

    property string namber_station: "33"


    Rectangle {
        id: root
        width: 134
        height: 324
        color: "transparent" // или #3b3b3b если фон нужен
        visible: true

        Row {
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0

            Rectangle {
                id: zone_led
                width: 40
                color: "#3b3b3b"
                border.width: 1
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0

                Grid {
                    id: grid1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 12
                    anchors.rightMargin: 3
                    anchors.topMargin: 15
                    anchors.bottomMargin: 229
                    padding: 0
                    rows: 6
                    columns: 2

                    Label {
                        id: label_sf
                        width: 11
                        height: 11
                        color: "#a09866"
                        text: qsTr("SF")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
                        font.pixelSize: 8
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    LedIndicator {
                        id: led_IndicatorSf
                        border.color: "#555555"
                        mode: simatic_et200m_153_1.ledSFMod
                        glowEdge: "#ff0000"

                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 0
                        anchors.topMargin: 0
                        onColor: "#f29797"
                    }

                    Label {
                        id: label_bf
                        width: 11
                        color: "#a09866"
                        text: qsTr("BF")
                        anchors.left: parent.left
                        anchors.top: label_sf.bottom
                        anchors.leftMargin: 0
                        anchors.topMargin: 2
                        font.pixelSize: 8
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    LedIndicator {
                        id: led_IndicatorBf
                        width: 11
                        border.color: "#555555"
                        anchors.right: parent.right
                        mode: simatic_et200m_153_1.ledBFMod
                        glowEdge: "#ff0000"

                        anchors.top: parent.top
                        anchors.rightMargin: 0
                        anchors.topMargin: 13
                        onColor: "#f48f8f"
                    }

                    LedIndicator {
                        id: led_Indicator1
                        color: "#fdfdfd"
                        border.color: "#555555"
                        mode: simatic_et200m_153_1.led1Mod
                        glowEdge: "#00ff24"

                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 0
                        anchors.topMargin: 26
                        onColor: "#a9f7a1"
                    }

                    LedIndicator {
                        id: led_IndicatorOn
                        width: 11
                        height: 11
                        border.color: "#555555"
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 0
                        anchors.topMargin: 41
                        onColor: "#a9f7a1"
                        mode: simatic_et200m_153_1.ledOnMod
                        glowEdge: "#00ff24"

                    }

                    LedIndicator {
                        id: led_Indicator2
                        border.color: "#555555"
                        mode: simatic_et200m_153_1.led2Mod
                        glowEdge: "#00ff1e"

                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 0
                        anchors.topMargin: 53
                        onColor: "#a9f7a1"
                    }

                    LedIndicator {
                        id: led_Indicator3
                        border.color: "#555555"
                        mode: simatic_et200m_153_1.led3Mod
                        glowEdge: "#00ff24"

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 14
                        anchors.rightMargin: 0
                        anchors.topMargin: 66
                        onColor: "#a9f7a1"
                    }

                    Label {
                        id: label_on
                        width: 11
                        color: "#a09866"
                        text: qsTr("ON")
                        anchors.left: parent.left
                        anchors.top: label_bf.bottom
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.topMargin: 19
                        anchors.bottomMargin: 28
                        font.pixelSize: 8
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }
            }

            Rectangle {
                id: zone_info
                color: "#3b3b3b"
                border.color: "#555555"
                border.width: 1
                anchors.left: zone_led.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0

                Rectangle {
                    id: bg_label
                    color: "#1183a4"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 7
                    anchors.rightMargin: 8
                    anchors.topMargin: 15
                    anchors.bottomMargin: 282

                    Item {
                        id: _item
                        x: -7
                        anchors.fill: parent
                        Text {
                            color: "#ba000000"
                            text: "SIEMENS"
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 7
                            anchors.topMargin: 4
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }

                        Text {
                            color: "#ffffff"
                            text: "SIEMENS"
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 5
                            anchors.topMargin: 2
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }
                }

                Label {
                    id: label
                    color: "#a09866"
                    text: qsTr("SIMATIC")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 15
                    anchors.rightMargin: 17
                    anchors.topMargin: 147
                    anchors.bottomMargin: 144
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 16
                }

                Label {
                    id: label1
                    color: "#a09866"
                    text: qsTr("ET 200M")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 15
                    anchors.rightMargin: 17
                    anchors.topMargin: 177
                    anchors.bottomMargin: 120
                    font.pixelSize: 21
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    id: label2
                    color: "#a09866"
                    text: qsTr("IM 153-1")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 15
                    anchors.rightMargin: 36
                    anchors.topMargin: 221
                    anchors.bottomMargin: 87
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    id: bg_number
                    color: "#282727"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 4
                    anchors.rightMargin: 56
                    anchors.topMargin: 280
                    anchors.bottomMargin: 20

                    Label {
                        id: label_namber_station
                        color: "#a09866"
                        text: simatic_et200m_153_1.namber_station
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    id: bg_type
                    color: "#00000000"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 60
                    anchors.rightMargin: 8
                    anchors.topMargin: 279
                    anchors.bottomMargin: 20


                    Grid {
                        id: grid
                        width: 22
                        height: 22
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 0

                        Rectangle {
                            id: rectangle
                            width: 11
                            height: 11
                            color: "#00000000"
                            border.color: "#a8a8a8"
                            border.width: 0
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 0
                            anchors.topMargin: 0

                            Label {
                                id: label3
                                color: "#a09866"
                                text: qsTr("X")
                                anchors.fill: parent
                                font.pixelSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            id: rectangle1
                            width: 11
                            height: 11
                            color: "#00000000"
                            border.color: "#a8a8a8"
                            border.width: 0
                            anchors.left: rectangle.right
                            anchors.top: parent.top
                            anchors.leftMargin: 0
                            anchors.topMargin: 0

                            Label {
                                id: label4
                                color: "#a09866"
                                text: qsTr("19")
                                anchors.fill: parent
                                font.pixelSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            id: rectangle2
                            width: 11
                            height: 11
                            color: "#00000000"
                            border.color: "#a8a8a8"
                            border.width: 0

                            anchors.left: parent.left
                            anchors.top: rectangle.bottom
                            anchors.leftMargin: 0
                            anchors.topMargin: 0

                            Label {
                                id: label5
                                color: "#a09866"
                                text: qsTr("20")
                                anchors.fill: parent
                                font.pixelSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            id: rectangle3
                            width: 11
                            height: 11
                            color: "#00000000"
                            border.color: "#a8a8a8"
                            border.width: 0

                            anchors.left: rectangle2.right
                            anchors.top: rectangle1.bottom
                            anchors.leftMargin: 0
                            anchors.topMargin: 0

                            Label {
                                id: label6
                                color: "#a09866"
                                text: qsTr("21")
                                anchors.fill: parent
                                font.pixelSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                Label {
                    id: label_type_module
                    color: "#a09866"
                    text: qsTr("153-1AA03-0XB0")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    anchors.topMargin: 304
                    anchors.bottomMargin: 4
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    DropShadow {
        anchors.fill: root
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8
        samples: 16
        color: "#80000000"
        source: root
        visible: true
    }
    
}
