import QtQuick
import QtQuick.Layouts

import qml.content.main_window.main_window_widgets.center_widget.component.silos

Item{
    id: root
    visible: false

    property alias silos_vertical: silos_vertical

    Component {
        id: silos_vertical
        SilosVertical {
            anchors.fill: parent
        }
    }
}
