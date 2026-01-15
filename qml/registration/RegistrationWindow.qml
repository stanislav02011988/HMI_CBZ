import QtQuick
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Timeline
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.menager_windows

import qml.component.button
import qml.component.progress_bar
import qml.component.text_field
import qml.component.dialog

import python.py_auth_menager.interface_auth_menager

ApplicationWindow {
    id: root
    width: 380
    height: 580
    visible: true
    color: "#00000000"
    flags: Qt.SplashScreen | Qt.FramelessWindowHint



    readonly property bool allFieldsFilled:
        last_name.text.trim() !== "" &&
        first_name.text.trim() !== "" &&
        second_name.text.trim() !== "" &&
        tab_number.text.trim() !== "" &&
        position_user.text.trim() !== "" &&
        login_user.text.trim() !== "" &&
        password_user.text.trim() !== "" &&
        code_registration.text.trim() !== ""

    Component.onDestruction: {
        last_name.text = ""
        first_name.text = ""
        second_name.text = ""
        tab_number.text = ""
        position_user.text = ""
        login_user.text = ""
        password_user.text = ""
        code_registration.text = ""

        authMenager.destroy()
        fileDialog.destroy()
        customMessageDialog.destroy()
        timeline.destroy()
        timelineAnimation.destroy()
    }

    Rectangle {
        id: bg
        width: 360
        height: 560
        color: "#1d0d0d"
        radius: 10
        border.color: "#1d0d0d"
        anchors.centerIn: parent
        z: 1

        CustomButtonClose {
            id: closeBtn
            m_width: 30
            m_height: 30
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            m_background_color: "transparent"
            onClicked: { root.close(); MenagerWindows.show("../splesh_screen/SpleshScreen.qml", customMessageDialog) }
        }

        Label {
            id: label
            text: qsTr("Окно регистрации пользователя")
            color: "#ffffff"
            font.family: "Segoe UI"
            font.pointSize: 10
            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
        }

        CustomTextField {
            id: last_name
            placeholderText: "Фамилия"
            anchors.top: label.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 36
        }

        CustomTextField {
            id: first_name
            placeholderText: "Имя"
            anchors.top: last_name.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        CustomTextField {
            id: second_name
            placeholderText: "Отчество"
            anchors.top: first_name.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        CustomTextField {
            id: tab_number
            placeholderText: "Табельный номер"
            anchors.top: second_name.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            // inputMethodHints: Qt.ImhDigitsOnly
        }

        CustomTextField {
            id: position_user
            placeholderText: "Должность"
            anchors.top: tab_number.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        CustomTextField {
            id: login_user
            placeholderText: "Логин"
            anchors.top: position_user.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        CustomTextField {
            id: password_user
            placeholderText: "Пароль"
            echoMode: TextInput.Password
            anchors.top: login_user.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        CustomTextField {
            id: code_registration
            placeholderText: "Код регистрации"
            anchors.top: password_user.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10

            MouseArea {
                anchors.fill: parent
                onClicked: fileDialog.open()
            }
        }

        CustomButton {
            id: btnRegistration
            text: "Регистрация пользователя"
            width: 300
            anchors.right: parent.right
            anchors.top: code_registration.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.rightMargin: 30
            anchors.topMargin: 22
            anchors.bottomMargin: 25

            // Динамические цвета
            colorDefault: root.allFieldsFilled ? "#67aa25" : "#666666"
            colorMouseOver: root.allFieldsFilled ? "#7ece2d" : "#777777"
            colorPressed: root.allFieldsFilled ? "#558b1f" : "#555555"

            enabled: root.allFieldsFilled

            onClicked: {
                AuthMenager.register(
                    last_name.text,
                    first_name.text,
                    second_name.text,
                    tab_number.text,
                    position_user.text,
                    login_user.text,
                    password_user.text,
                    code_registration.text
                )
            }
        }

        Label {
            id: label1
            text: qsTr("Вернуться обратно к окну входа")
            anchors.top: btnRegistration.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.family: "Segoe UI"
            font.pointSize: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {root.close(); MenagerWindows.show("../splesh_screen/SpleshScreen.qml", customMessageDialog)}
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Выберите файл"

        onAccepted: {
            let url = fileDialog.selectedFile
            if (url) {
                let path = url.toString().replace(/^file:\/\/\//, "")
                AuthMenager.processRegistrationKey(path)
            }
        }
    }

    CustomMessageDialog {
        id: customMessageDialog
        m_width: 320
        m_height: 160
    }

    Connections {
        id: authMenager
        target: AuthMenager

        function onRegisterSuccess() {
            root.close()
            MenagerWindows.show("../splesh_screen/SpleshScreen.qml", customMessageDialog)
        }

        function onRegisterFailed(errorMsg1, errorMsg2, errorMsg3) {
            if (errorMsg2 === "Ошибка регистрации") {
                login_user.text = ""
                login_user.placeholderText = errorMsg
                login_user.placeholderTextColor = 'red'

                if (customMessageDialog.visible) {
                    customMessageDialog.close()
                }
                customMessageDialog.showDialog("error", errorMsg1, errorMsg2, errorMsg3)


            } else {
                if (customMessageDialog.visible) {
                    customMessageDialog.close()
                }
                customMessageDialog.showDialog("error", errorMsg1, errorMsg2, errorMsg3)
            }
        }

        function onKeyRegistrationSuccess(accessGroup) {
            code_registration.text = accessGroup
            code_registration.color = 'green'
            if (customMessageDialog.visible) {
                customMessageDialog.close()
            }
            customMessageDialog.showDialog("error", errorMsg1, errorMsg2, errorMsg3)
        }

        function onKeyRegistrationFailed(errorMsg1, errorMsg2, errorMsg3) {
            if (onKeyRegistrationFailed._handler) {
                customMessageDialog.signalBtnOK.disconnect(onKeyRegistrationFailed._handler)
            }
            var handler = function() {
                root.close()
                MenagerWindows.show("../splesh_screen/SpleshScreen.qml", customMessageDialog)
            }
            onKeyRegistrationFailed._handler = handler

            customMessageDialog.signalBtnOK.connect(handler)

            if (customMessageDialog.visible) {
                customMessageDialog.close()
            }
            customMessageDialog.showDialog("error", errorMsg1, errorMsg2, errorMsg3)
        }
    }

    DropShadow{
        anchors.fill: bg
        source: bg
        verticalOffset: 0
        horizontalOffset: 0
        radius: 10
        color: "#40000000"
        z: 0
    }

    Timeline {
        id: timeline
        animations: [
            TimelineAnimation {
                id: timelineAnimation
                duration: 3000
                running: true
                loops: 1
                to: 3000
                from: 0
            }
        ]
        enabled: true
        startFrame: 0
        endFrame: 3000

        KeyframeGroup {
            target: bg
            property: "height"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 500; value: 0 }
            Keyframe { frame: 1000; value: 560; easing.bezierCurve: [0.221,-0.00103,0.222,0.997,1,1] }
        }

        KeyframeGroup {
            target: label
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 700; value: 0 }
            Keyframe { frame: 1100; value: 1 }
        }

        KeyframeGroup {
            target: closeBtn
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 700; value: 0 }
            Keyframe { frame: 1200; value: 1 }
        }

        KeyframeGroup {
            target: last_name
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 800; value: 0 }
            Keyframe { frame: 1200; value: 1 }
        }

        KeyframeGroup {
            target: first_name
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 900; value: 0 }
            Keyframe { frame: 1300; value: 1 }
        }

        KeyframeGroup {
            target: second_name
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1000; value: 0 }
            Keyframe { frame: 1400; value: 1 }
        }

        KeyframeGroup {
            target: tab_number
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1100; value: 0 }
            Keyframe { frame: 1500; value: 1 }
        }

        KeyframeGroup {
            target: position_user
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1200; value: 0 }
            Keyframe { frame: 1600; value: 1 }
        }

        KeyframeGroup {
            target: login_user
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1200; value: 0 }
            Keyframe { frame: 1600; value: 1 }
        }

        KeyframeGroup {
            target: password_user
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1200; value: 0 }
            Keyframe { frame: 1600; value: 1 }
        }

        KeyframeGroup {
            target: code_registration
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1200; value: 0 }
            Keyframe { frame: 1600; value: 1 }
        }

        KeyframeGroup {
            target: btnRegistration
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1200; value: 0 }
            Keyframe { frame: 1600; value: 1 }
        }

        KeyframeGroup {
            target: label1
            property: "opacity"
            Keyframe { frame: 0; value: 0 }
            Keyframe { frame: 1200; value: 0 }
            Keyframe { frame: 1600; value: 1 }
        }
    }
}
