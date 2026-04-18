import SwiftUI
import UIKit
import Combine

// MARK: - Public: Full-page chrome backdrop
//
// Used by all full-screen pages that overlay the home field (Mes Promi,
// Brouillons, Karma, Créer un Promi, Réglages, etc.) so they inherit the
// EXACT same visual feel as the tri/+ dropdown menus — live Voronoi below,
// subtle blur on top, dark tint at the CompactMenuSurface level.
//
// IMPORTANT: uses .blur(radius:) explicitly instead of .ultraThinMaterial
// because SwiftUI's material backdrop filter does NOT blur content behind
// the view when it lives in a sheet / modal presentation context (the
// render pass is separate). The menus use material correctly because they
// sit inside the home ContentView's ZStack, not in a sheet. For pages
// presented as sheets, an explicit .blur() is the only way to get a
// predictable, identical visual result.

struct PromiChromePageBackground: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let promis: [PromiItem]
    let languageCode: String

    init(
        pack: PromiVisualPack,
        mood: PromiColorMood,
        promis: [PromiItem] = [],
        languageCode: String = "fr_FR"
    ) {
        self.pack = pack
        self.mood = mood
        self.promis = promis
        self.languageCode = languageCode
    }

    var body: some View {
        ZStack {
            // Layer 1: live Voronoi backdrop rasterized into its OWN Metal
            // layer via .drawingGroup(). This is CRITICAL — without it,
            // the .ultraThinMaterial layer on top cannot backdrop-sample
            // a sibling SwiftUI view inside the same ZStack when the page
            // is presented as a sheet, and you get a washed-out uniform
            // blur instead of the distinct abstract color patches visible
            // through the tri/+ dropdown menus. drawingGroup forces the
            // Voronoi to become a Metal bitmap source that material can
            // correctly sample and blur on top of.
            GeometryReader { geo in
                PromiFieldPreviewView(
                    pack: pack,
                    mood: mood,
                    size: geo.size,
                    promis: promis,
                    languageCode: languageCode,
                    sortOption: .inspiration
                )
            }
            .drawingGroup()

            // Layer 2: ultraThinMaterial — IDENTICAL recipe to the
            // CompactMenuSurface used by the tri and + dropdown menus.
            // Same material tier, same amount of frosted-glass blur.
            Rectangle()
                .fill(.ultraThinMaterial)

            // Layer 3: dark tint — IDENTICAL opacity to CompactMenuSurface
            // (0.18 for dark-field moods, 0.10 for light-field moods).
            // No more, no less. Exactly the same darkening level as the
            // dropdown menus, so pages inherit the same tonal weight.
            Rectangle()
                .fill(Color.black.opacity(mood.prefersDarkChrome ? 0.18 : 0.10))
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Public: Live zoomable field

struct PromiFieldRootView: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            ZoomablePromiViewport {
                // Le pack détermine sa propre taille intrinsèque (qui
                // peut être plus grande que l'écran quand il y a beaucoup
                // de Promi). Le ZoomablePromiViewport gère le scroll
                // et le zoom pour naviguer dans le contenu étendu.
                packContent(size: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func packContent(size: CGSize) -> some View {
        switch pack {
        case .galets:
            GaletsPromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
            )
        case .alveolesSignature:
            AlveolesPromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
            )
        case .mosaicFlat:
            MosaicFlatPromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
            )
        case .spectrumSoft:
            SpectrumSoftPromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
            )
        case .cristal:
            CristalPromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
            )
        case .vitrailChrome:
            VitrailChromePromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
            )
        case .trame:
            TramePromiFieldView(
                mood: mood, size: size, promis: promis, nuées: nuées,
                languageCode: languageCode, sortOption: sortOption,
                onTapPromi: onTapPromi, onTapNuée: onTapNuée,
                onLongPressPromi: onLongPressPromi
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
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption

    init(
        pack: PromiVisualPack,
        mood: PromiColorMood,
        size: CGSize,
        promis: [PromiItem] = [],
        nuées: [Nuée] = [],
        languageCode: String = "fr_FR",
        sortOption: PromiFieldSortOption = .inspiration
    ) {
        self.pack = pack
        self.mood = mood
        self.size = size
        self.promis = promis
        self.nuées = nuées
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
                nuées: nuées,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in },
                onTapNuée: { _ in }
            )
        case .alveolesSignature:
            CommonPromiFieldView(
                theme: .alveoles,
                mood: mood,
                size: size,
                promis: promis,
                nuées: nuées,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in },
                onTapNuée: { _ in }
            )
        case .mosaicFlat:
            CommonPromiFieldView(
                theme: .mosaic,
                mood: mood,
                size: size,
                promis: promis,
                nuées: nuées,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in },
                onTapNuée: { _ in }
            )
        case .spectrumSoft:
            CommonPromiFieldView(
                theme: .spectrum,
                mood: mood,
                size: size,
                promis: promis,
                nuées: nuées,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in },
                onTapNuée: { _ in }
            )
        case .cristal:
            CommonPromiFieldView(
                theme: .cristal,
                mood: mood,
                size: size,
                promis: promis,
                nuées: nuées,
                languageCode: languageCode,
                sortOption: sortOption,
                onTapPromi: { _ in },
                onTapNuée: { _ in }
            )
        case .vitrailChrome:
            // Si des Promi sont passés → rendu réel (share/composition).
            // Sinon → preview Studio (tuiles PaletteView sans Promi).
            if promis.isEmpty && nuées.isEmpty {
                VitrailChromeStudioPreview(mood: mood, size: size)
            } else {
                VitrailChromeShareContent(
                    mood: mood,
                    size: size,
                    promis: promis,
                    nuées: nuées,
                    sortOption: sortOption
                )
            }
        case .trame:
            if promis.isEmpty && nuées.isEmpty {
                TrameStudioPreview(mood: mood, size: size)
            } else {
                TrameShareContent(
                    mood: mood,
                    size: size,
                    promis: promis,
                    nuées: nuées,
                    languageCode: languageCode,
                    sortOption: sortOption
                )
            }
        }
    }
}

/// Aperçu Studio du pack vitrailChrome : zoom cadré sur une zone du vrai
/// PNG vitrail_chrome_overlay.png, avec les 141 cellules réelles remplies
/// des couleurs de la palette mood (toutes allumées pour la démo).
fileprivate struct VitrailChromeStudioPreview: View {
    let mood: PromiColorMood
    let size: CGSize

    var body: some View {
        // Image native 1024x1536. On en cadre une zone centrale qui remplit
        // complètement la tuile du Studio (pas de bande vide).
        let imageRatio: CGFloat = 1024.0 / 1536.0
        let tileRatio = size.width / size.height
        let imageWidth: CGFloat
        let imageHeight: CGFloat
        if tileRatio > imageRatio {
            imageWidth = size.width
            imageHeight = size.width / imageRatio
        } else {
            imageHeight = size.height
            imageWidth = size.height * imageRatio
        }
        let canvas = CGSize(width: imageWidth, height: imageHeight)
        let cells = VitrailChromeCellsData.cells
        let swatches = mood.swatches

        return ZStack(alignment: .center) {
            Color.white
            ZStack(alignment: .topLeading) {
                // Remplissage palette : chaque cellule reçoit une couleur
                // piochée cycliquement dans mood.swatches.
                ForEach(Array(cells.enumerated()), id: \.element.id) { idx, vc in
                    let color = swatches[idx % max(swatches.count, 1)]
                    let rawPts = vc.polygon.map {
                        CGPoint(x: $0.x * canvas.width, y: $0.y * canvas.height)
                    }
                    // Même dilatation que dans l'app principale pour que
                    // les cellules apparaissent pleines malgré les ombres
                    // du chrome qui rétrécissent les polygones détectés.
                    let cx = vc.centroid.x * canvas.width
                    let cy = vc.centroid.y * canvas.height
                    let dilationFactor: CGFloat = 1.12
                    let pts = rawPts.map { p in
                        CGPoint(
                            x: cx + (p.x - cx) * dilationFactor,
                            y: cy + (p.y - cy) * dilationFactor
                        )
                    }
                    VitrailCellShape(points: pts)
                        .fill(color)
                }
                // Une seule couche chrome en multiply. Pas de screen — la
                // couche screen délave les palettes saturées vers du pastel,
                // donc les 3 Vitrail finissent par se ressembler. Dans
                // l'app principale on garde screen pour les reflets (c'est
                // une grande surface), mais dans la tuile preview du Studio
                // on veut voir la vraie palette saturée.
                Image("vitrail_chrome_overlay")
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .blendMode(.multiply)
            }
            .frame(width: imageWidth, height: imageHeight)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }
}

// MARK: - Zoomable viewport (Photos-like)

final class ZoomHostScrollView: UIScrollView {
    weak var hostedView: UIView?
    private var lastConfiguredBoundsSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let hosted = hostedView else { return }

        let viewportSize = bounds.size
        let atRestScale = abs(zoomScale - 1.0) < 0.001

        // On demande au SwiftUI sa taille intrinsèque (sizeThatFits), et
        // on s'assure que le contenu couvre AU MINIMUM la taille du
        // viewport dans chaque dimension (pour éviter une zone vide
        // visible quand le contenu SwiftUI est plus petit que l'écran).
        if viewportSize != .zero && viewportSize != lastConfiguredBoundsSize && atRestScale {
            lastConfiguredBoundsSize = viewportSize
            let intrinsic = hosted.sizeThatFits(
                CGSize(width: CGFloat.greatestFiniteMagnitude,
                       height: CGFloat.greatestFiniteMagnitude)
            )
            let finalSize = CGSize(
                width: max(intrinsic.width, viewportSize.width),
                height: max(intrinsic.height, viewportSize.height)
            )
            hosted.frame = CGRect(origin: .zero, size: finalSize)
            contentSize = finalSize
        }

        centerContentIfNeeded()
    }

    /// Simple symmetric centering — when zoomed out, the content
    /// centers in the full viewport. No reserved zones for dock or
    /// status bar — the Voronoï extends edge-to-edge and the chrome
    /// overlays on top. Exactly how Photos.app centers its content.
    func centerContentIfNeeded() {
        guard hostedView != nil else { return }

        let scaledW = contentSize.width * zoomScale
        let scaledH = contentSize.height * zoomScale

        let horizontalInset = max(0, (bounds.width - scaledW) / 2)
        let verticalInset = max(0, (bounds.height - scaledH) / 2)

        contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

struct ZoomablePromiViewport<Content: View>: UIViewRepresentable {
    let content: Content
    let onSingleTap: ((CGPoint) -> Void)?
    let onLongPress: ((CGPoint) -> Void)?

    init(
        onSingleTap: ((CGPoint) -> Void)? = nil,
        onLongPress: ((CGPoint) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.onSingleTap = onSingleTap
        self.onLongPress = onLongPress
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(rootView: content, onSingleTap: onSingleTap, onLongPress: onLongPress)
    }

    func makeUIView(context: Context) -> ZoomHostScrollView {
        let scrollView = ZoomHostScrollView()
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator
        // Le minimum zoom scale est calculé pour que tout le contenu
        // (y compris l'overscan Voronoï) puisse être vu en dézoomant.
        // À scale 1.0 = taille native (ce que la home montre par défaut).
        // En dessous de 1.0 = dézoom, on voit plus de la toile.
        scrollView.minimumZoomScale = 0.3
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.bouncesZoom = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.clipsToBounds = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .normal

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

        // Single-tap recognizer (1 doigt, 1 tap). Coexiste avec le pinch
        // natif du scrollview : 2 doigts → pinch, 1 doigt → tap.
        // Le tap "fail" si un double-tap se déclenche, pour éviter qu'un
        // double-tap zoom ouvre aussi la cellule.
        let singleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSingleTap(_:))
        )
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.delaysTouchesBegan = false
        singleTap.require(toFail: doubleTap)
        singleTap.require(toFail: scrollView.pinchGestureRecognizer!)
                singleTap.require(toFail: scrollView.panGestureRecognizer)
                scrollView.addGestureRecognizer(singleTap)

                // Long-press recognizer (1 doigt, 0.5s) pour le menu de
                // signalement/blocage sur les Promi reçus d'autres utilisateurs.
                // Coexiste naturellement avec le pinch : 2 doigts = pinch gagne
                // immédiatement, 1 doigt maintenu = long-press se déclenche après
                // la durée minimum. Le single tap require(toFail:) du long-press
                // n'est PAS nécessaire ici parce que le UILongPressGestureRecognizer
                // ne "fail" jamais avant sa durée — il se déclenche ou il est
                // annulé si le doigt bouge trop. Le tap attend déjà le pinch et le
                // pan, le long-press vit en parallèle sans conflit.
                let longPress = UILongPressGestureRecognizer(
                    target: context.coordinator,
                    action: #selector(Coordinator.handleLongPress(_:))
                )
                longPress.minimumPressDuration = 0.5
                longPress.numberOfTouchesRequired = 1
                longPress.allowableMovement = 10
                scrollView.addGestureRecognizer(longPress)

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
        let onSingleTap: ((CGPoint) -> Void)?
        let onLongPress: ((CGPoint) -> Void)?

        init(rootView: Content, onSingleTap: ((CGPoint) -> Void)?, onLongPress: ((CGPoint) -> Void)?) {
            self.hostingController = UIHostingController(rootView: rootView)
            self.onSingleTap = onSingleTap
            self.onLongPress = onLongPress
            hostingController.view.backgroundColor = .clear
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController.view
        }

        /// Centre le contenu dans le viewport quand il est plus petit
        /// (après dézoom). Sans ça, le contenu se colle en haut à gauche.


        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            (scrollView as? ZoomHostScrollView)?.centerContentIfNeeded()
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            (scrollView as? ZoomHostScrollView)?.centerContentIfNeeded()
        }

        @objc
        func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
            let point = recognizer.location(in: hostingController.view)
            onSingleTap?(point)
        }

        @objc
        func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            // On ne réagit qu'au .began (pas au .ended/.changed) pour
            // éviter de déclencher le menu plusieurs fois par geste.
            guard recognizer.state == .began else { return }
            let point = recognizer.location(in: hostingController.view)
            onLongPress?(point)
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
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    var body: some View {
        CommonPromiFieldView(
            theme: .galets,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi,
            onTapNuée: onTapNuée,
            onLongPressPromi: onLongPressPromi
        )
        .background(mood.homeBackground)
    }
}

