import SwiftUI
import UIKit

struct PromiCompositionShareView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    let pack: PromiVisualPack
    let mood: PromiColorMood
    let sortOption: PromiFieldSortOption

    @State private var hideText = false
    @State private var selectedTemplate: PromiShareTemplate = .instagramStory
    @State private var shareImage: UIImage?
    @State private var isPreparingShare = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    controls
                    previewArea
                    footer
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
        }
    }

    private func stableRank(_ promi: PromiItem) -> Int {
        var hasher = Hasher()
        hasher.combine(promi.id)
        hasher.combine(promi.createdAt.timeIntervalSinceReferenceDate)
        return abs(hasher.finalize())
    }

    // MARK: - Background (mood-anchored, Promi identity)

    @ViewBuilder
    private var backgroundLayer: some View {
        ZStack {
            mood.homeBackground

            LinearGradient(
                colors: [
                    Color.white.opacity(mood.prefersDarkChrome ? 0.05 : 0.22),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(mood.prefersDarkChrome ? 0.18 : 0.06)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mon Promi")
                    .font(.system(size: 31, weight: .light))
                    .foregroundColor(primaryTextColor)

                Text("composition pleine page et partage")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(secondaryTextColor)
            }

            Spacer()

            Button(action: {
                Haptics.shared.lightTap()
                dismiss()
            }) {
                Text("Fermer")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.96, green: 0.47, blue: 0.20))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(ChromeCapsuleSurface(isDarkField: mood.prefersDarkChrome))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Controls (templates + toggles)

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PromiShareTemplate.allCases, id: \.self) { template in
                        templateChip(template)
                    }
                }
                .padding(.horizontal, 20)
            }

            HStack(spacing: 12) {
                toggleButton(
                    title: hideText ? "Textes masqués" : "Textes visibles",
                    isSelected: hideText
                ) {
                    Haptics.shared.tinyPop()
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                        hideText.toggle()
                    }
                }

                actionButton(
                    title: isPreparingShare ? "Préparation…" : "Partager",
                    emphasized: true
                ) {
                    prepareShare()
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 14)
    }

    @ViewBuilder
    private func templateChip(_ template: PromiShareTemplate) -> some View {
        let isSelected = selectedTemplate == template

        Button(action: {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                selectedTemplate = template
            }
        }) {
            VStack(alignment: .leading, spacing: 3) {
                Text(template.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : primaryTextColor.opacity(0.86))

                Text(template.subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(isSelected ? .white.opacity(0.80) : secondaryTextColor)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            isSelected
                            ? Color(red: 0.18, green: 0.26, blue: 0.42)
                            : Color.white.opacity(mood.prefersDarkChrome ? 0.10 : 0.22)
                        )

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            Color.white.opacity(isSelected ? 0 : (mood.prefersDarkChrome ? 0.18 : 0.34)),
                            lineWidth: 0.8
                        )
                }
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : primaryTextColor.opacity(0.86))
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(
                    ZStack {
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)

                        Capsule(style: .continuous)
                            .fill(
                                isSelected
                                ? Color(red: 0.96, green: 0.39, blue: 0.28)
                                : Color.white.opacity(mood.prefersDarkChrome ? 0.10 : 0.22)
                            )

                        Capsule(style: .continuous)
                            .stroke(
                                Color.white.opacity(isSelected ? 0 : (mood.prefersDarkChrome ? 0.18 : 0.34)),
                                lineWidth: 0.8
                            )
                    }
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func actionButton(title: String, emphasized: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(emphasized ? .white : primaryTextColor.opacity(0.86))
                .padding(.horizontal, 20)
                .frame(height: 40)
                .background(
                    ZStack {
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)

                        Capsule(style: .continuous)
                            .fill(
                                emphasized
                                ? Color(red: 0.18, green: 0.26, blue: 0.42)
                                : Color.white.opacity(mood.prefersDarkChrome ? 0.10 : 0.22)
                            )

                        Capsule(style: .continuous)
                            .stroke(
                                Color.white.opacity(emphasized ? 0 : (mood.prefersDarkChrome ? 0.18 : 0.34)),
                                lineWidth: 0.8
                            )
                    }
                )
        }
        .buttonStyle(.plain)
        .disabled(isPreparingShare)
    }

    // MARK: - Preview area (centered, no scroll, fits both dims)

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
                    title: "Mon Promi",
                    subtitle: selectedTemplate.previewBadge
                )
                .animation(.spring(response: 0.40, dampingFraction: 0.86), value: selectedTemplate)
                .animation(.spring(response: 0.40, dampingFraction: 0.86), value: hideText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(inset)
        }
    }

    // MARK: - Footer (template description)

    @ViewBuilder
    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selectedTemplate.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(primaryTextColor.opacity(0.86))

            Text(selectedTemplate.shareHint)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 22)
        .padding(.top, 4)
        .animation(.spring(response: 0.30, dampingFraction: 0.88), value: selectedTemplate)
    }

    // MARK: - Adaptive text colors

    private var primaryTextColor: Color {
        mood.prefersDarkChrome ? .white.opacity(0.96) : .black.opacity(0.86)
    }

    private var secondaryTextColor: Color {
        mood.prefersDarkChrome ? .white.opacity(0.62) : .black.opacity(0.50)
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
            title: "Mon Promi",
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

    private func makeShareItems(with image: UIImage) -> [Any] {
        let caption = selectedTemplate.captionText
        return [caption, image]
    }
}

