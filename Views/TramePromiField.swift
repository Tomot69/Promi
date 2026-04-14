//
//  TramePromiField.swift
//  Promi
//
//  Pack visuel "Trame" : mosaïque Voronoï dense générée en code,
//  contours fins + points au centroïde. 4 moods (Jardin, Obsidienne,
//  Adobe, Confettis) partagent la même géométrie, seules les couleurs
//  changent. Totalement indépendant du pack Chrome × Vitrail qui lui
//  est basé sur un PNG photoréaliste.
//

import SwiftUI

// MARK: - Data

/// Une cellule Voronoï pré-calculée, coordonnées normalisées [0, 1]
/// relativement à un canvas carré unité. Le polygone est trié dans
/// l'ordre du contour (sens trigonométrique).
struct TrameCell: Identifiable, Hashable {
    let id: Int
    let polygon: [CGPoint]
    let centroid: CGPoint
}

// MARK: - Mood mapping

/// Extrait les 3 couleurs pertinentes d'un PromiColorMood pour le pack Trame :
/// fond, contour, et (pour les 3 premiers moods) couleur de point unique.
/// Pour Confettis, la fonction dotColor(for:) cycle sur 6 teintes via index % 6.
enum TrameMood {
    static func background(for mood: PromiColorMood) -> Color {
        switch mood {
        case .trameJardin:     return Color(red: 1.00, green: 1.00, blue: 1.00)
        case .trameObsidienne: return Color(red: 0.039, green: 0.039, blue: 0.059)
        case .trameAdobe:      return Color(red: 0.851, green: 0.722, blue: 0.541)
        case .trameConfettis:  return Color(red: 0.980, green: 0.969, blue: 0.941)
        default:               return Color.white
        }
    }

    static func stroke(for mood: PromiColorMood) -> Color {
        switch mood {
        case .trameJardin:     return Color(red: 0.180, green: 0.369, blue: 0.227)
        case .trameObsidienne: return Color(red: 1.000, green: 0.549, blue: 0.259)
        case .trameAdobe:      return Color(red: 0.290, green: 0.173, blue: 0.102)
        case .trameConfettis:  return Color(red: 0.169, green: 0.169, blue: 0.169)
        default:               return Color.black
        }
    }

    /// Couleur du point au centroïde de la cellule d'index donné.
    /// Pour les 3 premiers moods, une couleur unique. Pour Confettis,
    /// rotation déterministe parmi 6 teintes selon index % 6.
    static func dotColor(for mood: PromiColorMood, cellIndex: Int) -> Color {
        switch mood {
        case .trameJardin:
            return Color(red: 0.910, green: 0.365, blue: 0.239)
        case .trameObsidienne:
            return Color(red: 0.961, green: 0.914, blue: 0.376)
        case .trameAdobe:
            return Color(red: 0.961, green: 0.937, blue: 0.878)
        case .trameConfettis:
            let confettiPalette: [Color] = [
                Color(red: 1.000, green: 0.231, blue: 0.498), // rose
                Color(red: 1.000, green: 0.824, blue: 0.247), // jaune
                Color(red: 0.102, green: 0.737, blue: 0.612), // turquoise
                Color(red: 0.557, green: 0.267, blue: 0.847), // violet
                Color(red: 1.000, green: 0.420, blue: 0.102), // orange
                Color(red: 0.239, green: 0.647, blue: 0.910)  // bleu ciel
            ]
            return confettiPalette[cellIndex % confettiPalette.count]
        default:
            return Color.gray
        }
    }
}

// MARK: - Geometry generator

/// Génère une géométrie Voronoï dense (≈500 cellules) de manière
/// 100% déterministe (même seed → mêmes polygones à chaque lancement),
/// en coordonnées normalisées [0, 1] × [0, 1].
///
/// Implémentation : génération pseudo-aléatoire de sites avec un LCG seedé
/// (indépendant de arc4random / srand48 système, donc totalement stable),
/// puis calcul des cellules via clipping du demi-plan (Bowyer / intersection
/// itérative) sur un rectangle unité. Pour 500 sites c'est O(n²) = 250k
/// opérations de clipping — largement acceptable en one-shot au lancement.
enum TrameGeometry {
    static let shared: [TrameCell] = generateCells()

