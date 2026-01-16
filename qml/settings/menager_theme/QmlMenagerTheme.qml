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
