import QtQuick
import QtQuick.Layouts

import qml.controls.button
import qml.controls.button.toggle_button
Item {
    id: root

    signal signalActivateGridLayer(bool check)
    signal signalActivateEditeMode(bool check)
    signal signalSaveSceneLogicMap ()

    // =====================================================
    // РЕЖИМ FALSE - RUN MODE TRUE - EDIT MODE
    // =====================================================
    property bool editMode: false

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
        anchors.fill: parent
        spacing: 5

            CustomToggleButtonText {
                id: toggleBtn12
                text: "G"
                width: 30
                height: 30
                m_background_color: "transparent"
                m_colorText: "black"
                m_radius: 4

                checkable: true

                onCheckedChanged: {
                    root.signalActivateGridLayer(checked)
                }
            }

            CustomToggleButtonText {
                id: toggleBtn
                text: "E"
                width: 30
                height: 30
                m_background_color: "transparent"
                m_colorText: "black"
                m_radius: 4

                checkable: true
                checked: root.editMode
                onCheckedChanged: {
                    root.signalActivateEditeMode(checked)
                }
            }

            CustomToggleButtonText {
                id: toggleBtn2
                text: "S"
                width: 30
                height: 30
                m_background_color: "transparent"
                m_colorText: "black"
                m_radius: 4

                onClicked: {
                    root.signalSaveSceneLogicMap()
                }
            }
        }
    }
}