    /// Ratio hauteur/largeur de l'espace logique dans lequel les sites
    /// sont distribués. Plus grand = cellules plus hautes à l'écran.
    static let aspectRatio: CGFloat = 2.1

    private static let siteCount = 500
    private static let seed: UInt64 = 0x50_72_6F_6D_69_21_21_21 // "Promi!!!"

    private static func generateCells() -> [TrameCell] {
        // 1. Générer les sites avec une densité variable : 3 foyers
        // d'attraction qui concentrent plus de sites autour d'eux,
        // donnant des zones denses et des zones aérées comme dans la
        // référence visuelle. Rejection sampling : on tire un point
        // aléatoire, on accepte avec une probabilité = densité locale.
        var rng = LCG(seed: seed)

        // 3 foyers répartis de manière intéressante (pas symétrique).
        // Coordonnées en espace [0, 1] × [0, 1.5] (espace haut d'écran).
        let attractors: [(CGPoint, CGFloat)] = [
            (CGPoint(x: 0.30, y: 0.25), 0.18),  // haut-gauche, fort
            (CGPoint(x: 0.72, y: 0.55), 0.22),  // centre-droit, moyen
            (CGPoint(x: 0.40, y: 1.15), 0.20)   // bas-centre, fort
        ]

        var sites: [CGPoint] = []
        sites.reserveCapacity(siteCount)
        let margin: CGFloat = 0.01
        var attempts = 0
        let maxAttempts = siteCount * 20
        while sites.count < siteCount && attempts < maxAttempts {
            attempts += 1
            let x = margin + CGFloat(rng.nextUnit()) * (1.0 - 2 * margin)
            let y = margin + CGFloat(rng.nextUnit()) * (TrameGeometry.aspectRatio - 2 * margin)
            let p = CGPoint(x: x, y: y)

            // Densité locale : baseline 0.25 + pic près des foyers.
            var density: CGFloat = 0.25
            for (center, radius) in attractors {
                let dx = p.x - center.x
                let dy = p.y - center.y
                let d = sqrt(dx * dx + dy * dy)
                let gauss = exp(-(d * d) / (2 * radius * radius))
                density = max(density, gauss)
            }
            // Accepte/rejette selon la densité
            if CGFloat(rng.nextUnit()) < density {
                sites.append(p)
            }
        }
        // Complète si besoin par des sites uniformes (marge de sécurité)
        while sites.count < siteCount {
            let x = margin + CGFloat(rng.nextUnit()) * (1.0 - 2 * margin)
            let y = margin + CGFloat(rng.nextUnit()) * (TrameGeometry.aspectRatio - 2 * margin)
            sites.append(CGPoint(x: x, y: y))
        }

        // 2. Lloyd's relaxation légère (1 seule passe) pour éviter les
        // cellules trop distordues, sans lisser complètement les zones
        // de densité variable.
        for _ in 0..<1 {
            var newSites: [CGPoint] = []
            newSites.reserveCapacity(sites.count)
            for i in 0..<sites.count {
                let poly = voronoiCell(for: i, sites: sites)
                newSites.append(polygonCentroid(poly))
            }
            sites = newSites
        }

        // 3. Cellules finales + centroïdes.
        var cells: [TrameCell] = []
        cells.reserveCapacity(sites.count)
        for i in 0..<sites.count {
            let poly = voronoiCell(for: i, sites: sites)
            guard poly.count >= 3 else { continue }
            let c = polygonCentroid(poly)
            cells.append(TrameCell(id: i, polygon: poly, centroid: c))
        }
        return cells
    }

