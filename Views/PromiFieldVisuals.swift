import SwiftUI
import UIKit

// MARK: - Public: Live zoomable field

struct PromiFieldRootView: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    var body: some View {
        GeometryReader { geo in
            ZoomablePromiViewport {
                packContent(size: geo.size)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func packContent(size: CGSize) -> some View {
        switch pack {
        case .galets:
            GaletsPromiFieldView(
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: onTapPromi
            )
        case .alveolesSignature:
            AlveolesPromiFieldView(
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: onTapPromi
            )
        case .mosaicFlat:
            MosaicFlatPromiFieldView(
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: onTapPromi
            )
        case .spectrumSoft:
            SpectrumSoftPromiFieldView(
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: onTapPromi
            )
        case .cristal:
            CristalPromiFieldView(
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: onTapPromi
            )
        }
    }
}

// MARK: - Public: Preview (Studio + Partage, non-zoomable, same engine)

struct PromiFieldPreviewView: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption

    init(
        pack: PromiVisualPack,
        mood: PromiColorMood,
        size: CGSize,
        promis: [PromiItem] = [],
        languageCode: String = "fr_FR",
        sortOption: PromiFieldSortOption = .inspiration
    ) {
        self.pack = pack
        self.mood = mood
        self.size = size
        self.promis = promis
        self.languageCode = languageCode
        self.sortOption = sortOption
    }

    var body: some View {
        ZStack {
            mood.homeBackground

            packContent
                .frame(width: size.width, height: size.height, alignment: .topLeading)
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .clipped()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var packContent: some View {
        switch pack {
        case .galets:
            CommonPromiFieldView(
                theme: .galets,
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in }
            )
        case .alveolesSignature:
            CommonPromiFieldView(
                theme: .alveoles,
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in }
            )
        case .mosaicFlat:
            CommonPromiFieldView(
                theme: .mosaic,
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in }
            )
        case .spectrumSoft:
            CommonPromiFieldView(
                theme: .spectrum,
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in }
            )
        case .cristal:
            CommonPromiFieldView(
                theme: .cristal,
                mood: mood,
                size: size,
                promis: promis,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in }
            )
        }
    }
}

// MARK: - Zoomable viewport (Photos-like)

private final class ZoomHostScrollView: UIScrollView {
    weak var hostedView: UIView?
    private var lastConfiguredBoundsSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let hosted = hostedView else { return }

        let currentSize = bounds.size
        let atRestScale = abs(zoomScale - 1.0) < 0.001

        // Only reconfigure when bounds change AND we're at rest scale.
        if currentSize != .zero && currentSize != lastConfiguredBoundsSize && atRestScale {
            lastConfiguredBoundsSize = currentSize
            hosted.frame = CGRect(origin: .zero, size: currentSize)
            contentSize = currentSize
        }

        centerContentIfNeeded()
    }

    func centerContentIfNeeded() {
        guard let hosted = hostedView else { return }
        var frame = hosted.frame
        frame.origin.x = frame.width < bounds.width ? (bounds.width - frame.width) / 2 : 0
        frame.origin.y = frame.height < bounds.height ? (bounds.height - frame.height) / 2 : 0
        hosted.frame = frame
    }
}

private struct ZoomablePromiViewport<Content: View>: UIViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(rootView: content)
    }

    func makeUIView(context: Context) -> ZoomHostScrollView {
        let scrollView = ZoomHostScrollView()
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.6
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.clipsToBounds = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast

        let hosting = context.coordinator.hostingController
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = true
        hosting.view.autoresizingMask = []
        hosting.view.frame = .zero

        scrollView.addSubview(hosting.view)
        scrollView.hostedView = hosting.view

        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = false
        scrollView.addGestureRecognizer(doubleTap)

        context.coordinator.scrollView = scrollView
        return scrollView
    }

    func updateUIView(_ scrollView: ZoomHostScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content
        scrollView.setNeedsLayout()
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let hostingController: UIHostingController<Content>
        weak var scrollView: ZoomHostScrollView?

        init(rootView: Content) {
            hostingController = UIHostingController(rootView: rootView)
            hostingController.view.backgroundColor = .clear
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            (scrollView as? ZoomHostScrollView)?.centerContentIfNeeded()
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            (scrollView as? ZoomHostScrollView)?.centerContentIfNeeded()
        }

        @objc
        func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView else { return }

            if scrollView.zoomScale > 1.01 {
                scrollView.setZoomScale(1.0, animated: true)
                return
            }

            let tapPoint = recognizer.location(in: hostingController.view)
            let newScale: CGFloat = min(2.5, scrollView.maximumZoomScale)

            let width = scrollView.bounds.width / newScale
            let height = scrollView.bounds.height / newScale
            let zoomRect = CGRect(
                x: tapPoint.x - width / 2,
                y: tapPoint.y - height / 2,
                width: width,
                height: height
            )

            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}

// MARK: - Pack wrappers

struct GaletsPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    var body: some View {
        CommonPromiFieldView(
            theme: .galets,
            mood: mood,
            size: size,
            promis: promis,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi
        )
        .background(mood.homeBackground)
    }
}

struct AlveolesPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    var body: some View {
        CommonPromiFieldView(
            theme: .alveoles,
            mood: mood,
            size: size,
            promis: promis,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi
        )
        .background(mood.homeBackground)
    }
}

struct MosaicFlatPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    var body: some View {
        CommonPromiFieldView(
            theme: .mosaic,
            mood: mood,
            size: size,
            promis: promis,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi
        )
        .background(mood.homeBackground)
    }
}

struct SpectrumSoftPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    var body: some View {
        CommonPromiFieldView(
            theme: .spectrum,
            mood: mood,
            size: size,
            promis: promis,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi
        )
        .background(mood.homeBackground)
    }
}

struct CristalPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    var body: some View {
        CommonPromiFieldView(
            theme: .cristal,
            mood: mood,
            size: size,
            promis: promis,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi
        )
        .background(mood.homeBackground)
    }
}

// MARK: - Shared field

fileprivate struct CommonPromiFieldView: View {
    let theme: PromiFieldTheme
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void

    @State private var cachedLayout: PromiFieldLayout = PromiFieldLayout(
        cells: [],
        nestedSubCells: nil,
        fieldScale: 1,
        offsetX: 0,
        offsetY: 0
    )
    @State private var cachedKey: String = ""
    @State private var dispatchGeneration: Int = 0

    /// Composite key that invalidates the cache whenever any input that
    /// affects the layout changes. The Promi list is hashed by id+intensity
    /// so that promotion/size changes trigger a refresh but cosmetic changes
    /// (title, metadata) do not.
    private var renderKey: String {
        let promiHash = promis
            .map { "\($0.id.uuidString):\($0.intensity)" }
            .joined(separator: ",")
        return "\(Int(size.width))x\(Int(size.height))|\(theme.id)|\(mood.rawValue)|\(sortOption)|\(promiHash)"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let subCells = cachedLayout.nestedSubCells {
                CristalNestedUnderlay(
                    subCells: subCells,
                    size: size
                )
            }

            ForEach(cachedLayout.cells) { cell in
                cellView(for: cell)
            }
        }
        .frame(width: max(size.width, 1), height: max(size.height, 1), alignment: .topLeading)
        .scaleEffect(cachedLayout.fieldScale, anchor: .center)
        .offset(x: cachedLayout.offsetX, y: cachedLayout.offsetY)
        .animation(.spring(response: 0.44, dampingFraction: 0.86), value: cachedKey)
        .onAppear { regenerateLayoutIfNeeded() }
        .onChange(of: renderKey) { _ in regenerateLayoutIfNeeded() }
    }

    /// Recomputes the layout when the render key changes. Fast themes
    /// (galets/alveoles/mosaic/spectrum) compute synchronously on the main
    /// thread — they're cheap (<20ms) and sync avoids race conditions entirely.
    /// Cristal computes on a background queue because the ~6000-cell sub-pavage
    /// takes 1-3s; a generation counter protects against stale results landing
    /// after the user has already switched to a different mood.
    private func regenerateLayoutIfNeeded() {
        let newKey = renderKey
        guard newKey != cachedKey else { return }

        // Fast sync path — non-cristal themes compute in < 20ms, main thread
        // is fine. Direct, predictable, no race conditions.
        if theme != .cristal {
            let fresh = PromiFieldLayoutFactory.make(
                theme: theme,
                mood: mood,
                size: size,
                promis: promis,
                sortOption: sortOption
            )
            cachedLayout = fresh
            cachedKey = newKey
            return
        }

        // Slow async path — cristal only. Generation counter discards stale
        // results if the user switches mood while a compute is in flight.
        dispatchGeneration += 1
        let myGeneration = dispatchGeneration

        let capturedTheme = theme
        let capturedMood = mood
        let capturedSize = size
        let capturedPromis = promis
        let capturedSortOption = sortOption

        DispatchQueue.global(qos: .userInitiated).async {
            let fresh = PromiFieldLayoutFactory.make(
                theme: capturedTheme,
                mood: capturedMood,
                size: capturedSize,
                promis: capturedPromis,
                sortOption: capturedSortOption
            )
            DispatchQueue.main.async {
                // @State is read through live storage even when self is
                // captured by value, so this correctly detects if a newer
                // regeneration has happened in the meantime and discards
                // this stale result.
                guard self.dispatchGeneration == myGeneration else { return }
                self.cachedLayout = fresh
                self.cachedKey = newKey
            }
        }
    }

    @ViewBuilder
    private func cellView(for cell: PromiFieldCell) -> some View {
        let shape = PromiFieldPolygonShape(
            points: cell.points,
            softness: PromiFieldThemeConfig.polygonSoftness(for: theme)
        )

        if let promi = cell.promotedPromi {
            Button(action: {
                Haptics.shared.lightTap()
                onTapPromi(promi)
            }) {
                shape
                    .fill(cell.fillStyle)
                    .overlay(shape.stroke(cell.strokeColor, style: cell.strokeStyle))
                    .overlay(
                        PromiCellCenteredLabelView(
                            promi: promi,
                            languageCode: languageCode,
                            frame: cell.visibleBounds,
                            textMode: cell.textMode
                        )
                    )
            }
            .buttonStyle(.plain)
        } else {
            shape
                .fill(cell.fillStyle)
                .overlay(shape.stroke(cell.strokeColor, style: cell.strokeStyle))
        }
    }
}

