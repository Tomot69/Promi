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

    let pack: PromiVisualPack
    let mood: PromiColorMood
    let sortOption: PromiFieldSortOption

    @State private var hideText = false
    @State private var showSignature = true
    @State private var selectedTemplate: PromiShareTemplate = .instagramStory
    @State private var shareImage: UIImage?
    @State private var isPreparingShare = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false


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
        }
    }

    // MARK: - Promis (home-mirrored sorting)

    private var visiblePromis: [PromiItem] {
        promiStore.promis.filter { $0.status != .done }
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
                    icon: "signature",
                    label: "Promi",
                    isActive: showSignature
                ) {
                    Haptics.shared.tinyPop()
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                        showSignature.toggle()
                    }
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

    @ViewBuilder
    private var previewArea: some View {
        GeometryReader { geo in
            let inset: CGFloat = 20
            let available = CGSize(
                width: max(140, geo.size.width - inset * 2),
                height: max(140, geo.size.height - inset * 2)
            )
            let canvas = selectedTemplate.canvasSize(fitting: available)

            ZStack {
                CompositionPreviewCard(
                    size: canvas,
                    pack: pack,
                    mood: mood,
                    promis: sortedPromis,
                    languageCode: userStore.selectedLanguage,
                    sortOption: sortOption,
                    hideText: hideText,
                    showSignature: showSignature,
                    title: isEnglish ? "My Promi" : "Mon Promi",
                    subtitle: selectedTemplate.previewBadge
                )
                .animation(.spring(response: 0.40, dampingFraction: 0.86), value: selectedTemplate)
                .animation(.spring(response: 0.40, dampingFraction: 0.86), value: hideText)
            }
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
        let view = CompositionPreviewCard(
            size: renderSize,
            pack: pack,
            mood: mood,
            promis: sortedPromis,
            languageCode: userStore.selectedLanguage,
            sortOption: sortOption,
            hideText: hideText,
            showSignature: showSignature,
            title: isEnglish ? "My Promi" : "Mon Promi",
            subtitle: selectedTemplate.previewBadge
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
    let size: CGSize
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let hideText: Bool
    let showSignature: Bool
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topLeading) {
                PromiFieldPreviewView(
                    pack: pack,
                    mood: mood,
                    size: size,
                    promis: promis,
                    languageCode: languageCode,
                    sortOption: sortOption
                )

                if !hideText {
                    overlayPlates
                }
            }
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.38), lineWidth: 1)
            )
            .padding(6)
        }
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

            HStack {
                Spacer()

                Text(textFooter)
                    .font(.system(size: footerSize, weight: .regular))
                    .foregroundColor(overlayTextColor.opacity(0.78))
                    .padding(.horizontal, plateHorizontal)
                    .padding(.vertical, max(8, plateVertical - 2))
                    .background(overlayPlate)
            }
            .padding(overlayPadding)
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

    private var textFooter: String {
        if !showSignature {
            if promis.isEmpty { return "" }
            return "\(promis.count) Promi · \(sortOption.rawValue.lowercased())"
        }
        if promis.isEmpty {
            return "promi.app"
        }
        return "\(promis.count) Promi · promi.app"
    }

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

private struct ShareSheet: UIViewControllerRepresentable {
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
