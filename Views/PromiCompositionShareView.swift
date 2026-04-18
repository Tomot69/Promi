import SwiftUI
import UIKit

// MARK: - PromiCompositionShareView
//
// Page "Composition & Partage" accessible depuis le bouton partage du dock.
// Design chrome cohérent avec les autres pages : PromiChromePageBackground
// (mood-aware, même recette que CompactMenuSurface) + titre "Mon Promi" avec
// "Promi" en orange + chips template chrome + bouton Partager orange.
//
// La preview card au centre, elle, conserve son propre système visuel car
// c'est le RENDU final de l'image qui sera partagée — ses couleurs doivent
// s'adapter au mood pour que l'export ait de la légitimité.

struct PromiCompositionShareView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var nuéeStore: NuéeStore

    let pack: PromiVisualPack
    let mood: PromiColorMood
    let sortOption: PromiFieldSortOption

    /// Taille de l'écran home, passée par ContentView. Le champ sera
    /// rendu à cette taille pour reproduire le même layout Voronoï
    /// que la home — c'est SA toile, pas une version réduite.
    let homeSize: CGSize

    @State private var hideText = false
    /// Alignement du logo promi.app en bas : trailing (défaut) ou leading.
    /// Le logo est toujours visible, pas supprimable, mais déplaçable.
    @State private var signatureAlignment: HorizontalAlignment = .trailing
    @State private var selectedTemplate: PromiShareTemplate = .instagramStory
    @State private var shareImage: UIImage?
    @State private var isPreparingShare = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

    // Crop : zoom + pan pour choisir la zone à partager.
    // Le champ est rendu à taille fixe, l'utilisateur zoome/pane
    // dans la fenêtre de preview — ce qui est visible = ce qui est
    // partagé. Pinch = zoom, drag 1 doigt = pan.
    @State private var cropScale: CGFloat = 1.0
    @State private var cropOffset: CGSize = .zero
    @State private var lastCropScale: CGFloat = 1.0
    @State private var lastCropOffset: CGSize = .zero

    // Promi individuels à exclure de la composition (non affichés ni
    // dans la preview ni dans l'export). L'utilisateur toggle via la
    // liste « Visible / Masqué » dans les contrôles.
    @State private var excludedPromiIds: Set<UUID> = []
    @State private var excludedNuéeIds: Set<UUID> = []
    @State private var showPromiPicker = false


    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    // MARK: - Body
    //
    // Layout priority: the preview card is the HERO element — it takes
    // all available vertical space. Controls, toggles and the share CTA
    // sit below in a compact stack. The user sees their composition
    // first, configures second, shares third.

    var body: some View {
        NavigationStack {
            ZStack {
                PromiChromePageBackground(
                    pack: pack,
                    mood: mood,
                    promis: promiStore.promis,
                    languageCode: userStore.selectedLanguage
                )

                VStack(spacing: 0) {
                    header
                    previewArea
                    bottomControls
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: shareItems)
            }
            .sheet(isPresented: $showPromiPicker) {
                SharePromiFilterSheet(
                    promis: promiStore.promis.filter { $0.status != .done },
                    nuées: nuéeStore.activeNuées(for: userStore.localUserId),
                    excludedPromiIds: $excludedPromiIds,
                    excludedNuéeIds: $excludedNuéeIds,
                    isEnglish: isEnglish
                )
            }
        }
    }

    // MARK: - Promis (home-mirrored sorting)

    private var visiblePromis: [PromiItem] {
        promiStore.promis
            .filter { $0.status != .done }
            .filter { !excludedPromiIds.contains($0.id) }
    }

    private var visibleNuées: [Nuée] {
        nuéeStore.activeNuées(for: userStore.localUserId)
            .filter { !excludedNuéeIds.contains($0.id) }
    }

    private var sortedPromis: [PromiItem] {
        switch sortOption {
        case .date:
            return visiblePromis.sorted { $0.dueDate < $1.dueDate }

        case .urgency:
            let now = Date()
            return visiblePromis.sorted {
                abs($0.dueDate.timeIntervalSince(now)) < abs($1.dueDate.timeIntervalSince(now))
            }

        case .person:
            return visiblePromis.sorted {
                let lhs = ($0.assignee ?? "").localizedLowercase
                let rhs = ($1.assignee ?? "").localizedLowercase
                if lhs == rhs {
                    return $0.createdAt < $1.createdAt
                }
                return lhs < rhs
            }

        case .importance:
            return visiblePromis.sorted { lhs, rhs in
                if lhs.intensity == rhs.intensity {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhs.intensity > rhs.intensity
            }

        case .inspiration:
            return visiblePromis.sorted { lhs, rhs in
                stableRank(lhs) < stableRank(rhs)
            }

        case .nuée:
            return visiblePromis.sorted { lhs, rhs in
                let lhsKey = lhs.nuéeId?.uuidString ?? "zzz"
                let rhsKey = rhs.nuéeId?.uuidString ?? "zzz"
                if lhsKey == rhsKey {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhsKey < rhsKey
            }
        }
    }

    private func stableRank(_ promi: PromiItem) -> Int {
        var hasher = Hasher()
        hasher.combine(promi.id)
        hasher.combine(promi.createdAt.timeIntervalSinceReferenceDate)
        return abs(hasher.finalize())
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                titleAttributed
                    .font(.system(size: 28, weight: .light))

                Text(isEnglish ? "share your composition" : "partage ta composition")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.48))
                    .tracking(0.2)
            }

            Spacer()

            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    /// "Partager" with "Promi" style — or "Mon Promi" with orange accent.
    private var titleAttributed: Text {
        let raw = isEnglish ? "My Promi" : "Mon Promi"
        var attributed = AttributedString(raw)
        attributed.foregroundColor = Color.white.opacity(0.94)

        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = Brand.orange
        }

        return Text(attributed)
    }

    private var closeButton: some View {
        Button {
            Haptics.shared.lightTap()
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.86))
                Text(isEnglish ? "Close" : "Fermer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(chromePill)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom controls (under the preview)
    //
    // Compact stack: template chips → toggles → share CTA → hint.
    // Everything below the preview, so the composition stays the hero.

    @ViewBuilder
    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Template chips (horizontal scroll)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PromiShareTemplate.allCases, id: \.self) { template in
                        templateChip(template)
                    }
                }
                .padding(.horizontal, 20)
            }

            // Toggles row: text visible + signature Promi
            HStack(spacing: 10) {
                iconToggle(
                    icon: hideText ? "eye.slash" : "eye",
                    label: hideText
                        ? (isEnglish ? "Hidden" : "Masqués")
                        : (isEnglish ? "Visible" : "Visibles"),
                    isActive: !hideText
                ) {
                    Haptics.shared.tinyPop()
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                        hideText.toggle()
                    }
                }

                iconToggle(
                    icon: signatureAlignment == .trailing
                        ? "text.alignright"
                        : "text.alignleft",
                    label: "promi.app",
                    isActive: true
                ) {
                    Haptics.shared.tinyPop()
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                        signatureAlignment = signatureAlignment == .trailing
                            ? .leading
                            : .trailing
                    }
                }

                iconToggle(
                    icon: "checklist",
                    label: (excludedPromiIds.isEmpty && excludedNuéeIds.isEmpty)
                        ? (isEnglish ? "All" : "Tous")
                        : (isEnglish ? "Filtered" : "Filtré"),
                    isActive: !excludedPromiIds.isEmpty || !excludedNuéeIds.isEmpty
                ) {
                    Haptics.shared.tinyPop()
                    showPromiPicker = true
                }

                Spacer()
            }
            .padding(.horizontal, 20)

            // Full-width share CTA
            Button(action: prepareShare) {
                HStack(spacing: 8) {
                    if isPreparingShare {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                    }

                    Text(isPreparingShare
                         ? (isEnglish ? "Preparing…" : "Préparation…")
                         : (isEnglish ? "Share" : "Partager"))
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color.white.opacity(0.96))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Brand.orange.opacity(isPreparingShare ? 0.54 : 0.86))
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 0.6)
                    }
                )
            }
            .buttonStyle(.plain)
            .disabled(isPreparingShare)
            .padding(.horizontal, 20)

            // Template hint (subtle description)
            Text(selectedTemplate.shareHint(isEnglish: isEnglish))
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.42))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .animation(.spring(response: 0.30, dampingFraction: 0.88), value: selectedTemplate)
        }
        .padding(.bottom, 24)
        .padding(.top, 8)
    }

    // MARK: - Icon toggle (compact, visual)

    @ViewBuilder
    private func iconToggle(
        icon: String,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        isActive
                            ? Brand.orange.opacity(0.86)
                            : Color.white.opacity(0.52)
                    )

                Text(label)
                    .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                    .foregroundColor(Color.white.opacity(isActive ? 0.92 : 0.62))
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(isActive ? 0.12 : 0.04))
                    Capsule(style: .continuous)
                        .stroke(
                            Color.white.opacity(isActive ? 0.22 : 0.10),
                            lineWidth: 0.6
                        )
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Template chip (chrome card)

    @ViewBuilder
    private func templateChip(_ template: PromiShareTemplate) -> some View {
        let isSelected = selectedTemplate == template

        Button {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                selectedTemplate = template
            }
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(template.title(isEnglish: isEnglish))
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(
                        isSelected
                            ? Color.white.opacity(0.98)
                            : Color.white.opacity(0.84)
                    )

                Text(template.subtitle(isEnglish: isEnglish))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(
                        isSelected
                            ? Color.white.opacity(0.82)
                            : Color.white.opacity(0.54)
                    )
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            isSelected
                                ? Color.white.opacity(0.14)
                                : Color.white.opacity(0.05)
                        )
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isSelected
                                ? Color.white.opacity(0.24)
                                : Color.white.opacity(0.12),
                            lineWidth: 0.6
                        )
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview area
    //
    // The preview is the HERO — it takes all remaining vertical space
    // via Spacer-free GeometryReader. The composition card is centered
    // and sized to fit the available area with generous margins.

    /// Échelle de base : la toile complète (homeSize) tient dans la
    /// carte (cardSize). C'est le multiplicateur appliqué quand
    /// cropScale = 1.0 (vue d'ensemble). cropScale > 1.0 = zoom.
    /// Échelle de base : la toile (homeSize) REMPLIT la carte (cardSize)
    /// sans vide. max() garantit que la dimension la plus courte de la
    /// toile couvre la carte — la dimension la plus longue déborde et
    /// est clippée. L'utilisateur peut paner pour cadrer la zone souhaitée.
    private func fitScale(cardSize: CGSize) -> CGFloat {
        guard homeSize.width > 0, homeSize.height > 0 else { return 1.0 }
        return max(
            cardSize.width / homeSize.width,
            cardSize.height / homeSize.height
        )
    }

    /// Offset libre mais borné pour que la toile ne sorte pas
    /// complètement du cadre. L'utilisateur peut laisser du vide
    /// sur les bords s'il veut cadrer un coin spécifique.
    private func clampedOffset(_ raw: CGSize, effectiveScale: CGFloat, cardSize: CGSize) -> CGSize {
        let apparentW = homeSize.width * effectiveScale
        let apparentH = homeSize.height * effectiveScale
        // La toile peut se décaler jusqu'à sa propre largeur/hauteur
        // dans chaque direction — assez pour explorer tout le champ.
        let maxX = max(apparentW, cardSize.width) / 2
        let maxY = max(apparentH, cardSize.height) / 2
        return CGSize(
            width:  min(maxX, max(-maxX, raw.width)),
            height: min(maxY, max(-maxY, raw.height))
        )
    }

    @ViewBuilder
    private var previewArea: some View {
        GeometryReader { geo in
            let inset: CGFloat = 20
            let available = CGSize(
                width: max(140, geo.size.width - inset * 2),
                height: max(140, geo.size.height - inset * 2)
            )
            let canvas = selectedTemplate.canvasSize(fitting: available)
            // effective = fitScale × cropScale.
            // cropScale=1.0 → vue d'ensemble (toile complète).
            // cropScale=2.0 → zoomé 2× dans la toile.
            let fit = fitScale(cardSize: canvas)
            let effective = fit * cropScale

            CompositionPreviewCard(
                size: canvas,
                fieldSize: homeSize,
                pack: pack,
                mood: mood,
                promis: sortedPromis,
                nuées: visibleNuées,
                languageCode: userStore.selectedLanguage,
                sortOption: sortOption,
                hideText: hideText,
                signatureAlignment: signatureAlignment,
                title: isEnglish ? "My Promi" : "Mon Promi",
                subtitle: selectedTemplate.previewBadge,
                fieldScale: effective,
                fieldOffset: clampedOffset(cropOffset, effectiveScale: effective, cardSize: canvas)
            )
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        let raw = CGSize(
                            width: lastCropOffset.width + value.translation.width,
                            height: lastCropOffset.height + value.translation.height
                        )
                        cropOffset = clampedOffset(raw, effectiveScale: effective, cardSize: canvas)
                    }
                    .onEnded { _ in
                        cropOffset = clampedOffset(cropOffset, effectiveScale: effective, cardSize: canvas)
                        lastCropOffset = cropOffset
                    }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { value in
                        // minCrop : échelle à laquelle la toile complète
                        // tient dans le cadre (sans crop, avec du vide).
                        // fitScale utilise max() → remplit le cadre.
                        // min()/max() ratio → vue d'ensemble complète.
                        let newCrop = max(0.15, min(5.0, lastCropScale * value.magnification))
                        cropScale = newCrop
                        let newEffective = fit * newCrop
                        cropOffset = clampedOffset(cropOffset, effectiveScale: newEffective, cardSize: canvas)
                    }
                    .onEnded { _ in
                        lastCropScale = cropScale
                        lastCropOffset = cropOffset
                    }
            )
            .overlay(alignment: .bottomTrailing) {
                if cropScale > 1.01 {
                    Button {
                        Haptics.shared.tinyPop()
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                            cropScale = 1.0
                            cropOffset = .zero
                            lastCropScale = 1.0
                            lastCropOffset = .zero
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 9, weight: .bold))
                            Text("\(Int(cropScale * 100))%")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(Color.white.opacity(0.86))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.black.opacity(0.54)))
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
            }
            .animation(.spring(response: 0.40, dampingFraction: 0.86), value: selectedTemplate)
            .animation(.spring(response: 0.40, dampingFraction: 0.86), value: hideText)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(inset)
        }
    }

    // MARK: - Chrome pill helper

    private var chromePill: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.22))
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    // MARK: - Share rendering

    private func prepareShare() {
        guard !isPreparingShare else { return }

        Haptics.shared.lightTap()
        isPreparingShare = true

        let renderSize = selectedTemplate.renderSize
        let fit = fitScale(cardSize: renderSize)
        let effective = fit * cropScale
        let scaleFactor = renderSize.width / 300.0
        let renderOffset = clampedOffset(
            CGSize(
                width: cropOffset.width * scaleFactor,
                height: cropOffset.height * scaleFactor
            ),
            effectiveScale: effective,
            cardSize: renderSize
        )

        let view = CompositionPreviewCard(
            size: renderSize,
            fieldSize: homeSize,
            pack: pack,
            mood: mood,
            promis: sortedPromis,
            nuées: visibleNuées,
            languageCode: userStore.selectedLanguage,
            sortOption: sortOption,
            hideText: hideText,
            signatureAlignment: signatureAlignment,
            title: isEnglish ? "My Promi" : "Mon Promi",
            subtitle: selectedTemplate.previewBadge,
            fieldScale: cropScale,
            fieldOffset: renderOffset
        )
        .frame(width: renderSize.width + 12, height: renderSize.height + 12)

        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(
            width: renderSize.width + 12,
            height: renderSize.height + 12
        )
        renderer.scale = displayScale

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let image = renderer.uiImage {
                shareImage = image
                shareItems = makeShareItems(with: image)
                showShareSheet = true
            }
            isPreparingShare = false
        }
    }

    private var displayScale: CGFloat {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            return scene.screen.scale
        }
        return 3.0
    }

    /// Share items: image ONLY. Passing a String alongside the image causes
    /// many social apps (Instagram, X, Pinterest) to not appear in the
    /// UIActivityViewController because they don't support mixed content.
    /// With image-only, all image-capable apps show up: Instagram, X,
    /// LinkedIn, Pinterest, Messages, Mail, Save to Photos, etc.
    private func makeShareItems(with image: UIImage) -> [Any] {
        [image]
    }
}

