import QtQuick
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Timeline
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.content

import qml.controls.button
import qml.controls.progress_bar
import qml.controls.text_field
import qml.controls.dialog

import qml.settings.menager_theme

import python.py_auth_menager.interface_auth_menager
import python.py_settings_project.interface_settings_project

Window {
    id: splashScreen
    width: 380
    height: 580
    visible: true
    color: "#00000000"

    property var registrationWindow: null

    flags: Qt.SplashScreen | Qt.FramelessWindowHint

    Component.onDestruction: {
        authMenager.destroy()
    }

    Connections {
        id: authMenager
        target: AuthMenager

        function onLoginSuccess(dict_user) {
            customMessageDialog.showDialog("access", "Авторизация успешна", "Добро пожаловать!!!", dict_user.last_name + " " + dict_user.first_name + " " + dict_user.second_name)
            SettingsProject.write_block_user_settings_project(dict_user)
            welcomeTimer.start()
        }

        function onLoginFailed(errorMsg1, errorMsg2, errorMsg3) {
            if (errorMsg3 === "login_user") {
                if (onLoginFailed._handler) {
                    customMessageDialog.signalBtnOK.disconnect(onLoginFailed._handler)
                }
                var handler1 = function() {
                    textUsername.color = "red"
                    textUsername.placeholderTextColor = "red"
                    textUsername.placeholderText = "Неверный логин"

                    textPassword.color = "red"
                    textPassword.text = ""
                    customMessageDialog.close()
                }
                onLoginFailed._handler = handler1

                customMessageDialog.signalBtnOK.connect(handler1)

                if (customMessageDialog.visible) {
                    customMessageDialog.close()
                }
                customMessageDialog.showDialog("error", errorMsg1, errorMsg2, "Обратитесь к разработчику программы")
            }

            if (errorMsg3 === "password_user") {
                if (onLoginFailed._handler) {
                    customMessageDialog.signalBtnOK.disconnect(onLoginFailed._handler)
                }
                var handler2 = function() {
                    textPassword.color = "red"
                    textPassword.placeholderTextColor = "red"
                    textPassword.placeholderText = "Неверный пароль"
                    customMessageDialog.close()
                }
                onLoginFailed._handler = handler2

                customMessageDialog.signalBtnOK.connect(handler2)

                if (customMessageDialog.visible) {
                    customMessageDialog.close()
                }
                customMessageDialog.showDialog("error", errorMsg1, errorMsg2, "")
            }

            if (errorMsg3 !== "login_user" && errorMsg3 !== "password_user") {
                customMessageDialog.showDialog("error", errorMsg1, errorMsg2, errorMsg3)
            }
        }
    }

    CustomMessageDialog {
        id: customMessageDialog
        m_width: 320
        m_height: 160
    }

    Timer {
        id: welcomeTimer
        interval: 1000
        repeat: false
        onTriggered: {
            customMessageDialog.close()
            splashScreen.close()
            MenagerWindows.show("main_window/main_window/MainWindow.qml", customMessageDialog)
        }
    }

    Rectangle {
        id: bg
        x: 78
        y: 131
        width: 360
        height: 300
        color: "transparent"
        radius: 10
        border.color: "transparent"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1

        CircularProgressBar {
            id: circularProgressBar
            x: 55
            y: 198
            opacity: 0
            anchors.verticalCenter: parent.verticalCenter
            image_source: SettingsProject.itemsFileSettingsDict.logo_progect
            progressWidth: 8
            strokeBgWidth: 4
            progressColor: QmlMenagerTheme.log_win_progressColor
            bgStrokeColor: QmlMenagerTheme.log_win_bgStrokeColor
            anchors.horizontalCenter: parent.horizontalCenter
        }


        CustomTextField {
            id: textUsername
            x: 30
            y: 365
            opacity: 1
            anchors.bottom: textPassword.top
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Username"
            placeholderTextColor: QmlMenagerTheme.log_win_textColor
            colorDefault: "transparent"
        }

        CustomTextField {
            id: textPassword
            x: 30
            y: 418
            opacity: 1
            anchors.bottom: btnLogin.top
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Password"
            placeholderTextColor: QmlMenagerTheme.log_win_textColor
            colorDefault: "transparent"
            echoMode: TextInput.Password
        }

        CustomButton {
            id: btnLogin
            text: "Sign in"
            width: 300
            height: 50

            enabled: textUsername.text.trim() !== "" && textPassword.text.trim() !== ""

            colorDefault: "transparent"
            colorMouseOver: "#7ece2d"
            colorPressed: "#558b1f"

            colorDefaultText: "white"
            colorMouseOverText: "yellow"
            colorPressedText: "#81848c"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50

            onClicked: AuthMenager.login(textUsername.text, textPassword.text)
        }

        CustomButton {
            id: btnRegistration
            text: "Пройти регистрацию"
            width: 300
            height: 40

            colorDefault: "transparent"
            colorMouseOver: "transparent"
            colorPressed: "transparent"

            colorDefaultText: "yellow"
            colorMouseOverText: "#ff007f"
            colorPressedText: "#81848c"

            m_text_size: 8

            border_width: 0
            border_color: "transparent"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            onClicked: { splashScreen.close(); MenagerWindows.show("registration/RegistrationWindow.qml", customMessageDialog) }
        }

        Label {
            id: label1
            x: 55
            y: 330
            opacity: 1
            color: "#ffffff"
            text: qsTr("Введите ваш логин и пароль")
            anchors.bottom: textUsername.top
            anchors.bottomMargin: 20
            anchors.horizontalCenterOffset: 0
            font.family: "Segoe UI"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 10
        }

        Label {
            id: label
            x: 100
            y: 294
            opacity: 1
            color: "#ffffff"
            text: qsTr("Вход программу")
            anchors.bottom: label1.top
            anchors.bottomMargin: 10
            font.family: "Segoe UI"
            font.pointSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        CustomButtonClose {
            id: closeBtn
            m_width: 30
            m_height: 30
            m_background_color: "transparent"

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.rightMargin: 10

            onClicked: splashScreen.close()
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
            target: circularProgressBar
            property: "value"
            Keyframe {
                frame: 0
                value: 0
            }

            Keyframe {
                frame: 1300
                value: 100
            }
        }

        KeyframeGroup {
            target: circularProgressBar
            property: "opacity"
            Keyframe {
                frame: 1301
                value: 1
            }

            Keyframe {
                frame: 1800
                value: 0
            }

            Keyframe {
                frame: 0
                value: 1
            }
        }

        KeyframeGroup {
            target: bg
            property: "color"
            Keyframe { frame: 1500; value: "transparent" }
            Keyframe { frame: 2500; value: QmlMenagerTheme.log_win_background }
        }

        KeyframeGroup {
            target: closeBtn
            property: "opacity"
            Keyframe { frame: 0;      value: 0.0 }
            Keyframe { frame: 2000;   value: 0.0 }
            Keyframe { frame: 2400;   value: 1.0 }
        }

        KeyframeGroup {
            target: label
            property: "opacity"
            Keyframe {
                frame: 1899
                value: 0
            }

            Keyframe {
                frame: 2396
                value: 1
            }

            Keyframe {
                frame: 0
                value: 0
            }
        }

        KeyframeGroup {
            target: label1
            property: "opacity"
            Keyframe {
                frame: 1996
                value: 0
            }

            Keyframe {
                frame: 2504
                value: 1
            }

            Keyframe {
                frame: 0
                value: 0
            }
        }

        KeyframeGroup {
            target: textUsername
            property: "opacity"
            Keyframe {
                frame: 2097
                value: 0
            }

            Keyframe {
                frame: 2652
                value: 1
            }

            Keyframe {
                frame: 0
                value: 0
            }
        }

        KeyframeGroup {
            target: textPassword
            property: "opacity"
            Keyframe {
                frame: 2198
                value: 0
            }

            Keyframe {
                frame: 2796
                value: 1
            }

            Keyframe {
                frame: 0
                value: 0
            }
        }

        KeyframeGroup {
            target: btnLogin
            property: "opacity"
            Keyframe {
                frame: 2298
                value: 0
            }

            Keyframe {
                frame: 2951
                value: 1
            }

            Keyframe {
                frame: 0
                value: 0
            }
        }

        KeyframeGroup {
            target: btnRegistration
            property: "opacity"
            Keyframe {
                frame: 2951
                value: 0
            }

            Keyframe {
                frame: 3000
                value: 1
            }

            Keyframe {
                frame: 0
                value: 0
            }
        }
    }
}
