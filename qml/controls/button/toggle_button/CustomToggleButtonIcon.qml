import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Button {
    id: root

    // === Режим переключателя ===
    checkable: true

    // === Безопасная базовая единица (НЕ зависит от собственного width/height!) ===
    readonly property real baseUnit: 4

    // === Размеры ===
    property int m_radius: Math.round(baseUnit * 1.5)
    property real m_borderWidth: 1
    property int iconSize: Math.round(baseUnit * 6)
    property real iconScale: 0.65
    property bool adaptiveIcon: true

    property int fontSize: Math.round(baseUnit * 3)

    // === Цвета фона кнопки ===
    property color m_background_color: "#e0e0e0"
    property color m_color_checked: "#ff4d4d"
    property color m_color_hovered: "#ff9999"
    property color m_color_checked_hovered: Qt.darker(m_color_checked, 2)
    property color m_borderColor: "#999"

    // === Цвета текста ===
    property color m_colorText: "#333333"
    property color m_colorTextChecked: "white"
    property color m_colorTextHovered: "white"
    property color m_colorTextCheckedHovered: "white"

    // === Цвета иконки ===
    property bool tintIcon: true
    property color iconColor: "#666666"
    property color iconColorHovered: "white"
    property color iconColorChecked: "green"
    property color iconColorCheckedHovered: "green"

    // === Иконка ===
    property url iconSource: ""
    readonly property bool showIcon: iconSource.toString() !== ""
    property string iconPosition: "left"

    // === Размеры кнопки ===
    implicitWidth: {
        const baseIconSize = iconSize > 0 ? iconSize : Math.round(baseUnit * 6)
        let contentWidth = 0
        if (iconPosition === "center" && showIcon && !text) {
            contentWidth = baseIconSize
        } else if (iconPosition === "top") {
            contentWidth = Math.max(textMetrics.width, showIcon ? baseIconSize : 0)
        } else {
            if (showIcon && iconPosition !== "center") contentWidth += baseIconSize
            if (text) {
                if (showIcon && iconPosition !== "center") contentWidth += spacing
                contentWidth += textMetrics.width
            }
        }
        return Math.max(40, contentWidth + padding * 2)
    }

    implicitHeight: {
        const baseIconSize = iconSize > 0 ? iconSize : Math.round(baseUnit * 6)
        let contentHeight = 0
        if (iconPosition === "center" && showIcon && !text) {
            contentHeight = baseIconSize
        } else if (iconPosition === "top") {
            if (showIcon) contentHeight += baseIconSize
            if (text) {
                if (showIcon) contentHeight += spacing
                contentHeight += textMetrics.height
            }
        } else {
            contentHeight = Math.max(
                showIcon && iconPosition !== "center" ? baseIconSize : 0,
                text ? textMetrics.height : 0
            )
        }
        return Math.max(30, contentHeight + padding * 2)
    }

    padding: baseUnit * 1.5
    spacing: baseUnit * 1.2
    Layout.alignment: Qt.AlignCenter

    // === Метрики текста ===
    readonly property var textMetrics: TextMetrics {
        font.family: "Times New Roman"
        font.pixelSize: fontSize
        font.bold: true
        text: root.text || ""
    }

    readonly property int displayIconSize: {
        if (!adaptiveIcon || !showIcon) return iconSize > 0 ? iconSize : Math.round(baseUnit * 6)
        return Math.max(16, Math.round(Math.min(width, height) * iconScale))
    }

    // === Контент кнопки ===
    contentItem: Item {
        anchors.fill: parent

        Row {
            anchors.centerIn: parent
            visible: root.iconPosition === "left" || root.iconPosition === "right"
            spacing: root.spacing

            Loader {
                active: root.showIcon && root.iconPosition === "left"
                sourceComponent: iconComponent
            }

            Loader {
                active: root.text !== ""
                sourceComponent: textComponent
            }

            Loader {
                active: root.showIcon && root.iconPosition === "right"
                sourceComponent: iconComponent
            }
        }

        Column {
            anchors.centerIn: parent
            visible: root.iconPosition === "top"
            spacing: root.spacing

            Loader {
                active: root.showIcon
                sourceComponent: iconComponent
            }

            Loader {
                active: root.text !== ""
                sourceComponent: textComponent
            }
        }

        Loader {
            anchors.centerIn: parent
            visible: root.iconPosition === "center" && root.showIcon
            sourceComponent: iconComponent
        }
    }

    background: Rectangle {
        anchors.fill: parent
        radius: root.m_radius
        color: {
            if (!root.enabled) {
                return root.checked
                    ? Qt.darker(root.m_color_checked, 1.3)
                    : Qt.darker(root.m_background_color, 1.2)
            }
            if (root.checked && root.hovered) return root.m_color_checked_hovered;
            if (root.checked) return root.m_color_checked;
            if (root.hovered) return root.m_color_hovered;
            return root.m_background_color;
        }

        border.color: root.m_borderColor
        border.width: root.m_borderWidth
        opacity: root.enabled ? 1.0 : 0.65
    }

    // === Компонент иконки ===
    Component {
        id: iconComponent
        Item {
            width: root.displayIconSize
            height: root.displayIconSize

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                visible: root.tintIcon && root.showIcon

                layer.enabled: true
                layer.effect: ColorOverlay {
                    source: iconImage
                    color: {
                        if (!root.enabled) {
                            return root.checked
                                ? Qt.darker(root.iconColorChecked, 1.2)
                                : Qt.darker(root.iconColor, 1.5)
                        }
                        if (root.checked && root.hovered) return root.iconColorCheckedHovered;
                        if (root.checked) return root.iconColorChecked;
                        if (root.hovered) return root.iconColorHovered;
                        return root.iconColor;
                    }
                    opacity: 0.95
                }
            }

            Image {
                id: iconImage
                anchors.centerIn: parent
                width: parent.width * 0.88
                height: parent.height * 0.88
                source: root.iconSource
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: !root.tintIcon && root.showIcon
                opacity: root.enabled ? 1.0 : 0.5
            }
        }
    }

    // === Компонент текста ===
    Component {
        id: textComponent
        Text {
            text: root.text
            font.family: "Times New Roman"
            font.pixelSize: {
                if (adaptiveIcon) return Math.max(8, Math.min(root.height * 0.4, root.fontSize))
                return root.fontSize
            }
            font.bold: true
            color: {
                if (!root.enabled) {
                    return root.checked
                        ? Qt.lighter(root.m_colorTextChecked, 1.3)
                        : Qt.darker(root.m_colorText, 2.0)
                }
                if (root.checked && root.hovered) return root.m_colorTextCheckedHovered;
                if (root.checked) return root.m_colorTextChecked;
                if (root.hovered) return root.m_colorTextHovered;
                return root.m_colorText;
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            opacity: root.enabled ? 1.0 : 0.7
        }
    }
}