// MARK: - Composition card (Promi-styled, uses PromiFieldPreviewView)
//
// This is the SHAREABLE render — it's independent from the chrome page
// background. Its visual system stays mood-adaptive so the exported image
// has the mood's full colors, not the muted chrome version.

private struct CompositionPreviewCard: View {
    /// Taille de la fenêtre de crop (= template dimensions).
    let size: CGSize
    /// Taille réelle du champ Voronoï (= taille écran home).
    let fieldSize: CGSize
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let promis: [PromiItem]
    let nuées: [Nuée]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let hideText: Bool
    let signatureAlignment: HorizontalAlignment
    let title: String
    let subtitle: String
    /// Échelle appliquée au champ Voronoï à l'intérieur de la carte.
    /// Les bordures et overlays restent fixes — seul le champ bouge.
    var fieldScale: CGFloat = 1.0
    var fieldOffset: CGSize = .zero

   var body: some View {
        ZStack {
            // Fond de la carte (visible quand le champ est dézoomé).
            mood.homeBackground
                .frame(width: size.width, height: size.height)

            // Couche 1 : le champ Voronoï. Quand zoomé il déborde et
            // est clippé par le ZStack. Quand dézoomé il apparaît en
            // entier avec ses coins arrondis naturels — comme la home
            // en miniature, positionnable librement dans la carte.
            PromiFieldPreviewView(
                pack: pack,
                mood: mood,
                size: fieldSize,
                promis: promis,
                nuées: nuées,
                languageCode: languageCode,
                sortOption: sortOption
            )
            .frame(width: fieldSize.width, height: fieldSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(fieldScale, anchor: .center)
            .offset(fieldOffset)

            // Couche 2 : titre + sous-titre (masquable).
            if !hideText {
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: titleSize, weight: .light))
                                .foregroundColor(overlayTextColor)
                            Text(subtitle)
                                .font(.system(size: subtitleSize, weight: .medium))
                                .foregroundColor(overlayTextColor.opacity(0.72))
                        }
                        .padding(.horizontal, plateHorizontal)
                        .padding(.vertical, plateVertical)
                        .background(overlayPlate)
                        Spacer()
                    }
                    .padding(overlayPadding)
                    Spacer()
                }
                .frame(width: size.width, height: size.height)
            }

            // Couche 3 : promi.app — TOUJOURS visible, jamais masquable.
            VStack {
                Spacer()
                HStack {
                    if signatureAlignment == .trailing { Spacer() }
                    Text("promi.app")
                        .font(.system(size: footerSize, weight: .semibold))
                        .foregroundColor(overlayTextColor.opacity(0.88))
                    if signatureAlignment == .leading { Spacer() }
                }
                .padding(.horizontal, overlayPadding + 6)
                .padding(.bottom, overlayPadding + 6)
            }
            .frame(width: size.width, height: size.height)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.38), lineWidth: 1)
        )
        .padding(6)
        .frame(width: size.width + 12, height: size.height + 12)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius + 6, style: .continuous)
                .fill(Color.black.opacity(0.06))
        )
        .shadow(color: .black.opacity(0.32), radius: 30, x: 0, y: 14)
    }

    @ViewBuilder
    private var overlayPlates: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: titleSize, weight: .light))
                        .foregroundColor(overlayTextColor)

                    Text(subtitle)
                        .font(.system(size: subtitleSize, weight: .medium))
                        .foregroundColor(overlayTextColor.opacity(0.72))
                }
                .padding(.horizontal, plateHorizontal)
                .padding(.vertical, plateVertical)
                .background(overlayPlate)

                Spacer()
            }
            .padding(overlayPadding)

            Spacer()

            // Logo promi.app : toujours visible, jamais supprimable.
            // Fond semi-transparent pour garantir la lisibilité à
            // l'export (ImageRenderer + compression Instagram/X).
            HStack {
                if signatureAlignment == .trailing { Spacer() }

                Text("promi.app")
                    .font(.system(size: footerSize, weight: .semibold))
                    .foregroundColor(overlayTextColor.opacity(0.88))

                if signatureAlignment == .leading { Spacer() }
            }
            .padding(.horizontal, overlayPadding + 6)
            .padding(.bottom, overlayPadding + 6)
        }
    }

    private var overlayTextColor: Color {
        mood.prefersDarkChrome ? .white.opacity(0.97) : .black.opacity(0.86)
    }

    private var overlayPlate: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(mood.prefersDarkChrome ? 0.10 : 0.26))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    Color.white.opacity(mood.prefersDarkChrome ? 0.20 : 0.44),
                    lineWidth: 0.8
                )
        }
    }

    // textFooter supprimé — le logo promi.app est toujours affiché
    // directement dans overlayPlates, sans conditionnalité.

    // MARK: Sizing (scales with canvas)

    private var cardCornerRadius: CGFloat {
        min(34, max(18, size.width * 0.045))
    }

    private var titleSize: CGFloat {
        min(36, max(22, size.width * 0.072))
    }

    private var subtitleSize: CGFloat {
        min(16, max(11, size.width * 0.028))
    }

    private var footerSize: CGFloat {
        min(15, max(10, size.width * 0.024))
    }

    private var plateHorizontal: CGFloat {
        min(20, max(12, size.width * 0.036))
    }

    private var plateVertical: CGFloat {
        min(14, max(10, size.width * 0.026))
    }

    private var overlayPadding: CGFloat {
        min(24, max(14, size.width * 0.042))
    }
}

