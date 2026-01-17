// FlipClock.qml
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    // === ВНЕШНИЕ СВОЙСТВА ===
    property bool use24HourFormat: true   // true = 24h, false = 12h
    property bool useUTC: false           // true = UTC, false = local time
    property bool showSeconds: true

    spacing: Math.max(4, height * 0.05)
    Layout.minimumHeight: 30
    Layout.preferredHeight: parent ? parent.height : 60

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

    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered: colonVisible = !colonVisible
    }

    // Храним предыдущие значения
    property int prevHour: -1
    property int prevMinute: -1
    property int prevSecond: -1

    function updateTime() {
        const now = new Date();

        let h, m, s;
        if (useUTC) {
            h = now.getUTCHours();
            m = now.getUTCMinutes();
            s = now.getUTCSeconds();
        } else {
            h = now.getHours();
            m = now.getMinutes();
            s = now.getSeconds();
        }

        // Обработка 12-часового формата
        if (!use24HourFormat) {
            if (h === 0) h = 12;
            else if (h > 12) h -= 12;
        }

        // Обновление часов
        if (h !== prevHour) {
            hourTens.setDigit(Math.floor(h / 10));
            hourOnes.setDigit(h % 10);
            prevHour = h;
        }
        if (m !== prevMinute) {
            minuteTens.setDigit(Math.floor(m / 10));
            minuteOnes.setDigit(m % 10);
            prevMinute = m;
        }

        // Обновление секунд — только если включены
        if (root.showSeconds && s !== prevSecond) {
            secondTens.setDigit(Math.floor(s / 10));
            secondOnes.setDigit(s % 10);
            prevSecond = s;
        }
    }

    Component.onCompleted: {
        updateTime();
    }

    Timer {
        interval: root.showSeconds ? 1000 : 60000  // если секунды скрыты — обновлять раз в минуту
        repeat: true
        running: true
        onTriggered: root.updateTime()
    }
}