// MARK: - Cristal nested underlay (fine sub-pavage tiling the full plane)

fileprivate struct CristalNestedUnderlay: View {
    let subCells: [CristalSubCell]
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            // Draw every sub-cell in one flat pass. No clipping — the sub-cells
            // tile the plane continuously and the thick black borders of the
            // outer compartments drawn above (in the main ZStack cells loop)
            // visually separate the regions. This avoids the "orphan zones"
            // bug caused by per-parent grouping where sub-cells whose centroids
            // lie in compartment A but extend into B left gaps in B.
            for subCell in subCells {
                let path = makePath(points: subCell.points)
                context.fill(path, with: .color(subCell.color))
                context.stroke(
                    path,
                    with: .color(.black.opacity(0.38)),
                    lineWidth: 0.5
                )
            }
        }
        .frame(width: max(size.width, 1), height: max(size.height, 1))
        .allowsHitTesting(false)
    }

    private func makePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for p in points.dropFirst() {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Layout model

fileprivate struct PromiFieldLayout {
    let cells: [PromiFieldCell]
    let nestedSubCells: [CristalSubCell]?
    let fieldScale: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
}

fileprivate struct CristalSubCell {
    let points: [CGPoint]
    let color: Color
}

fileprivate struct PromiFieldCell: Identifiable {
    let id: UUID
    let points: [CGPoint]
    let visibleBounds: CGRect
    let promotedPromi: PromiItem?
    let fillStyle: AnyShapeStyle
    let strokeColor: Color
    let strokeStyle: StrokeStyle
    let textMode: PromiTextMode
}

fileprivate enum PromiFieldTheme: String {
    case galets
    case alveoles
    case cristal
    case mosaic
    case spectrum

    var id: String { rawValue }
}

fileprivate enum PromiTextMode {
    case lightCentered
    case darkCentered
}

// MARK: - Theme config

fileprivate enum PromiFieldThemeConfig {
    static func polygonSoftness(for theme: PromiFieldTheme) -> CGFloat {
        switch theme {
        case .galets: return 58
        case .alveoles: return 14
        case .cristal: return 0
        case .mosaic: return 4
        case .spectrum: return 1
        }
    }

    static func strokeWidth(for theme: PromiFieldTheme) -> CGFloat {
        switch theme {
        case .galets: return 0.0
        case .alveoles: return 6.0
        case .cristal: return 4.0
        case .mosaic: return 2.1
        case .spectrum: return 0.55
        }
    }

    static func strokeColor(for theme: PromiFieldTheme, mood: PromiColorMood) -> Color {
        switch theme {
        case .galets:
            // Pas de stroke visible — les galets sont des couleurs solides.
            return Color.clear

        case .alveoles:
            return mood.prefersDarkChrome ? Color.white.opacity(0.96) : Color.white.opacity(0.94)

        case .cristal:
            // Bordures noires pures, identité Cristal.
            return Color.black.opacity(0.92)

        case .mosaic:
            return mood.prefersDarkChrome ? Color.white.opacity(0.26) : Color(red: 0.08, green: 0.12, blue: 0.24).opacity(0.82)

        case .spectrum:
            return mood.prefersDarkChrome ? Color.white.opacity(0.10) : Color.white.opacity(0.06)
        }
    }

    static func textMode(for theme: PromiFieldTheme, mood: PromiColorMood) -> PromiTextMode {
        mood.prefersDarkChrome ? .lightCentered : .darkCentered
    }

    static func baseSiteCount(for theme: PromiFieldTheme, size: CGSize, promiCount: Int) -> Int {
        let area = max(size.width * size.height, 1)
        let density = Int(area / 22_000)

        switch theme {
        case .galets:
            // Quasi-grid layout: lower count for breathing room, grows with promises.
            return min(28, max(15, 18 + promiCount))
        case .alveoles:
            return min(70, max(26, density + 14 + promiCount))
        case .cristal:
            // Scale with area: ~14 outer compartments in Studio preview cards,
            // ~38-44 in full-screen home. Keeps the Studio from freezing the
            // main thread while preserving the density on the home view.
            let scaled = Int(area / 15_000)
            return min(44, max(14, scaled + 12 + promiCount / 2))
        case .mosaic:
            return min(62, max(24, density + 12 + promiCount))
        case .spectrum:
            return min(94, max(38, density + 24 + promiCount * 2))
        }
    }

    static func lloydIterations(for theme: PromiFieldTheme) -> Int {
        switch theme {
        case .galets: return 0
        case .alveoles: return 2
        case .cristal: return 0
        case .mosaic: return 1
        case .spectrum: return 1
        }
    }
}

// MARK: - Layout factory

fileprivate enum PromiFieldLayoutFactory {
    static func make(
        theme: PromiFieldTheme,
        mood: PromiColorMood,
        size: CGSize,
        promis: [PromiItem],
        sortOption: PromiFieldSortOption
    ) -> PromiFieldLayout {
        let safeSize = CGSize(width: max(size.width, 1), height: max(size.height, 1))
        let siteCount = PromiFieldThemeConfig.baseSiteCount(
            for: theme,
            size: safeSize,
            promiCount: promis.count
        )

        let overscanX: CGFloat = theme == .spectrum ? 90 : 54
        let overscanYTop: CGFloat = 36
        let overscanYBottom: CGFloat = 120

        let bounds = CGRect(
            x: -overscanX,
            y: -overscanYTop,
            width: safeSize.width + overscanX * 2,
            height: safeSize.height + overscanYTop + overscanYBottom
        )

        let baseSites = makeStableSites(theme: theme, size: safeSize, count: siteCount)
        let weights = makeWeights(
            theme: theme,
            sites: baseSites,
            size: safeSize,
            promis: promis,
            sortOption: sortOption
        )

        var weightedSites = zip(baseSites, weights).map { WeightedSite(point: $0.0, weight: $0.1) }

        for _ in 0..<PromiFieldThemeConfig.lloydIterations(for: theme) {
            let moved = weightedSites.enumerated().map { index, site -> CGPoint in
                let polygon = VoronoiMath.weightedCellPolygon(index: index, sites: weightedSites, bounds: bounds)
                let centroid = polygonCentroid(for: polygon)
                let fallback = centroid == .zero ? site.point : centroid
                return clampPoint(fallback, to: bounds)
            }

            weightedSites = weightedSites.enumerated().map { index, site in
                WeightedSite(point: moved[index], weight: site.weight)
            }
        }

        let polygons = weightedSites.enumerated().map { index, _ in
            VoronoiMath.weightedCellPolygon(index: index, sites: weightedSites, bounds: bounds)
        }

        let adjacency = buildAdjacency(polygons: polygons)

        let promotedMap = assignPromisToCells(
            polygons: polygons,
            size: safeSize,
            promis: promis,
            sortOption: sortOption
        )

        let idleIndices = makeIdlePaletteIndices(
            theme: theme,
            adjacency: adjacency,
            polygons: polygons,
            size: safeSize,
            promotedSet: Set(promotedMap.keys)
        )

        let idleStyles = makeIdleStyles(
            theme: theme,
            mood: mood,
            indices: idleIndices,
            polygons: polygons,
            size: safeSize
        )

        let promotedStyles = makePromotedStyles(
            theme: theme,
            mood: mood,
            idleIndices: idleIndices,
            promotedMap: promotedMap
        )

        let viewport = CGRect(origin: .zero, size: safeSize)
        let textMode = PromiFieldThemeConfig.textMode(for: theme, mood: mood)
        let strokeColor = PromiFieldThemeConfig.strokeColor(for: theme, mood: mood)
        let strokeWidth = PromiFieldThemeConfig.strokeWidth(for: theme)

        let strokeStyle = StrokeStyle(
            lineWidth: strokeWidth,
            lineCap: .round,
            lineJoin: .round
        )

        var cells = polygons.enumerated().map { index, polygon -> PromiFieldCell in
            let promoted = promotedMap[index]
            let fill: AnyShapeStyle = promoted != nil
                ? (promotedStyles[index] ?? AnyShapeStyle(Color.orange))
                : idleStyles[index]

            return PromiFieldCell(
                id: deterministicUUID(for: index),
                points: polygon,
                visibleBounds: visibleBoundingBox(for: polygon, viewport: viewport),
                promotedPromi: promoted,
                fillStyle: fill,
                strokeColor: strokeColor,
                strokeStyle: strokeStyle,
                textMode: textMode
            )
        }

        // Galets pack: place a black anchor on the idle cell whose centroid
        // is closest to the viewport centre. Mirrors the central black circle
        // présent dans chaque slide d'onboarding — le repère signature.
        if theme == .galets {
            let center = CGPoint(x: viewport.midX, y: viewport.midY)

            let anchorIndex = cells.indices
                .filter { cells[$0].promotedPromi == nil }
                .min(by: { lhs, rhs in
                    let lc = polygonCentroid(for: cells[lhs].points)
                    let rc = polygonCentroid(for: cells[rhs].points)
                    let dl = hypot(lc.x - center.x, lc.y - center.y)
                    let dr = hypot(rc.x - center.x, rc.y - center.y)
                    return dl < dr
                })

            if let idx = anchorIndex {
                let original = cells[idx]
                let anchor = galetsAnchorColor(for: mood)
                cells[idx] = PromiFieldCell(
                    id: original.id,
                    points: original.points,
                    visibleBounds: original.visibleBounds,
                    promotedPromi: nil,
                    fillStyle: AnyShapeStyle(anchor),
                    strokeColor: original.strokeColor,
                    strokeStyle: original.strokeStyle,
                    textMode: original.textMode
                )
            }
        }

        // Cristal pack: outer compartments become stroke-only frames (transparent
        // fill) so the fine sub-pavage rendered underneath shows through. The
        // nested sub-cells are computed once as a flat list — no per-compartment
        // grouping, no clipping. Sub-cells tile the plane globally and the
        // thick black borders of the outer compartments drawn above visually
        // separate the regions.
        var nestedSubCells: [CristalSubCell]? = nil
        if theme == .cristal {
            cells = cells.map { cell in
                PromiFieldCell(
                    id: cell.id,
                    points: cell.points,
                    visibleBounds: cell.visibleBounds,
                    promotedPromi: cell.promotedPromi,
                    fillStyle: AnyShapeStyle(Color.clear),
                    strokeColor: cell.strokeColor,
                    strokeStyle: cell.strokeStyle,
                    textMode: cell.textMode
                )
            }

            nestedSubCells = computeCristalNested(
                outerSites: weightedSites.map(\.point),
                bounds: bounds,
                idleIndices: idleIndices,
                mood: mood,
                seed: seedBase(for: theme),
                fineCount: Int(max(200, min(6000, safeSize.width * safeSize.height / 55)))
            )
        }

        // Smart dezoom: ensure every promoted cell is visible in viewport.
        let (fieldScale, offsetX, offsetY) = computeFitTransform(
            promotedPolygons: promotedMap.keys.sorted().compactMap { polygons.indices.contains($0) ? polygons[$0] : nil },
            viewport: viewport
        )

        return PromiFieldLayout(
            cells: cells,
            nestedSubCells: nestedSubCells,
            fieldScale: fieldScale,
            offsetX: offsetX,
            offsetY: offsetY
        )
    }

    // MARK: - Fit transform (smart dezoom)

    private static func computeFitTransform(
        promotedPolygons: [[CGPoint]],
        viewport: CGRect
    ) -> (scale: CGFloat, offsetX: CGFloat, offsetY: CGFloat) {
        guard !promotedPolygons.isEmpty else { return (1.0, 0, 0) }

        let boxes = promotedPolygons.map { polygonBoundingBox(for: $0) }
        guard let first = boxes.first else { return (1.0, 0, 0) }

        var combined = first
        for box in boxes.dropFirst() {
            combined = combined.union(box)
        }

        let margin: CGFloat = 0.08
        let targetWidth = viewport.width * (1 - margin * 2)
        let targetHeight = viewport.height * (1 - margin * 2)

        let scaleX = targetWidth / max(combined.width, 1)
        let scaleY = targetHeight / max(combined.height, 1)
        let fitScale = min(scaleX, scaleY)

        // Never scale UP beyond 1.0 (no forced zoom in).
        // Floor at 0.55 to avoid absurd shrinkage on extreme overflow.
        let scale = min(1.0, max(0.55, fitScale))

        // Center the combined box inside the viewport after scaling.
        let offsetX = (viewport.midX - combined.midX) * scale
        let offsetY = (viewport.midY - combined.midY) * scale

        return (scale, offsetX, offsetY)
    }

    // MARK: - Sites

    private static func deterministicUUID(for index: Int) -> UUID {
        UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", index + 1))") ?? UUID()
    }

    private static func makeStableSites(theme: PromiFieldTheme, size: CGSize, count: Int) -> [CGPoint] {
        let seed = seedBase(for: theme)

        switch theme {
        case .galets:
            // Quasi-grid placement → roughly rectangular Voronoi cells matching the
            // identité Galets (rectangles arrondis, asymétrie composée).
            return makeGaletsGridSites(size: size, count: count, seed: seed)

        case .alveoles:
            return (0..<count).map { index in
                let x = randomUnit(seed: seed, index: index, stream: 11)
                let y = randomUnit(seed: seed, index: index, stream: 27)
                return CGPoint(
                    x: size.width * CGFloat(0.02 + x * 0.96),
                    y: size.height * CGFloat(0.02 + y * 0.96)
                )
            }

        case .mosaic:
            return (0..<count).map { index in
                let x = randomUnit(seed: seed, index: index, stream: 19)
                let y = randomUnit(seed: seed, index: index, stream: 31)
                return CGPoint(
                    x: size.width * CGFloat(-0.02 + x * 1.04),
                    y: size.height * CGFloat(-0.02 + y * 1.04)
                )
            }

        case .cristal:
            // Densité élevée, dispersion fluide hors-cadre légère.
            return (0..<count).map { index in
                let x = randomUnit(seed: seed, index: index, stream: 61)
                let y = randomUnit(seed: seed, index: index, stream: 73)
                return CGPoint(
                    x: size.width * CGFloat(-0.06 + x * 1.12),
                    y: size.height * CGFloat(-0.04 + y * 1.08)
                )
            }

        case .spectrum:
            return (0..<count).map { index in
                let x = randomUnit(seed: seed, index: index, stream: 41)
                let y = randomUnit(seed: seed, index: index, stream: 53)
                return CGPoint(
                    x: size.width * CGFloat(-0.10 + x * 1.20),
                    y: size.height * CGFloat(-0.08 + y * 1.18)
                )
            }
        }
    }

    /// Quasi-grid placement that produces roughly rectangular Voronoi cells.
    /// Utilisé par le pack Galets pour reproduire les rectangles arrondis
    /// du langage formel hérité des slides d'onboarding.
    private static func makeGaletsGridSites(size: CGSize, count: Int, seed: UInt64) -> [CGPoint] {
        let aspect = max(0.35, min(2.5, size.width / size.height))

        // Choose cols/rows so cells are roughly square on the current viewport.
        // For iPhone portrait (aspect ≈ 0.46), this gives 3 cols × 5-7 rows.
        var cols = max(2, Int((Double(count).squareRoot() * sqrt(Double(aspect))).rounded()))
        if cols < 2 { cols = 2 }
        var rows = max(2, Int((Double(count) / Double(cols)).rounded(.up)))
        if rows < 2 { rows = 2 }

        // Bleed slightly off-screen so edge cells aren't truncated awkwardly.
        let bleedX: CGFloat = 0.06
        let bleedY: CGFloat = 0.04
        let regionWidth = size.width * (1 + bleedX * 2)
        let regionHeight = size.height * (1 + bleedY * 2)
        let originX = -size.width * bleedX
        let originY = -size.height * bleedY

        let cellW = regionWidth / CGFloat(cols)
        let cellH = regionHeight / CGFloat(rows)

        var sites: [CGPoint] = []
        let total = cols * rows
        let actualCount = min(count, total)

        for index in 0..<actualCount {
            let r = index / cols
            let c = index % cols

            let baseX = originX + (CGFloat(c) + 0.5) * cellW
            let baseY = originY + (CGFloat(r) + 0.5) * cellH

            // Jitter ≤ ±42% of cell size — keeps the grid feel while breaking
            // the perfect uniformity for an organic-but-structured composition.
            let jitterX = (randomUnit(seed: seed, index: index, stream: 71) - 0.5) * cellW * 0.42
            let jitterY = (randomUnit(seed: seed, index: index, stream: 79) - 0.5) * cellH * 0.42

            sites.append(CGPoint(x: baseX + jitterX, y: baseY + jitterY))
        }

        return sites
    }

    private static func makeWeights(
        theme: PromiFieldTheme,
        sites: [CGPoint],
        size: CGSize,
        promis: [PromiItem],
        sortOption: PromiFieldSortOption
    ) -> [CGFloat] {
        let target = preferredTarget(for: sortOption, size: size)
        let maxDistance = max(hypot(size.width, size.height), 1)
        let sortedPromis = sortPromis(promis, by: sortOption)
        let rankedSiteIndices = rankedIndicesClosestTo(
            points: sites,
            target: target,
            count: min(sortedPromis.count, sites.count)
        )

        return sites.enumerated().map { index, point in
            let distanceFactor = hypot(point.x - target.x, point.y - target.y) / maxDistance
            let closeness = max(0, 1 - distanceFactor * 1.45)
            var weight = CGFloat(23_000 + closeness * 9_400)

            if let rank = rankedSiteIndices.firstIndex(of: index), rank < sortedPromis.count {
                weight += CGFloat(max(1, sortedPromis[rank].intensity)) * 310
            }

            switch theme {
            case .galets:
                // Low variation: keep cells close to grid uniform.
                weight += CGFloat((index % 4) * 220)
            case .alveoles:
                weight += CGFloat((index % 5) * 980)
            case .cristal:
                // Strong size variation → compartments of radically varied sizes.
                weight += CGFloat((index % 7) * 2_200)
            case .mosaic:
                weight += CGFloat((index % 4) * 720)
            case .spectrum:
                weight += CGFloat((index % 7) * 520)
            }

            return weight
        }
    }

    private static func preferredTarget(for sortOption: PromiFieldSortOption, size: CGSize) -> CGPoint {
        switch sortOption {
        case .date:
            return CGPoint(x: size.width * 0.46, y: size.height * 0.28)
        case .urgency:
            return CGPoint(x: size.width * 0.50, y: size.height * 0.24)
        case .person:
            return CGPoint(x: size.width * 0.26, y: size.height * 0.48)
        case .importance:
            return CGPoint(x: size.width * 0.50, y: size.height * 0.38)
        case .inspiration:
            return CGPoint(x: size.width * 0.52, y: size.height * 0.50)
        }
    }

    // MARK: - Adjacency

    private static func buildAdjacency(polygons: [[CGPoint]]) -> [[Int]] {
        var result = Array(repeating: [Int](), count: polygons.count)

        for i in polygons.indices {
            for j in polygons.indices where j > i {
                if polygonsShareBoundary(polygons[i], polygons[j]) {
                    result[i].append(j)
                    result[j].append(i)
                }
            }
        }
        return result
    }

    private static func polygonsShareBoundary(_ a: [CGPoint], _ b: [CGPoint]) -> Bool {
        let boxA = polygonBoundingBox(for: a).insetBy(dx: -3, dy: -3)
        let boxB = polygonBoundingBox(for: b)
        guard boxA.intersects(boxB) else { return false }

        var shared = 0

        for pa in a {
            for pb in b {
                if hypot(pa.x - pb.x, pa.y - pb.y) < 9 {
                    shared += 1
                    if shared >= 2 { return true }
                }
            }
        }

        return false
    }

    // MARK: - Promi attribution

    private static func assignPromisToCells(
        polygons: [[CGPoint]],
        size: CGSize,
        promis: [PromiItem],
        sortOption: PromiFieldSortOption
    ) -> [Int: PromiItem] {
        guard !promis.isEmpty else { return [:] }

        let viewport = CGRect(origin: .zero, size: size)
        let sorted = sortPromis(promis, by: sortOption)

        let rankedCellIndices: [Int]

        switch sortOption {
        case .date:
            rankedCellIndices = polygons.enumerated()
                .sorted { lhs, rhs in
                    let l = visibleBoundingBox(for: lhs.element, viewport: viewport)
                    let r = visibleBoundingBox(for: rhs.element, viewport: viewport)
                    if abs(l.midY - r.midY) > 8 { return l.midY < r.midY }
                    if abs(l.midX - r.midX) > 8 { return l.midX < r.midX }
                    return l.width * l.height > r.width * r.height
                }
                .map(\.offset)

        case .urgency:
            rankedCellIndices = rankedCellsForTarget(
                polygons: polygons,
                viewport: viewport,
                target: CGPoint(x: size.width * 0.50, y: size.height * 0.24)
            )

        case .person:
            rankedCellIndices = polygons.enumerated()
                .sorted { lhs, rhs in
                    let l = visibleBoundingBox(for: lhs.element, viewport: viewport)
                    let r = visibleBoundingBox(for: rhs.element, viewport: viewport)
                    if abs(l.midX - r.midX) > 8 { return l.midX < r.midX }
                    if abs(l.midY - r.midY) > 8 { return l.midY < r.midY }
                    return l.width * l.height > r.width * r.height
                }
                .map(\.offset)

        case .importance:
            rankedCellIndices = rankedCellsForTarget(
                polygons: polygons,
                viewport: viewport,
                target: CGPoint(x: size.width * 0.50, y: size.height * 0.38)
            )

        case .inspiration:
            rankedCellIndices = polygons.enumerated()
                .sorted { lhs, rhs in
                    let l = visibleBoundingBox(for: lhs.element, viewport: viewport)
                    let r = visibleBoundingBox(for: rhs.element, viewport: viewport)
                    let areaL = l.width * l.height
                    let areaR = r.width * r.height
                    if abs(areaL - areaR) > 900 { return areaL > areaR }
                    return lhs.offset < rhs.offset
                }
                .map(\.offset)
        }

        var result: [Int: PromiItem] = [:]
        for (offset, promi) in sorted.enumerated() where offset < rankedCellIndices.count {
            result[rankedCellIndices[offset]] = promi
        }
        return result
    }

    private static func rankedCellsForTarget(
        polygons: [[CGPoint]],
        viewport: CGRect,
        target: CGPoint
    ) -> [Int] {
        polygons.enumerated()
            .sorted { lhs, rhs in
                let l = visibleBoundingBox(for: lhs.element, viewport: viewport)
                let r = visibleBoundingBox(for: rhs.element, viewport: viewport)

                let areaL = max(l.width * l.height, 1)
                let areaR = max(r.width * r.height, 1)

                let visibleL = areaL * visibilityScore(for: l, viewport: viewport)
                let visibleR = areaR * visibilityScore(for: r, viewport: viewport)

                let dl = hypot(l.midX - target.x, l.midY - target.y)
                let dr = hypot(r.midX - target.x, r.midY - target.y)

                let scoreL = visibleL - dl * 150
                let scoreR = visibleR - dr * 150

                if abs(scoreL - scoreR) > 800 {
                    return scoreL > scoreR
                }

                return dl < dr
            }
            .map(\.offset)
    }

    // MARK: - Idle palette indices (hardened adjacency)

    private static func makeIdlePaletteIndices(
        theme: PromiFieldTheme,
        adjacency: [[Int]],
        polygons: [[CGPoint]],
        size: CGSize,
        promotedSet: Set<Int>
    ) -> [Int] {
        let paletteSize: Int
        switch theme {
        case .galets, .alveoles, .mosaic, .cristal:
            paletteSize = 5
        case .spectrum:
            paletteSize = max(5, min(9, 7))
        }

        if theme == .spectrum {
            return assignSpectrumIndices(
                adjacency: adjacency,
                polygons: polygons,
                size: size,
                paletteCount: paletteSize
            )
        }

        // Graph-coloring greedy: assign a palette index that no neighbor already uses.
        var result = Array(repeating: -1, count: adjacency.count)

        // Process promoted-adjacent cells last so idle cells don't lock palette slots
        // that promoted cells need their neighbors to avoid.
        let orderedIndices = adjacency.indices.sorted { lhs, rhs in
            let lhsAdjPromoted = adjacency[lhs].contains(where: { promotedSet.contains($0) })
            let rhsAdjPromoted = adjacency[rhs].contains(where: { promotedSet.contains($0) })
            if lhsAdjPromoted != rhsAdjPromoted { return !lhsAdjPromoted }
            return lhs < rhs
        }

        for index in orderedIndices {
            let usedByNeighbors = Set(adjacency[index].compactMap { neighbor -> Int? in
                let value = result[neighbor]
                return value >= 0 ? value : nil
            })

            var chosen = -1
            for candidate in 0..<paletteSize where !usedByNeighbors.contains(candidate) {
                chosen = candidate
                break
            }
            if chosen < 0 { chosen = index % paletteSize }
            result[index] = chosen
        }

        return result
    }

    // MARK: - Idle styles

    private static func makeIdleStyles(
        theme: PromiFieldTheme,
        mood: PromiColorMood,
        indices: [Int],
        polygons: [[CGPoint]],
        size: CGSize
    ) -> [AnyShapeStyle] {
        switch theme {
        case .galets, .alveoles, .mosaic, .cristal:
            let palette = themedPalette(for: theme, mood: mood)
            return indices.map { idx in
                AnyShapeStyle(palette[idx % palette.count])
            }

        case .spectrum:
            return indices.map { idx in
                spectrumGradientStyle(mood: mood, index: idx)
            }
        }
    }

    // MARK: - Promoted styles
    //
    // Architecture clé : les Promi promues utilisent la MÊME palette que les
    // cellules idle. Le graph-coloring de makeIdlePaletteIndices a déjà attribué
    // un index à chaque cellule (y compris les promues) en garantissant qu'aucun
    // voisin direct n'a la même couleur. On reprend simplement cet index : la
    // Promi se fond dans l'univers visuel signature, et c'est sa TAILLE
    // (poids Voronoï) qui la distingue, pas sa couleur.

    private static func makePromotedStyles(
        theme: PromiFieldTheme,
        mood: PromiColorMood,
        idleIndices: [Int],
        promotedMap: [Int: PromiItem]
    ) -> [Int: AnyShapeStyle] {
        switch theme {
        case .galets, .alveoles, .mosaic, .cristal:
            let palette = themedPalette(for: theme, mood: mood)
            guard !palette.isEmpty else { return [:] }

            var result: [Int: AnyShapeStyle] = [:]
            for index in promotedMap.keys {
                let raw = idleIndices.indices.contains(index) ? idleIndices[index] : index
                let safe = ((raw % palette.count) + palette.count) % palette.count
                result[index] = AnyShapeStyle(palette[safe])
            }
            return result

        case .spectrum:
            // Spectrum : les promues utilisent un dégradé du même mood que les idle.
            var result: [Int: AnyShapeStyle] = [:]
            for index in promotedMap.keys {
                let raw = idleIndices.indices.contains(index) ? idleIndices[index] : index
                result[index] = spectrumGradientStyle(mood: mood, index: raw)
            }
            return result
        }
    }

    // MARK: - Spectrum assignment

    private static func assignSpectrumIndices(
        adjacency: [[Int]],
        polygons: [[CGPoint]],
        size: CGSize,
        paletteCount: Int
    ) -> [Int] {
        var result = Array(repeating: 0, count: polygons.count)

        let ordered = polygons.enumerated()
            .sorted { lhs, rhs in
                let l = polygonBoundingBox(for: lhs.element)
                let r = polygonBoundingBox(for: rhs.element)
                if abs(l.midX - r.midX) > 12 { return l.midX < r.midX }
                return l.midY < r.midY
            }
            .map(\.offset)

        for index in ordered {
            let box = polygonBoundingBox(for: polygons[index])
            let x = max(0, min(1, box.midX / max(size.width, 1)))
            let y = max(0, min(1, box.midY / max(size.height, 1)))
            let preferred = preferredSpectrumIndex(x: x, y: y, paletteCount: paletteCount)

            let used = Set(adjacency[index].map { result[$0] })
            if !used.contains(preferred) {
                result[index] = preferred
            } else {
                let candidates = [
                    (preferred + 1) % paletteCount,
                    (preferred + 2) % paletteCount,
                    (preferred - 1 + paletteCount) % paletteCount,
                    (preferred + 3) % paletteCount,
                    (preferred - 2 + paletteCount) % paletteCount
                ]
                result[index] = candidates.first(where: { !used.contains($0) }) ?? preferred
            }
        }

        return result
    }

    private static func preferredSpectrumIndex(x: CGFloat, y: CGFloat, paletteCount: Int) -> Int {
        guard paletteCount > 0 else { return 0 }

        if x < 0.16 && y < 0.26 { return 0 % paletteCount }
        if x < 0.24 { return 1 % paletteCount }
        if x < 0.36 { return (y < 0.62 ? 2 : 3) % paletteCount }
        if x < 0.52 { return (y < 0.56 ? 3 : 4) % paletteCount }
        if x < 0.70 { return (y < 0.56 ? 5 : 6) % paletteCount }
        if x < 0.84 { return (y < 0.56 ? 6 : 7) % paletteCount }
        return (y < 0.58 ? 7 : 8) % paletteCount
    }

    // MARK: - Helpers

    private static func rankedIndicesClosestTo(points: [CGPoint], target: CGPoint, count: Int) -> [Int] {
        Array(
            points.enumerated()
                .sorted { lhs, rhs in
                    let dl = hypot(lhs.element.x - target.x, lhs.element.y - target.y)
                    let dr = hypot(rhs.element.x - target.x, rhs.element.y - target.y)
                    return dl < dr
                }
                .map(\.offset)
                .prefix(count)
        )
    }

    private static func visibilityScore(for box: CGRect, viewport: CGRect) -> CGFloat {
        let intersection = box.intersection(viewport)
        guard !intersection.isNull else { return 0 }
        let visible = max(intersection.width * intersection.height, 1)
        let total = max(box.width * box.height, 1)
        return visible / total
    }

    private static func sortPromis(_ promis: [PromiItem], by option: PromiFieldSortOption) -> [PromiItem] {
        switch option {
        case .date:
            return promis.sorted { $0.dueDate < $1.dueDate }

        case .urgency:
            let now = Date()
            return promis.sorted {
                abs($0.dueDate.timeIntervalSince(now)) < abs($1.dueDate.timeIntervalSince(now))
            }

        case .person:
            return promis.sorted {
                let lhs = ($0.assignee ?? "").localizedLowercase
                let rhs = ($1.assignee ?? "").localizedLowercase
                if lhs == rhs {
                    return $0.createdAt < $1.createdAt
                }
                return lhs < rhs
            }

        case .importance:
            return promis.sorted {
                if $0.intensity == $1.intensity {
                    return $0.createdAt < $1.createdAt
                }
                return $0.intensity > $1.intensity
            }

        case .inspiration:
            return promis.sorted { lhs, rhs in
                stablePromiRank(lhs) < stablePromiRank(rhs)
            }
        }
    }

    private static func stablePromiRank(_ promi: PromiItem) -> Int {
        var hasher = Hasher()
        hasher.combine(promi.id)
        hasher.combine(promi.createdAt.timeIntervalSinceReferenceDate)
        return abs(hasher.finalize())
    }

    // MARK: - Cristal nested sub-pavage
    //
    // Generates a fine Voronoi sub-pavage (~280 cells) over the same bounds
    // as the outer compartments, then assigns each fine cell to its parent
    // outer compartment by closest-site test. The color of each fine cell is
    // pulled from the parent's palette slot with a per-cell lightness variation
    // to produce the watercolor / stained-glass texture.

    private static func computeCristalNested(
        outerSites: [CGPoint],
        bounds: CGRect,
        idleIndices: [Int],
        mood: PromiColorMood,
        seed: UInt64,
        fineCount: Int
    ) -> [CristalSubCell] {
        let palette = cristalThemedPalette(mood: mood)
        guard !palette.isEmpty, !outerSites.isEmpty else { return [] }

        let fineSeed = seed &+ 9_001

        // Uniform random distribution, uniform weights. Voronoi cells from
        // a uniform random point set naturally vary ±30% in size — enough
        // organic feel without creating giant cells that leave gaps.
        let fineSites: [WeightedSite] = (0..<fineCount).map { idx in
            let x = randomUnit(seed: fineSeed, index: idx, stream: 137)
            let y = randomUnit(seed: fineSeed, index: idx, stream: 211)
            let point = CGPoint(
                x: bounds.minX + CGFloat(x) * bounds.width,
                y: bounds.minY + CGFloat(y) * bounds.height
            )
            return WeightedSite(point: point, weight: 22_000)
        }

        let finePolygons = fineSites.enumerated().map { index, _ in
            VoronoiMath.weightedCellPolygon(
                index: index,
                sites: fineSites,
                bounds: bounds
            )
        }

        // Flat list: each fine cell stores its polygon and the color derived
        // from its closest outer compartment. No grouping, no clipping —
        // sub-cells tile the plane globally, the thick black borders of the
        // outer compartments drawn above will visually separate the regions.
        var result: [CristalSubCell] = []
        result.reserveCapacity(finePolygons.count)

        for (fineIdx, finePolygon) in finePolygons.enumerated() {
            guard !finePolygon.isEmpty else { continue }
            let centroid = polygonCentroid(for: finePolygon)
            guard centroid != .zero else { continue }

            var bestIdx = 0
            var bestDist = CGFloat.greatestFiniteMagnitude
            for (oIdx, oSite) in outerSites.enumerated() {
                let dx = centroid.x - oSite.x
                let dy = centroid.y - oSite.y
                let d = dx * dx + dy * dy
                if d < bestDist {
                    bestDist = d
                    bestIdx = oIdx
                }
            }

            let paletteSlot: Int = {
                if idleIndices.indices.contains(bestIdx) {
                    return idleIndices[bestIdx]
                }
                return bestIdx
            }()
            let safeSlot = ((paletteSlot % palette.count) + palette.count) % palette.count
            let baseColor = palette[safeSlot]

            // Strong HSB variation for the watercolor texture: lightness ±27%,
            // saturation ±18%. Each sub-cell has its own tonal identity within
            // the compartment's color family.
            let rawL = randomUnit(seed: fineSeed &+ 7_777, index: fineIdx, stream: 333)
            let rawS = randomUnit(seed: fineSeed &+ 8_888, index: fineIdx, stream: 444)
            let lightnessDelta = CGFloat(rawL - 0.5) * 0.54
            let saturationDelta = CGFloat(rawS - 0.5) * 0.36
            let varied = adjustColor(
                baseColor,
                lightness: lightnessDelta,
                saturation: saturationDelta
            )

            result.append(CristalSubCell(points: finePolygon, color: varied))
        }

        return result
    }

    /// Adjusts a color's lightness and saturation using HSB decomposition.
    /// `lightness` and `saturation` are deltas in [-1, 1] applied multiplicatively
    /// to the brightness and saturation components respectively.
    private static func adjustColor(
        _ color: Color,
        lightness: CGFloat,
        saturation: CGFloat
    ) -> Color {
        let ui = UIColor(color)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        let nb = min(max(b * (1 + lightness), 0), 1)
        let ns = min(max(s * (1 + saturation), 0), 1)

        return Color(
            hue: Double(h),
            saturation: Double(ns),
            brightness: Double(nb),
            opacity: Double(a)
        )
    }

    private static func adjustLightness(_ color: Color, by amount: CGFloat) -> Color {
        adjustColor(color, lightness: amount, saturation: 0)
    }

    private static func seedBase(for theme: PromiFieldTheme) -> UInt64 {
        switch theme {
        case .galets: return 87_101
        case .alveoles: return 11_731
        case .cristal: return 53_281
        case .mosaic: return 23_921
        case .spectrum: return 41_113
        }
    }

    private static func randomUnit(seed: UInt64, index: Int, stream: UInt64) -> Double {
        var z = seed &+ UInt64(index &* 7919) &+ stream &* 0x9E3779B97F4A7C15
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return Double(z) / Double(UInt64.max)
    }

    // MARK: - Palettes (per-mood, per-theme, hand-tuned for native combos)
    //
    // Philosophy: the 9 native pack×mood combinations (per PaletteView sections)
    // carry the full Promi identity and must be hand-tuned. Non-native combos
    // fall back to a gentle tonalShift on the base palette for graceful degrade.

    private static func themedPalette(for theme: PromiFieldTheme, mood: PromiColorMood) -> [Color] {
        switch theme {
        case .galets:
            return galetsThemedPalette(mood: mood)
        case .alveoles:
            return alveolesThemedPalette(mood: mood)
        case .cristal:
            return cristalThemedPalette(mood: mood)
        case .mosaic:
            return mosaicThemedPalette(mood: mood)
        case .spectrum:
            // Spectrum uses gradients derived from swatches; palette not used directly.
            return moodBasePalette(for: mood)
        }
    }

    // MARK: Cristal — tessellation dense, pastels d'aquarelle, bordures noires
    //
    // 3 moods radicalement distincts : pastels d'aube, sous-bois forestier,
    // néons électriques. Aucune couleur partagée avec les autres packs.

    private static func cristalThemedPalette(mood: PromiColorMood) -> [Color] {
        switch mood {
        case .auroreFraise:
            // Pastels d'aube : pêche, saumon, ciel pastel, menthe pastel, beurre.
            return [
                Color(red: 0.98, green: 0.78, blue: 0.66),
                Color(red: 0.96, green: 0.62, blue: 0.58),
                Color(red: 0.74, green: 0.86, blue: 0.94),
                Color(red: 0.78, green: 0.88, blue: 0.78),
                Color(red: 0.98, green: 0.92, blue: 0.74)
            ]

        case .foretSousBois:
            // Verts profonds, mousse, écorce, champignon.
            return [
                Color(red: 0.30, green: 0.45, blue: 0.28),
                Color(red: 0.20, green: 0.40, blue: 0.30),
                Color(red: 0.55, green: 0.62, blue: 0.40),
                Color(red: 0.36, green: 0.26, blue: 0.18),
                Color(red: 0.78, green: 0.54, blue: 0.44)
            ]

        case .neonMidi:
            // Néons électriques sur nuit absolue.
            return [
                Color(red: 0.96, green: 0.22, blue: 0.62),
                Color(red: 0.20, green: 0.86, blue: 0.92),
                Color(red: 0.66, green: 0.96, blue: 0.30),
                Color(red: 0.30, green: 0.20, blue: 0.86),
                Color(red: 0.98, green: 0.78, blue: 0.20)
            ]

        default:
            // Non-native fallback: use the mood's base palette.
            return moodBasePalette(for: mood)
        }
    }

    // MARK: Alveoles — vitrail organique signature, contrastes nets
    //
    // Architecture : palette CONSTANTE quel que soit le nombre de Promi.
    // Les Promi se posent dans la même palette, distingués par la taille de
    // cellule (poids Voronoï), pas par un changement de famille chromatique.

    private static func alveolesThemedPalette(mood: PromiColorMood) -> [Color] {
        switch mood {
        case .terrePromi:
            // Warm earth territory : brun profond (ancrage) + sienne + ocre + rouille
            // + olive. Zero bleu — identité vraiment terreuse, strict disjoint avec
            // nuitCobalt (blues only) et ivoireCorail (ivoire/corail/teal/marine).
            return [
                Color(red: 0.16, green: 0.10, blue: 0.08),
                Color(red: 0.62, green: 0.32, blue: 0.18),
                Color(red: 0.88, green: 0.66, blue: 0.22),
                Color(red: 0.80, green: 0.40, blue: 0.20),
                Color(red: 0.36, green: 0.40, blue: 0.18)
            ]

        case .nuitCobalt:
            // Pure blues territory : navy abyssal + navy profond + cobalt électrique
            // + indigo saturé + lilas glacé. Plus aucun indigo partagé avec terrePromi
            // (qui n'a plus de bleu du tout).
            return [
                Color(red: 0.04, green: 0.06, blue: 0.14),
                Color(red: 0.10, green: 0.14, blue: 0.26),
                Color(red: 0.16, green: 0.22, blue: 0.68),
                Color(red: 0.28, green: 0.20, blue: 0.78),
                Color(red: 0.50, green: 0.54, blue: 0.88)
            ]

        case .ivoireCorail:
            // Ivoire chaud lumineux : corail vif + teal + marine. Inchangé —
            // pas de conflit avec les deux autres moods après leur refonte.
            return [
                Color(red: 0.96, green: 0.93, blue: 0.87),
                Color(red: 0.92, green: 0.86, blue: 0.78),
                Color(red: 0.98, green: 0.55, blue: 0.40),
                Color(red: 0.27, green: 0.78, blue: 0.77),
                Color(red: 0.18, green: 0.26, blue: 0.38)
            ]

        default:
            // Non-native fallback: vivid base, no dimming.
            return moodBasePalette(for: mood)
        }
    }

    // MARK: Galets — pavage rond, couleurs primaires, ancre noire centrale
    //
    // Architecture : palette CONSTANTE. Les Promi prennent leurs couleurs
    // dans la même signature, l'ancre noire reste tant que le centre est libre.

    private static func galetsThemedPalette(mood: PromiColorMood) -> [Color] {
        switch mood {
        case .terrePromi:
            // Pixel-fidélité aux couleurs des slides d'onboarding :
            // orange + bleu + jaune + vert + rose. Identité canonique Promi.
            // L'ancre noire est placée séparément.
            return [
                Color(red: 1.00, green: 0.40, blue: 0.06),
                Color(red: 0.12, green: 0.44, blue: 0.95),
                Color(red: 0.98, green: 0.84, blue: 0.08),
                Color(red: 0.10, green: 0.75, blue: 0.48),
                Color(red: 1.00, green: 0.78, blue: 0.84)
            ]

        case .ivoireCorail:
            // Warm terracotta territory : terracotta / brique / pêche / sienne / lin.
            // Zero bleu, zero jaune saturé, zero vert, zero rose — strict disjoint
            // avec terrePromi et nuitCobalt.
            return [
                Color(red: 0.88, green: 0.42, blue: 0.28),
                Color(red: 0.70, green: 0.24, blue: 0.18),
                Color(red: 0.96, green: 0.68, blue: 0.48),
                Color(red: 0.78, green: 0.46, blue: 0.22),
                Color(red: 0.94, green: 0.86, blue: 0.72)
            ]

        case .nuitCobalt:
            // Cool blues & purples territory : cobalt profond / violet royal /
            // indigo nuit / lilas clair / ardoise froide. Zero orange, zero jaune,
            // zero vert, zero rose, zero corail — strict disjoint.
            return [
                Color(red: 0.16, green: 0.28, blue: 0.78),
                Color(red: 0.42, green: 0.22, blue: 0.82),
                Color(red: 0.22, green: 0.18, blue: 0.56),
                Color(red: 0.68, green: 0.60, blue: 0.94),
                Color(red: 0.42, green: 0.48, blue: 0.62)
            ]

        default:
            // Non-native fallback: vivid base.
            return moodBasePalette(for: mood)
        }
    }

    /// Couleur d'ancre noire utilisée par le pack Galets pour reproduire
    /// le cercle noir central des slides d'onboarding. Placée sur la cellule
    /// idle la plus proche du centre du viewport.
    private static func galetsAnchorColor(for mood: PromiColorMood) -> Color {
        switch mood {
        case .terrePromi:    return Color(red: 0.06, green: 0.06, blue: 0.08)
        case .nuitCobalt:    return Color(red: 0.04, green: 0.05, blue: 0.10)
        case .ivoireCorail:  return Color(red: 0.10, green: 0.10, blue: 0.14)
        default:             return Color(red: 0.08, green: 0.08, blue: 0.12)
        }
    }

    // MARK: Mosaic — éditorial graphique, contrastes nets

    private static func mosaicThemedPalette(mood: PromiColorMood) -> [Color] {
        switch mood {
        case .craieMarine:
            // Bleus marine sur craie : froid graphique.
            return [
                Color(red: 0.94, green: 0.93, blue: 0.90),
                Color(red: 0.78, green: 0.82, blue: 0.88),
                Color(red: 0.44, green: 0.56, blue: 0.72),
                Color(red: 0.18, green: 0.26, blue: 0.38),
                Color(red: 0.09, green: 0.14, blue: 0.26)
            ]

        case .sableMenthe:
            // Sable et menthe : neutre tiède + accent corail.
            return [
                Color(red: 0.94, green: 0.90, blue: 0.82),
                Color(red: 0.82, green: 0.90, blue: 0.84),
                Color(red: 0.46, green: 0.78, blue: 0.72),
                Color(red: 0.28, green: 0.56, blue: 0.52),
                Color(red: 0.92, green: 0.74, blue: 0.58)
            ]

        case .mineralPrune:
            // Prune minérale : violets profonds, gravité.
            return [
                Color(red: 0.80, green: 0.82, blue: 0.86),
                Color(red: 0.58, green: 0.50, blue: 0.64),
                Color(red: 0.36, green: 0.22, blue: 0.46),
                Color(red: 0.26, green: 0.28, blue: 0.36),
                Color(red: 0.14, green: 0.14, blue: 0.20)
            ]

        default:
            return moodBasePalette(for: mood)
        }
    }

    private static func moodBasePalette(for mood: PromiColorMood) -> [Color] {
        switch mood {
        case .terrePromi:
            return [
                Color(red: 0.24, green: 0.18, blue: 0.15),
                Color(red: 0.18, green: 0.13, blue: 0.12),
                Color(red: 0.13, green: 0.10, blue: 0.10),
                Color(red: 0.98, green: 0.37, blue: 0.27),
                Color(red: 0.33, green: 0.31, blue: 0.93)
            ]

        case .nuitCobalt:
            return [
                Color(red: 0.08, green: 0.11, blue: 0.20),
                Color(red: 0.14, green: 0.19, blue: 0.32),
                Color(red: 0.22, green: 0.30, blue: 0.46),
                Color(red: 0.33, green: 0.31, blue: 0.93),
                Color(red: 0.27, green: 0.78, blue: 0.77)
            ]

        case .ivoireCorail:
            return [
                Color(red: 0.96, green: 0.93, blue: 0.87),
                Color(red: 0.92, green: 0.86, blue: 0.78),
                Color(red: 0.98, green: 0.63, blue: 0.48),
                Color(red: 0.27, green: 0.78, blue: 0.77),
                Color(red: 0.18, green: 0.26, blue: 0.38)
            ]

        case .craieMarine:
            return [
                Color(red: 0.94, green: 0.93, blue: 0.90),
                Color(red: 0.78, green: 0.82, blue: 0.88),
                Color(red: 0.44, green: 0.56, blue: 0.72),
                Color(red: 0.18, green: 0.26, blue: 0.38),
                Color(red: 0.09, green: 0.14, blue: 0.26)
            ]

        case .sableMenthe:
            return [
                Color(red: 0.94, green: 0.90, blue: 0.82),
                Color(red: 0.82, green: 0.90, blue: 0.84),
                Color(red: 0.46, green: 0.78, blue: 0.72),
                Color(red: 0.28, green: 0.56, blue: 0.52),
                Color(red: 0.92, green: 0.74, blue: 0.58)
            ]

        case .mineralPrune:
            return [
                Color(red: 0.80, green: 0.82, blue: 0.86),
                Color(red: 0.48, green: 0.42, blue: 0.56),
                Color(red: 0.36, green: 0.22, blue: 0.46),
                Color(red: 0.26, green: 0.28, blue: 0.36),
                Color(red: 0.14, green: 0.14, blue: 0.20)
            ]

        case .jardinPromi:
            return [
                Color(red: 0.95, green: 0.90, blue: 0.28),
                Color(red: 0.64, green: 0.83, blue: 0.30),
                Color(red: 0.28, green: 0.68, blue: 0.50),
                Color(red: 0.22, green: 0.46, blue: 0.58),
                Color(red: 0.36, green: 0.18, blue: 0.48),
                Color(red: 0.72, green: 0.28, blue: 0.52)
            ]

        case .auroreCobalt:
            return [
                Color(red: 0.16, green: 0.22, blue: 0.46),
                Color(red: 0.24, green: 0.48, blue: 0.66),
                Color(red: 0.28, green: 0.72, blue: 0.76),
                Color(red: 0.38, green: 0.36, blue: 0.72),
                Color(red: 0.54, green: 0.26, blue: 0.62),
                Color(red: 0.82, green: 0.36, blue: 0.48)
            ]

        case .citrusBrume:
            return [
                Color(red: 0.97, green: 0.92, blue: 0.48),
                Color(red: 0.86, green: 0.94, blue: 0.58),
                Color(red: 0.62, green: 0.88, blue: 0.78),
                Color(red: 0.58, green: 0.74, blue: 0.94),
                Color(red: 0.84, green: 0.70, blue: 0.92),
                Color(red: 0.96, green: 0.78, blue: 0.68)
            ]

        case .auroreFraise:
            return [
                Color(red: 0.98, green: 0.78, blue: 0.66),
                Color(red: 0.96, green: 0.62, blue: 0.58),
                Color(red: 0.74, green: 0.86, blue: 0.94),
                Color(red: 0.78, green: 0.88, blue: 0.78),
                Color(red: 0.98, green: 0.92, blue: 0.74)
            ]

        case .foretSousBois:
            return [
                Color(red: 0.30, green: 0.45, blue: 0.28),
                Color(red: 0.20, green: 0.40, blue: 0.30),
                Color(red: 0.55, green: 0.62, blue: 0.40),
                Color(red: 0.36, green: 0.26, blue: 0.18),
                Color(red: 0.78, green: 0.54, blue: 0.44)
            ]

        case .neonMidi:
            return [
                Color(red: 0.96, green: 0.22, blue: 0.62),
                Color(red: 0.20, green: 0.86, blue: 0.92),
                Color(red: 0.66, green: 0.96, blue: 0.30),
                Color(red: 0.30, green: 0.20, blue: 0.86),
                Color(red: 0.98, green: 0.78, blue: 0.20)
            ]
        }
    }

    private static func spectrumGradientStyle(mood: PromiColorMood, index: Int) -> AnyShapeStyle {
        let colors = moodBasePalette(for: mood)
        let safe = colors.isEmpty ? [Color.gray, Color.white] : colors
        let base = safe[index % safe.count]
        let next = safe[(index + 1) % safe.count]
        let previous = safe[(index - 1 + safe.count) % safe.count]
        let seed = Double((index * 37) % 100) / 100.0

        let leading = seed > 0.5 ? base.opacity(0.82) : previous.opacity(0.74)
        let trailing = seed > 0.5 ? next.opacity(0.70) : base.opacity(0.84)

        return AnyShapeStyle(
            LinearGradient(
                stops: [
                    .init(color: leading, location: 0.0),
                    .init(color: base.opacity(0.78), location: 0.56),
                    .init(color: trailing, location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Label (always visible on promoted cells)

fileprivate struct PromiCellCenteredLabelView: View {
    let promi: PromiItem
    let languageCode: String
    let frame: CGRect
    let textMode: PromiTextMode

    var body: some View {
        VStack(spacing: verticalSpacing) {
            Text(fullPromiTitle)
                .font(.system(size: titleSize, weight: .medium))
                .foregroundColor(primaryColor)
                .lineLimit(maxTitleLines)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.42)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)

            Text(dateText)
                .font(.system(size: secondarySize, weight: .medium, design: .rounded))
                .foregroundColor(secondaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .monospacedDigit()
                .allowsTightening(true)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(width: textWidth, height: textHeight, alignment: .center)
        .position(x: frame.midX, y: frame.midY)
    }

    // MARK: Text content

    private var fullPromiTitle: String {
        let trimmed = promi.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.localizedLowercase
        return lowered.hasPrefix("promi") ? trimmed : "Promi \(trimmed)"
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageCode.isEmpty ? "fr_FR" : languageCode)

        if frame.width > 140 && frame.height > 80 {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        } else if frame.width > 96 {
            formatter.dateFormat = "d MMM HH:mm"
        } else {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: promi.dueDate)
    }

    // MARK: Sizing

    private var maxTitleLines: Int {
        if frame.height > 220 { return 4 }
        if frame.height > 140 { return 3 }
        if frame.height > 70 { return 2 }
        return 1
    }

    private var horizontalPadding: CGFloat {
        max(4, min(14, frame.width * 0.08))
    }

    private var verticalSpacing: CGFloat {
        if frame.height > 140 { return 7 }
        if frame.height > 80 { return 5 }
        return 3
    }

    private var textWidth: CGFloat {
        max(38, min(frame.width * 0.82, frame.width - 10))
    }

    private var textHeight: CGFloat {
        max(28, min(frame.height * 0.78, frame.height - 6))
    }

    private var titleSize: CGFloat {
        let candidate = min(frame.width * 0.16, frame.height * 0.22)
        return max(11, min(candidate, 30))
    }

    private var secondarySize: CGFloat {
        let candidate = min(frame.width * 0.068, frame.height * 0.090)
        return max(8, min(candidate, 13))
    }

    // MARK: Colors

    private var primaryColor: Color {
        switch textMode {
        case .lightCentered: return .white.opacity(0.97)
        case .darkCentered: return .black.opacity(0.84)
        }
    }

    private var secondaryColor: Color {
        switch textMode {
        case .lightCentered: return .white.opacity(0.80)
        case .darkCentered: return .black.opacity(0.58)
        }
    }
}

// MARK: - Polygon shape

fileprivate struct PromiFieldPolygonShape: Shape {
    let points: [CGPoint]
    let softness: CGFloat

    func path(in rect: CGRect) -> Path {
        _ = rect
        return roundedPolygonPath(points: points, softness: softness)
    }
}

fileprivate func roundedPolygonPath(points: [CGPoint], softness: CGFloat) -> Path {
    guard points.count > 2 else { return Path() }

    if softness <= 1 {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    var path = Path()

    for index in points.indices {
        let previous = points[(index - 1 + points.count) % points.count]
        let current = points[index]
        let next = points[(index + 1) % points.count]

        let radius = min(softness, min(distance(current, previous), distance(current, next)) * 0.20)
        let start = pointToward(from: current, to: previous, by: radius)
        let end = pointToward(from: current, to: next, by: radius)

        if index == 0 {
            path.move(to: start)
        } else {
            path.addLine(to: start)
        }

        path.addQuadCurve(to: end, control: current)
    }

    path.closeSubpath()
    return path
}

// MARK: - Geometry helpers

fileprivate func polygonBoundingBox(for points: [CGPoint]) -> CGRect {
    guard let first = points.first else { return .zero }

    var minX = first.x
    var maxX = first.x
    var minY = first.y
    var maxY = first.y

    for point in points {
        minX = min(minX, point.x)
        maxX = max(maxX, point.x)
        minY = min(minY, point.y)
        maxY = max(maxY, point.y)
    }

    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

fileprivate func polygonCentroid(for points: [CGPoint]) -> CGPoint {
    guard points.count > 2 else { return .zero }

    var signedArea: CGFloat = 0
    var cx: CGFloat = 0
    var cy: CGFloat = 0

    for index in points.indices {
        let p0 = points[index]
        let p1 = points[(index + 1) % points.count]
        let cross = p0.x * p1.y - p1.x * p0.y
        signedArea += cross
        cx += (p0.x + p1.x) * cross
        cy += (p0.y + p1.y) * cross
    }

    signedArea *= 0.5

    guard abs(signedArea) > 0.0001 else {
        let box = polygonBoundingBox(for: points)
        return CGPoint(x: box.midX, y: box.midY)
    }

    return CGPoint(x: cx / (6 * signedArea), y: cy / (6 * signedArea))
}

fileprivate func visibleBoundingBox(for points: [CGPoint], viewport: CGRect) -> CGRect {
    let raw = polygonBoundingBox(for: points)
    let clipped = raw.intersection(viewport)
    return clipped.isNull ? raw : clipped
}

fileprivate func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    hypot(a.x - b.x, a.y - b.y)
}

fileprivate func pointToward(from start: CGPoint, to end: CGPoint, by amount: CGFloat) -> CGPoint {
    let d = max(distance(start, end), 0.0001)
    let t = amount / d
    return CGPoint(
        x: start.x + (end.x - start.x) * t,
        y: start.y + (end.y - start.y) * t
    )
}

fileprivate func clampPoint(_ point: CGPoint, to rect: CGRect) -> CGPoint {
    CGPoint(
        x: min(max(point.x, rect.minX), rect.maxX),
        y: min(max(point.y, rect.minY), rect.maxY)
    )
}

// MARK: - Voronoi math

fileprivate struct WeightedSite {
    let point: CGPoint
    let weight: CGFloat
}

fileprivate enum VoronoiMath {
    static func weightedCellPolygon(index: Int, sites: [WeightedSite], bounds: CGRect) -> [CGPoint] {
        guard !sites.isEmpty else {
            return [
                CGPoint(x: bounds.minX, y: bounds.minY),
                CGPoint(x: bounds.maxX, y: bounds.minY),
                CGPoint(x: bounds.maxX, y: bounds.maxY),
                CGPoint(x: bounds.minX, y: bounds.maxY)
            ]
        }

        var polygon: [CGPoint] = [
            CGPoint(x: bounds.minX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.maxY),
            CGPoint(x: bounds.minX, y: bounds.maxY)
        ]

        let site = sites[index]

        for (j, other) in sites.enumerated() where j != index {
            let a = 2 * (other.point.x - site.point.x)
            let b = 2 * (other.point.y - site.point.y)

            let c = (
                other.point.x * other.point.x + other.point.y * other.point.y - other.weight
                - site.point.x * site.point.x - site.point.y * site.point.y + site.weight
            )

            polygon = clipPolygon(polygon, a: a, b: b, c: c)

            if polygon.isEmpty {
                break
            }
        }

        return polygon
    }

    private static func clipPolygon(_ polygon: [CGPoint], a: CGFloat, b: CGFloat, c: CGFloat) -> [CGPoint] {
        guard !polygon.isEmpty else { return [] }

        var output: [CGPoint] = []

        for index in polygon.indices {
            let current = polygon[index]
            let next = polygon[(index + 1) % polygon.count]

            let currentInside = isInside(current, a: a, b: b, c: c)
            let nextInside = isInside(next, a: a, b: b, c: c)

            if currentInside && nextInside {
                output.append(next)
            } else if currentInside && !nextInside {
                if let intersection = intersection(from: current, to: next, a: a, b: b, c: c) {
                    output.append(intersection)
                }
            } else if !currentInside && nextInside {
                if let intersection = intersection(from: current, to: next, a: a, b: b, c: c) {
                    output.append(intersection)
                }
                output.append(next)
            }
        }

        return output
    }

    private static func isInside(_ point: CGPoint, a: CGFloat, b: CGFloat, c: CGFloat) -> Bool {
        a * point.x + b * point.y <= c + 0.0001
    }

    private static func intersection(from p1: CGPoint, to p2: CGPoint, a: CGFloat, b: CGFloat, c: CGFloat) -> CGPoint? {
        let d1 = a * p1.x + b * p1.y - c
        let d2 = a * p2.x + b * p2.y - c
        let denominator = d1 - d2
        guard abs(denominator) > 0.0001 else { return nil }

        let t = d1 / denominator
        return CGPoint(
            x: p1.x + (p2.x - p1.x) * t,
            y: p1.y + (p2.y - p1.y) * t
        )
    }
}
