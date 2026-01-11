import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Timeline
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import qml.component.button
import qml.component.progress_bar
import qml.component.text_field

import python.py_auth_menager.interface_auth_menager

Window {
    id: splashScreen
    width: 380
    height: 580
    visible: true
    color: "#00000000"
    title: qsTr("Hello World")

    // Remove Title Bar
    flags: Qt.SplashScreen | Qt.FramelessWindowHint

    QtObject {
        id: openWindowRegistration

        function openWindow() {
            var component = Qt.createComponent("../registration_window/RegistrationWindow.qml")
            if (component.status === Component.Ready) {
                var win = component.createObject(null)
                if (win) {
                    win.show()
                    splashScreen.close()
                }
            }
        }
    }

    Connections {
        target: AuthMenager
        function onLoginSuccess() {
            console.log("[Qml - SplashScreen] Успешно")
            var component = Qt.createComponent("../main_window/main.qml")
            if (component.status === Component.Ready) {
                var win = component.createObject(null)
                if (win) {
                    win.show()
                    splashScreen.close()
                }
            }
        }

        function onLoginFailed(errorMsg1, errorMsg2) {
            if (errorMsg2 === "login_user") {
                textUsername.color = "red"
                textUsername.placeholderTextColor = "red"
                textUsername.placeholderText = "Неверный логин"

                textPassword.color = "red"
                textPassword.placeholderTextColor = "red"
                textPassword.placeholderText = "Неверный пароль"
            } else {
                textUsername.color = "green"
                textUsername.placeholderTextColor = "green"
                textUsername.placeholderText = "UserName"

                textPassword.color = "green"
                textPassword.placeholderTextColor = "green"
                textPassword.placeholderText = "Password"
            }

            if (errorMsg2 === "password_user") {
                textPassword.color = "red"
                textPassword.placeholderTextColor = "red"
                textPassword.placeholderText = "Неверный пароль"
            }

            if (errorMsg2 !== "login_user" && errorMsg2 !== "password_user") {
                console.error(errorMsg1, errorMsg2)
            }
        }
    }

    Rectangle {
        id: bg
        x: 78
        y: 131
        width: 360
        height: 300
        color: "#1d0d0d"
        radius: 10
        border.color: "#1d0d0d"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1

        CircularProgressBar {
            id: circularProgressBar
            x: 55
            y: 198
            opacity: 0
            anchors.verticalCenter: parent.verticalCenter
            // value: 0
            image_source: "../../../res/svg/logo.svg"
            progressWidth: 8
            strokeBgWidth: 4
            progressColor: "#67aa25"
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
            echoMode: TextInput.Password
        }

        CustomButton {
            id: btnLogin
            text: "Sign in"
            width: 300
            height: 50

            colorDefault: "#67aa25"
            colorMouseOver: "#7ece2d"
            colorPressed: "#558b1f"

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

            border_width: 0
            border_color: "transparent"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            onClicked: { openWindowRegistration.openWindow() }
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

        CustomButton {
            id: closeBtn
            text: "✕"

            colorDefault: "#67aa25"
            colorMouseOver: "#ff4d4d"
            colorPressed: "#e0e0e0"

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

        // KeyframeGroup {
        //     target: logoImage
        //     property: "opacity"
        //     Keyframe {
        //         frame: 1801
        //         value: 0
        //     }

        //     Keyframe {
        //         frame: 2300
        //         value: 1
        //     }

        //     Keyframe {
        //         frame: 0
        //         value: 0
        //     }
        // }

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

        // KeyframeGroup {
        //     target: bg
        //     property: "height"
        //     Keyframe {
        //         frame: 1301
        //         value: 360
        //     }

        //     Keyframe {
        //         easing.bezierCurve: [0.221,-0.00103,0.222,0.997,1,1]
        //         frame: 1899
        //         value: 300
        //     }

        //     Keyframe {
        //         frame: 0
        //         value: 360
        //     }
        // }
    }
}
