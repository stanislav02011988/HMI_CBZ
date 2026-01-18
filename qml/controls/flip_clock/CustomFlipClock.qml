// FlipClock.qml
import QtQuick
import QtQuick.Layouts

import python.py_utils.time_menager.interface_qml_menager_time

RowLayout {
    id: root

    // === ВНЕШНИЕ СВОЙСТВА ===
    property bool use24HourFormat: true   // true = 24h, false = 12h
    property bool useUTC: false           // true = UTC, false = local time
    property bool showSeconds: false

    spacing: Math.max(4, height * 0.05)
    Layout.minimumHeight: 30
    Layout.preferredHeight: parent ? parent.height : 60

    // === AM/PM индикатор ===
    Text {
        id: amPmText
        Layout.fillHeight: true
        text: ""
        font.pixelSize: 12
        font.family: "Courier New"
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        visible: !root.use24HourFormat  // ← Показываем ТОЛЬКО в 12-часовом формате
    }

    // ЧЧ
    CustomFlipDigit { id: hourTens;   Layout.fillHeight: true; Layout.minimumWidth: height * 0.6 }
    CustomFlipDigit { id: hourOnes;   Layout.fillHeight: true; Layout.minimumWidth: height * 0.6 }

    Text {
        Layout.fillHeight: true
        text: ":"
        font.pixelSize: height * 0.8
        font.family: "Courier New"
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: colonVisible ? 1 : 0
    }

    // ММ
    CustomFlipDigit { id: minuteTens; Layout.fillHeight: true; Layout.minimumWidth: height * 0.6 }
    CustomFlipDigit { id: minuteOnes; Layout.fillHeight: true; Layout.minimumWidth: height * 0.6 }

    // Двоеточие и СС — только если showSeconds == true
    Text {
        Layout.fillHeight: true
        text: ":"
        font.pixelSize: height * 0.8
        font.family: "Courier New"
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: colonVisible ? 1 : 0
        visible: root.showSeconds
    }

    CustomFlipDigit {
        id: secondTens
        Layout.fillHeight: true
        Layout.minimumWidth: height * 0.6
        visible: root.showSeconds
    }
    CustomFlipDigit {
        id: secondOnes
        Layout.fillHeight: true
        Layout.minimumWidth: height * 0.6
        visible: root.showSeconds
    }

    property bool colonVisible: true

    // Храним предыдущие значения
    property int prevHour: -1
    property int prevMinute: -1
    property int prevSecond: -1
    property string prevAmPm: ""

    Connections {
        target: TimeManager
        function onTimeUpdated(h, m, s, blink) {
            colonVisible = blink;

            var displayHour = h;
            var amPm = "AM";

            if (!root.use24HourFormat) {
                // Определяем AM/PM по исходному 24-часовому значению `h`
                if (h >= 12) {
                    amPm = "PM";
                } else {
                    amPm = "AM";
                }

                // Преобразуем в 12-часовой формат
                if (h === 0) {
                    displayHour = 12;       // 00:xx → 12:xx AM
                } else if (h > 12) {
                    displayHour = h - 12;   // 13–23 → 1–11 PM
                } else if (h === 12) {
                    displayHour = 12;       // 12:xx → 12:xx PM
                }
                // h = 1..11 → остаётся как есть (AM)

                // Обновляем AM/PM, только если изменилось
                if (amPm !== prevAmPm) {
                    amPmText.text = amPm;
                    prevAmPm = amPm;
                }
            }

            // Обновляем часы, минуты, секунды
            if (displayHour !== prevHour) {
                hourTens.setDigit(Math.floor(displayHour / 10));
                hourOnes.setDigit(displayHour % 10);
                prevHour = displayHour;
            }
            if (m !== prevMinute) {
                minuteTens.setDigit(Math.floor(m / 10));
                minuteOnes.setDigit(m % 10);
                prevMinute = m;
            }
            if (root.showSeconds && s !== prevSecond) {
                secondTens.setDigit(Math.floor(s / 10));
                secondOnes.setDigit(s % 10);
                prevSecond = s;
            }
        }
    }
}
