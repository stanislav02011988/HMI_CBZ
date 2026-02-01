import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.controls.flip_clock
import qml.controls.button

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

                CustomToggleButton {
                    id: toggleBtn12
                    text: "12"
                    m_width: containerBtn12.height
                    m_height: containerBtn12.height
                    m_radius: 4

                    checked: !QmlProjectSettings.use24HourFormat  // ← автоматическая привязка
                    checkable: true

                    onClicked: {
                        if (!checked) return; // уже снято — не нужно сохранять
                        QmlProjectSettings.saveBlockSettingsTimeUsFormat(false);
                        // toggleBtn24.checked = false; ← НЕ НУЖНО — он сам станет false!
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

                CustomToggleButton {
                    id: toggleBtn24
                    text: "24"
                    m_width: containerBtn24.height
                    m_height: containerBtn24.height
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