    /// Calcule le polygone Voronoï de `sites[index]` par clipping successif
    /// du rectangle unité avec les médiatrices entre le site et tous les
    /// autres sites. Simple et fiable pour ~500 sites.
    private static func voronoiCell(for index: Int, sites: [CGPoint]) -> [CGPoint] {
        // Rectangle de clipping au ratio 1 × 1.5 (plutôt que carré 1×1)
        // pour que les cellules ne soient pas écrasées quand on les
        // étire à la taille écran verticale.
        var poly: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: TrameGeometry.aspectRatio),
            CGPoint(x: 0, y: TrameGeometry.aspectRatio)
        ]
        let me = sites[index]
        for j in 0..<sites.count where j != index {
            let other = sites[j]
            // Médiatrice : plan demi-espace des points plus proches de `me`
            // que de `other`. Clipping Sutherland–Hodgman.
            poly = clipPolygonToHalfPlane(poly, keepCloserTo: me, than: other)
            if poly.count < 3 { return [] }
        }
        return poly
    }

    /// Clip un polygone convexe au demi-plan des points plus proches
    /// de `a` que de `b` (Sutherland–Hodgman).
    private static func clipPolygonToHalfPlane(
        _ polygon: [CGPoint],
        keepCloserTo a: CGPoint,
        than b: CGPoint
    ) -> [CGPoint] {
        guard polygon.count >= 3 else { return [] }
        var out: [CGPoint] = []
        out.reserveCapacity(polygon.count + 1)

        let n = polygon.count
        for i in 0..<n {
            let curr = polygon[i]
            let next = polygon[(i + 1) % n]
            let dCurr = squaredDist(curr, a) - squaredDist(curr, b)
            let dNext = squaredDist(next, a) - squaredDist(next, b)
            let currInside = dCurr <= 0
            let nextInside = dNext <= 0

            if currInside {
                out.append(curr)
                if !nextInside {
                    if let inter = perpendicularBisectorIntersection(
                        segmentFrom: curr, to: next, a: a, b: b
                    ) {
                        out.append(inter)
                    }
                }
            } else if nextInside {
                if let inter = perpendicularBisectorIntersection(
                    segmentFrom: curr, to: next, a: a, b: b
                ) {
                    out.append(inter)
                }
            }
        }
        return out
    }

    private static func perpendicularBisectorIntersection(
        segmentFrom p: CGPoint,
        to q: CGPoint,
        a: CGPoint,
        b: CGPoint
    ) -> CGPoint? {
        // Médiatrice de AB : ensemble des points équidistants.
        // Équation : (b.x - a.x)(x - mx) + (b.y - a.y)(y - my) = 0
        // avec m = midpoint(a, b). On cherche t ∈ [0,1] tel que p + t*(q-p)
        // soit sur la médiatrice.
        let mx = (a.x + b.x) / 2
        let my = (a.y + b.y) / 2
        let nx = b.x - a.x
        let ny = b.y - a.y
        let dx = q.x - p.x
        let dy = q.y - p.y
        let denom = nx * dx + ny * dy
        if abs(denom) < 1e-12 { return nil }
        let t = (nx * (mx - p.x) + ny * (my - p.y)) / denom
        guard t.isFinite, t >= -0.0001, t <= 1.0001 else { return nil }
        return CGPoint(x: p.x + t * dx, y: p.y + t * dy)
    }

    private static func squaredDist(_ p: CGPoint, _ q: CGPoint) -> CGFloat {
        let dx = p.x - q.x
        let dy = p.y - q.y
        return dx * dx + dy * dy
    }

    private static func polygonCentroid(_ poly: [CGPoint]) -> CGPoint {
        guard poly.count >= 3 else {
            return poly.first ?? CGPoint(x: 0.5, y: 0.5)
        }
        var area: CGFloat = 0
        var cx: CGFloat = 0
        var cy: CGFloat = 0
        let n = poly.count
        for i in 0..<n {
            let p0 = poly[i]
            let p1 = poly[(i + 1) % n]
            let cross = p0.x * p1.y - p1.x * p0.y
            area += cross
            cx += (p0.x + p1.x) * cross
            cy += (p0.y + p1.y) * cross
        }
        area /= 2
        guard abs(area) > 1e-12 else {
            let avgX = poly.reduce(0) { $0 + $1.x } / CGFloat(n)
            let avgY = poly.reduce(0) { $0 + $1.y } / CGFloat(n)
            return CGPoint(x: avgX, y: avgY)
        }
        cx /= (6 * area)
        cy /= (6 * area)
        return CGPoint(x: cx, y: cy)
    }
}

// MARK: - Seeded RNG (Linear Congruential Generator)