struct AlveolesPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    var body: some View {
        CommonPromiFieldView(
            theme: .alveoles,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi,
            onTapNuée: onTapNuée,
            onLongPressPromi: onLongPressPromi
        )
        .background(mood.homeBackground)
    }
}

struct VitrailChromePromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    @StateObject private var motion = MotionTilt.shared

    var body: some View {
        let clampedTilt = CGSize(
            width: min(max(-0.4, motion.tilt.width), 0.4),
            height: min(max(-0.4, motion.tilt.height), 0.4)
        )
        let layout = PromiFieldLayoutFactory.make(
            theme: .vitrail,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            sortOption: sortOption
        )
        // Image native 1024x1536 -> ratio 2:3. Objectif : remplir TOUT
        // l'écran safe area comprise, avec un léger débordement pour un
        // zoom initial un cran plus serré (cellules plus grosses, plus
        // présentes). On multiplie par 1.15 et on ajoute 120 pts à la
        // hauteur pour couvrir safe areas haut+bas sur tout iPhone.
        let imageRatio: CGFloat = 1024.0 / 1536.0
        let targetHeight = (size.height + 120) * 1.15
        let imageHeight = targetHeight
        let imageWidth = targetHeight * imageRatio
        let canvas = CGSize(width: imageWidth, height: imageHeight)
        let remapped = Self.vitrailRemappedCells(from: layout.cells, canvas: canvas)

        return ZoomablePromiViewport(
            onSingleTap: { point in
                for cell in remapped {
                    guard cell.promotedPromi != nil || cell.promotedNuée != nil else { continue }
                    if Self.polygon(cell.points, contains: point) {
                        if let n = cell.promotedNuée { onTapNuée(n) }
                        else if let p = cell.promotedPromi { onTapPromi(p) }
                        return
                    }
                }
            },
            onLongPress: { point in
                // Long-press : trouver le Promi sous le doigt et déclencher
                // le menu signalement/blocage (seulement si reçu d'un tiers).
                for cell in remapped {
                    guard let promi = cell.promotedPromi, promi.isReceivedFromOther else { continue }
                    if Self.polygon(cell.points, contains: point) {
                        Haptics.shared.lightTap()
                        onLongPressPromi?(promi)
                        return
                    }
                }
            }
        ) {
            ZStack(alignment: .topLeading) {
                // Couche 1 : chrome multiply (plombs sombres qui dessinent la
                // grille). Placé AVANT les remplissages pour que le contour
                // des cellules soit visible.
                Image("vitrail_chrome_overlay")
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .blendMode(.multiply)
                    .allowsHitTesting(false)
                // Couche 2 : chrome screen (reflets métalliques). Appliqué
                // uniquement sur le fond blanc, donc les zones claires vont
                // se nuancer. Les remplissages colorés passent par-dessus
                // dans la Couche 3 pour ne pas être délavés.
                Image("vitrail_chrome_overlay")
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .blendMode(.screen)
                    .opacity(0.7)
                    .allowsHitTesting(false)
                // Couche 3 : vitrail qui s'allume — PAR-DESSUS le chrome pour
                // que les vraies couleurs de la palette ressortent sans être
                // délavées par le blendMode screen. Promi = couleur palette
                // cyclée, Nuée = dernière swatch (accent).
                ForEach(remapped) { cell in
                    let isNuée = cell.promotedNuée != nil
                    let isPromi = cell.promotedPromi != nil
                    if isNuée || isPromi {
                        let shape = VitrailCellShape(points: cell.points)
                        let b = cell.visibleBounds
                        let radius = max(b.width, b.height) * 0.70
                        let swatches = mood.swatches
                        let swatchCount = max(swatches.count, 1)
                        let promiSwatchIdx = abs(cell.id.hashValue) % swatchCount
                        let tint: AnyShapeStyle = isNuée
                            ? AnyShapeStyle(swatches[swatchCount - 1])
                            : AnyShapeStyle(swatches[promiSwatchIdx])
                        // Remplissage coloré saturé, masqué par un gradient
                        // radial pour un effet vitrail rétro-éclairé : centre
                        // opaque (couleur vive), bords translucides (on devine
                        // encore le chrome dessous). Les couleurs sont saturées
                        // parce qu'elles sont AU-DESSUS des deux couches chrome.
                        shape.fill(tint)
                            .mask(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .white.opacity(0.95), location: 0.0),
                                        .init(color: .white.opacity(0.80), location: 0.55),
                                        .init(color: .white.opacity(0.0),  location: 1.0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: radius
                                )
                                .frame(width: b.width, height: b.height)
                                .position(x: b.midX, y: b.midY)
                            )
                            .allowsHitTesting(false)
                    }
                }
                // Couche 4 : PromiItems / Nuées centrés sur les vrais centroïdes,
                // hit-test par polygone (pas bbox).
                ForEach(remapped) { cell in
                    if cell.promotedPromi != nil || cell.promotedNuée != nil {
                        let title: String = cell.promotedNuée?.name
                            ?? cell.promotedPromi?.title
                            ?? ""
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.85))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: max(cell.visibleBounds.width * 0.8, 40))
                            .position(
                                x: cell.visibleBounds.midX,
                                y: cell.visibleBounds.midY
                            )
                            .allowsHitTesting(false)
                                                }
                                            }
                                        }
                                        .frame(width: imageWidth, height: imageHeight)
                                        .background(Color.white)
        }
        .frame(width: size.width, height: size.height)
        .background(mood.homeBackground)
        .ignoresSafeArea()
        .onAppear { motion.subscribe() }
        .onDisappear { motion.unsubscribe() }
    }

    /// Remappe les cellules synthétiques du layout factory sur les 141 vraies
    /// cellules détectées dans vitrail_chrome_overlay.png, en préservant
    /// fillStyle, promotedPromi, promotedNuée, strokeColor, strokeStyle, textMode.
    /// Les vraies cellules sont triées par distance croissante au centre de
    /// l'image, donc les premiers Promis/Nuées tombent au milieu de l'écran
    /// (visibles dès le lancement) plutôt que sur les bords.
    fileprivate static func vitrailRemappedCells(
        from source: [PromiFieldCell],
        canvas: CGSize
    ) -> [PromiFieldCell] {
        let real = VitrailChromeCellsData.cells
        guard !real.isEmpty else { return source }
        // Tri des cellules réelles par distance centroïde -> centre de l'image.
        // Le centre est (0.5, 0.5) en coordonnées normalisées.
        let sortedReal = real.sorted { a, b in
            let da = (a.centroid.x - 0.5) * (a.centroid.x - 0.5)
                   + (a.centroid.y - 0.5) * (a.centroid.y - 0.5)
            let db = (b.centroid.x - 0.5) * (b.centroid.x - 0.5)
                   + (b.centroid.y - 0.5) * (b.centroid.y - 0.5)
            return da < db
        }
        return source.enumerated().prefix(sortedReal.count).map { idx, base in
            let vc = sortedReal[idx]
            let rawPts = vc.polygon.map {
                CGPoint(x: $0.x * canvas.width, y: $0.y * canvas.height)
            }
            // Dilatation du polygone vers l'extérieur pour compenser les
            // ombres du chrome sur l'image source : la détection OpenCV
            // s'arrête au bord de la zone blanche, donc les polygones sont
            // un peu plus petits que la vraie cellule. On étire chaque
            // sommet depuis le centroïde d'un facteur 1.12, le chrome en
            // multiply par-dessus masque naturellement le débordement.
            let cx = vc.centroid.x * canvas.width
            let cy = vc.centroid.y * canvas.height
            let dilationFactor: CGFloat = 1.12
            let pts = rawPts.map { p in
                CGPoint(
                    x: cx + (p.x - cx) * dilationFactor,
                    y: cy + (p.y - cy) * dilationFactor
                )
            }
            let xs = pts.map(\.x), ys = pts.map(\.y)
            let bounds = CGRect(
                x: xs.min() ?? 0,
                y: ys.min() ?? 0,
                width: (xs.max() ?? 0) - (xs.min() ?? 0),
                height: (ys.max() ?? 0) - (ys.min() ?? 0)
            )
            return PromiFieldCell(
                id: base.id,
                points: pts,
                visibleBounds: bounds,
                promotedPromi: base.promotedPromi,
                promotedNuée: base.promotedNuée,
                fillStyle: base.fillStyle,
                strokeColor: base.strokeColor,
                strokeStyle: base.strokeStyle,
                textMode: base.textMode
            )
        }
    }

    /// Ray-casting : teste si `point` est dans le polygone `pts`.
    /// Utilisé par le tap UIKit du ZoomablePromiViewport pour router
    /// le tap vers le bon Promi/Nuée sans bloquer le pinch à 2 doigts.
    fileprivate static func polygon(_ pts: [CGPoint], contains point: CGPoint) -> Bool {
        guard pts.count >= 3 else { return false }
        var inside = false
        var j = pts.count - 1
        for i in 0..<pts.count {
            let pi = pts[i]
            let pj = pts[j]
            if ((pi.y > point.y) != (pj.y > point.y)) &&
               (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) {
                inside.toggle()
            }
            j = i
        }
        return inside
    }
}

