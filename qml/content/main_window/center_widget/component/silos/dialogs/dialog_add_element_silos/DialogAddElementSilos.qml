// qml/content/main_window/dialogs/dialog_add_element/DialogAddElement.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Shapes

import qml.content.main_window.main_window_widgets.center_widget.component.silos
import qml.settings.project_settings

ApplicationWindow {
    id: dialog
    visible: false
    width: 900
    height: 600
    title: "Добавить силос цемента"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    Material.theme: Material.Dark
    Material.accent: "#2196F3"

    // === СОСТОЯНИЕ ДИАЛОГА ===
    property string selectedSubtype: ""
    property int selectedSubtypeIndex: -1
    property string nameValue: ""
    property string idValue: ""
    property string motorIdValue: ""
    property real levelPreSilos: 0
    property bool isSaving: false
    property string saveStatus: ""
    property bool idExistsError: false
    property bool idFormatError: false
    property bool nameFormatError: false

    // === РЕАКТИВНОЕ СВОЙСТВО ДЛЯ ВАЛИДАЦИИ КНОПКИ ===
    property bool formIsValid: {
        // Проверка выбранного подтипа
        if (!dialog.selectedSubtype || dialog.selectedSubtypeIndex === -1) return false

        // Проверка имени
        if (!dialog.validateName(dialog.nameValue)) return false

        // Проверка формата ID
        if (!dialog.validateIdFormat(dialog.idValue)) return false

        // Проверка уникальности ID (только если формат валиден)
        if (dialog.validateIdFormat(dialog.idValue) && !dialog.isIdUnique(dialog.idValue)) return false

        // Проверка двигателя для подтипов с мотором
        if (silosSubtypesModel.get(dialog.selectedSubtypeIndex).hasMotor) {
            if (!dialog.validateIdFormat(dialog.motorIdValue)) return false
        }

        return true
    }

    // === МОДЕЛЬ ПОДТИПОВ СИЛОСОВ ===
    ListModel {
        id: silosSubtypesModel
        ListElement {
            subtypeId: "silos_vertical"
            name: "Вертикальный силос"
            description: "Классический вертикальный силос для цемента"
            previewImage: "qrc:/icons/silos_vertical.svg"
            defaultWidth: 100
            defaultHeight: 200
            hasMotor: true
        }
        // ListElement {
        //     subtypeId: "silos_cone"
        //     name: "Конический силос"
        //     description: "Силос с коническим днищем для лучшей выгрузки"
        //     previewImage: "qrc:/icons/silos_cone.svg"
        //     defaultWidth: 80
        //     defaultHeight: 220
        //     hasMotor: true
        // }
        // ListElement {
        //     subtypeId: "silos_with_doser"
        //     name: "Силос с дозатором"
        //     description: "Силос со встроенным дозирующим устройством"
        //     previewImage: "qrc:/icons/silos_doser.svg"
        //     defaultWidth: 90
        //     defaultHeight: 240
        //     hasMotor: true
        // }
    }

    // === ОСНОВНОЙ ЛЕЙАУТ (3 столбца) ===
    RowLayout {
        anchors.fill: parent
        spacing: 15
        anchors.margins: 20

        // === СТОЛБЕЦ 1: СПИСОК ПОДТИПОВ ===
        ColumnLayout {
            Layout.preferredWidth: 280
            Layout.fillHeight: true

            // Заголовок
            Label {
                text: "Список типов силосов"
                font.bold: true
                font.pixelSize: 16
                color: "white"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.topMargin: 5
            }

            // Список подтипов
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Repeater {
                    model: silosSubtypesModel
                    delegate: ItemDelegate {
                        width: parent.width
                        height: 85
                        highlighted: dialog.selectedSubtypeIndex === index
                        hoverEnabled: true

                        contentItem: RowLayout {
                            spacing: 15
                            Layout.fillHeight: true

                            // Превью подтипа
                            Rectangle {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 50
                                radius: 6
                                color: "#3a3a3a"
                                Layout.alignment: Qt.AlignVCenter

                                Image {
                                    anchors.centerIn: parent
                                    // source: model.previewImage || "qrc:/icons/placeholder.svg"
                                    width: 36
                                    height: 36
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                            }

                            // Название и описание
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: model.name
                                    color: dialog.selectedSubtypeIndex === index ? "#2196F3" : "#e0e0e0"
                                    font.pixelSize: 14
                                    font.bold: dialog.selectedSubtypeIndex === index
                                }

                                Text {
                                    text: model.description
                                    color: "#999999"
                                    font.pixelSize: 11
                                    wrapMode: Text.Wrap
                                    Layout.maximumWidth: 160
                                }
                            }
                        }

                        onClicked: {
                            dialog.selectedSubtypeIndex = index
                            dialog.selectedSubtype = model.subtypeId
                            dialog.autoFillForm(model)
                        }
                    }
                }
            }

            // Кнопки управления
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 15
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    text: "Отмена"
                    onClicked: dialog.close()
                    enabled: !dialog.isSaving

                    background: Rectangle {
                        radius: 5
                        color: parent.enabled ? "#555555" : "#333333"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: dialog.isSaving ? "Сохранение..." : "Добавить силос"
                    // ИСПОЛЬЗУЕМ РЕАКТИВНОЕ СВОЙСТВО formIsValid
                    enabled: dialog.formIsValid && !dialog.isSaving

                    background: Rectangle {
                        radius: 5
                        color: parent.enabled ? "#2196F3" : "#555555"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: dialog.saveElement()
                }
            }

            // Индикатор статуса с анимацией
            Rectangle {
                id: statusIndicator
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 12
                width: parent.width - 20
                height: 42  // Чуть больше для лучшей видимости
                radius: 10
                color: "#4CAF50"
                opacity: 0
                scale: 1.0
                visible: opacity > 0.01

                Behavior on opacity { NumberAnimation { duration: 250 } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 200 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    // Иконка для лучшей визуализации
                    Text {
                        text: dialog.saveStatus.indexOf("✓") >= 0 ? "\uf00c" : "\uf00d"
                        font.family: "Font Awesome 5 Free"
                        font.pixelSize: 18
                        color: "white"
                        font.weight: Font.Bold
                        visible: dialog.saveStatus !== ""
                    }

                    Text {
                        text: dialog.saveStatus
                        color: "white"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                // Анимация пульсации
                function startPulseAnimation() {
                    if (pulseAnimation.running) pulseAnimation.stop()
                    scale = 1.0
                    pulseAnimation.start()
                }

                SequentialAnimation {
                    id: pulseAnimation
                    loops: 3

                    PropertyAnimation {
                        target: statusIndicator
                        property: "scale"
                        from: 1.0
                        to: 1.08
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAnimation {
                        target: statusIndicator
                        property: "scale"
                        from: 1.08
                        to: 1.0
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                    PauseAnimation { duration: 150 }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        // === СТОЛБЕЦ 2: ПРЕДПРОСМОТР (ИСПРАВЛЕННЫЙ) ===
        ColumnLayout {
            Layout.preferredWidth: 300
            Layout.fillHeight: true

            Label {
                text: "Предпросмотр элемента"
                font.bold: true
                font.pixelSize: 16
                color: "white"
                Layout.topMargin: 5
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#252525"
                radius: 8
                border.color: "#444444"
                border.width: 1

                // Динамический предпросмотр
                Loader {
                    anchors.fill: parent
                    anchors.margins: 25
                    sourceComponent: dialog.getPreviewComponent()
                }
            }

            // Информация о выбранном элементе
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 15
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#444444"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Label {
                            text: "Текущий выбор:"
                            color: "#aaaaaa"
                            font.pixelSize: 12
                        }

                        Text {
                            text: {
                                if (!dialog.selectedSubtype) return "Не выбран тип силоса"
                                return silosSubtypesModel.get(dialog.selectedSubtypeIndex).name
                            }
                            color: dialog.selectedSubtype ? "#2196F3" : "#ff9800"
                            font.pixelSize: 14
                            font.bold: true
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        // === СТОЛБЕЦ 3: ПАРАМЕТРЫ ===
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                text: "Параметры элемента"
                font.bold: true
                font.pixelSize: 16
                color: "white"
                Layout.topMargin: 5
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    Layout.topMargin: 10

                    // Название
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            Label {
                                text: "Название силоса"
                                color: "#bbbbbb"
                                font.pixelSize: 13
                            }

                            Text {
                                text: "*"
                                color: "#F44336"
                                font.pixelSize: 16
                            }
                        }

                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            text: dialog.nameValue
                            onTextChanged: {
                                dialog.nameValue = text
                                dialog.nameFormatError = !dialog.validateName(text)
                            }
                            placeholderText: "Введите название"
                            color: "white"
                            selectedTextColor: "white"
                            selectionColor: "#2196F3"
                            font.pixelSize: 14
                            onActiveFocusChanged: dialog.handlePlaceholder(this, "Введите название")

                            background: Rectangle {
                                radius: 6
                                color: "#2d2d2d"
                                border.color: nameField.activeFocus ? "#2196F3" :
                                             (dialog.nameFormatError ? "#F44336" : "#555555")
                                border.width: nameField.activeFocus ? 2 : (dialog.nameFormatError ? 2 : 1)
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }
                        }

                        Text {
                            text: dialog.nameFormatError ? "✗ Название должно содержать 2-100 символов" : ""
                            color: "#F44336"
                            font.pixelSize: 11
                            visible: dialog.nameFormatError
                        }
                    }

                    // ID элемента
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            Label {
                                text: "Уникальный ID силоса"
                                color: "#bbbbbb"
                                font.pixelSize: 13
                            }

                            Text {
                                text: "*"
                                color: "#F44336"
                                font.pixelSize: 16
                            }
                        }

                        TextField {
                            id: idField
                            Layout.fillWidth: true
                            text: dialog.idValue
                            onTextChanged: {
                                dialog.idValue = text
                                dialog.idFormatError = !dialog.validateIdFormat(text)
                                // Проверяем уникальность ТОЛЬКО если формат валиден
                                if (dialog.validateIdFormat(text)) {
                                    dialog.idExistsError = !dialog.isIdUnique(text)
                                } else {
                                    dialog.idExistsError = false
                                }
                            }
                            placeholderText: "Например: silos.cement.1"
                            color: "white"
                            selectedTextColor: "white"
                            selectionColor: "#2196F3"
                            font.pixelSize: 14
                            onActiveFocusChanged: dialog.handlePlaceholder(this, "Например: silos.cement.1")

                            background: Rectangle {
                                radius: 6
                                color: "#2d2d2d"
                                border.color: {
                                    if (idField.activeFocus) return "#2196F3"
                                    if (dialog.idExistsError || dialog.idFormatError) return "#F44336"
                                    return "#555555"
                                }
                                border.width: idField.activeFocus ? 2 :
                                              (dialog.idExistsError || dialog.idFormatError ? 2 : 1)
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.topMargin: 4

                            Text {
                                text: dialog.idExistsError ? "✗ ID уже существует в системе" :
                                     (dialog.idFormatError ? "✗ Неверный формат ID" :
                                     "Используется для связи с ПЛК и конфигурации")
                                color: dialog.idExistsError || dialog.idFormatError ? "#F44336" : "#777777"
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }

                            Text {
                                text: "Разрешены: буквы, цифры, точки, подчеркивания, дефисы (3-50 символов)"
                                color: "#777777"
                                font.pixelSize: 10
                                visible: !dialog.idExistsError && !dialog.idFormatError
                            }
                        }
                    }

                    // ID двигателя (только для силосов с двигателем)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        visible: dialog.selectedSubtype &&
                                 dialog.selectedSubtypeIndex !== -1 &&
                                 silosSubtypesModel.get(dialog.selectedSubtypeIndex).hasMotor

                        RowLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            Label {
                                text: "ID электродвигателя"
                                color: "#bbbbbb"
                                font.pixelSize: 13
                            }

                            Text {
                                text: "*"
                                color: "#F44336"
                                font.pixelSize: 16
                            }
                        }

                        TextField {
                            id: motorIdField
                            Layout.fillWidth: true
                            text: dialog.motorIdValue
                            onTextChanged: {
                                dialog.motorIdValue = text
                            }
                            placeholderText: "Например: motor.cement.shnek.1"
                            color: "white"
                            selectedTextColor: "white"
                            selectionColor: "#2196F3"
                            font.pixelSize: 14
                            onActiveFocusChanged: dialog.handlePlaceholder(this, "Например: motor.cement.shnek.1")

                            background: Rectangle {
                                radius: 6
                                color: "#2d2d2d"
                                border.color: motorIdField.activeFocus ? "#2196F3" : "#555555"
                                border.width: motorIdField.activeFocus ? 2 : 1
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }
                        }

                        Text {
                            text: "Электродвигатель для выгрузки материала из силоса"
                            color: "#777777"
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                        }
                    }

                    // Уровень заполнения (только для силосов)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        visible: dialog.selectedSubtype && dialog.selectedSubtypeIndex !== -1

                        Label {
                            text: "Начальный уровень заполнения"
                            color: "#bbbbbb"
                            font.pixelSize: 13
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Slider {
                                id: fillSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 1
                                value: dialog.levelPreSilos
                                stepSize: 0.01
                                onValueChanged: dialog.levelPreSilos = value
                                snapMode: Slider.SnapOnRelease

                                background: Rectangle {
                                    y: parent.height/2 - height/2
                                    width: parent.width
                                    height: 4
                                    radius: 2
                                    color: "#444444"
                                }

                                handle: Rectangle {
                                    x: parent.leftPadding + (parent.availableWidth - width) * parent.visualPosition
                                    y: parent.height/2 - height/2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "#2196F3"
                                    border.color: "white"
                                    border.width: 2

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 10
                                        color: "transparent"
                                        border.color: "#2196F3"
                                        border.width: 2
                                        opacity: fillSlider.pressed ? 0.5 : 0
                                        Behavior on opacity { NumberAnimation { duration: 100 } }
                                    }
                                }
                            }

                            Text {
                                text: Math.round(fillSlider.value * 100) + "%"
                                color: "#2196F3"
                                font.pixelSize: 15
                                font.bold: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        Text {
                            text: "Уровень заполнения при первом запуске системы"
                            color: "#777777"
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }

    // ===== Предо Смотр элементов ======
    Component {
        id: emptyPreview
        Rectangle {
            color: "transparent"
            anchors.fill: parent
            Text {
                anchors.centerIn: parent
                text: "Выберите тип силоса"
                color: "#666666"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                font.italic: true
            }
        }
    }

    Component {
        id: silosPreview
        Item {
            anchors.fill: parent
            ColumnLayout {
                anchors.fill: parent
                Silos {
                    id: previewSilos
                    Layout.preferredWidth: silosSubtypesModel.get(dialog.selectedSubtypeIndex).defaultWidth
                    Layout.maximumWidth: silosSubtypesModel.get(dialog.selectedSubtypeIndex).defaultWidth
                    Layout.preferredHeight: silosSubtypesModel.get(dialog.selectedSubtypeIndex).defaultHeight
                    Layout.alignment: Qt.AlignHCenter
                    name_silos: nameField.text || "Силос"
                    level_cement_silos: dialog.levelPreSilos
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    // === ПРОВЕРКА УНИКАЛЬНОСТИ ID (с принудительным обновлением кэша) ===
    function isIdUnique(id) {
        if (!id || id.trim() === "") return true

        // Принудительно получаем свежие данные из синглтона
        if (!QmlProjectSettings || typeof QmlProjectSettings.get_all_silos_elements !== "function") {
            console.warn("[DialogAddElement] QmlProjectSettings недоступен для проверки уникальности ID")
            return true
        }

        try {
            var allElements = QmlProjectSettings.get_all_silos_elements()

            // Обработка разных форматов возврата (массив или объект)
            if (allElements && typeof allElements === "object") {
                // Если возвращается объект с элементами
                if (allElements.elements && Array.isArray(allElements.elements)) {
                    allElements = allElements.elements
                }
                // Если возвращается простой массив
                else if (!Array.isArray(allElements)) {
                    // Попытка преобразовать в массив
                    var keys = Object.keys(allElements)
                    if (keys.length > 0 && allElements[keys[0]].id !== undefined) {
                        allElements = Object.values(allElements)
                    } else {
                        allElements = []
                    }
                }
            } else {
                allElements = []
            }

            var trimmedId = id.trim()
            for (var i = 0; i < allElements.length; i++) {
                var elementId = allElements[i].id ? allElements[i].id.trim() : ""
                if (elementId === trimmedId) {
                    return false
                }
            }
            return true
        } catch (e) {
            console.error("[DialogAddElement] Ошибка при проверке уникальности ID:", e)
            return true // В случае ошибки разрешаем сохранение, но логируем
        }
    }

    // === ВАЛИДАЦИЯ ФОРМАТА ID ===
    function validateIdFormat(id) {
        if (!id || id.trim() === "") return false
        var trimmed = id.trim()
        // Разрешаем буквы, цифры, точки, подчеркивания, дефисы (3-50 символов)
        var pattern = /^[a-zA-Z0-9._-]{3,50}$/
        return pattern.test(trimmed)
    }

    // === ВАЛИДАЦИЯ ИМЕНИ ===
    function validateName(name) {
        if (!name) return false
        var trimmed = name.trim()
        return trimmed.length >= 2 && trimmed.length <= 100
    }

    // === ОПРЕДЕЛЕНИЕ ПУТЕЙ К КОМПОНЕНТАМ ===
    function getSilosPath(subtype) {
        switch(subtype) {
            case "silos_cone": return "qrc:/qml/content/main_window/main_window_widgets/center_widget/component/silos/SilosCone.qml"
            case "silos_with_doser": return "qrc:/qml/content/main_window/main_window_widgets/center_widget/component/silos/SilosWithDoser.qml"
            default: return "qrc:/qml/content/main_window/main_window_widgets/center_widget/component/silos/Silos.qml"
        }
    }

    // === АВТОЗАПОЛНЕНИЕ ФОРМЫ ===
    function autoFillForm(model) {
        // Заполняем название только если поле пустое
        if (dialog.nameValue.trim() === "") {
            dialog.nameValue = model.name
        }

        // Генерируем уникальный ID если поле пустое ИЛИ если текущий ID не уникален
        if (dialog.idValue.trim() === "" || !dialog.isIdUnique(dialog.idValue)) {
            var baseId = model.subtypeId
            var uniqueId = baseId
            var counter = 1

            // Генерируем уникальный ID с суффиксом при необходимости
            while (!dialog.isIdUnique(uniqueId)) {
                uniqueId = baseId + "_" + counter
                counter++
            }

            dialog.idValue = uniqueId
            dialog.idExistsError = false
            dialog.idFormatError = false
        }

        // Заполняем ID двигателя если требуется и поле пустое
        if (model.hasMotor && dialog.motorIdValue.trim() === "") {
            var baseMotorId = "motor_" + model.subtypeId
            var uniqueMotorId = baseMotorId
            var counter = 1

            // Проверяем уникальность ID двигателя (если есть такая функция в синглтоне)
            // Для простоты используем тот же принцип, что и для силоса
            dialog.motorIdValue = uniqueMotorId
        }

        // Принудительно обновляем состояние валидации
        // Обновление состояния кнопки происходит автоматически через formIsValid
        Qt.callLater(function() { })
    }

    // === СОХРАНЕНИЕ ЭЛЕМЕНТА (ПОЛНОСТЬЮ НА ТАЙМЕРАХ) ===
    function saveElement() {
        if (!dialog.formIsValid) {
            // Собираем все ошибки для отображения
            var errors = []
            if (!dialog.selectedSubtype) errors.push("Выберите тип силоса")
            if (!dialog.validateName(dialog.nameValue)) errors.push("Название: 2-100 символов")
            if (!dialog.validateIdFormat(dialog.idValue)) errors.push("ID: 3-50 символов (буквы, цифры, ., _, -)")
            if (dialog.validateIdFormat(dialog.idValue) && !dialog.isIdUnique(dialog.idValue)) errors.push("ID уже существует")
            if (dialog.selectedSubtypeIndex !== -1 &&
                silosSubtypesModel.get(dialog.selectedSubtypeIndex).hasMotor &&
                !dialog.validateIdFormat(dialog.motorIdValue)) errors.push("ID двигателя: 3-50 символов")

            dialog.saveStatus = "✗ " + errors.join("; ")
            statusIndicator.opacity = 1
            statusIndicator.color = "#F44336"

            // Останавливаем все таймеры и запускаем таймер ошибки
            autoCloseTimer.stop()
            errorStatusTimer.stop()
            criticalErrorTimer.stop()
            errorStatusTimer.restart()

            return
        }

        dialog.isSaving = true
        dialog.saveStatus = "Сохранение..."
        statusIndicator.opacity = 1
        statusIndicator.color = "#2196F3"

        // Останавливаем все таймеры
        autoCloseTimer.stop()
        errorStatusTimer.stop()
        criticalErrorTimer.stop()

        // Определяем пути к компонентам
        var silosPath = getSilosPath(dialog.selectedSubtype)

        // Формируем конфигурацию
        var elementConfig = {
            id: dialog.idValue.trim(),
            name: dialog.nameValue.trim(),
            motorId: dialog.selectedSubtypeIndex !== -1 && silosSubtypesModel.get(dialog.selectedSubtypeIndex).hasMotor ? dialog.motorIdValue.trim() : "",
            level: dialog.levelPreSilos,
            type: "silos",
            subtype: dialog.selectedSubtype,
            timestamp: new Date().toISOString(),
            path_file_element: silosPath
        }

        try {
            var success = QmlProjectSettings.save_silos_element(elementConfig)

            if (success) {
                // УСТАНАВЛИВАЕМ СТАТУС И ЗАПУСКАЕМ АНИМАЦИЮ
                dialog.saveStatus = "✓ Успешно добавлено!"
                statusIndicator.color = "#4CAF50"
                statusIndicator.opacity = 1
                statusIndicator.startPulseAnimation()

                // КРИТИЧЕСКИ ВАЖНО: сбрасываем флаг СРАЗУ после сохранения
                dialog.isSaving = false

                // Запускаем таймер автозакрытия
                autoCloseTimer.restart()
            } else {
                dialog.saveStatus = "✗ Ошибка: не удалось сохранить конфигурацию"
                statusIndicator.color = "#F44336"
                dialog.isSaving = false

                // Запускаем таймер скрытия статуса ошибки
                errorStatusTimer.restart()
            }
        } catch (error) {
            console.error("[DialogAddElement] Ошибка сохранения:", error)
            dialog.saveStatus = "✗ Критическая ошибка: " + error.message
            statusIndicator.color = "#F44336"
            dialog.isSaving = false

            // Запускаем таймер для критических ошибок (8 секунд)
            criticalErrorTimer.restart()
        }
    }
    // === ТАЙМЕРЫ (добавить после свойств диалога) ===
    // Таймер для успешного сохранения (автозакрытие окна)
    Timer {
        id: autoCloseTimer
        interval: 3000  // 3 секунды для показа статуса
        repeat: false
        onTriggered: {
            if (dialog.visible && !dialog.isSaving) {
                dialog.close()
            }
        }
    }

    // Таймер для скрытия статуса ошибки
    Timer {
        id: errorStatusTimer
        interval: 6000  // 6 секунд для чтения ошибки
        repeat: false
        onTriggered: {
            statusIndicator.opacity = 0
            dialog.saveStatus = ""
        }
    }

    // Таймер для критических ошибок
    Timer {
        id: criticalErrorTimer
        interval: 8000  // 8 секунд для критических ошибок
        repeat: false
        onTriggered: {
            statusIndicator.opacity = 0
            dialog.saveStatus = ""
        }
    }

    // === СБРОС ФОРМЫ ===
    function resetForm() {
        dialog.selectedSubtype = ""
        dialog.selectedSubtypeIndex = -1
        dialog.nameValue = ""
        dialog.idValue = ""
        dialog.motorIdValue = ""
        dialog.levelPreSilos = 0
        dialog.isSaving = false
        dialog.saveStatus = ""
        dialog.idExistsError = false
        dialog.idFormatError = false
        dialog.nameFormatError = false
        statusIndicator.opacity = 0
    }

    // === ОБРАБОТКА ПЛАЙСХОЛДЕРОВ ===
    function handlePlaceholder(field, placeholderText) {
        if (field.activeFocus) {
            if (field.text !== "") field.placeholderText = ""
        } else {
            if (field.text === "") field.placeholderText = placeholderText
        }
    }

    // === КОМПОНЕНТЫ ПРЕДПРОСМОТРА ===
    function getPreviewComponent() {
        if (!dialog.selectedSubtype || dialog.selectedSubtypeIndex === -1) return emptyPreview
        return silosPreview
    }

    // === СБРОС ФОРМЫ ПРИ ИЗМЕНЕНИИ ВИДИМОСТИ ===
    onVisibleChanged: {
        if (visible) {
            // При открытии диалога - сбрасываем форму и останавливаем все таймеры
            dialog.resetForm()
            autoCloseTimer.stop()
            errorStatusTimer.stop()
            criticalErrorTimer.stop()
        } else {
            // При закрытии диалога - сбрасываем форму
            dialog.resetForm()
        }
    }

    // === ИСПРАВЛЕННЫЙ ОБРАБОТЧИК ЗАКРЫТИЯ ===
    onClosing: function(close) {
        if (dialog.isSaving) {
            close.accepted = false
            return
        }
        // Останавливаем все таймеры при ручном закрытии
        autoCloseTimer.stop()
        errorStatusTimer.stop()
        criticalErrorTimer.stop()
        // Сброс формы будет выполнен в onVisibleChanged
    }
}