// MARK: - Templates

private enum PromiShareTemplate: CaseIterable {
    case instagramStory
    case instagramPost
    case xPost
    case linkedinPost
    case pinterestPin

    func title(isEnglish: Bool) -> String {
        switch self {
        case .instagramStory: return "Story"
        case .instagramPost:  return isEnglish ? "Square post" : "Post carré"
        case .xPost:          return isEnglish ? "X / landscape" : "X / paysage"
        case .linkedinPost:   return "LinkedIn"
        case .pinterestPin:   return "Pinterest"
        }
    }

    func subtitle(isEnglish: Bool) -> String {
        switch self {
        case .instagramStory: return isEnglish ? "9:16, immersive" : "9:16, immersif"
        case .instagramPost:  return isEnglish ? "1:1, clean" : "1:1, propre"
        case .xPost:          return isEnglish ? "16:9, wide" : "16:9, large"
        case .linkedinPost:   return isEnglish ? "4:5, editorial" : "4:5, éditorial"
        case .pinterestPin:   return isEnglish ? "2:3, vertical" : "2:3, vertical"
        }
    }

    var previewBadge: String {
        switch self {
        case .instagramStory: return "Story"
        case .instagramPost:  return "Post"
        case .xPost:          return "X"
        case .linkedinPost:   return "LinkedIn"
        case .pinterestPin:   return "Pinterest"
        }
    }

