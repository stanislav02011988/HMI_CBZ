import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.settings.menager_theme
import qml.controls.button


Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    color: "#2a2a2a"
    radius: 6

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeAllCursor
        property point dragStart
        onPressed: dragStart = Qt.point(mouseX, mouseY)
        onPositionChanged: (mouse) => {
            if (mouse.buttons & Qt.LeftButton) {
                root.x += mouseX - dragStart.x
                root.y += mouseY - dragStart.y
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: "Добавить элемент в схему"
            font.bold: true
            font.pixelSize: 16
            color: "white"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        CustomButton {
            id: closeBtn
            text: "✕"
            m_width: 30
            m_height: 30
            Layout.alignment: Qt.AlignCenter
            Layout.rightMargin: 10

            m_background_color: QmlMenagerTheme.reg_win_cBtnClose_background
            m_color_hovered: QmlMenagerTheme.reg_win_cBtnClose_color_hovered
            m_borderColor: QmlMenagerTheme.reg_win_cBtnClose_borderColor

            m_colorText: QmlMenagerTheme.reg_win_cBtnClose_colorText
            m_colorTextHovered: QmlMenagerTheme.reg_win_cBtnClose_colorTextHovered

            onClicked: { root.close() }
        }
    }
}
