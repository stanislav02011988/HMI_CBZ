// internal/OrthogonalRouter.js

// =====================================================
// КОНСТАНТЫ
// =====================================================
const LINE_IN_OUT = 20;
const PARALLEL_LINE_SPACING = 20;

// =====================================================
// СТРУКТУРЫ ДАННЫХ
// =====================================================

class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
}

class RectElement {
    constructor(x, y, width, height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    static fromQMLItem(item) {
        if (!item) return null;
        return new RectElement(
            item.x || 0,
            item.y || 0,
            item.width || 0,
            item.height || 0
        );
    }

    center() {
        return new Point(this.x + this.width / 2, this.y + this.height / 2);
    }

    isWide() {
        return this.width > this.height;
    }

    getBoundsWithPadding(padding) {
        return new RectElement(
            this.x - padding,
            this.y - padding,
            this.width + padding * 2,
            this.height + padding * 2
        );
    }

    intersectsSegment(p1, p2) {
        if (Math.abs(p1.y - p2.y) < 0.1) {
            const y = p1.y;
            const minX = Math.min(p1.x, p2.x);
            const maxX = Math.max(p1.x, p2.x);
            if (y < this.y || y > this.y + this.height) return false;
            if (maxX < this.x || minX > this.x + this.width) return false;
            return true;
        }
        if (Math.abs(p1.x - p2.x) < 0.1) {
            const x = p1.x;
            const minY = Math.min(p1.y, p2.y);
            const maxY = Math.max(p1.y, p2.y);
            if (x < this.x || x > this.x + this.width) return false;
            if (maxY < this.y || minY > this.y + this.height) return false;
            return true;
        }
        return false;
    }
}

// =====================================================
// ✅ ОСНОВНАЯ ФУНКЦИЯ МАРШРУТИЗАЦИИ
// =====================================================

function buildRoute(fromItem, toItem, fromPortX, fromPortY, toPortX, toPortY,
                    fromIsWide, toIsWide, obstacles, lineIndex = 0) {

    const fromElement = RectElement.fromQMLItem(fromItem);
    const toElement = RectElement.fromQMLItem(toItem);

    if (!fromElement || !toElement) {
        console.error("[OrthogonalRouter] Invalid fromItem or toItem");
        return [];
    }

    const obstacleElements = [];
    if (obstacles && obstacles.length > 0) {
        for (let i = 0; i < obstacles.length; i++) {
            const obs = RectElement.fromQMLItem(obstacles[i]);
            if (obs) obstacleElements.push(obs);
        }
    }

    const path = [];

    const startPoint = new Point(fromPortX, fromPortY);
    const endPoint = new Point(toPortX, toPortY);

    const isSelfConnection = fromElement.x === toElement.x &&
                             fromElement.y === toElement.y &&
                             fromElement.width === toElement.width &&
                             fromElement.height === toElement.height;

    const totalOffset = LINE_IN_OUT + (lineIndex * PARALLEL_LINE_SPACING);

    // ✅ 1. ВЫХОД ИЗ СИГНАЛА: 2 сегмента (L-образный)
    // Сегмент 1: от порта наружу (горизонтально для vertical, вертикально для horizontal)
    const fromExitPoint = calculateExitPoint(fromElement, startPoint, fromIsWide, totalOffset);
    path.push(startPoint);
    path.push(fromExitPoint);

    // Сегмент 2: поворот на 90° (вертикально для vertical, горизонтально для horizontal)
    const turnDirection = getTurnDirection(fromElement, startPoint, fromIsWide);
    const fromTurnPoint = new Point(
        fromExitPoint.x + turnDirection.x * totalOffset,
        fromExitPoint.y + turnDirection.y * totalOffset
    );
    path.push(fromTurnPoint);

    // ✅ 2. ВХОД В СЛОТ: 2 сегмента (L-образный)
    // Точка входа (на totalOffset от порта)
    const toEntryPoint = calculateEntryPoint(toElement, endPoint, toIsWide, totalOffset);

    // 3. Маршрут от поворота к точке перед входом
    let intermediatePath;
    if (isSelfConnection) {
        intermediatePath = routeSelfConnection(
            fromTurnPoint,
            toEntryPoint,
            fromElement,
            fromIsWide,
            totalOffset,
            lineIndex
        );
    } else {
        intermediatePath = routeToTarget(
            fromTurnPoint,
            toEntryPoint,
            fromElement,
            toElement,
            obstacleElements,
            totalOffset
        );
    }

    for (let i = 0; i < intermediatePath.length; i++) {
        path.push(intermediatePath[i]);
    }

    // ✅ Сегмент входа: от toEntryPoint к порту
    path.push(endPoint);

    return optimizePath(path);
}

// =====================================================
// ✅ РАСЧЁТ ТОЧКИ ВЫХОДА (Сегмент 1)
// =====================================================

function calculateExitPoint(element, portPoint, isWide, totalOffset) {
    if (isWide) {
        // Горизонтальный: сигналы СВЕРХУ → выход ВВЕРХ
        return new Point(portPoint.x, portPoint.y - totalOffset);
    } else {
        // Вертикальный: сигналы СЛЕВА → выход ВЛЕВО
        return new Point(portPoint.x - totalOffset, portPoint.y);
    }
}

// =====================================================
// ✅ НАПРАВЛЕНИЕ ПОВОРОТА (Сегмент 2)
// =====================================================

function getTurnDirection(element, portPoint, isWide) {
    const center = element.center();
    if (isWide) {
        // Горизонтальный: выход ВВЕРХ → поворот ВЛЕВО или ВПРАВО
        const dirX = portPoint.x > center.x ? 1 : -1;
        return { x: dirX, y: 0 };
    } else {
        // Вертикальный: выход ВЛЕВО → поворот ВВЕРХ или ВНИЗ
        const dirY = portPoint.y > center.y ? 1 : -1;
        return { x: 0, y: dirY };
    }
}

// =====================================================
// ✅ РАСЧЁТ ТОЧКИ ВХОДА (Сегмент перед последним)
// =====================================================

function calculateEntryPoint(element, portPoint, isWide, totalOffset) {
    if (isWide) {
        // Горизонтальный: слоты СНИЗУ → вход СНИЗУ
        return new Point(portPoint.x, portPoint.y + totalOffset);
    } else {
        // Вертикальный: слоты СПРАВА → вход СПРАВА
        return new Point(portPoint.x + totalOffset, portPoint.y);
    }
}

// =====================================================
// ✅ SELF-CONNECTION
// =====================================================

function routeSelfConnection(start, end, element, isWide, totalOffset, lineIndex) {
    const path = [start];
    const bypassDistance = Math.max(element.width, element.height) / 2 ;

    if (isWide) {
        const goLeft = start.x < element.center().x;
        const horizontalOffset = goLeft ? -bypassDistance : bypassDistance;
        const point1 = new Point(start.x + horizontalOffset, start.y);
        const point2 = new Point(point1.x, end.y);
        const point3 = new Point(end.x, end.y);
        path.push(point1);
        path.push(point2);
        path.push(point3);
    } else {
        const goUp = start.y < element.center().y;
        const verticalOffset = goUp ? -bypassDistance : bypassDistance;
        const point1 = new Point(start.x, start.y + verticalOffset);
        const point2 = new Point(end.x, point1.y);
        const point3 = new Point(end.x, end.y);
        path.push(point1);
        path.push(point2);
        path.push(point3);
    }
    return path;
}

// =====================================================
// ✅ МАРШРУТИЗАЦИЯ К ЦЕЛИ
// =====================================================

function routeToTarget(start, end, fromElement, toElement, obstacles, offset) {
    const route1 = [start, new Point(end.x, start.y), end];
    if (!hasCollisions(route1, fromElement, toElement, obstacles, offset)) {
        return route1;
    }

    const route2 = [start, new Point(start.x, end.y), end];
    if (!hasCollisions(route2, fromElement, toElement, obstacles, offset)) {
        return route2;
    }

    const bypassDistance = offset ;
    const topRoute = [
        start,
        new Point(start.x, start.y - bypassDistance),
        new Point(end.x, start.y - bypassDistance),
        new Point(end.x, end.y),
        end
    ];
    if (!hasCollisions(topRoute, fromElement, toElement, obstacles, offset)) {
        return topRoute;
    }

    const bottomRoute = [
        start,
        new Point(start.x, start.y + bypassDistance),
        new Point(end.x, start.y + bypassDistance),
        new Point(end.x, end.y),
        end
    ];
    if (!hasCollisions(bottomRoute, fromElement, toElement, obstacles, offset)) {
        return bottomRoute;
    }

    return [start, new Point(start.x, end.y), end];
}

// =====================================================
// ✅ ПРОВЕРКА КОЛЛИЗИЙ
// =====================================================

function hasCollisions(path, fromElement, toElement, obstacles, offset) {
    for (let i = 0; i < path.length - 1; i++) {
        if (i === 0 || i === path.length - 2) continue;
        const p1 = path[i];
        const p2 = path[i + 1];
        for (let j = 0; j < obstacles.length; j++) {
            const obs = obstacles[j];
            const obsWithPadding = obs.getBoundsWithPadding(offset);
            if (obsWithPadding.intersectsSegment(p1, p2)) {
                return true;
            }
        }
        const fromWithPadding = fromElement.getBoundsWithPadding(offset);
        if (fromWithPadding.intersectsSegment(p1, p2)) {
            return true;
        }
        const toWithPadding = toElement.getBoundsWithPadding(offset);
        if (toWithPadding.intersectsSegment(p1, p2)) {
            return true;
        }
    }
    return false;
}

// =====================================================
// ✅ ОПТИМИЗАЦИЯ ПУТИ
// =====================================================

function optimizePath(path) {
    if (!path || path.length <= 2) return path || [];
    const optimized = [path[0]];
    for (let i = 1; i < path.length - 1; i++) {
        const prev = path[i - 1];
        const curr = path[i];
        const next = path[i + 1];
        const isCollinear = (Math.abs(curr.x - prev.x) < 0.1 && Math.abs(curr.x - next.x) < 0.1) ||
                           (Math.abs(curr.y - prev.y) < 0.1 && Math.abs(curr.y - next.y) < 0.1);
        if (!isCollinear) {
            optimized.push(curr);
        }
    }
    optimized.push(path[path.length - 1]);
    return optimized;
}