// MARK: - Composition card (Promi-styled, uses PromiFieldPreviewView)

private struct CompositionPreviewCard: View {
    let size: CGSize
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let promis: [PromiItem]
    let languageCode: String
    let sortOption: PromiFieldSortOption
    let hideText: Bool
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
        .shadow(color: .black.opacity(0.24), radius: 30, x: 0, y: 14)
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
        if promis.isEmpty {
            return "promi.app"
        }
        return "\(promis.count) Promi · \(sortOption.rawValue.lowercased())"
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

    var title: String {
        switch self {
        case .instagramStory: return "Story"
        case .instagramPost: return "Post carré"
        case .xPost: return "X / paysage"
        case .linkedinPost: return "LinkedIn"
        case .pinterestPin: return "Pinterest"
        }
    }

    var subtitle: String {
        switch self {
        case .instagramStory: return "9:16, immersif"
        case .instagramPost: return "1:1, propre"
        case .xPost: return "16:9, large"
        case .linkedinPost: return "4:5, éditorial"
        case .pinterestPin: return "2:3, vertical"
        }
    }

    var previewBadge: String {
        switch self {
        case .instagramStory: return "Story"
        case .instagramPost: return "Post"
        case .xPost: return "X"
        case .linkedinPost: return "LinkedIn"
        case .pinterestPin: return "Pinterest"
        }
    }

    var shareHint: String {
        switch self {
        case .instagramStory:
            return "Idéal pour une publication immersive verticale, avec logo et composition bien lisibles."
        case .instagramPost:
            return "Format simple, net et centré, parfait pour un post classique et esthétique."
        case .xPost:
            return "Version large pour une composition plus panoramique, adaptée aux posts rapides."
        case .linkedinPost:
            return "Lecture éditoriale et plus posée, adaptée à une promesse racontée sobrement."
        case .pinterestPin:
            return "Vertical, ample et très visuel, utile pour mettre en avant une composition forte."
        }
    }

    var captionText: String {
        "Mon Promi"
    }

    /// Aspect ratio expressed as width / height.
    var aspectRatio: CGFloat {
        switch self {
        case .instagramStory: return 9.0 / 16.0
        case .instagramPost: return 1.0
        case .xPost: return 16.0 / 9.0
        case .linkedinPost: return 4.0 / 5.0
        case .pinterestPin: return 2.0 / 3.0
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
        case .instagramStory:
            return CGSize(width: 1080, height: 1920)
        case .instagramPost:
            return CGSize(width: 1080, height: 1080)
        case .xPost:
            return CGSize(width: 1600, height: 900)
        case .linkedinPost:
            return CGSize(width: 1200, height: 1500)
        case .pinterestPin:
            return CGSize(width: 1000, height: 1500)
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

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