/// Générateur pseudo-aléatoire simple et 100% déterministe à partir d'un
/// seed 64 bits. Remplace drand48/arc4random qui ne garantissent pas la
/// même séquence d'une plateforme / version iOS à l'autre.
private struct LCG {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEAD_BEEF_CAFE_BABE : seed
    }
    
    /// Retourne un Double uniformément réparti dans [0, 1).
    mutating func nextUnit() -> Double {
        // Constantes de Numerical Recipes.
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let top = UInt32(state >> 32)
        return Double(top) / Double(UInt32.max)
    }
}

// MARK: - Shape (hit-test polygone)

/// Shape polygonale utilisée pour le clip et le hit-test des cellules Trame.
/// `points` est déjà dénormalisé (coordonnées écran).
fileprivate struct TrameCellShape: Shape {
        let points: [CGPoint]
        func path(in rect: CGRect) -> Path {
            var p = Path()
            guard let first = points.first else { return p }
            p.move(to: first)
            for pt in points.dropFirst() { p.addLine(to: pt) }
            p.closeSubpath()
            return p
        }
    }

    // MARK: - Main view (home screen)

    /// Vue principale du pack Trame pour l'écran d'accueil. Affiche la mosaïque
    /// Voronoï 500 cellules dans un ZoomablePromiViewport (pinch + scroll),
    /// avec les Promis/Nuées placés sur les centroïdes des cellules les plus
    /// centrales. Hit-test polygone pour les taps (pas bbox).
    struct TramePromiFieldView: View {
        let mood: PromiColorMood
        let size: CGSize
        let promis: [PromiItem]
        let nuées: [Nuée]
        let languageCode: String
        let sortOption: PromiFieldSortOption
        let onTapPromi: (PromiItem) -> Void
        let onTapNuée: (Nuée) -> Void

        var body: some View {
                // Canvas largement plus grand que l'écran pour remplir toutes
                // les directions dans le ZoomablePromiViewport, quel que soit
                // le niveau de zoom. Évite le trou visible quand le contenu
                // est plus petit que le viewport.
                let canvasHeight = (size.height + 120) * 1.4
                let canvasWidth = size.width * 1.4
                let assignments = Self.makeAssignments(promis: promis, nuées: nuées)
                let bgColor = TrameMood.background(for: mood)
                let strokeColor = TrameMood.stroke(for: mood)

                return ZoomablePromiViewport {
                    TrameCanvasLayer(
                        mood: mood,
                        canvasWidth: canvasWidth,
                        canvasHeight: canvasHeight,
                        assignments: assignments,
                        bgColor: bgColor,
                        strokeColor: strokeColor
                    )
                    .overlay(
                        TrameLabelsLayer(
                            canvasWidth: canvasWidth,
                            canvasHeight: canvasHeight,
                            assignments: assignments,
                            strokeColor: strokeColor,
                            onTapPromi: onTapPromi,
                            onTapNuée: onTapNuée
                        )
                    )
                    .frame(width: canvasWidth, height: canvasHeight)
                }
                .frame(width: size.width, height: size.height)
                .background(bgColor)
                .ignoresSafeArea()
            }

            /// Calcule l'assignation Promis/Nuées → cellules triées par proximité
            /// au centre. Nuées en premier (prioritaires), puis Promis.
            fileprivate static func makeAssignments(
                promis: [PromiItem],
                nuées: [Nuée]
            ) -> [Int: TrameItem] {
                // Centre de l'espace logique : (0.5, 0.75) — pas (0.5, 0.5) —
                        // parce qu'on travaille maintenant en ratio 1×1.5.
                let centerY = TrameGeometry.aspectRatio / 2
                        let sortedCells = TrameGeometry.shared.sorted { a, b in
                            let da = (a.centroid.x - 0.5) * (a.centroid.x - 0.5)
                                   + (a.centroid.y - centerY) * (a.centroid.y - centerY)
                            let db = (b.centroid.x - 0.5) * (b.centroid.x - 0.5)
                                   + (b.centroid.y - centerY) * (b.centroid.y - centerY)
                            return da < db
                        }
                let items = nuées.map(TrameItem.nuée) + promis.map(TrameItem.promi)
                var assignments: [Int: TrameItem] = [:]
                for (idx, item) in items.enumerated() where idx < sortedCells.count {
                    assignments[sortedCells[idx].id] = item
                }
                return assignments
            }
        }

        // MARK: - Sous-vue : Canvas layer (fond + contours + points)

        fileprivate struct TrameCanvasLayer: View {
            let mood: PromiColorMood
            let canvasWidth: CGFloat
            let canvasHeight: CGFloat
            let assignments: [Int: TrameItem]
            let bgColor: Color
            let strokeColor: Color

            var body: some View {
                ZStack {
                    bgColor
                    Canvas { context, _ in
                        let strokeStyle = StrokeStyle(lineWidth: 0.8, lineCap: .round, lineJoin: .round)
                        for cell in TrameGeometry.shared {
                            drawCell(
                                cell,
                                context: context,
                                strokeStyle: strokeStyle
                            )
                        }
                    }
                    .allowsHitTesting(false)
                }
                .frame(width: canvasWidth, height: canvasHeight)
            }

            private func drawCell(
                    _ cell: TrameCell,
                    context: GraphicsContext,
                    strokeStyle: StrokeStyle
                ) {
                    // Coordonnées source en [0,1] × [0,1.5], on divise y par 1.5
                    // pour normaliser avant d'étirer au canvas. Comme ça le ratio
                    // est respecté et les cellules ne sont pas écrasées.
                    let pts = cell.polygon.map {
                                CGPoint(x: $0.x * canvasWidth, y: ($0.y / TrameGeometry.aspectRatio) * canvasHeight)
                            }
                    
                guard let first = pts.first else { return }

                var path = Path()
                path.move(to: first)
                for p in pts.dropFirst() { path.addLine(to: p) }
                path.closeSubpath()
                context.stroke(path, with: .color(strokeColor), style: strokeStyle)

                    let dotColor = TrameMood.dotColor(for: mood, cellIndex: cell.id)
                            let cx = cell.centroid.x * canvasWidth
                            let cy = (cell.centroid.y / TrameGeometry.aspectRatio) * canvasHeight
                let dotCenter = computeDotCenter(
                    cell: cell,
                    pts: pts,
                    cx: cx,
                    cy: cy,
                    occupied: assignments[cell.id] != nil
                )
                let dotRect = CGRect(
                    x: dotCenter.x - 1.6,
                    y: dotCenter.y - 1.6,
                    width: 3.2, height: 3.2
                )
                context.fill(Path(ellipseIn: dotRect), with: .color(dotColor))
            }

            private func computeDotCenter(
                cell: TrameCell,
                pts: [CGPoint],
                cx: CGFloat,
                cy: CGFloat,
                occupied: Bool
            ) -> CGPoint {
                if !occupied { return CGPoint(x: cx, y: cy) }
                let quadrant = cell.id % 4
                let xs = pts.map(\.x)
                let ys = pts.map(\.y)
                let xMin = xs.min() ?? cx
                let xMax = xs.max() ?? cx
                let yMin = ys.min() ?? cy
                let yMax = ys.max() ?? cy
                let offX: CGFloat = (quadrant == 0 || quadrant == 3)
                    ? (xMin + (cx - xMin) * 0.35)
                    : (cx + (xMax - cx) * 0.65)
                let offY: CGFloat = (quadrant == 0 || quadrant == 1)
                    ? (yMin + (cy - yMin) * 0.35)
                    : (cy + (yMax - cy) * 0.65)
                return CGPoint(x: offX, y: offY)
            }
        }

        // MARK: - Sous-vue : Labels + hit-test

        fileprivate struct TrameLabelsLayer: View {
            let canvasWidth: CGFloat
            let canvasHeight: CGFloat
            let assignments: [Int: TrameItem]
            let strokeColor: Color
            let onTapPromi: (PromiItem) -> Void
            let onTapNuée: (Nuée) -> Void

            var body: some View {
                ZStack(alignment: .topLeading) {
                    ForEach(TrameGeometry.shared) { cell in
                        if let item = assignments[cell.id] {
                            cellLabel(cell: cell, item: item)
                        }
                    }
                }
                .frame(width: canvasWidth, height: canvasHeight)
            }

            @ViewBuilder
                private func cellLabel(cell: TrameCell, item: TrameItem) -> some View {
                    let pts = cell.polygon.map {
                        CGPoint(x: $0.x * canvasWidth, y: ($0.y / TrameGeometry.aspectRatio) * canvasHeight)
                    }
                    let xs = pts.map(\.x)
                    let ys = pts.map(\.y)
                    let xMin = xs.min() ?? 0
                    let xMax = xs.max() ?? 0
                    let yMin = ys.min() ?? 0
                    let yMax = ys.max() ?? 0
                    let midX = (xMin + xMax) / 2
                    let midY = (yMin + yMax) / 2
                    let width = xMax - xMin

                    VStack(spacing: 2) {
                        // Icône SF Symbol uniquement pour les Nuées (tag/lock.heart
                        // selon le kind). Les Promis n'ont pas d'icône, juste leur
                        // titre textuel.
                        if case .nuée(let n) = item {
                            Image(systemName: n.displayIconGlyph)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(strokeColor)
                        }
                        Text(Self.titleFor(item))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(strokeColor)
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: max(width * 0.8, 24))
                    .position(x: midX, y: midY)
                    .contentShape(TrameCellShape(points: pts))
                    .onTapGesture {
                        switch item {
                        case .promi(let p): onTapPromi(p)
                        case .nuée(let n):  onTapNuée(n)
                        }
                    }
                }

                        private static func titleFor(_ item: TrameItem) -> String {
                            switch item {
                            case .promi(let p): return p.title
                            case .nuée(let n):  return n.name
                            }
                        }
                    }

    /// Union type minimal pour distinguer un Promi d'une Nuée assignés à une cellule.
    fileprivate enum TrameItem {
        case promi(PromiItem)
        case nuée(Nuée)
    }
