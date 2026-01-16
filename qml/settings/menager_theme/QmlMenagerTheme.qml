pragma Singleton
import QtQuick
import QtQuick.Controls

import python.py_menager_theme.interface_qml_menager_theme
import python.py_settings_project.interface_settings_project

QtObject {
    id: root

    property string name_theme: MenagerTheme.colorsDict.name_theme

    // ----- Свойства окна Логина ----
    property color log_win_background: MenagerTheme.colorsDict.theme_login_window.background
    property color log_win_borderColor: MenagerTheme.colorsDict.theme_login_window.borderColor
    property color log_win_textColor: MenagerTheme.colorsDict.theme_login_window.textColor
    property color log_win_progressColor: MenagerTheme.colorsDict.theme_login_window.progressColor
    property color log_win_bgStrokeColor: MenagerTheme.colorsDict.theme_login_window.bgStrokeColor
    property color log_win_strokeBgWidth: MenagerTheme.colorsDict.theme_login_window.strokeBgWidth

    // ---- Свойства окна Регистрации
    property color reg_win_background: MenagerTheme.colorsDict.theme_registration_window.background
    property color reg_win_borderColor: MenagerTheme.colorsDict.theme_registration_window.borderColor

    property color reg_win_cBtnClose_background: MenagerTheme.colorsDict.theme_registration_window.cBtnClose_background
    property color reg_win_cBtnClose_color_hovered: MenagerTheme.colorsDict.theme_registration_window.cBtnClose_color_hovered
    property color reg_win_cBtnClose_borderColor: MenagerTheme.colorsDict.theme_registration_window.cBtnClose_borderColor
    property color reg_win_cBtnClose_colorText: MenagerTheme.colorsDict.theme_registration_window.cBtnClose_colorText
    property color reg_win_cBtnClose_colorTextHovered: MenagerTheme.colorsDict.theme_registration_window.cBtnClose_colorTextHovered

    property color reg_win_cBtnCallBackLogin_background: MenagerTheme.colorsDict.theme_registration_window.cBtnCallBackLogin_background
    property color reg_win_cBtnCallBackLogin_color_hovered: MenagerTheme.colorsDict.theme_registration_window.cBtnCallBackLogin_color_hovered
    property color reg_win_cBtnCallBackLogin_borderColor: MenagerTheme.colorsDict.theme_registration_window.cBtnCallBackLogin_borderColor
    property color reg_win_cBtnCallBackLogin_colorText: MenagerTheme.colorsDict.theme_registration_window.cBtnCallBackLogin_colorText
    property color reg_win_cBtnCallBackLogin_colorTextHovered: MenagerTheme.colorsDict.theme_registration_window.cBtnCallBackLogin_colorTextHovered

    property color reg_win_cTextField_placeholderTextColor: MenagerTheme.colorsDict.theme_registration_window.cTextField_placeholderTextColor

    property color reg_win_cBtnRegistration_colorDefault: MenagerTheme.colorsDict.theme_registration_window.cBtnRegistration_colorDefault
    property color reg_win_cBtnRegistration_colorMouseOver: MenagerTheme.colorsDict.theme_registration_window.cBtnRegistration_colorMouseOver
    property color reg_win_cBtnRegistration_colorPressed: MenagerTheme.colorsDict.theme_registration_window.cBtnRegistration_colorPressed

    property color reg_win_cBtnRegistration_colorDefaultText: MenagerTheme.colorsDict.theme_registration_window.cBtnRegistration_colorDefaultText
    property color reg_win_cBtnRegistration_colorMouseOverText: MenagerTheme.colorsDict.theme_registration_window.cBtnRegistration_colorMouseOverText
    property color reg_win_cBtnRegistration_colorPressedText: MenagerTheme.colorsDict.theme_registration_window.cBtnRegistration_colorPressedText

    // --- Анимации при смене цветов ---
    // Behavior on background { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    // Behavior on background_block { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    // Behavior on border_color { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    // Behavior on model_card_background { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    // Behavior on model_card_border_color { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    // Behavior on textColor { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    function toggleTheme() {
        MenagerTheme.toggle_theme()
        SettingsProject.save_theme(MenagerTheme.colorsDict.name_theme)
    }

}
