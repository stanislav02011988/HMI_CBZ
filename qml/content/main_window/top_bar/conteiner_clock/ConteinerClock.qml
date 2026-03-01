import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.controls.flip_clock
import qml.controls.button.toggle_button

import qml.settings.project_settings

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
            use24HourFormat: QmlProjectSettings.use24HourFormat
            useUTC: QmlProjectSettings.useUTC
            showSeconds: QmlProjectSettings.showSeconds

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter            
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3
        }

        ColumnLayout {
            id: columnLayoutBtn
            spacing: 2

            Rectangle {
                id: containerBtn12
                width: 30
                height: 30
                color: "transparent"

                CustomToggleButtonText {
                    id: toggleBtn12
                    text: "12"
                    width: containerBtn12.height
                    height: containerBtn12.height
                    m_background_color: "transparent"
                    m_colorText: "black"
                    m_radius: 4

                    checked: !QmlProjectSettings.use24HourFormat  // ← автоматическая привязка
                    checkable: true

                    onClicked: {
                        if (!checked) return
                        QmlProjectSettings.saveBlockSettingsTimeUsFormat(false)
                    }
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Rectangle {
                id: containerBtn24
                width: 30
                height: 30
                color: "transparent"

                CustomToggleButtonText {
                    id: toggleBtn24
                    text: "24"
                    width: containerBtn24.height
                    height: containerBtn24.height
                    m_background_color: "transparent"
                    m_colorText: "black"
                    m_radius: 4
                    checked: QmlProjectSettings.use24HourFormat  // ← автоматическая привязка
                    checkable: true

                    onClicked: {
                        if (!checked) return;
                        QmlProjectSettings.saveBlockSettingsTimeUsFormat(true);
                    }
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
