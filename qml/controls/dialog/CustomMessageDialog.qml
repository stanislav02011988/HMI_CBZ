import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import qml.component.button
import qml.settings.menager_theme

import python.py_settings_project.interface_settings_project

Popup {
    id: root

    signal signalBtnOK()

    property string path_image_logo: SettingsProject.itemsFileSettingsDict.logo_progect

    property int m_width: 320
    property int m_height: 160

    // Тип сообщения: "access", "error", "warning", "info"
    property string messageType: "info"

    // Тексты
    property string titleText: ""
    property string messageText: ""
    property string detailText: ""

    // Видимость кнопки ОК
    property bool visibleBtnOK: {
        switch (messageType) {
            case "access": return false;
            case "error":  return true;
            case "warning": return true;
            case "info": return true
            default:       return true;
        }
    }

    // Иконка — вычисляется на основе типа
    readonly property string iconSource: {
        switch (messageType) {
            case "access": return "qrc:/svg_icon_message/res/svg/svg_icon_message/icon_ok.svg";
            case "error":  return "qrc:/svg_icon_message/res/svg/svg_icon_message/icon_error.svg";
            case "warning": return "qrc:/svg_icon_message/res/svg/svg_icon_message/icon_warning.svg";
            case "info": return "qrc:/svg_icon_message/res/svg/svg_icon_message/icon_info.svg"
            default:       return "qrc:/svg_icon_message/res/svg/svg_icon_message/icon_info.svg";
        }
    }

    // Цвет фона — тоже зависит от типа
    readonly property string backgroundColor: {
        switch (messageType) {
            case "access": return "#a3c6c0"; // светло-зелёный
            case "error":  return "#d2d3d6"; // светло-красный
            case "warning":return "#faebd7"; // светло-жёлтый
            case "info":
            default:       return "#cce5ff"; // светло-синий
        }
    }

    padding: 0

    x: Math.round((Overlay.overlay.width - width) / 2)
    y: Math.round((Overlay.overlay.height - height) / 2)

    modal: true
    closePolicy: Popup.CloseOnEscape
    Overlay.modal: Rectangle {
            color: "transparent"
        }

    implicitWidth: Overlay.overlay.width - 40
    implicitHeight: Math.max(120, contentLayout.implicitHeight + 20)

    background: Rectangle {
        color: root.backgroundColor
        radius: 6
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors {
            leftMargin: 5
            rightMargin: 5
        }
        spacing: 5

        RowLayout {
            id: header
            height: 30
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                id: bgLogo
                width: 65
                height: header.height
                color: "transparent"

                Image {
                    source: root.path_image_logo
                    width: 50
                    height: 50
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    anchors.horizontalCenter: bgLogo.horizontalCenter
                    anchors.verticalCenter: bgLogo.verticalCenter
                }
            }

            Rectangle {
                height: header.height
                Layout.fillWidth: true
                color: "transparent"

                Text {
                    text: qsTr(root.titleText)
                    font.family: "Times New Roman"
                    Layout.fillWidth: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    font.pointSize: 14
                }
            }

            CustomButtonClose {
                id: btnClose
                m_width: 30
                m_height: 30
                visible: root.visibleBtnOK
                m_background_color: QmlMenagerTheme.reg_win_cBtnClose_background
                m_color_hovered: QmlMenagerTheme.reg_win_cBtnClose_color_hovered
                m_borderColor: QmlMenagerTheme.reg_win_cBtnClose_borderColor

                m_colorText: QmlMenagerTheme.reg_win_cBtnClose_colorText
                m_colorTextHovered: QmlMenagerTheme.reg_win_cBtnClose_colorTextHovered

                onClicked: { root.close() }
            }
        }

        RowLayout {
            id: layoutContent
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: bgIcon
                width: 50
                height: 50
                color: "transparent"

                Image {
                    source: root.iconSource
                    width: bgIcon.width
                    height: bgIcon.height
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    anchors.horizontalCenter: bgIcon.horizontalCenter
                    anchors.verticalCenter: bgIcon.verticalCenter
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Text {
                    text: qsTr(root.messageText + "\n" + root.detailText)
                    font.family: "Times New Roman"
                    font.pointSize: 10
                    Layout.fillWidth: true
                    color: "#555"
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }

        RowLayout {
            id: layoutButton
            height: 100
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 10

            CustomButton {
                id: btnLogin1
                text: "ОК"
                visible: root.visibleBtnOK
                m_width: 50
                m_height: 30

                colorDefault: "transparent"
                colorMouseOver: "#81848c"
                colorPressed: "#1c1f18"

                colorDefaultText: "#81848c"
                colorMouseOverText: "black"
                colorPressedText: "#81848c"

                onClicked: root.signalBtnOK()
            }
        }
    }

    onClosed: {
        root.messageType = ""
        root.titleText = ""
        root.messageText = ""
        root.detailText = ""
    }

    function showDialog(type, title, message, detail){
        root.messageType = type
        root.titleText = title
        root.messageText = message
        root.detailText = detail
        root.open()
    }
}
