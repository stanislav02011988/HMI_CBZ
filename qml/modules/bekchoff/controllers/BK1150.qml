import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../components/led_indicator"
import "../../../../window/window_dialog/dialog_description_module"

Item {
    id: bk1150
    width: 152
    height: 340

    property var global_dialog_manager

    property string path_source_qml_file_decriton_module: "dialog_description_module/WindowDescriptionPopup.qml"
    property string path_source_qml_file_electric_scheme_module: "dialog_electric_scheme_module/WindowDialogElectricSchemePopup.qml"

    property string type_module: "bk1150"

    property string module_title: "BK1150"
    property string module_description: "EtherCAT Compact Bus Coupler"
    property string module_long_description: "Соединитель BK1150 EtherCAT служит связующим звеном между протоколом EtherCAT на уровне полевой шины и терминалами шины. Соединитель преобразует передаваемые телеграммы из Ethernet 100BASE-TX во внутреннюю, независимую от полевой шины терминальную шину. Станция состоит из соединителя и до 64 терминалов шины, а также оконечного терминала шины. Образ процесса в системе EtherCAT назначается автоматически. Через расширение K-Bus можно подключить до 255 автобусных терминалов."
    property string module_features: "Особые характеристики:

        Компактная конструкция
        Технология подключения: 2 разъема RJ45
        Длина соединения: до 100 м
        соединяет протокол EtherCAT с шинными терминалами
    BK1150 работает так же, как BK1120, и дополняет эту серию своим компактным дизайном. Коммутатор имеет два разъема RJ45. Верхний интерфейс Ethernet используется для подключения коммутатора к сети; нижний разъем служит для дополнительного подключения других устройств EtherCAT в том же сегменте. Системное и полевое питание, каждое по 24 В постоянного тока, подается непосредственно на коммутатор. Подключаемые клеммные колодки получают ток, необходимый для связи, от подаваемого системного напряжения. Питание от сети подается на отдельные входы/выходы компоненты через силовые контакты с током до 10 А. Клеммные колодки настраиваются через ADS с помощью программного обеспечения KS2000; разъем KS2000 не требуется. В качестве альтернативы контроллер (ПЛК, ПЛКМ) может настраивать клеммные колодки с помощью функциональных блоков ПЛК.

    В сети EtherCAT соединитель BK1150 можно установить в любом месте на участке передачи сигнала Ethernet (100BASE-TX), кроме непосредственной близости к коммутатору. Соединители EK9000 и EK1000 подходят для использования на коммутаторе."

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
            source: "../../../../../src/bekchoff/images_controllers/bk1150.jpg"
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: rect_mouse_area_decription
            height: 90
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 77
            anchors.rightMargin: 46
            anchors.bottomMargin: 9

            color: hovered ? "#93939393" : "#00ffffff"

            property bool hovered: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                hoverEnabled: true
                onEntered: rect_mouse_area_decription.hovered = true
                onExited: rect_mouse_area_decription.hovered = false

                onClicked: {
                    global_dialog_manager.openPopup(
                                bk1150.path_source_qml_file_decriton_module,
                                "decription",
                                bk1150.x,
                                bk1150.y,
                                bk1150.type_module,
                                bk1150.module_title,
                                bk1150.module_description,
                                bk1150.module_long_description,
                                bk1150.module_features
                                )
                }
            }            
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
        }
    }

}
