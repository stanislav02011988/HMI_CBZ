import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Button {
    id: root
    checkable: true
    hoverEnabled: true
    enabled: !isErrorStateActivate

    signal signalActivateStartStopElMotor(state:int)

    property string id_btn: ""
    property string name_btn: ""

    readonly property real baseUnit: 4
    property int m_radius: Math.round(baseUnit * 1.5)

    width: parent.width
    height: parent.height
    padding: baseUnit * 1.5
    Layout.alignment: Qt.AlignCenter

    /* =========================================================
     * FSM СОСТОЯНИЯ
     * 0 = Stop
     * 1 = START
     * 2 = WAIT
     * 3 = ERROR
     * ========================================================= */
    property int state: 0

    /* =========================================================
     * БЛОКИРОВКА ОШИБКИ
     * ========================================================= */
    property bool isErrorStateActivate: false

    /* =========================================================
     * ЦВЕТА
     * ========================================================= */
    property color m_background_color: "#e0e0e0"    // CLOSED
    property color m_color_hovered: "#cfcfcf"        // HOVER
    property color m_borderColor: "#999"

    property color m_color_start: "#666666"         // START
    property color m_color_wait: "yellow"           // WAIT
    property color m_color_error: "red"             // ERROR
    /* =========================================================
     * ПРОГРАММНОЕ API
     * ========================================================= */
    function setClosed() {
        state = 0
        checked = false
        isErrorStateActivate = false
        root.signalActivateStartStopElMotor(state)
    }

    function setStart() {
        state = 1
        checked = true
        root.signalActivateStartStopElMotor(state)
    }

    function setWait() {
        state = 2
        root.signalActivateStartStopElMotor(state)
    }

    function setError() {
        state = 3
        isErrorStateActivate = true
        checked = false
        root.signalActivateStartStopElMotor(state)
    }

    /* =========================================================
     * ЗАЩИТА КЛИКОВ
     * ========================================================= */
    onClicked: {
        if (state === 2 || state === 3) {
            checked = !checked
            return
        }
    }

    /* =========================================================
     * СБРОС ПРИ ВКЛЮЧЕНИИ MANUAL
     * ========================================================= */
    onEnabledChanged: {
        if (!isErrorStateActivate)   // MANUAL
            setClosed()
    }

    /* =========================================================
     * WAIT МИГАНИЕ
     * ========================================================= */
    Timer {
        id: blinkTimer
        interval: 450
        repeat: true
        running: root.state === 2
        onTriggered: waitBlink = !waitBlink
    }

    property bool waitBlink: false

    /* =========================================================
     * HOVER РАЗРЕШЁН ТОЛЬКО В CLOSED / START
     * ========================================================= */
    property bool hoverAllowed: enabled && (state === 0 || state === 1)

    /* =========================================================
     * ЦВЕТ ФОНА (FSM + HOVER)
     * ========================================================= */
    property color currentColor: {
        if (state === 3)
            return m_color_error

        if (state === 2)
            return waitBlink
                   ? m_color_wait
                   : Qt.darker(m_color_wait, 1.4)

        if (hovered && hoverAllowed)
            return m_color_hovered

        if (state === 1)
            return m_color_start

        return m_background_color
    }

    /* =========================================================
     * BACKGROUND
     * ========================================================= */
    background: Rectangle {
        anchors.fill: parent
        radius: root.m_radius
        color: root.currentColor
        border.color: root.m_borderColor
        border.width: 1.3
        opacity: root.enabled ? 1.0 : 0.6
    }
}