    func shareHint(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .instagramStory: return "Ideal for an immersive vertical post, with logo and composition fully readable."
            case .instagramPost:  return "Simple, clean and centered format — perfect for a classic, elegant post."
            case .xPost:          return "Wide version for a more panoramic composition, suited to quick posts."
            case .linkedinPost:   return "Editorial, slower reading pace — fits a promise told with sobriety."
            case .pinterestPin:   return "Vertical, ample and highly visual — useful to highlight a strong composition."
            }
        } else {
            switch self {
            case .instagramStory: return "Idéal pour une publication immersive verticale, avec logo et composition bien lisibles."
            case .instagramPost:  return "Format simple, net et centré, parfait pour un post classique et esthétique."
            case .xPost:          return "Version large pour une composition plus panoramique, adaptée aux posts rapides."
            case .linkedinPost:   return "Lecture éditoriale et plus posée, adaptée à une promesse racontée sobrement."
            case .pinterestPin:   return "Vertical, ample et très visuel, utile pour mettre en avant une composition forte."
            }
        }
    }

    func captionText(isEnglish: Bool) -> String {
        isEnglish ? "My Promi" : "Mon Promi"
    }

    /// Aspect ratio expressed as width / height.
    var aspectRatio: CGFloat {
        switch self {
        case .instagramStory: return 9.0 / 16.0
        case .instagramPost:  return 1.0
        case .xPost:          return 16.0 / 9.0
        case .linkedinPost:   return 4.0 / 5.0
        case .pinterestPin:   return 2.0 / 3.0
        }
    }

    /// Fit canvas into `available` keeping aspect ratio — never exceeds either dimension.
    func canvasSize(fitting available: CGSize) -> CGSize {
        let availableW = max(140, available.width)
        let availableH = max(140, available.height)
        let ratio = aspectRatio

        // Candidate: constrained by width
        let byWidth = CGSize(width: availableW, height: availableW / ratio)
        if byWidth.height <= availableH {
            return byWidth
        }

        // Candidate: constrained by height
        let byHeight = CGSize(width: availableH * ratio, height: availableH)
        return byHeight
    }

    var renderSize: CGSize {
        switch self {
        case .instagramStory: return CGSize(width: 1080, height: 1920)
        case .instagramPost:  return CGSize(width: 1080, height: 1080)
        case .xPost:          return CGSize(width: 1600, height: 900)
        case .linkedinPost:   return CGSize(width: 1200, height: 1500)
        case .pinterestPin:   return CGSize(width: 1000, height: 1500)
        }
    }
}