/// Shape polygonale utilisée pour le hit-test précis des cellules vitrailChrome
/// (pas de bbox — tap uniquement si le doigt est réellement dans le polygone).
fileprivate struct VitrailCellShape: Shape {
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

fileprivate struct VitrailChromeCellView: View {
    let cell: PromiFieldCell
    let clampedTilt: CGSize

    var body: some View {
        let path: Path = {
            var p = Path()
            guard let first = cell.points.first else { return p }
            p.move(to: first)
            for pt in cell.points.dropFirst() { p.addLine(to: pt) }
            p.closeSubpath()
            return p
        }()
        let bounds = cell.visibleBounds
        let tx = clampedTilt.width
        let ty = clampedTilt.height
        return ZStack {
            path.fill(cell.fillStyle)
            path.fill(RadialGradient(
                colors: [Color.white.opacity(0.35), .clear],
                center: UnitPoint(x: 0.35 + tx * 0.4, y: 0.35 + ty * 0.4),
                startRadius: 0,
                endRadius: max(bounds.width, bounds.height) * 0.6
            ))
        }
    }
}

struct MosaicFlatPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    var body: some View {
        CommonPromiFieldView(
            theme: .mosaic,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi,
            onTapNuée: onTapNuée,
            onLongPressPromi: onLongPressPromi
        )
        .background(mood.homeBackground)
    }
}

struct SpectrumSoftPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    var body: some View {
        CommonPromiFieldView(
            theme: .spectrum,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi,
            onTapNuée: onTapNuée,
            onLongPressPromi: onLongPressPromi
        )
        .background(mood.homeBackground)
    }
}

struct CristalPromiFieldView: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    var body: some View {
        CommonPromiFieldView(
            theme: .cristal,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            languageCode: languageCode,
            sortOption: sortOption,
            onTapPromi: onTapPromi,
            onTapNuée: onTapNuée,
            onLongPressPromi: onLongPressPromi
        )
        .background(mood.homeBackground)
    }
}

/// Rendu Chrome×Vitrail pour le partage : même contenu que
/// VitrailChromePromiFieldView mais sans le ZoomablePromiViewport
/// (pas de scroll, pas de hit-test, pas de motion tilt). Compatible
/// avec ImageRenderer pour l'export.
fileprivate struct VitrailChromeShareContent: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let sortOption: PromiFieldSortOption

    var body: some View {
        let layout = PromiFieldLayoutFactory.make(
            theme: .vitrail,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            sortOption: sortOption
        )
        let imageRatio: CGFloat = 1024.0 / 1536.0
        let targetHeight = (size.height + 120) * 1.15
        let imageHeight = targetHeight
        let imageWidth = targetHeight * imageRatio
        let canvas = CGSize(width: imageWidth, height: imageHeight)
        let remapped = VitrailChromePromiFieldView.vitrailRemappedCells(
            from: layout.cells, canvas: canvas
        )

        ZStack(alignment: .topLeading) {
            Image("vitrail_chrome_overlay")
                .resizable()
                .frame(width: imageWidth, height: imageHeight)
                .blendMode(.multiply)
                .allowsHitTesting(false)

            Image("vitrail_chrome_overlay")
                .resizable()
                .frame(width: imageWidth, height: imageHeight)
                .blendMode(.screen)
                .opacity(0.7)
                .allowsHitTesting(false)

            ForEach(remapped) { cell in
                let isNuée = cell.promotedNuée != nil
                let isPromi = cell.promotedPromi != nil
                if isNuée || isPromi {
                    let shape = VitrailCellShape(points: cell.points)
                    let b = cell.visibleBounds
                    let radius = max(b.width, b.height) * 0.70
                    let swatches = mood.swatches
                    let swatchCount = max(swatches.count, 1)
                    let promiSwatchIdx = abs(cell.id.hashValue) % swatchCount
                    let tint: AnyShapeStyle = isNuée
                        ? AnyShapeStyle(swatches[swatchCount - 1])
                        : AnyShapeStyle(swatches[promiSwatchIdx])

                    shape.fill(tint)
                        .mask(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .white.opacity(0.95), location: 0.0),
                                    .init(color: .white.opacity(0.80), location: 0.55),
                                    .init(color: .white.opacity(0.0),  location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: radius
                            )
                            .frame(width: b.width, height: b.height)
                            .position(x: b.midX, y: b.midY)
                        )
                        .allowsHitTesting(false)
                }
            }

            ForEach(remapped) { cell in
                if cell.promotedPromi != nil || cell.promotedNuée != nil {
                    let title: String = cell.promotedNuée?.name
                        ?? cell.promotedPromi?.title
                        ?? ""
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: max(cell.visibleBounds.width * 0.8, 40))
                        .position(
                            x: cell.visibleBounds.midX,
                            y: cell.visibleBounds.midY
                        )
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(width: imageWidth, height: imageHeight)
        .background(Color.white)
    }
}

/// Rendu Trame pour le partage : même contenu que TramePromiFieldView
/// mais sans le ZoomablePromiViewport. Compatible avec ImageRenderer.
fileprivate struct TrameShareContent: View {
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption

    var body: some View {
        TramePromiFieldShareView(
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            languageCode: languageCode,
            sortOption: sortOption
        )
    }
}

// MARK: - Shared field

/// Class-based cache for PromiFieldLayout. Using a reference type wrapped in
/// @StateObject guarantees that async writes from background queues always
/// land in the correct storage, even if the parent View is recreated due to
/// sheet open/close cycles or AppStorage propagation. The previous @State-based
/// approach silently dropped writes when the view was re-instantiated.
fileprivate final class PromiFieldLayoutCache: ObservableObject {
    @Published var layout: PromiFieldLayout = PromiFieldLayout(
        cells: [],
        cristalMediumCells: nil,
        nestedSubCells: nil,
        bounds: .zero
    )
    @Published var key: String = ""
    private var generation: Int = 0

    func regenerateIfNeeded(
        theme: PromiFieldTheme,
        mood: PromiColorMood,
        size: CGSize,
        promis: [PromiItem],
        nuées: [Nuée],
        sortOption: PromiFieldSortOption,
        renderKey: String
    ) {
        guard renderKey != key else { return }

        // Fast sync path for non-Cristal themes (compute < 20ms).
        if theme != .cristal {
            let fresh = PromiFieldLayoutFactory.make(
                theme: theme,
                mood: mood,
                size: size,
                promis: promis,
                nuées: nuées,
                sortOption: sortOption
            )
            layout = fresh
            key = renderKey
            return
        }

        // Async path for Cristal — three-tier compute is fast enough now
        // (~50-200ms) but still off main to keep UI buttery. Generation
        // counter discards stale results from rapid mood-switches.
        generation += 1
        let myGeneration = generation

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fresh = PromiFieldLayoutFactory.make(
                theme: theme,
                mood: mood,
                size: size,
                promis: promis,
                nuées: nuées,
                sortOption: sortOption
            )
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard self.generation == myGeneration else { return }
                self.layout = fresh
                self.key = renderKey
            }
        }
    }
}

