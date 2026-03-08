import QtQuick
import QtQuick.Layouts

import qml.controls.button
import qml.controls.button.toggle_button
Item {
    id: root

    signal signalActivateGridLayer(bool check)
    property bool isActivateGridLayer: false

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
        anchors.fill: parent
        spacing: 5

        CustomToggleButtonText {
            id: toggleBtn12
            text: "S"
            width: 30
            height: 30
            m_background_color: "transparent"
            m_colorText: "black"
            m_radius: 4

            checkable: true

            onClicked: {
                const check = !root.isActivateGridLayer
                root.isActivateGridLayer = check
                root.signalActivateGridLayer(check)
            }
        }

            CustomButton {
                m_width: 30
                m_height: 30
                m_background_color: "transparent"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: "B"
            }
        }
    }
}