// MARK: - Share sheet bridge

// MARK: - CGSize scaling helper

private extension CGSize {
    /// Multiplie les deux composantes par un facteur. Sert à transposer
    /// l'offset de la preview (en points écran) vers l'offset du render
    /// (en pixels haute-résolution).
    func scaled(by factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }
}

// MARK: - Share Promi filter sheet

private struct SharePromiFilterSheet: View {
    let promis: [PromiItem]
    let nuées: [Nuée]
    @Binding var excludedPromiIds: Set<UUID>
    @Binding var excludedNuéeIds: Set<UUID>
    let isEnglish: Bool
    @Environment(\.dismiss) private var dismiss

    private var allHidden: Bool {
        excludedPromiIds.count >= promis.count && excludedNuéeIds.count >= nuées.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.96).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Section Nuées
                        if !nuées.isEmpty {
                            sectionHeader(isEnglish ? "NUÉES" : "NUÉES")

                            ForEach(nuées) { nuée in
                                let isExcluded = excludedNuéeIds.contains(nuée.id)
                                filterRow(
                                    icon: nuée.kind == .intimate
                                        ? "hands.sparkles.fill"
                                        : "circle.hexagongrid.fill",
                                    title: nuée.name,
                                    isExcluded: isExcluded,
                                    accentColor: NuéePalette.color(fromHex: nuée.moodHintRawValue) ?? Brand.orange
                                ) {
                                    if isExcluded {
                                        excludedNuéeIds.remove(nuée.id)
                                    } else {
                                        excludedNuéeIds.insert(nuée.id)
                                    }
                                }
                            }
                        }

