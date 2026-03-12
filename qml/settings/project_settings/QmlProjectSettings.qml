//QmlProjectSettings.qml
pragma Singleton
import QtQuick

import python.py_settings_project.interface_settings_project
import python.py_utils.time_menager.interface_qml_menager_time

QtObject {
    id: root

    // ---- Название и Логотип приложения
    property string title_project: SettingsProject.dict_settings_project.title_project
    property string logoImage: SettingsProject.dict_settings_project.logo_progect

    // ---- Настройки показа времени
    property bool use24HourFormat: SettingsProject.dict_settings_project.block_time_settings.use24HourFormat
    property bool useUTC: SettingsProject.dict_settings_project.block_time_settings.useUTC
    property bool showSeconds: SettingsProject.dict_settings_project.block_time_settings.showSeconds

    function saveBlockSettingsTimeUsFormat(usFormat:bool) { SettingsProject.save_block_settings_time_us_format(usFormat) }    

    //---- Данные Пользователя
    property int idUser: SettingsProject.dict_settings_project.block_user.id_user
    property string last_name: SettingsProject.dict_settings_project.block_user.last_name
    property string first_name: SettingsProject.dict_settings_project.block_user.first_name
    property string second_name: SettingsProject.dict_settings_project.block_user.second_name
    property string position_users: SettingsProject.dict_settings_project.block_user.position_users
    property string access_group: SettingsProject.dict_settings_project.block_user.access_group

    function saveBlockUserSettings(dict_user){ SettingsProject.save_block_user_settings_project(dict_user) }    

    //======== Данные Проектов
    property var model: SettingsProject.projectModel ? SettingsProject.projectModel : []

    Component.onCompleted: {
        TimeManager.start_timer()
    }
}
