// qml.content.main_window.main_window_widgets.center_widget CenterWidget.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import qml.managers

import qml.content.main_window.center_widget.modes.operating_mode
import qml.content.main_window.center_widget.modes.edit_mode
import "managers" as Managers

Item {
    id: centerWidget
    anchors.fill: parent

    property var managers: ({})

    // === ГЛОБАЛЬНАЯ ШИНА СИГНАЛОВ (НОВАЯ АРХИТЕКТУРА) ===
    Managers.SignalBus {
        id: signalBus
    }

    // // === РЕГИСТРАТОР ОБЪЕКТОВ СЦЕНЫ (ЕДИНЫЙ ДЛЯ ВСЕХ РЕЖИМОВ) ===
    // Managers.ComponentObjectRegister {
    //     id: componentRegister
    //     // Автоматическая синхронизация списка ID для диалогов
    //     onRegistryChanged: {
    //         // Передаём актуальный список ID во все подписанные компоненты
    //         if (mode && mode.signalListIdScene) {
    //             mode.signalListIdScene(getAllIds())
    //         }
    //     }
    // }

    // === МЕНЕДЖЕР СВЯЗЕЙ (ЕДИНЫЙ ДЛЯ ВСЕХ РЕЖИМОВ) ===
    Managers.ConnectionManager {
        id: connectionManager
        signalBus: signalBus
        componentRegister: QmlRegisterComponentObject
        onConnectionCreated: (rule) => {
            console.log(`Связь создана: ${rule.fromId}.${rule.signal} → ${rule.toId}.${rule.slot}`)
        }

        onConnectionRemoved: (fromId, toId) => {
            console.log(`Связь удалена: ${fromId} → ${toId}`)
        }
    }

    property bool editMode: true
    property alias mode: modeLoader.item
    signal sceneSaveRequested(var data)

    Loader {
        id: modeLoader
        anchors.fill: parent
        sourceComponent: editMode ? editModeComponent : operatingModeComponent
        onLoaded: {
            if (item) {
                // 🔑 ПЕРЕДАЁМ ГЛОБАЛЬНЫЕ МЕНЕДЖЕРЫ В РЕЖИМ
                item.signalBus = signalBus
                item.componentRegister = QmlRegisterComponentObject
                item.connectionManager = connectionManager

                // Сигнал сохранения сцены
                if (item.sceneSaveRequested) {
                    item.sceneSaveRequested.connect(centerWidget.sceneSaveRequested)
                }

                // Для OperatingMode: автоматическая обработка связей
                if (!editMode && item.initializeOperatingMode) {
                    item.initializeOperatingMode()
                }
            }
        }
    }

    Component { id: editModeComponent; EditMode {} }
    Component { id: operatingModeComponent; OperatingMode {} }

    // === КНОПКА ПЕРЕКЛЮЧЕНИЯ (ПОСЛЕ Loader, с высоким z) ===
    Button {
        id: modeToggleButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        width: 180
        height: 36
        z: 1000  // 🔑 ГАРАНТИРУЕМ, ЧТО КНОПКА ВСЕГДА ПОВЕРХ ВСЕГО!
        // Визуальная обратная связь
        hoverEnabled: true
        text: centerWidget.editMode ? "⚙️ Режим работы" : "✏️ Режим редактирования"
        font.pixelSize: 13
        font.bold: true
        onClicked: {
            // 🔑 КРИТИЧЕСКИ ВАЖНО: сначала меняем свойство, потом логируем
            const newMode = !centerWidget.editMode
            centerWidget.editMode = newMode
        }
        background: Rectangle {
            radius: 6
            // Динамический цвет: зелёный для редактирования, синий для работы
            color: {
                if (modeToggleButton.pressed) return centerWidget.editMode ? "#388E3C" : "#1565C0"
                if (modeToggleButton.hovered) return centerWidget.editMode ? "#66BB6A" : "#42A5F5"
                return centerWidget.editMode ? "#4CAF50" : "#2196F3"
            }
            border.color: "white"
            border.width: 1
        }
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Segoe UI"
        }
        ToolTip {
            id: modeToolTip
            text: centerWidget.editMode
                ? "Текущий режим: РЕДАКТИРОВАНИЕ\nНажмите для перехода в рабочий режим"
                : "Текущий режим: РАБОТА\nНажмите для перехода в режим редактирования"
            visible: modeToggleButton.hovered
            delay: 500
        }
    }
}
