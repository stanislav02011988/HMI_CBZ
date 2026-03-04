//QmlProjectSettings.qml
pragma Singleton
import QtQuick

import python.py_settings_project.interface_settings_project
import python.py_utils.time_menager.interface_qml_menager_time

QtObject {

    // ---- Название и Логотип приложения
    property string title_project: SettingsProject.itemsFileSettingsDict.title_project
    property string logoImage: SettingsProject.itemsFileSettingsDict.logo_progect

    // ---- Настройки показа времени
    property bool use24HourFormat: SettingsProject.itemsFileSettingsDict.block_time_settings.use24HourFormat
    property bool useUTC: SettingsProject.itemsFileSettingsDict.block_time_settings.useUTC
    property bool showSeconds: SettingsProject.itemsFileSettingsDict.block_time_settings.showSeconds

    function saveBlockSettingsTimeUsFormat(usFormat:bool) { SettingsProject.save_block_settings_time_us_format(usFormat) }

    //---- Данные установки (завода)
    property string name_installation: SettingsProject.itemsFileSettingsDict.block_installation_settings.name_installation
    property string type_installation: SettingsProject.itemsFileSettingsDict.block_installation_settings.type_installation
    property string inf_number: SettingsProject.itemsFileSettingsDict.block_installation_settings.inf_number
    property string installation_number: SettingsProject.itemsFileSettingsDict.block_installation_settings.installation_number
    property string year_installation: SettingsProject.itemsFileSettingsDict.block_installation_settings.year_installation

    function saveBlockInstallationSettings (dict) {SettingsProject.save_block_installation_settings(dict)}

    //---- Данные Пользователя
    property int idUser: SettingsProject.itemsFileSettingsDict.block_user.id_user
    property string last_name: SettingsProject.itemsFileSettingsDict.block_user.last_name
    property string first_name: SettingsProject.itemsFileSettingsDict.block_user.first_name
    property string second_name: SettingsProject.itemsFileSettingsDict.block_user.second_name
    property string position_users: SettingsProject.itemsFileSettingsDict.block_user.position_users
    property string access_group: SettingsProject.itemsFileSettingsDict.block_user.access_group

    function saveBlockUserSettings(dict_user){ SettingsProject.save_block_user_settings_project(dict_user) }    

    //======== Сохранение и Загрузка данных Центральной Сцены Элементов QmlProjectSettings ========
    function saveBlockGraphics(dict_scene){ SettingsProject.save_block_graphics(dict_scene) }
    function loadBlockGraphics() { return SettingsProject.get_block_graphics() }

    //======== Сохранение и Загрузка данных камеры сцены и зум QmlProjectSettings =====================================
    function saveCameraParams(cameraData) { SettingsProject.save_camera_params(cameraData) }
    function loadCameraParams() { return SettingsProject.load_camera_params() }
    function resetCameraParams() { return SettingsProject.reset_camera_params() }


    Component.onCompleted: {
        TimeManager.start_timer()
    }
}
