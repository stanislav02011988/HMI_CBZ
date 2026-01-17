import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.controls.flip_clock
import qml.controls.button

// === 1. Часы ===
Rectangle {
    id: rec_clock
    color: "#00ffffff"
    radius: 4
    border.color: "#504e4e"
    border.width: 1

    Layout.rowSpan: 0
    Layout.margins: 0
    Layout.columnSpan: 0
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

    Layout.fillHeight: true
    implicitWidth: rowLayout.implicitWidth

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 2

        CustomFlipClock {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            spacing: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        ColumnLayout {
            id: columnLayoutBtn
            spacing: 2

            Rectangle {
                id: btn1
                width: 30
                height: 30
                color: "transparent"
                CustomButtonClose {
                    id: closeBtn
                    text: "12"
                    m_width: btn1.height
                    m_height: btn1.height
                    m_raduis: 4
                }
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Rectangle {
                id: btn2
                width: 30
                height: 30
                color: "transparent"

                CustomButtonClose {
                    id: closeBtn1
                    text: "24"
                    m_width: btn2.height
                    m_height: btn2.height
                    m_raduis: 4
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
    }
}
