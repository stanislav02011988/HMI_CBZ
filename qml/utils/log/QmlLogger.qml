// qml.utils.log /Logger.qml
// ============================================================================
// ЦЕНТРАЛИЗОВАННАЯ СИСТЕМА ЛОГИРОВАНИЯ
// ============================================================================
// Уровни логирования:
// 0 = LOG   (обычные сообщения)
// 1 = INFO  (информационные)
// 2 = DEBUG (отладочные)
// 3 = WARN  (предупреждения)
// 4 = ERROR (ошибки)
// ============================================================================
pragma Singleton

import QtQuick

Item {
    id: logger

    // =========================================================================
    // УРОВЕНЬ ЛОГИРОВАНИЯ (0-4)
    // =========================================================================
    // Показывать логи этого уровня и ВСЕ выше (чем выше число = важнее)
    // Пример: logLevel = 3 → показывать WARN(3) и ERROR(4)
    // Пример: logLevel = 0 → показывать ВСЕ логи
    // =========================================================================
    property int logLevel: 0  // 0 = показывать всё, 4 = только ошибки

    // =========================================================================
    // НАСТРОЙКИ
    // =========================================================================
    property bool enableTimestamp: true
    property bool enableColors: true
    property string logPrefix: "📝"

    // =========================================================================
    // СЧЁТЧИКИ
    // =========================================================================
    property int logCount: 0
    property int infoCount: 0
    property int debugCount: 0
    property int warnCount: 0
    property int errorCount: 0

    // =========================================================================
    // СИГНАЛЫ
    // =========================================================================
    signal logMessage(int level, string message, var data)
    signal errorOccurred(string message)

    // =========================================================================
    // ОСНОВНАЯ ФУНКЦИЯ ЛОГИРОВАНИЯ
    // =========================================================================
    // Параметры:
    // - message: текст сообщения
    // - level: уровень (0=log, 1=info, 2=debug, 3=warn, 4=error)
    // - data: дополнительные данные (объект, опционально)
    // =========================================================================
    function log(message, level = 0, data = null) {
        // Проверка уровня (показываем если уровень >= текущего порога)
        if (level < logLevel) return

        // Формирование префикса
        const prefix = getPrefix(level)
        const timestamp = enableTimestamp ? getTimestamp() : ""
        const levelName = getLevelName(level)

        // Формирование сообщения
        let logMessage = `${timestamp}  [${levelName}] ${message}`

        // Добавление данных если есть
        if (data !== null) {
            logMessage += `\n   Data: ${JSON.stringify(data, null, 2)}`
        }

        // Вывод в консоль
        console.log(logMessage)

        // Обновление счётчиков
        updateCounters(level)

        // Эмит сигнала (для внешних подписчиков)
        // logMessage(level, message, data)

        // Для ошибок — дополнительный сигнал
        if (level === 4) {
            errorOccurred(message)
        }
    }

    // =========================================================================
    // УДОБНЫЕ ОБЁРТКИ ДЛЯ РАЗНЫХ УРОВНЕЙ
    // =========================================================================
    function logMsg(message, data = null) {
        log(message, 0, data)
    }

    function info(message, data = null) {
        log(message, 1, data)
    }

    function debug(message, data = null) {
        log(message, 2, data)
    }

    function warn(message, data = null) {
        log(message, 3, data)
    }

    function error(message, data = null) {
        log(message, 4, data)
    }

    // =========================================================================
    // ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
    // =========================================================================
    function getPrefix(level) {
        if (!enableColors) return getLevelName(level)

        const prefixes = ["📝 LOG", "ℹ️ INFO", "🔍 DEBUG", "⚠️ WARN", "❌ ERROR"]
        return prefixes[level] || "•"
    }

    function getLevelName(level) {
        const names = ["LOG", "INFO", "DEBUG", "WARN", "ERROR"]
        return names[level] || "UNKNOWN"
    }

    function getTimestamp() {
        const now = new Date()
        return `[${now.toISOString().slice(11, 23)}]`
    }

    function updateCounters(level) {
        logCount++
        switch(level) {
            case 0: break  // log не считаем отдельно
            case 1: infoCount++; break
            case 2: debugCount++; break
            case 3: warnCount++; break
            case 4: errorCount++; break
        }
    }

    // =========================================================================
    // СБРОС СЧЁТЧИКОВ
    // =========================================================================
    function resetCounters() {
        logCount = 0
        infoCount = 0
        debugCount = 0
        warnCount = 0
        errorCount = 0
        logMsg("Счётчики логов сброшены", 1)
    }

    // =========================================================================
    // ПОЛУЧЕНИЕ СТАТИСТИКИ
    // =========================================================================
    function getStats() {
        return {
            total: logCount,
            info: infoCount,
            debug: debugCount,
            warn: warnCount,
            error: errorCount,
            currentLevel: logLevel
        }
    }

    // =========================================================================
    // ПРИ ИНИЦИАЛИЗАЦИИ
    // =========================================================================
    Component.onCompleted: {
        logMsg("Logger инициализирован", 1, {
            logLevel: logLevel,
            enableTimestamp: enableTimestamp,
            enableColors: enableColors
        })
    }
}
