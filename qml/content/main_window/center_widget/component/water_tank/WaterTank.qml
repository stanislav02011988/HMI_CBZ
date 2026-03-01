import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Item{
    width: 300
    height: 500

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 0
        // Область емкостей воды
        Rectangle {
            id: rectangle
            color: "red"
            Layout.preferredHeight: 170
            Layout.fillWidth: true

            RowLayout {
                id: rowLayout
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    id: rectangle3
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                }

                Rectangle {
                    id: rectangle4
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                }
            }
        }

        // Область водяного насоса
        Rectangle {
            id: rectangle1
            color: "transparent"
            border.width: 1
            Layout.preferredHeight: 118
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    id: rectangle5
                    width: 200
                    height: 200
                    color: "#00515951"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        id: rowLayout2
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            id: rectangle7
                            width: 200
                            height: 200
                            color: "#759275"
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }

                        Rectangle {
                            id: rect_water_pump
                            width: 200
                            height: 200
                            color: "#0092bf92"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            ColumnLayout {
                                id: columnLayout1
                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    id: rectangle8
                                    width: 200
                                    height: 200
                                    color: "#00ffffff"
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                                    RowLayout {
                                        id: rowLayout3
                                        anchors.fill: parent
                                        spacing: 0

                                        Rectangle {
                                            id: rectangle12
                                            width: 200
                                            height: 200
                                            color: "#dbe81d"
                                            Layout.preferredHeight: 30
                                            Layout.preferredWidth: 10
                                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        }

                                        Rectangle {
                                            id: rectangle13
                                            width: 200
                                            height: 200
                                            color: "#676951"
                                            Layout.preferredHeight: 10
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                                        }

                                        Rectangle {
                                            id: rectangle14
                                            width: 200
                                            height: 200
                                            color: "#dfea21"
                                            Layout.preferredHeight: 30
                                            Layout.preferredWidth: 10
                                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        }
                                    }
                                }

                                Rectangle {
                                    id: rectangle10
                                    color: "#ffffff"
                                    Layout.preferredHeight: 30
                                    Layout.preferredWidth: 30
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                    radius: 15
                                }
                            }
                        }

                        Rectangle {
                            id: rectangle9
                            width: 200
                            height: 200
                            color: "#9aaa9a"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }
                }

                Rectangle {
                    id: rectangle6
                    width: 200
                    height: 200
                    color: "#59a0b8"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }



            }
        }

        // Область водяных весов
        Rectangle {
            id: rectangle2
            color: "#ffffff"
            z: -4
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredHeight: 222
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color:"transparent"

                    RowLayout {
                        id: rowLayout1
                        spacing: 0
                        anchors.fill: parent

                        Rectangle {
                            id: rectangle11
                            color: "yellow"
                            Layout.preferredWidth: 25
                            Layout.fillHeight: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "grey"
                        }
                    }
                }

                Rectangle {
                    color: "yellow"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90

                    RowLayout {
                        spacing: 0
                        anchors.fill: parent

                        Rectangle {
                            color: "green"
                            Layout.preferredWidth: 25
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }
                        Rectangle {
                            color: "grey"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    Layout.preferredWidth: 6
                                    Layout.preferredHeight: 40
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                    color: "#ffffff"
                                }

                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                    color: "red"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