                        // Section Promi
                        if !promis.isEmpty {
                            sectionHeader("PROMI")
                                .padding(.top, nuées.isEmpty ? 0 : 8)

                            ForEach(promis) { promi in
                                let isExcluded = excludedPromiIds.contains(promi.id)
                                filterRow(
                                    icon: nil,
                                    title: promi.title,
                                    isExcluded: isExcluded,
                                    accentColor: Brand.orange
                                ) {
                                    if isExcluded {
                                        excludedPromiIds.remove(promi.id)
                                    } else {
                                        excludedPromiIds.insert(promi.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(isEnglish ? "Visible elements" : "Éléments visibles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEnglish ? "Done" : "OK") {
                        dismiss()
                    }
                    .foregroundColor(Brand.orange)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(allHidden
                           ? (isEnglish ? "Show all" : "Tout afficher")
                           : (isEnglish ? "Hide all" : "Tout masquer")
                    ) {
                        Haptics.shared.tinyPop()
                        if allHidden {
                            excludedPromiIds.removeAll()
                            excludedNuéeIds.removeAll()
                        } else {
                            excludedPromiIds = Set(promis.map(\.id))
                            excludedNuéeIds = Set(nuées.map(\.id))
                        }
                    }
                    .foregroundColor(Color.white.opacity(0.62))
                    .font(.system(size: 13))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.0)
            .foregroundColor(Color.white.opacity(0.46))
            .padding(.leading, 4)
    }

    @ViewBuilder
    private func filterRow(
        icon: String?,
        title: String,
        isExcluded: Bool,
        accentColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.shared.tinyPop()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isExcluded ? "eye.slash" : "eye.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(
                        isExcluded
                            ? Color.white.opacity(0.32)
                            : accentColor.opacity(0.86)
                    )
                    .frame(width: 22)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(
                            isExcluded
                                ? Color.white.opacity(0.28)
                                : accentColor.opacity(0.72)
                        )
                        .frame(width: 18)
                }

                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(isExcluded ? 0.38 : 0.88))
                    .lineLimit(2)
                    .strikethrough(isExcluded)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(isExcluded ? 0.02 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(isExcluded ? 0.06 : 0.12), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}
