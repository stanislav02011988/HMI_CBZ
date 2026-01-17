import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qml.controls.flip_clock
import qml.controls.button

Rectangle {
    id: container_data
    color: "#00ffffff"
    radius: 4
    border.color: "#666565"
    border.width: 1

    Layout.fillHeight: true

    // Текущая дата (обновляется раз в день)
    property var currentDate: new Date()

    // Форматированный день недели на русском
    readonly property string formattedDayOfWeek: {
        const days = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"];
        return days[currentDate.getDay()];
    }

    // Форматированная дата: "20 января 2026"
    readonly property string formattedDate: {
        const months = [
            "января", "февраля", "марта", "апреля", "мая", "июня",
            "июля", "августа", "сентября", "октября", "ноября", "декабря"
        ];
        const day = currentDate.getDate();
        const month = months[currentDate.getMonth()];
        const year = currentDate.getFullYear();
        return `${day} ${month} ${year}`;
    }

    // === Измеряем ширину самого широкого текста ===
    TextMetrics {
        id: dayMetrics
        text: formattedDayOfWeek
        font.pixelSize: 16
        font.family: "Arial"
    }

    TextMetrics {
        id: dateMetrics
        text: formattedDate
        font.pixelSize: 16
        font.family: "Arial"
    }

    // Ширина = максимум из двух + отступы
    implicitWidth: Math.max(dayMetrics.width, dateMetrics.width) + 16  // 8px слева + 8px справа

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 2

        Rectangle {
            color: "#00ffffff"
            radius: 4
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                text: formattedDayOfWeek
                font.pixelSize: 16
                font.family: "Arial"
                color: "#000000"
                // Важно: не задавать width — пусть центрируется
            }
        }

        Rectangle {
            color: "#00ffffff"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                text: formattedDate
                font.pixelSize: 16
                font.family: "Arial"
                color: "#000000"
            }
        }
    }
}
