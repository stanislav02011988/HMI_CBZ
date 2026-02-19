import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ToolTip {
    id: root

    // === НАСТРАИВАЕМЫЕ СВОЙСТВА ===
    property string customText: ""
    property int customDelay: 300
    property bool showOnDisabledOnly: true
    property var target: null  // Обязательно: ссылка на целевой элемент

    // Стиль подсказки
    property color backgroundColor: "#2c3e50"
    property color borderColor: "#3498db"
    property color textColor: "white"
    property int radius: 5
    property int borderWidth: 1
    property int textPadding: 8
    property int maxWidth: 220
    property bool showShadow: true
    property int fontSize: 12

    visible: {
        if (!target || customText === "") return false

        // Для MouseArea используем containsMouse, для Control — hovered
        var isHovered = target.containsMouse !== undefined ?
                        target.containsMouse :
                        (target.hovered !== undefined ? target.hovered : false)

        var isEnabled = target.enabled !== undefined ? target.enabled : true

        return isHovered && (!showOnDisabledOnly || !isEnabled)
    }

    delay: customDelay
    text: customText

    // === СТИЛИЗАЦИЯ ФОНА ===
    background: Rectangle {
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: root.borderWidth
        radius: root.radius

        layer.enabled: root.showShadow
        layer.effect: DropShadow {
            anchors.fill: parent
            horizontalOffset: 1
            verticalOffset: 2
            radius: 6
            samples: 12
            color: "#44000000"
            transparentBorder: true
        }
    }

    // === СТИЛИЗАЦИЯ ТЕКСТА С КОРРЕКТНЫМИ ОТСТУПАМИ ===
    contentItem: Text {
        text: root.text
        color: root.textColor
        font.family: "Times New Roman"
        font.pixelSize: Math.max(10, Math.round(root.fontSize * 0.9))
        font.bold: true
        wrapMode: Text.WordWrap
        width: root.maxWidth
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        padding: root.textPadding
    }
}

// MouseArea {
//     id: silosMouseArea
//     anchors.fill: parent
//     hoverEnabled: true
//     acceptedButtons: Qt.NoButton  // Клики проходят к дочерним элементам

//     // Обновляем позицию тултипа при движении мыши
//     onPositionChanged: {
//         if (customToolTip.visible) {
//             updateToolTipPosition()
//         }
//     }

//     function updateToolTipPosition() {
//         // Позиционируем тултип: левый верхний угол = позиция курсора в глобальных координатах
//         var globalPos = silosBody.mapToGlobal(mouseX, mouseY)
//         customToolTip.x = globalPos.x
//         customToolTip.y = globalPos.y
//     }
// }

// // === КАСТОМНЫЙ ТУЛТИП С ТОЧНЫМ ПОЗИЦИОНИРОВАНИЕМ ===
// Popup {
//     id: customToolTip
//     width: contentColumn.implicitWidth + 24  // Отступы слева/справа
//     padding: 0
//     modal: false
//     focus: false
//     closePolicy: Popup.NoAutoClose
//     z: 1000  // Высокий z-index для отображения поверх всего

//     // Видимость с задержкой 400мс
//     property bool scheduledShow: false
//     visible: scheduledShow && silosMouseArea.containsMouse && root.name_silos !== ""

//     // Таймеры для задержки показа/скрытия
//     Timer {
//         id: showTimer
//         interval: 400
//         onTriggered: customToolTip.scheduledShow = true
//     }

//     Timer {
//         id: hideTimer
//         interval: 150
//         onTriggered: customToolTip.scheduledShow = false
//     }

//     Connections {
//         target: silosMouseArea
//         function onContainsMouseChanged() {
//             if (silosMouseArea.containsMouse) {
//                 hideTimer.stop()
//                 showTimer.restart()
//             } else {
//                 showTimer.stop()
//                 hideTimer.restart()
//             }
//         }
//     }

//     // Стилизация фона
//     background: Rectangle {
//         color: "#2c3e50"
//         border.color: "#3498db"
//         border.width: 1.5
//         radius: 8
//         implicitHeight: contentColumn.implicitHeight + 16

//         // Тень для глубины
//         layer.enabled: true
//         layer.effect: DropShadow {
//             radius: 8
//             samples: 16
//             color: "#66000000"
//             horizontalOffset: 1
//             verticalOffset: 2
//         }
//     }

//     // Содержимое тултипа
//     Column {
//         id: contentColumn
//         spacing: 4
//         anchors.fill: parent
//         anchors.margins: 10

//         Text {
//             text: "Силос: <b>" + root.name_silos + "</b>"
//             textFormat: Text.RichText
//             color: "white"
//             font.family: "Segoe UI"
//             font.pixelSize: 14
//             font.bold: true
//             horizontalAlignment: Text.AlignLeft
//         }

//         Text {
//             text: "Уровень заполнения: <b>" + Math.round(root.level_cement_silos * 100) + "%</b>"
//             textFormat: Text.RichText
//             color: "#a0d2ff"
//             font.family: "Segoe UI"
//             font.pixelSize: 13
//             horizontalAlignment: Text.AlignLeft
//         }

//         Text {
//             text: "ID элемента: <i>" + root.id_silos + "</i>"
//             textFormat: Text.RichText
//             color: "#cccccc"
//             font.family: "Consolas"
//             font.pixelSize: 11
//             horizontalAlignment: Text.AlignLeft
//         }
//     }
// }
