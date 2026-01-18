import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"
import "../../../../window/window_dialog/dialog_description_module"

Item {
    id: bc3100
    width: 174
    height: 340
    
    
    
    property var global_dialog_manager

    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"

    property string type_module: "bc3100"

    property string name_module: qsTr("S11")
    property string text_address_x1: qsTr("1")
    property string text_address_x10: qsTr("8")

    property string module_title: "BC3100"
    property string module_description: "PROFIBUS Bus Terminal Controller"
    property string module_long_description: "Контроллер оконечного устройства шины BC3100 представляет собой шинный соединитель со встроенными функциями ПЛК и интерфейсом полевой шины для PROFIBUS. Это интеллектуальное подчиненное устройство, которое можно использовать в качестве распределенного интеллектуального устройства в системе PROFIBUS. В BC3100 одно устройство состоит из контроллера, от 1 до 64 оконечных устройств и оконечного устройства шины.

    Контроллер PROFIBUS обеспечивает автоматическое определение скорости передачи данных до 12 Мбит/с и имеет два переключателя выбора адреса для его назначения.

    Контроллер шинного терминала программируется с помощью TwinCAT 2 системы программирования в соответствии с IEC 61131-3. Для загрузки программы ПЛК используется интерфейс конфигурации/программирования BC3100. Если используется программное обеспечение ПЛК TwinCAT, программу ПЛК можно загрузить через полевую шину. Входы и выходы подключенных шинных терминалов назначаются в настройках ПЛК по умолчанию. Каждый шинный терминал можно настроить таким образом, чтобы он обменивался данными напрямую через полевую шину с устройством автоматизации более высокого уровня. Аналогичным образом можно осуществлять обмен предварительно обработанными данными между контроллером шинного терминала и контроллером более высокого уровня через полевую шину."
    property string module_features: "Контроллер для распределенной обработки сигналов
    Система программирования TwinCAT для BC3100 и BC3150 работает независимо от производителя в соответствии со стандартом IEC 61131-3. Программы для ПЛК можно писать на пяти разных языках программирования (IL, FBD, LD, SFC, ST). Кроме того, TwinCAT предлагает широкие возможности отладки (точки останова, одношаговое выполнение, мониторинг и т. д.), которые упрощают ввод в эксплуатацию. Также можно выполнять настройку и измерение времени цикла."
    

    Rectangle {
        id: bg
        color: "#00ffffff"
        border.color: "#7b7978"
        anchors.fill: parent

        // Тень
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#80000000"
            radius: 4
            horizontalOffset: 2
            samples: 16
            verticalOffset: 2
        }

        Image {
            id: image
            anchors.fill: parent
            source: "../../../../../src/bekchoff/images_controllers/bc3100.jpg"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: rect_mouse_area_decription
            x: 78
            y: 174
            height: 90
            color: hovered ? "#93939393" : "#00ffffff"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 78
            anchors.rightMargin: 52
            anchors.bottomMargin: 76

            property bool hovered: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                hoverEnabled: true
                onEntered: rect_mouse_area_decription.hovered = true
                onExited: rect_mouse_area_decription.hovered = false

                onClicked: {
                    global_dialog_manager.openPopup(
                                bc3100.path_source_qml_file_decriton_module,
                                "decription",
                                bc3100.x,
                                bc3100.y,
                                bc3100.type_module,
                                bc3100.module_title,
                                bc3100.module_description,
                                bc3100.module_long_description,
                                bc3100.module_features
                                )
                }
            }
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
        }
    }
}
