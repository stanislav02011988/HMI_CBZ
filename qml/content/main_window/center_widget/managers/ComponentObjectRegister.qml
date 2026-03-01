// ComponentRegister.qml
// ============================================================================
// РЕГИСТР ВСЕХ ЭЛЕМЕНТОВ СЦЕНЫ
// ============================================================================
// Хранит ссылки на все созданные виджеты
// Позволяет быстро найти элемент по ID
// ============================================================================

import QtQuick

Item {
    id: register

    // =========================================================================
    // ХРАНИЛИЩЕ ЭЛЕМЕНТОВ
    // =========================================================================
    // Структура: [{ wrapper, config, widgetRef, createdAt }]
    property var elements: []

    // =========================================================================
    // СИГНАЛЫ
    // =========================================================================
    signal elementAdded(string id)
    signal elementRemoved(string id)
    signal registryChanged()

    // =========================================================================
    // РЕГИСТРАЦИЯ ЭЛЕМЕНТА
    // =========================================================================
    function registerElement(wrapper, config, widgetRef) {
        // Проверка на дубликат ID
        if (getElementById(config.id_widget)) {
            console.warn(`️ ID "${config.id_widget}" уже существует!`)
            return false
        }

        // Добавление в массив
        elements.push({
            wrapper: wrapper,
            config: Object.assign({}, config),  // Копия конфига
            widgetRef: widgetRef,
            createdAt: new Date().toISOString()
        })

        elementAdded(config.id_widget)
        registryChanged()

        console.log(` Зарегистрирован элемент: ${config.id_widget}`)
        return true
    }

    // =========================================================================
    // УДАЛЕНИЕ ЭЛЕМЕНТА
    // =========================================================================
    function unregisterElement(wrapper) {
        for (let i = elements.length - 1; i >= 0; i--) {
            if (elements[i].wrapper === wrapper) {
                const id = elements[i].config.id_widget
                elements.splice(i, 1)
                elementRemoved(id)
                registryChanged()
                console.log(`️ Удалён элемент: ${id}`)
                return true
            }
        }
        return false
    }

    // =========================================================================
    // ПОИСК ПО ID (O(n) но обычно элементов < 1000)
    // =========================================================================
    function getElementById(id) {
        return elements.find(e => e.config.id_widget === id)
    }

    // =========================================================================
    // ПОЛУЧИТЬ ВСЕ ID
    // =========================================================================
    function getAllIds() {
        return elements.map(e => e.config.id_widget)
    }

    // =========================================================================
    // ЭКСПОРТ ДАННЫХ (ДЛЯ СОХРАНЕНИЯ)
    // =========================================================================
    function exportSceneData() {
        return elements.map(e => ({
            type: e.wrapper.type,
            relX: e.wrapper.relX,
            relY: e.wrapper.relY,
            relW: e.wrapper.relW,
            relH: e.wrapper.relH,
            widgetConfig: e.config
        }))
    }

    // =========================================================================
    // ОЧИСТКА
    // =========================================================================
    function clear() {
        elements = []
        registryChanged()
        console.log("️ Регистр очищен")
    }

    // =========================================================================
    // СТАТИСТИКА
    // =========================================================================
    function getCount() {
        return elements.length
    }
}
