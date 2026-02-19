//ControllersSignalsCementScales.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    id: root

    // === СИГНАЛЫ ДЛЯ ВЕСОВ ЦЕМЕНТА ===
    // Ручной режим
    property bool isHandMode: false

    // Активация/деактивация ручного режима
    function setHandMode(scalesId, checked, userId) {
        root.isHandMode = checked
    }
}