fileprivate struct CommonPromiFieldView: View {
    let theme: PromiFieldTheme
    let mood: PromiColorMood
    let size: CGSize
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let onTapPromi: (PromiItem) -> Void
    let onTapNuée: (Nuée) -> Void
    var onLongPressPromi: ((PromiItem) -> Void)? = nil

    @StateObject private var cache = PromiFieldLayoutCache()

    /// O(1) lookup of a Nuée by its id, used during cell rendering to find
    /// the swatch hex color of a Promi's parent Nuée (for the halo overlay)
    /// or to resolve the icon glyph and swatch for a promoted Nuée cell.
    private var nuéeLookup: [UUID: Nuée] {
        Dictionary(uniqueKeysWithValues: nuées.map { ($0.id, $0) })
    }

    /// Composite key that invalidates the cache whenever any input that
    /// affects the layout changes. The Promi list is hashed by id+intensity
    /// so that promotion/size changes trigger a refresh but cosmetic changes
    /// (title, metadata) do not. Nuées are hashed by id+kind so that adding
    /// or removing a Nuée triggers a layout refresh.
    private var renderKey: String {
        let promiHash = promis
            .map { "\($0.id.uuidString):\($0.intensity)" }
            .joined(separator: ",")
        let nuéeHash = nuées
            .map { "\($0.id.uuidString):\($0.kind.rawValue)" }
            .joined(separator: ",")
        return "\(Int(size.width))x\(Int(size.height))|\(theme.id)|\(mood.rawValue)|\(sortOption)|\(promiHash)|N:\(nuéeHash)"
    }

    var body: some View {
        let layout = cache.layout

        ZStack(alignment: .topLeading) {
            // Cristal: fine sub-cells layer. Rendered INLINE in this ZStack
            // (not wrapped in a sub-view with .drawingGroup) so their Shape
            // paths render in the same unclipped coordinate space as the
            // outer cells of every theme — matching exactly how galets,
            // alvéoles, mosaic and spectrum handle overscan.
            if let subCells = layout.nestedSubCells {
                ForEach(0..<subCells.count, id: \.self) { idx in
                    let cell = subCells[idx]
                    PromiFieldPolygonShape(points: cell.points, softness: 0)
                        .fill(cell.color)
                    PromiFieldPolygonShape(points: cell.points, softness: 0)
                        .stroke(Color.black.opacity(0.40), lineWidth: 0.5)
                }
            }

            // Cristal: medium-cell layer. Every medium cell (promoted or
            // not) contributes ONLY its bold stroke to visually group its
            // sub-cells into a single "moyenne alvéole". Promoted media no
            // longer get a solid fill — their sub-cell mosaic remains
            // visible underneath, preserving the cristal design coherence.
            // The interactive label for promoted media is rendered in the
            // overlay pass below.
            if let mediumCells = layout.cristalMediumCells {
                ForEach(0..<mediumCells.count, id: \.self) { idx in
                    let medium = mediumCells[idx]
                    PromiFieldPolygonShape(points: medium.points, softness: 0)
                        .stroke(Color.black.opacity(0.88), lineWidth: 1.9)
                }
            }

            // Outer cells (all themes). For Cristal these are stroke-only frames.
            ForEach(layout.cells) { cell in
                cellView(for: cell)
            }

            // Cristal: interactive label overlays for promoted medium cells.
            //
            // Two passes — Nuées first (they sit behind Promi labels in
            // the z-order, which is the correct visual layering since Nuées
            // are background anchors and Promis are foreground engagements).
            //
            // Nuée medium cells get a semi-transparent swatch tint ON TOP
            // of their sub-cell mosaic (preserving the cristal texture) plus
            // the Nuée icon+name label. Promi medium cells get the standard
            // transparent hit-area with the Promi label centered.
            if let medium = layout.cristalMediumCells {
                ForEach(medium.filter { $0.promotedNuée != nil }) { mediumCell in
                    cristalMediumNuéeButton(for: mediumCell)
                }
                ForEach(medium.filter { $0.promotedPromi != nil }) { mediumCell in
                    cristalMediumPromoButton(for: mediumCell)
                }
            }
        }
        .frame(width: max(size.width, 1), height: max(size.height, 1), alignment: .topLeading)
        .animation(.spring(response: 0.44, dampingFraction: 0.86), value: cache.key)
        .onAppear { regenerate() }
        .onChange(of: renderKey) { _, _ in regenerate() }
    }

    private func regenerate() {
        cache.regenerateIfNeeded(
            theme: theme,
            mood: mood,
            size: size,
            promis: promis,
            nuées: nuées,
            sortOption: sortOption,
            renderKey: renderKey
        )
    }

    @ViewBuilder
    private func cellView(for cell: PromiFieldCell) -> some View {
        let shape = PromiFieldPolygonShape(
            points: cell.points,
            softness: PromiFieldThemeConfig.polygonSoftness(for: theme)
        )

        if let nuée = cell.promotedNuée {
            // PROMOTED NUÉE CELL
            // The Nuée occupies a Voronoï space exactly like a Promi does,
            // but its visual treatment is distinct: the cell is filled with
            // the Nuée's chosen swatch hex (the user picked it in the
            // CreateNuéeView palette grid), bordered by the theme's normal
            // stroke for cohesion with the rest of the field, and overlaid
            // with the Nuée's icon glyph centered on the cell. Tap opens
            // NuéeDetailView via onTapNuée.
            let swatch = NuéePalette.color(fromHex: nuée.moodHintRawValue)
                ?? Color(red: 0.65, green: 0.40, blue: 0.30)

            Button(action: {
                Haptics.shared.lightTap()
                onTapNuée(nuée)
            }) {
                shape
                    .fill(swatch)
                    .overlay(shape.stroke(cell.strokeColor, style: cell.strokeStyle))
                    .overlay(
                        NuéeCellIconLabel(
                            nuée: nuée,
                            frame: cell.visibleBounds
                        )
                    )
            }
            .buttonStyle(.plain)

        } else if let promi = cell.promotedPromi {
            // PROMOTED PROMI CELL
            // Standard Promi cell rendering — cell.fillStyle uses the same
            // theme palette as idle cells (so promoted Promis blend visually
            // into the field; only their size distinguishes them). If the
            // Promi belongs to a Nuée, an additional colored halo stroke
            // overlay marks the membership using the Nuée's swatch color.
            // Halo is layered ON TOP of the regular theme stroke so it
            // reads as a clear secondary signal without erasing the cell's
            // native border.
            let haloColor: Color? = {
                // Promi tenu → halo vert doré (célébration visuelle).
                if promi.status == .done {
                    return Color(red: 0.34, green: 0.80, blue: 0.60)
                }
                // Promi rattaché à une Nuée → halo couleur swatch.
                guard let nuéeId = promi.nuéeId,
                      let parentNuée = nuéeLookup[nuéeId] else { return nil }
                return NuéePalette.color(fromHex: parentNuée.moodHintRawValue)
            }()

            Button(action: {
                Haptics.shared.lightTap()
                onTapPromi(promi)
            }) {
                shape
                    .fill(cell.fillStyle)
                    .overlay(shape.stroke(cell.strokeColor, style: cell.strokeStyle))
                    .overlay(
                        Group {
                            if let halo = haloColor {
                                shape
                                    .stroke(
                                        halo.opacity(0.86),
                                        style: StrokeStyle(
                                            lineWidth: 2.4,
                                            lineCap: .round,
                                            lineJoin: .round
                                        )
                                    )
                            }
                        }
                    )
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

    /// Renders the tappable Promi label for a promoted medium cell in Cristal.
    /// The sub-cell mosaic remains visible underneath — promoted media no
    /// longer get a solid color fill, per user request to preserve the
    /// cristal design. This layer provides only the interactive label
    /// centered on the medium centroid, plus an optional Nuée halo stroke
    /// if the Promi belongs to a Nuée (Option B: colored stroke on the
    /// medium cell border, coherent with Cristal's bold-line aesthetic).
    @ViewBuilder
    private func cristalMediumPromoButton(for medium: CristalMediumCell) -> some View {
        if let promi = medium.promotedPromi {
            let bbox = polygonBoundingBox(for: medium.points)
            let viewport = CGRect(origin: .zero, size: size)
            let visible = bbox.intersection(viewport)
            let frame = visible.isNull ? bbox : visible
            let textMode = PromiFieldThemeConfig.textMode(for: .cristal, mood: mood)
            let shape = PromiFieldPolygonShape(points: medium.points, softness: 0)

            // Resolve Nuée halo: if this Promi belongs to a Nuée, we
            // overlay a colored stroke on the medium cell border using
            // the Nuée's swatch hex. Layered ON TOP of the regular
            // Cristal black border so it reads as a clear secondary
            // signal — same principle as the outer-tier halo.
            let haloColor: Color? = {
                // Promi tenu → halo vert doré (célébration visuelle).
                if promi.status == .done {
                    return Color(red: 0.34, green: 0.80, blue: 0.60)
                }
                // Promi rattaché à une Nuée → halo couleur swatch.
                guard let nuéeId = promi.nuéeId,
                      let parentNuée = nuéeLookup[nuéeId] else { return nil }
                return NuéePalette.color(fromHex: parentNuée.moodHintRawValue)
            }()

            Button(action: {
                Haptics.shared.lightTap()
                onTapPromi(promi)
            }) {
                shape
                    .fill(Color.clear)
                    .contentShape(shape)
                    .overlay(
                        Group {
                            if let halo = haloColor {
                                shape
                                    .stroke(
                                        halo.opacity(0.86),
                                        style: StrokeStyle(
                                            lineWidth: 2.4,
                                            lineCap: .round,
                                            lineJoin: .round
                                        )
                                    )
                            }
                        }
                    )
                    .overlay(
                        PromiCellCenteredLabelView(
                            promi: promi,
                            languageCode: languageCode,
                            frame: frame,
                            textMode: textMode
                        )
                    )
            }
            .buttonStyle(.plain)
            .onLongPressGesture(minimumDuration: 0.5) {
                // Long-press = ouvrir le menu de signalement/blocage.
                // Ne se déclenche que sur les Promi reçus d'un autre
                // utilisateur (isReceivedFromOther). Pour les Promi
                // créés par soi-même, le long-press ne fait rien.
                guard promi.isReceivedFromOther else { return }
                Haptics.shared.lightTap()
                onLongPressPromi?(promi)
            }
        }
    }

    /// Renders a promoted Nuée cell at the Cristal medium tier.
    ///
    /// Design choice: the Nuée's swatch color is applied as a
    /// semi-transparent fill (opacity 0.72) ON TOP of the sub-cell
    /// mosaic, so the cristal texture bleeds through slightly — this
    /// preserves the three-tier design coherence while still making
    /// the Nuée cell visually distinct from its idle neighbours.
    /// The Nuée's icon and name are centered on the cell via
    /// `NuéeCellIconLabel`, same as the outer-tier Nuée rendering.
    @ViewBuilder
    private func cristalMediumNuéeButton(for medium: CristalMediumCell) -> some View {
        if let nuée = medium.promotedNuée {
            let bbox = polygonBoundingBox(for: medium.points)
            let viewport = CGRect(origin: .zero, size: size)
            let visible = bbox.intersection(viewport)
            let frame = visible.isNull ? bbox : visible
            let shape = PromiFieldPolygonShape(points: medium.points, softness: 0)

            let swatch = NuéePalette.color(fromHex: nuée.moodHintRawValue)
                ?? Color(red: 0.65, green: 0.40, blue: 0.30)

            Button(action: {
                Haptics.shared.lightTap()
                onTapNuée(nuée)
            }) {
                shape
                    // Semi-transparent swatch tint — lets the sub-cell
                    // mosaic texture bleed through (cristal identity).
                    .fill(swatch.opacity(0.72))
                    .contentShape(shape)
                    .overlay(
                        shape.stroke(
                            Color.black.opacity(0.88),
                            lineWidth: 1.9
                        )
                    )
                    .overlay(
                        NuéeCellIconLabel(
                            nuée: nuée,
                            frame: frame
                        )
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Layout model

fileprivate struct PromiFieldLayout {
    let cells: [PromiFieldCell]
    let cristalMediumCells: [CristalMediumCell]?
    let nestedSubCells: [CristalSubCell]?
    /// The full Voronoi bounds rect (viewport-relative, includes overscan).
    let bounds: CGRect
}

fileprivate struct CristalMediumCell: Identifiable {
    let id: UUID
    let points: [CGPoint]
    let baseColor: Color
    let parentOuterIndex: Int
    let centroid: CGPoint
    let promotedPromi: PromiItem?
    let promotedNuée: Nuée?
}

fileprivate struct CristalSubCell {
    let points: [CGPoint]
    let color: Color
    let parentMediumIdx: Int
}

fileprivate struct PromiFieldCell: Identifiable {
    let id: UUID
    let points: [CGPoint]
    let visibleBounds: CGRect
    let promotedPromi: PromiItem?
    let promotedNuée: Nuée?
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
    case vitrail
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
        case .vitrail: return 4
        case .spectrum: return 1
        }
    }

    static func strokeWidth(for theme: PromiFieldTheme) -> CGFloat {
        switch theme {
        case .galets: return 0.0
        case .alveoles: return 6.0
        case .cristal: return 4.0
        case .mosaic: return 2.1
        case .vitrail: return 0.0
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

        case .vitrail:
            return mood.prefersDarkChrome ? Color.white.opacity(0.26) : Color(red: 0.08, green: 0.12, blue: 0.24).opacity(0.82)

        case .spectrum:
            return mood.prefersDarkChrome ? Color.white.opacity(0.10) : Color.white.opacity(0.06)
        }
    }

    static func textMode(for theme: PromiFieldTheme, mood: PromiColorMood) -> PromiTextMode {
        mood.prefersDarkChrome ? .lightCentered : .darkCentered
    }

    /// Nombre de cellules Voronoï à générer. La formule fait croître le
    /// nombre de cellules avec le nombre de Promi+Nuées, avec un padding
    /// d'idle cells pour l'esthétique. Les plafonds sont relevés
    /// suffisamment haut pour qu'aucun utilisateur ne les atteigne en
    /// usage réel — les packs sont effectivement infinis.
    ///
    /// Performance : le Voronoï en O(n²) reste < 20ms pour n < 300 sur
    /// iPhone récent. Au-delà de 300, Cristal passe en async (déjà géré
    /// dans le cache). Les autres packs restent synchrones et fluides.
    static func baseSiteCount(for theme: PromiFieldTheme, size: CGSize, promiCount: Int) -> Int {
        let area = max(size.width * size.height, 1)
        let density = Int(area / 22_000)
        // Minimum garanti : chaque Promi/Nuée a sa cellule + idle padding.
        let needed = promiCount

        switch theme {
        case .galets:
            // Quasi-grid layout: lower density for breathing room.
            // Idle padding = 8 cells autour des Promi.
            return max(15, needed + 8)
        case .alveoles:
            // Dense honeycomb. Idle padding = density + 14.
            return max(26, density + 14 + needed)
        case .cristal:
            // Tier 1 outer compartments. Cristal a 3 niveaux (outer /
            // medium / sub), donc les outer cells sont ~1/3 du total
            // de Promi. On ajoute un scaling de base + idle.
            let scaled = Int(area / 22_000)
            return max(8, scaled + 8 + (needed + 2) / 3)
        case .mosaic:
            // Flat mosaic, medium density.
            return max(24, density + 12 + needed)
        case .vitrail:
            // Vitrail interne (pas Chrome×Vitrail qui est PNG).
            return max(24, density + 12 + needed)
        case .spectrum:
            // Très dense, petites cellules. 2× pour l'idle.
            return max(38, density + 24 + needed * 2)
        }
    }

    static func lloydIterations(for theme: PromiFieldTheme) -> Int {
        switch theme {
        case .galets: return 0
        case .alveoles: return 2
        case .cristal: return 0
        case .mosaic: return 1
        case .vitrail: return 1
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
        nuées: [Nuée],
        sortOption: PromiFieldSortOption
    ) -> PromiFieldLayout {
        let safeSize = CGSize(width: max(size.width, 1), height: max(size.height, 1))

        // Both Promis and Nuées occupy a Voronoï cell, so the site count
        // budget must account for the sum. Idle (non-promoted) cells fill
        // the rest of the field as background pavage.
        let siteCount = PromiFieldThemeConfig.baseSiteCount(
            for: theme,
            size: safeSize,
            promiCount: promis.count + nuées.count
        )

        let overscanX: CGFloat = theme == .spectrum ? 90 : 54
        let overscanYTop: CGFloat = 36
        let overscanYBottom: CGFloat = 120

        // Scale vertical : quand le nombre de cellules dépasse le seuil
        // de base (écran rempli à densité normale), on étend le canvas
        // verticalement pour que les cellules gardent une taille lisible
        // au lieu d'être compressées. Le viewport est scrollable, donc
        // l'utilisateur scrolle vers le bas pour voir les nouvelles
        // cellules — même UX que Photos.app avec beaucoup de photos.
        let baseIdleCount: CGFloat = {
            switch theme {
            case .galets: return 18
            case .alveoles: return 40
            case .cristal: return 16
            case .mosaic: return 36
            case .vitrail: return 36
            case .spectrum: return 62
            }
        }()
        let growthFactor = max(1.0, CGFloat(siteCount) / baseIdleCount)
        let scaledHeight = (safeSize.height + overscanYTop + overscanYBottom) * growthFactor

        let bounds = CGRect(
            x: -overscanX,
            y: -overscanYTop,
            width: safeSize.width + overscanX * 2,
            height: scaledHeight
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

        // Nuées are assigned FIRST to the most central cells (they're the
        // "anchor" entities — they get the prime visual real estate). Then
        // Promis are assigned to the remaining cells per the sort logic,
        // skipping any indices already claimed by a Nuée.
        let promotedNuéeMap = assignNuéesToCells(
            polygons: polygons,
            size: safeSize,
            nuées: nuées
        )

        let promotedMap = assignPromisToCells(
            polygons: polygons,
            size: safeSize,
            promis: promis,
            sortOption: sortOption,
            excluding: Set(promotedNuéeMap.keys)
        )

        let allPromotedSet = Set(promotedMap.keys).union(promotedNuéeMap.keys)

        let idleIndices = makeIdlePaletteIndices(
            theme: theme,
            adjacency: adjacency,
            polygons: polygons,
            size: safeSize,
            promotedSet: allPromotedSet
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
            let promotedNuée = promotedNuéeMap[index]

            // Fill style priority:
            //   1. If this cell is a promoted Nuée → swatch hex from the
            //      Nuée's moodHintRawValue (resolved at render time in
            //      cellView; here we just store a placeholder so the data
            //      pipeline stays uniform).
            //   2. If this cell is a promoted Promi → use the theme palette
            //      (the existing makePromotedStyles logic).
            //   3. Otherwise idle → makeIdleStyles.
            //
            // For Nuée cells we set fillStyle to .clear here because the
            // actual fill is applied in cellView via the swatch color. This
            // keeps the factory free of view-layer color resolution.
            let fill: AnyShapeStyle
            if promotedNuée != nil {
                fill = AnyShapeStyle(Color.clear)
            } else if promoted != nil {
                fill = promotedStyles[index] ?? AnyShapeStyle(Color.orange)
            } else {
                fill = idleStyles[index]
            }

            return PromiFieldCell(
                id: deterministicUUID(for: index),
                points: polygon,
                visibleBounds: visibleBoundingBox(for: polygon, viewport: viewport),
                promotedPromi: promoted,
                promotedNuée: promotedNuée,
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
                .filter { cells[$0].promotedPromi == nil && cells[$0].promotedNuée == nil }
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
                    promotedNuée: nil,
                    fillStyle: AnyShapeStyle(anchor),
                    strokeColor: original.strokeColor,
                    strokeStyle: original.strokeStyle,
                    textMode: original.textMode
                )
            }
        }

        // Cristal pack: outer compartments become stroke-only frames (transparent
        // fill). Inside each, a tier-2 medium-cell pavage is computed and clipped
        // to the outer polygon. Inside each medium, a tier-3 fine sub-pavage is
        // computed and clipped to the medium polygon. Promotion happens at the
        // medium tier — both Nuées and Promis take the place of medium alvéoles.
        //
        // Nuées are assigned FIRST to the most central medium cells (same
        // spatial logic as the outer tier: biggest visible cells closest to
        // the viewport centre). Promis are assigned AFTER, skipping any
        // medium cells already claimed by a Nuée. This mirrors the outer-tier
        // priority (Nuées are anchor entities) translated to the medium tier.
        var cristalMedium: [CristalMediumCell]? = nil
        var cristalSub: [CristalSubCell]? = nil
        if theme == .cristal {
            cells = cells.map { cell in
                PromiFieldCell(
                    id: cell.id,
                    points: cell.points,
                    visibleBounds: cell.visibleBounds,
                    promotedPromi: nil,
                    promotedNuée: nil,
                    fillStyle: AnyShapeStyle(Color.clear),
                    strokeColor: cell.strokeColor,
                    strokeStyle: cell.strokeStyle,
                    textMode: cell.textMode
                )
            }

            let nested = computeCristalNested(
                outerPolygons: polygons,
                idleIndices: idleIndices,
                mood: mood,
                seed: seedBase(for: theme)
            )

            var mediumWithPromotion = nested.medium
            var usedMediumIndices: Set<Int> = []

            // ── Phase 1: Nuées → most central medium cells ──────────
            //
            // Nuées are identity anchors. They get the prime medium-tier
            // real estate: largest visible cells closest to the viewport
            // centre. Sorted by createdAt (oldest first → most central).
            let nuéeCenter = CGPoint(x: safeSize.width * 0.50, y: safeSize.height * 0.42)
            let sortedNuéesForMedium = nuées.sorted { $0.createdAt < $1.createdAt }

            for nuée in sortedNuéesForMedium {
                var bestIdx: Int? = nil
                var bestScore = -CGFloat.greatestFiniteMagnitude
                for (idx, medium) in mediumWithPromotion.enumerated() {
                    if usedMediumIndices.contains(idx) { continue }
                    let area = polygonArea(for: medium.points)
                    let dx = medium.centroid.x - nuéeCenter.x
                    let dy = medium.centroid.y - nuéeCenter.y
                    let dist = hypot(dx, dy)
                    // Score: favour large cells close to centre.
                    let score = area - dist * 80
                    if score > bestScore {
                        bestScore = score
                        bestIdx = idx
                    }
                }
                if let idx = bestIdx {
                    let m = mediumWithPromotion[idx]
                    mediumWithPromotion[idx] = CristalMediumCell(
                        id: m.id,
                        points: m.points,
                        baseColor: m.baseColor,
                        parentOuterIndex: m.parentOuterIndex,
                        centroid: m.centroid,
                        promotedPromi: nil,
                        promotedNuée: nuée
                    )
                    usedMediumIndices.insert(idx)
                }
            }

            // ── Phase 2: Promis → remaining medium cells ────────────
            //
            // Standard sort-aware assignment, identical to pre-Nuée logic
            // but skipping any indices already claimed by a Nuée above.
            let target = preferredTarget(for: sortOption, size: safeSize)
            let sortedPromis = sortPromis(promis, by: sortOption)

            for promi in sortedPromis {
                var bestIdx: Int? = nil
                var bestDist = CGFloat.greatestFiniteMagnitude
                for (idx, medium) in mediumWithPromotion.enumerated() {
                    if usedMediumIndices.contains(idx) { continue }
                    let dx = medium.centroid.x - target.x
                    let dy = medium.centroid.y - target.y
                    let d = dx * dx + dy * dy
                    if d < bestDist {
                        bestDist = d
                        bestIdx = idx
                    }
                }
                if let idx = bestIdx {
                    let m = mediumWithPromotion[idx]
                    mediumWithPromotion[idx] = CristalMediumCell(
                        id: m.id,
                        points: m.points,
                        baseColor: m.baseColor,
                        parentOuterIndex: m.parentOuterIndex,
                        centroid: m.centroid,
                        promotedPromi: promi,
                        promotedNuée: nil
                    )
                    usedMediumIndices.insert(idx)
                }
            }

            // Keep ALL sub-cells visible — including those under promoted
            // medium cells (both Promi AND Nuée). Per user request,
            // promoted cells should NOT be filled with a solid color that
            // breaks the cristal mosaic. Instead they retain their sub-cell
            // pavage underneath, with only the thick medium border +
            // centered label marking them as promoted. For Nuée cells the
            // swatch color is applied as a semi-transparent tint at render
            // time so the sub-cell texture bleeds through slightly.
            cristalMedium = mediumWithPromotion
            cristalSub = nested.sub
        }

        // Zoom and pan are handled exclusively by the UIScrollView
        // (ZoomablePromiViewport). The layout always produces content at
        // 1:1 scale with no offset — the user controls the viewport
        // position via pinch/pan gestures, Photos-style. No more "smart
        // dezoom" that fights the scroll view and causes jumps.

        return PromiFieldLayout(
            cells: cells,
            cristalMediumCells: cristalMedium,
            nestedSubCells: cristalSub,
            bounds: bounds
        )
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

        case .alveoles, .vitrail:
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
            case .vitrail:
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
        case .nuée:
            // Groups radiate from the left so clusters read left-to-right.
            // Slightly higher than center to give swarm labels breathing room.
            return CGPoint(x: size.width * 0.28, y: size.height * 0.44)
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
        sortOption: PromiFieldSortOption,
        excluding: Set<Int> = []
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

        case .nuée:
            // Lateral grouping — same logic as .person but with the Nuée
            // target offset. Promis with the same nuéeId land in adjacent
            // cells reading left-to-right because both the Promi sort and
            // the cell rank share the same X-primary spatial ordering.
            rankedCellIndices = polygons.enumerated()
                .sorted { lhs, rhs in
                    let l = visibleBoundingBox(for: lhs.element, viewport: viewport)
                    let r = visibleBoundingBox(for: rhs.element, viewport: viewport)
                    if abs(l.midX - r.midX) > 8 { return l.midX < r.midX }
                    if abs(l.midY - r.midY) > 8 { return l.midY < r.midY }
                    return l.width * l.height > r.width * r.height
                }
                .map(\.offset)
        }

        // Filter out indices already promoted to a Nuée — Promis must not
        // overwrite Nuée cells. The Promi assignment then walks the ranked
        // list and picks the first available cells in order.
        let availableCellIndices = rankedCellIndices.filter { !excluding.contains($0) }

        var result: [Int: PromiItem] = [:]
        for (offset, promi) in sorted.enumerated() where offset < availableCellIndices.count {
            result[availableCellIndices[offset]] = promi
        }
        return result
    }

    // MARK: - Nuée attribution
    //
    // Nuées are placed BEFORE Promis on the field. Each Nuée takes the
    // most central available cell — they're the anchor entities, the
    // visual gravitational centers around which their member Promis
    // orbit. The "central" priority is intentionally simpler than
    // assignPromisToCells (which handles 5 sort options): a Nuée is
    // about identity, not about temporal/intensity ranking, so it just
    // picks the cells closest to the viewport center, biggest first.
    //
    // Nuées are assigned in `createdAt` order — the oldest Nuée gets
    // the most central cell, newer Nuées radiate outward. This gives
    // long-standing groups visual primacy on the home field.

    private static func assignNuéesToCells(
        polygons: [[CGPoint]],
        size: CGSize,
        nuées: [Nuée]
    ) -> [Int: Nuée] {
        guard !nuées.isEmpty else { return [:] }

        let viewport = CGRect(origin: .zero, size: size)
        let target = CGPoint(x: size.width * 0.50, y: size.height * 0.42)

        // Rank cells by (visibility × area) – distance to center, same
        // hybrid score as `rankedCellsForTarget` but slightly biased toward
        // larger cells so Nuées land on substantial visual real estate
        // rather than tiny edge slivers.
        let rankedCellIndices = polygons.enumerated()
            .sorted { lhs, rhs in
                let l = visibleBoundingBox(for: lhs.element, viewport: viewport)
                let r = visibleBoundingBox(for: rhs.element, viewport: viewport)

                let areaL = max(l.width * l.height, 1)
                let areaR = max(r.width * r.height, 1)

                let visibleL = areaL * visibilityScore(for: l, viewport: viewport)
                let visibleR = areaR * visibilityScore(for: r, viewport: viewport)

                let dl = hypot(l.midX - target.x, l.midY - target.y)
                let dr = hypot(r.midX - target.x, r.midY - target.y)

                let scoreL = visibleL - dl * 120
                let scoreR = visibleR - dr * 120

                if abs(scoreL - scoreR) > 800 {
                    return scoreL > scoreR
                }
                return dl < dr
            }
            .map(\.offset)

        // Sort Nuées by createdAt: oldest first → most central position.
        let sortedNuées = nuées.sorted { $0.createdAt < $1.createdAt }

        var result: [Int: Nuée] = [:]
        for (offset, nuée) in sortedNuées.enumerated() where offset < rankedCellIndices.count {
            result[rankedCellIndices[offset]] = nuée
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
        case .galets, .alveoles, .mosaic, .vitrail, .cristal:
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
        case .galets, .alveoles, .mosaic, .vitrail, .cristal:
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
        case .galets, .alveoles, .mosaic, .vitrail, .cristal:
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

        case .nuée:
            // Group by nuéeId — Promis belonging to the same Nuée cluster
            // together on the field. Personal Promis (nuéeId == nil) come
            // last. Within each group, oldest first for stable ordering.
            return promis.sorted { lhs, rhs in
                let lhsKey = lhs.nuéeId?.uuidString ?? "zzz"
                let rhsKey = rhs.nuéeId?.uuidString ?? "zzz"
                if lhsKey == rhsKey {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhsKey < rhsKey
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
        outerPolygons: [[CGPoint]],
        idleIndices: [Int],
        mood: PromiColorMood,
        seed: UInt64
    ) -> (medium: [CristalMediumCell], sub: [CristalSubCell]) {
        let palette = cristalThemedPalette(mood: mood)
        guard !palette.isEmpty, !outerPolygons.isEmpty else { return ([], []) }

        let mediumSeed = seed &+ 5_001
        let fineSeed = seed &+ 9_001

        var allMedium: [CristalMediumCell] = []
        var allSub: [CristalSubCell] = []

        for (outerIdx, outerPoly) in outerPolygons.enumerated() {
            guard outerPoly.count >= 3 else { continue }

            let bbox = polygonBoundingBox(for: outerPoly)
            guard bbox.width > 0, bbox.height > 0 else { continue }
            let outerArea = polygonArea(for: outerPoly)
            guard outerArea > 10 else { continue }
            let outerCentroidPt = polygonCentroid(for: outerPoly)

            // Tier 2: medium cells. Bumped per user "complexifie" request.
            let mediumCount = max(4, min(11, Int(outerArea / 5_500)))

            // DETERMINISTIC site placement.
            //
            // Theorem: for a convex polygon with vertices V_i and centroid C,
            // the line segment [V_i → C] lies entirely inside the polygon.
            // Therefore any point on this segment is GEOMETRICALLY guaranteed
            // to be inside, no rejection sampling needed. Voronoi cells are
            // always convex, so this works for every outer compartment, even
            // edge ones with bounds-clipped vertices and weird shapes.
            var mediumSites: [WeightedSite] = [
                WeightedSite(point: outerCentroidPt, weight: 22_000)
            ]

            let pullVertex: CGFloat = 0.35
            for vertex in outerPoly {
                if mediumSites.count >= mediumCount { break }
                let pulled = CGPoint(
                    x: vertex.x + (outerCentroidPt.x - vertex.x) * pullVertex,
                    y: vertex.y + (outerCentroidPt.y - vertex.y) * pullVertex
                )
                mediumSites.append(WeightedSite(point: pulled, weight: 22_000))
            }

            // If we still need more sites, use edge midpoints pulled toward
            // the centroid (also guaranteed inside by convexity).
            if mediumSites.count < mediumCount {
                let pullEdge: CGFloat = 0.30
                for i in 0..<outerPoly.count {
                    if mediumSites.count >= mediumCount { break }
                    let v0 = outerPoly[i]
                    let v1 = outerPoly[(i + 1) % outerPoly.count]
                    let mid = CGPoint(x: (v0.x + v1.x) / 2, y: (v0.y + v1.y) / 2)
                    let pulled = CGPoint(
                        x: mid.x + (outerCentroidPt.x - mid.x) * pullEdge,
                        y: mid.y + (outerCentroidPt.y - mid.y) * pullEdge
                    )
                    mediumSites.append(WeightedSite(point: pulled, weight: 22_000))
                }
            }

            // Optional: pad with random rejection sampling for organic variety.
            // The localIdx fix from earlier ensures the PRNG advances every
            // attempt — but even if every random point fails, we already have
            // mediumCount deterministic sites guaranteed.
            var mAttempts = 0
            var mIdx = 0
            while mediumSites.count < mediumCount && mAttempts < mediumCount * 60 {
                let rx = randomUnit(seed: mediumSeed, index: outerIdx * 200 + mIdx, stream: 211)
                let ry = randomUnit(seed: mediumSeed, index: outerIdx * 200 + mIdx, stream: 379)
                let p = CGPoint(
                    x: bbox.minX + CGFloat(rx) * bbox.width,
                    y: bbox.minY + CGFloat(ry) * bbox.height
                )
                if pointInPolygon(p, polygon: outerPoly) {
                    mediumSites.append(WeightedSite(point: p, weight: 22_000))
                }
                mIdx += 1
                mAttempts += 1
            }

            // Local Voronoi for the medium sites, with bounds slightly larger
            // than the outer compartment bbox so border cells aren't truncated.
            let localBounds = bbox.insetBy(dx: -bbox.width * 0.25, dy: -bbox.height * 0.25)
            let mediumPolygons = mediumSites.enumerated().map { idx, _ in
                VoronoiMath.weightedCellPolygon(
                    index: idx,
                    sites: mediumSites,
                    bounds: localBounds
                )
            }

            var mediumsAddedForThisOuter = 0
            for (mIdx2, mediumRaw) in mediumPolygons.enumerated() {
                // Clip the medium polygon to the outer compartment so it
                // never extends past the thick black border.
                let clippedMedium = PolygonClipper.clip(subject: mediumRaw, against: outerPoly)
                guard clippedMedium.count >= 3 else { continue }
                guard polygonArea(for: clippedMedium) > 30 else { continue }

                // Each medium gets a distinct palette slot from its outer parent.
                let baseSlot = idleIndices.indices.contains(outerIdx) ? idleIndices[outerIdx] : outerIdx
                let safeSlot = ((baseSlot + mIdx2 * 2) % palette.count + palette.count) % palette.count
                let mediumColor = palette[safeSlot]

                let medium = CristalMediumCell(
                    id: deterministicUUID(for: outerIdx * 1000 + mIdx2),
                    points: clippedMedium,
                    baseColor: mediumColor,
                    parentOuterIndex: outerIdx,
                    centroid: polygonCentroid(for: clippedMedium),
                    promotedPromi: nil,
                    promotedNuée: nil
                )
                allMedium.append(medium)
                mediumsAddedForThisOuter += 1
                let thisMediumIdx = allMedium.count - 1

                // Tier 3: fine sub-cells inside this medium cell.
                let subs = generateFineSubCells(
                    parent: medium,
                    parentMediumIdx: thisMediumIdx,
                    seed: fineSeed,
                    indexBase: outerIdx * 100_000 + mIdx2 * 1_000
                )
                allSub.append(contentsOf: subs)
            }

            // POST-CLIP FALLBACK: if every Voronoi cell got dropped during
            // clipping (extreme polygon shapes, numerical edge cases, etc),
            // we still must produce SOMETHING for this compartment otherwise
            // the user sees an empty hole inside the outer borders. We fall
            // back to "the whole compartment is one medium cell". This
            // guarantees every outer compartment has color coverage.
            if mediumsAddedForThisOuter == 0 {
                let baseSlot = idleIndices.indices.contains(outerIdx) ? idleIndices[outerIdx] : outerIdx
                let safeSlot = ((baseSlot % palette.count) + palette.count) % palette.count
                let fallbackMedium = CristalMediumCell(
                    id: deterministicUUID(for: outerIdx * 1000),
                    points: outerPoly,
                    baseColor: palette[safeSlot],
                    parentOuterIndex: outerIdx,
                    centroid: outerCentroidPt,
                    promotedPromi: nil,
                    promotedNuée: nil
                )
                allMedium.append(fallbackMedium)
                let fallbackMediumIdx = allMedium.count - 1
                let subs = generateFineSubCells(
                    parent: fallbackMedium,
                    parentMediumIdx: fallbackMediumIdx,
                    seed: fineSeed,
                    indexBase: outerIdx * 100_000
                )
                // Even the sub-cell generation has its own fallback (below);
                // if it returns empty, append a single sub = whole compartment.
                if subs.isEmpty {
                    allSub.append(CristalSubCell(
                        points: outerPoly,
                        color: palette[safeSlot],
                        parentMediumIdx: fallbackMediumIdx
                    ))
                } else {
                    allSub.append(contentsOf: subs)
                }
            }
        }

        return (allMedium, allSub)
    }

    /// Generates fine sub-cells inside a medium parent. Uses deterministic
    /// site placement (centroid + pulled vertices + edge midpoints) padded
    /// with random rejection sampling for organicity. Each fine cell is
    /// strictly clipped to the medium polygon via Sutherland-Hodgman.
    private static func generateFineSubCells(
        parent: CristalMediumCell,
        parentMediumIdx: Int,
        seed: UInt64,
        indexBase: Int
    ) -> [CristalSubCell] {
        let mediumPoly = parent.points
        guard mediumPoly.count >= 3 else { return [] }
        let bbox = polygonBoundingBox(for: mediumPoly)
        guard bbox.width > 0, bbox.height > 0 else { return [] }
        let mediumArea = polygonArea(for: mediumPoly)
        guard mediumArea > 15 else { return [] }
        let mediumCentroidPt = polygonCentroid(for: mediumPoly)

        // Density: reduced from the previous dense pattern to keep SwiftUI
        // rendering fluid now that sub-cells are rendered as individual
        // Shapes inline in the main ZStack (no .drawingGroup rasterization).
        // Targets ~2500-3500 total sub-cells on a typical iPhone home vs.
        // 5000-7000 before. Visual impact: slightly less "fractured glass"
        // granularity but still clearly cristal-style.
        let fineCount = max(8, min(40, Int(mediumArea / 130)))

        // DETERMINISTIC base sites: centroid + pulled vertices + pulled edge
        // midpoints. Same convexity theorem as the medium tier — guaranteed
        // inside the polygon, no luck involved.
        var fineSites: [WeightedSite] = [
            WeightedSite(point: mediumCentroidPt, weight: 22_000)
        ]

        let pullVertex: CGFloat = 0.40
        for vertex in mediumPoly {
            if fineSites.count >= max(4, fineCount / 3) { break }
            let pulled = CGPoint(
                x: vertex.x + (mediumCentroidPt.x - vertex.x) * pullVertex,
                y: vertex.y + (mediumCentroidPt.y - vertex.y) * pullVertex
            )
            fineSites.append(WeightedSite(point: pulled, weight: 22_000))
        }

        let pullEdge: CGFloat = 0.30
        for i in 0..<mediumPoly.count {
            if fineSites.count >= max(6, fineCount / 2) { break }
            let v0 = mediumPoly[i]
            let v1 = mediumPoly[(i + 1) % mediumPoly.count]
            let mid = CGPoint(x: (v0.x + v1.x) / 2, y: (v0.y + v1.y) / 2)
            let pulled = CGPoint(
                x: mid.x + (mediumCentroidPt.x - mid.x) * pullEdge,
                y: mid.y + (mediumCentroidPt.y - mid.y) * pullEdge
            )
            fineSites.append(WeightedSite(point: pulled, weight: 22_000))
        }

        // Pad with random rejection sampling for organic variety, with the
        // localIdx-fixed PRNG. Even if every random point fails, the
        // deterministic baseline above gives us enough sites to render.
        var attempts = 0
        var localIdx = 0
        while fineSites.count < fineCount && attempts < fineCount * 60 {
            let rx = randomUnit(seed: seed, index: indexBase + localIdx, stream: 137)
            let ry = randomUnit(seed: seed, index: indexBase + localIdx, stream: 449)
            let p = CGPoint(
                x: bbox.minX + CGFloat(rx) * bbox.width,
                y: bbox.minY + CGFloat(ry) * bbox.height
            )
            if pointInPolygon(p, polygon: mediumPoly) {
                fineSites.append(WeightedSite(point: p, weight: 22_000))
            }
            localIdx += 1
            attempts += 1
        }

        guard !fineSites.isEmpty else { return [] }

        let localBounds = bbox.insetBy(dx: -bbox.width * 0.30, dy: -bbox.height * 0.30)
        let finePolygons = fineSites.enumerated().map { idx, _ in
            VoronoiMath.weightedCellPolygon(
                index: idx,
                sites: fineSites,
                bounds: localBounds
            )
        }

        var result: [CristalSubCell] = []
        result.reserveCapacity(finePolygons.count)

        for (idx, fineRaw) in finePolygons.enumerated() {
            let clippedFine = PolygonClipper.clip(subject: fineRaw, against: mediumPoly)
            guard clippedFine.count >= 3 else { continue }

            let rawL = randomUnit(seed: seed &+ 7_777, index: indexBase + idx, stream: 333)
            let rawS = randomUnit(seed: seed &+ 8_888, index: indexBase + idx, stream: 444)
            let lightnessDelta = CGFloat(rawL - 0.5) * 0.42
            let saturationDelta = CGFloat(rawS - 0.5) * 0.30
            let varied = adjustColor(
                parent.baseColor,
                lightness: lightnessDelta,
                saturation: saturationDelta
            )

            result.append(CristalSubCell(
                points: clippedFine,
                color: varied,
                parentMediumIdx: parentMediumIdx
            ))
        }

        // POST-CLIP FALLBACK: if every fine Voronoi cell got dropped during
        // clipping, return a single sub-cell that IS the medium polygon. This
        // guarantees every medium cell has at least one visible sub-cell so
        // the user never sees a transparent hole inside a medium border.
        if result.isEmpty {
            result.append(CristalSubCell(
                points: mediumPoly,
                color: parent.baseColor,
                parentMediumIdx: parentMediumIdx
            ))
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
        case .vitrail: return 23_921
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
        case .vitrail:
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
        case .trameJardin, .trameObsidienne, .trameAdobe, .trameConfettis:
            // Les moods Trame n'utilisent pas cette palette (géométrie
            // dédiée avec contour + point). Fallback neutre pour satisfaire
            // le switch exhaustif sans impacter les autres packs.
            return [
                Color.gray, Color.gray, Color.gray, Color.gray, Color.gray
            ]
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

        case .vitrailCathédrale:
            return [
                Color(red: 0.78, green: 0.12, blue: 0.18),
                Color(red: 0.12, green: 0.22, blue: 0.62),
                Color(red: 0.86, green: 0.58, blue: 0.18),
                Color(red: 0.10, green: 0.50, blue: 0.32),
                Color(red: 0.42, green: 0.18, blue: 0.58)
            ]

        case .vitrailAube:
            return [
                Color(red: 0.98, green: 0.72, blue: 0.82),
                Color(red: 0.78, green: 0.72, blue: 0.95),
                Color(red: 0.68, green: 0.86, blue: 0.98),
                Color(red: 0.99, green: 0.82, blue: 0.68),
                Color(red: 0.72, green: 0.94, blue: 0.84)
            ]

        case .vitrailNuit:
            return [
                Color(red: 0.14, green: 0.16, blue: 0.42),
                Color(red: 0.36, green: 0.18, blue: 0.42),
                Color(red: 0.48, green: 0.10, blue: 0.18),
                Color(red: 0.10, green: 0.26, blue: 0.18),
                Color(red: 0.16, green: 0.16, blue: 0.20)
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

// MARK: - Nuée cell label (icon + name centered on a promoted Nuée cell)
//
// Renders the Nuée's SF Symbol icon centered on the cell, with the Nuée's
// name underneath. The icon size scales with the cell dimensions so a
// large central Nuée gets a prominent badge while a smaller cell gets a
// compact one. Both icon and name use white-with-shadow so they remain
// legible against any swatch hex color (the cell's fill is the swatch).

fileprivate struct NuéeCellIconLabel: View {
    let nuée: Nuée
    let frame: CGRect

    var body: some View {
        VStack(spacing: spacing) {
            Image(systemName: nuée.displayIconGlyph)
                .font(.system(size: iconSize, weight: .regular))
                .foregroundColor(.white.opacity(0.96))
                .shadow(color: .black.opacity(0.32), radius: 4, x: 0, y: 1)

            if showName {
                Text(nuée.name)
                    .font(.system(size: nameSize, weight: .semibold))
                    .foregroundColor(.white.opacity(0.94))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .shadow(color: .black.opacity(0.32), radius: 3, x: 0, y: 1)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(width: textWidth, height: textHeight, alignment: .center)
        .position(x: frame.midX, y: frame.midY)
    }

    // MARK: Sizing

    /// Hide the name on tiny cells where it would be unreadable. The icon
    /// alone still communicates "this is a Nuée" via its distinct visual.
    private var showName: Bool {
        frame.width > 70 && frame.height > 50
    }

    private var iconSize: CGFloat {
        let candidate = min(frame.width * 0.30, frame.height * 0.36)
        return max(16, min(candidate, 48))
    }

    private var nameSize: CGFloat {
        let candidate = min(frame.width * 0.10, frame.height * 0.14)
        return max(10, min(candidate, 16))
    }

    private var spacing: CGFloat {
        showName ? max(4, frame.height * 0.04) : 0
    }

    private var horizontalPadding: CGFloat {
        max(4, min(12, frame.width * 0.08))
    }

    private var textWidth: CGFloat {
        max(36, min(frame.width * 0.84, frame.width - 8))
    }

    private var textHeight: CGFloat {
        max(28, min(frame.height * 0.80, frame.height - 6))
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

fileprivate func polygonArea(for points: [CGPoint]) -> CGFloat {
    guard points.count >= 3 else { return 0 }
    var sum: CGFloat = 0
    for i in points.indices {
        let p0 = points[i]
        let p1 = points[(i + 1) % points.count]
        sum += p0.x * p1.y - p1.x * p0.y
    }
    return abs(sum) * 0.5
}

fileprivate func pointInPolygon(_ point: CGPoint, polygon: [CGPoint]) -> Bool {
    guard polygon.count >= 3 else { return false }
    var inside = false
    var j = polygon.count - 1
    for i in polygon.indices {
        let pi = polygon[i]
        let pj = polygon[j]
        if ((pi.y > point.y) != (pj.y > point.y)) {
            let xCross = (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x
            if point.x < xCross {
                inside.toggle()
            }
        }
        j = i
    }
    return inside
}

/// Sutherland-Hodgman polygon clipping. Clips a subject polygon against a
/// convex clip polygon. Voronoi cells are always convex so this works for
/// any compartment-against-compartment clipping in the Cristal three-tier
/// pipeline. Returns the clipped polygon vertices, or empty if no overlap.
fileprivate enum PolygonClipper {
    /// Clips a subject polygon against a convex clip polygon. Works in any
    /// coordinate system (Y-up or Y-down) and any winding order, because we
    /// determine "inside" empirically per edge by testing the centroid of
    /// the clip polygon — which is always inside a convex polygon. This
    /// avoids all the orientation pitfalls of textbook Sutherland-Hodgman.
    static func clip(subject: [CGPoint], against clipPoly: [CGPoint]) -> [CGPoint] {
        guard clipPoly.count >= 3, subject.count >= 3 else { return [] }

        // Centroid of the clip polygon — guaranteed inside since it's convex.
        var cx: CGFloat = 0
        var cy: CGFloat = 0
        for p in clipPoly {
            cx += p.x
            cy += p.y
        }
        cx /= CGFloat(clipPoly.count)
        cy /= CGFloat(clipPoly.count)
        let center = CGPoint(x: cx, y: cy)

        var output = subject

        for i in 0..<clipPoly.count {
            guard !output.isEmpty else { return [] }
            let edgeA = clipPoly[i]
            let edgeB = clipPoly[(i + 1) % clipPoly.count]

            // Determine which sign of the cross-product corresponds to "inside"
            // for this edge by testing the centroid.
            let centerCross = sideOf(point: center, edgeA: edgeA, edgeB: edgeB)
            let insideIsPositive = centerCross >= 0

            let input = output
            output.removeAll(keepingCapacity: true)

            for j in 0..<input.count {
                let current = input[j]
                let prev = input[(j + input.count - 1) % input.count]

                let currentCross = sideOf(point: current, edgeA: edgeA, edgeB: edgeB)
                let prevCross = sideOf(point: prev, edgeA: edgeA, edgeB: edgeB)

                let currentInside = insideIsPositive ? currentCross >= 0 : currentCross <= 0
                let prevInside = insideIsPositive ? prevCross >= 0 : prevCross <= 0

                if currentInside {
                    if !prevInside, let intersect = lineIntersection(prev, current, edgeA, edgeB) {
                        output.append(intersect)
                    }
                    output.append(current)
                } else if prevInside, let intersect = lineIntersection(prev, current, edgeA, edgeB) {
                    output.append(intersect)
                }
            }
        }

        return output
    }

    /// Z-component of the cross product (edgeB - edgeA) × (point - edgeA).
    /// The sign tells which side of the directed edge the point is on; the
    /// caller decides which sign means "inside".
    private static func sideOf(point: CGPoint, edgeA: CGPoint, edgeB: CGPoint) -> CGFloat {
        return (edgeB.x - edgeA.x) * (point.y - edgeA.y)
             - (edgeB.y - edgeA.y) * (point.x - edgeA.x)
    }

    private static func lineIntersection(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ p4: CGPoint) -> CGPoint? {
        let denom = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
        guard abs(denom) > 1e-10 else { return nil }

        let t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / denom
        return CGPoint(
            x: p1.x + t * (p2.x - p1.x),
            y: p1.y + t * (p2.y - p1.y)
        )
    }
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


// MARK: - Tour 3a Vitrail Chrome — fondations

import UIKit

extension Color {
    func lighter(_ amount: CGFloat = 0.2) -> Color {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(UIColor(hue: h, saturation: s, brightness: min(1, b + amount), alpha: a))
    }
    func darker(_ amount: CGFloat = 0.2) -> Color {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(UIColor(hue: h, saturation: s, brightness: max(0, b - amount), alpha: a))
    }
}

fileprivate struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0xDEADBEEF : seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