// MARK: - Studio preview (mini tuile dans le Studio)

/// Aperçu statique pour le Studio : mêmes contours et points que la vraie
/// vue, dimensionnés pour une tuile de ~294×168, sans scroll ni zoom.
/// Affiche un aperçu représentatif du mood en cadrant une zone centrale
/// de l'espace logique [0,1] × [0, aspectRatio].
struct TrameStudioPreview: View {
    let mood: PromiColorMood
    let size: CGSize

    var body: some View {
        let bgColor = TrameMood.background(for: mood)
        let strokeColor = TrameMood.stroke(for: mood)
        let w = size.width
        let h = size.height

        return ZStack {
            bgColor
            Canvas { context, _ in
                let strokeStyle = StrokeStyle(lineWidth: 0.6, lineCap: .round, lineJoin: .round)
                // Cadrage de l'espace logique au ratio exact de la tuile
                // pour éviter toute distorsion. On prend une bande
                // horizontale dont le ratio largeur/hauteur = tileRatio,
                // centrée verticalement sur un foyer dense (y ≈ 0.8).
                let tileRatio = w / h  // ex: 294/168 = 1.75
                // Largeur visible = 1.0, hauteur visible = 1/tileRatio
                // en coordonnées logiques x. Mais l'espace logique est
                // x ∈ [0,1], y ∈ [0, aspectRatio]. On veut un crop qui,
                // une fois étiré à w × h, ait le ratio naturel.
                let srcHeight: CGFloat = 1.0 / tileRatio
                let srcYMid: CGFloat = 0.85
                let srcYMin = max(0, srcYMid - srcHeight / 2)
                for cell in TrameGeometry.shared {
                    let pts = cell.polygon.map { p -> CGPoint in
                        CGPoint(
                            x: p.x * w,
                            y: ((p.y - srcYMin) / srcHeight) * h
                        )
                    }
                    guard let first = pts.first else { continue }
                    var path = Path()
                    path.move(to: first)
                    for p in pts.dropFirst() { path.addLine(to: p) }
                    path.closeSubpath()
                    context.stroke(path, with: .color(strokeColor), style: strokeStyle)

                    let dotColor = TrameMood.dotColor(for: mood, cellIndex: cell.id)
                    let cx = cell.centroid.x * w
                    let cy = ((cell.centroid.y - srcYMin) / srcHeight) * h
                    let dotRect = CGRect(x: cx - 1.2, y: cy - 1.2, width: 2.4, height: 2.4)
                    context.fill(Path(ellipseIn: dotRect), with: .color(dotColor))
                }
            }
            .frame(width: w, height: h)
        }
        .frame(width: w, height: h)
        .clipped()
    }
}
