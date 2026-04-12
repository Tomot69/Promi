import SwiftUI

// MARK: - PromiColorMood
//
// Definition canonique du mood couleur. NE PAS MODIFIER cette enum sans
// répercuter les changements dans PromiFieldVisuals.swift, ContentView.swift
// et tout fichier qui dépend de PromiColorMood.

enum PromiColorMood: String, CaseIterable, Identifiable {
    case terrePromi
    case nuitCobalt
    case ivoireCorail

    case craieMarine
    case sableMenthe
    case mineralPrune

    case jardinPromi
    case auroreCobalt
    case citrusBrume

    // Cristal pack — three radically distinct chromatic territories.
    case auroreFraise
    case foretSousBois
    case neonMidi

    // Vitrail pack — stained-glass cathedral palettes.
    case vitrailCathédrale
    case vitrailAube
    case vitrailNuit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .terrePromi: return "Terre Promi"
        case .nuitCobalt: return "Nuit Cobalt"
        case .ivoireCorail: return "Ivoire Corail"

        case .craieMarine: return "Craie Marine"
        case .sableMenthe: return "Sable Menthe"
        case .mineralPrune: return "Minéral Prune"

        case .jardinPromi: return "Jardin Promi"
        case .auroreCobalt: return "Aurore Cobalt"
        case .citrusBrume: return "Citrus Brume"

        case .auroreFraise: return "Aurore Fraise"
        case .foretSousBois: return "Forêt Sous-Bois"
        case .neonMidi: return "Néon Midi"

        case .vitrailCathédrale: return "Vitrail Cathédrale"
        case .vitrailAube: return "Vitrail Aube"
        case .vitrailNuit: return "Vitrail Nuit"
        }
    }

    var subtitle: String {
        switch self {
        case .terrePromi: return "terre chaude, corail discret, densité organique"
        case .nuitCobalt: return "fond nocturne, cobalt net, accents froids"
        case .ivoireCorail: return "fond clair, corail vif, lecture lumineuse"

        case .craieMarine: return "craie douce, marine graphique"
        case .sableMenthe: return "sable pâle, menthe fraîche"
        case .mineralPrune: return "minéral dense, prune feutrée"

        case .jardinPromi: return "spectre végétal, vivant, lumineux"
        case .auroreCobalt: return "cobalt, indigo, glissement atmosphérique"
        case .citrusBrume: return "agrumes pâles, brume colorée, aérien"

        case .auroreFraise: return "pastels d’aube, pêche, sauge, lavande"
        case .foretSousBois: return "verts profonds, mousse, écorce, champignon"
        case .neonMidi: return "néons électriques sur nuit absolue"

        case .vitrailCathédrale: return "rouge profond, cobalt, ocre, émeraude, violet"
        case .vitrailAube: return "rose, lavande, bleu ciel, pêche, mint lumineux"
        case .vitrailNuit: return "indigo, prune, bordeaux, sapin, anthracite"
        }
    }

    var homeBackground: Color {
        switch self {
        case .terrePromi:
            return Color(red: 0.14, green: 0.09, blue: 0.08)
        case .nuitCobalt:
            return Color(red: 0.05, green: 0.07, blue: 0.14)
        case .ivoireCorail:
            return Color(red: 0.95, green: 0.93, blue: 0.89)

        case .craieMarine:
            return Color(red: 0.95, green: 0.94, blue: 0.91)
        case .sableMenthe:
            return Color(red: 0.93, green: 0.91, blue: 0.85)
        case .mineralPrune:
            return Color(red: 0.85, green: 0.85, blue: 0.88)

        case .jardinPromi:
            return Color(red: 0.89, green: 0.93, blue: 0.80)
        case .auroreCobalt:
            return Color(red: 0.79, green: 0.85, blue: 0.95)
        case .citrusBrume:
            return Color(red: 0.94, green: 0.95, blue: 0.88)

        case .auroreFraise:
            return Color(red: 0.97, green: 0.94, blue: 0.93)
        case .foretSousBois:
            return Color(red: 0.07, green: 0.11, blue: 0.09)
        case .neonMidi:
            return Color(red: 0.05, green: 0.05, blue: 0.10)

        case .vitrailCathédrale:
            return Color(red: 0.08, green: 0.06, blue: 0.10)
        case .vitrailAube:
            return Color(red: 0.96, green: 0.94, blue: 0.97)
        case .vitrailNuit:
            return Color(red: 0.04, green: 0.04, blue: 0.08)
        }
    }

    var prefersDarkChrome: Bool {
        switch self {
        case .terrePromi, .nuitCobalt, .foretSousBois, .neonMidi, .vitrailCathédrale, .vitrailNuit:
            return true
        default:
            return false
        }
    }

    var swatches: [Color] {
        switch self {
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
                Color(red: 0.05, green: 0.08, blue: 0.15),
                Color(red: 0.10, green: 0.13, blue: 0.22),
                Color(red: 0.18, green: 0.26, blue: 0.38),
                Color(red: 0.33, green: 0.31, blue: 0.93),
                Color(red: 0.27, green: 0.78, blue: 0.77)
            ]

        case .ivoireCorail:
            return [
                Color(red: 0.96, green: 0.94, blue: 0.90),
                Color(red: 0.92, green: 0.89, blue: 0.83),
                Color(red: 0.98, green: 0.37, blue: 0.27),
                Color(red: 0.27, green: 0.78, blue: 0.77),
                Color(red: 0.18, green: 0.26, blue: 0.38)
            ]

        case .craieMarine:
            return [
                Color(red: 0.95, green: 0.94, blue: 0.91),
                Color(red: 0.84, green: 0.86, blue: 0.89),
                Color(red: 0.18, green: 0.26, blue: 0.38),
                Color(red: 0.09, green: 0.12, blue: 0.23),
                Color(red: 0.33, green: 0.31, blue: 0.93)
            ]

        case .sableMenthe:
            return [
                Color(red: 0.94, green: 0.91, blue: 0.84),
                Color(red: 0.87, green: 0.94, blue: 0.90),
                Color(red: 0.27, green: 0.78, blue: 0.77),
                Color(red: 0.18, green: 0.26, blue: 0.38),
                Color(red: 0.98, green: 0.37, blue: 0.27)
            ]

        case .mineralPrune:
            return [
                Color(red: 0.84, green: 0.85, blue: 0.88),
                Color(red: 0.26, green: 0.28, blue: 0.36),
                Color(red: 0.36, green: 0.02, blue: 0.45),
                Color(red: 0.18, green: 0.26, blue: 0.38),
                Color(red: 0.27, green: 0.78, blue: 0.77)
            ]

        case .jardinPromi:
            return [
                Color(red: 0.95, green: 0.90, blue: 0.14),
                Color(red: 0.64, green: 0.83, blue: 0.26),
                Color(red: 0.48, green: 0.79, blue: 0.34),
                Color(red: 0.20, green: 0.68, blue: 0.58),
                Color(red: 0.30, green: 0.36, blue: 0.66),
                Color(red: 0.36, green: 0.02, blue: 0.45)
            ]

        case .auroreCobalt:
            return [
                Color(red: 0.14, green: 0.21, blue: 0.45),
                Color(red: 0.24, green: 0.49, blue: 0.67),
                Color(red: 0.30, green: 0.76, blue: 0.76),
                Color(red: 0.30, green: 0.36, blue: 0.66),
                Color(red: 0.34, green: 0.22, blue: 0.56),
                Color(red: 0.36, green: 0.02, blue: 0.45)
            ]

        case .citrusBrume:
            return [
                Color(red: 0.97, green: 0.92, blue: 0.48),
                Color(red: 0.86, green: 0.94, blue: 0.58),
                Color(red: 0.72, green: 0.88, blue: 0.80),
                Color(red: 0.64, green: 0.78, blue: 0.94),
                Color(red: 0.84, green: 0.72, blue: 0.92),
                Color(red: 0.96, green: 0.82, blue: 0.70)
            ]

        case .auroreFraise:
            return [
                Color(red: 0.98, green: 0.78, blue: 0.66),
                Color(red: 0.96, green: 0.62, blue: 0.58),
                Color(red: 0.74, green: 0.86, blue: 0.94),
                Color(red: 0.78, green: 0.88, blue: 0.78),
                Color(red: 0.98, green: 0.92, blue: 0.74),
                Color(red: 0.86, green: 0.80, blue: 0.94)
            ]

        case .foretSousBois:
            return [
                Color(red: 0.30, green: 0.45, blue: 0.28),
                Color(red: 0.20, green: 0.40, blue: 0.30),
                Color(red: 0.55, green: 0.62, blue: 0.40),
                Color(red: 0.36, green: 0.26, blue: 0.18),
                Color(red: 0.78, green: 0.54, blue: 0.44),
                Color(red: 0.14, green: 0.20, blue: 0.16)
            ]

        case .neonMidi:
            return [
                Color(red: 0.96, green: 0.22, blue: 0.62),
                Color(red: 0.20, green: 0.86, blue: 0.92),
                Color(red: 0.66, green: 0.96, blue: 0.30),
                Color(red: 0.30, green: 0.20, blue: 0.86),
                Color(red: 0.98, green: 0.78, blue: 0.20),
                Color(red: 0.04, green: 0.04, blue: 0.10)
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
}

// MARK: - Studio
//
// Le Studio donne une vue d'ensemble des 4 packs visuels (Alvéoles, Galets,
// Mosaïque, Spectrum) × 9 moods couleur. Chaque vignette utilise le moteur
// PromiFieldPreviewView (le même que le home) avec deux Promi de démo
// déterministes pour montrer comment la signature absorbe les Promi sans
// changer d'univers visuel.

struct PaletteView: View {
    @Environment(\.dismiss) var dismiss

    // Persistence layer — read at init, written via onChange. Not consulted
    // by the body during normal selection flow because @AppStorage updates
    // from inside a Button action that observes the same @AppStorage have a
    // 1-frame propagation lag in iOS 17+ which makes the visual selection
    // feel like it requires a double-tap. We use @State for the live UI.
    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    // Live UI selection state. Updates instantly on tap, drives both the
    // card highlights AND the full-screen live background preview.
    @State private var liveSelectedPack: PromiVisualPack
    @State private var liveSelectedMood: PromiColorMood
    @State private var backgroundSize: CGSize = .zero

    init() {
        let storedPackRaw = UserDefaults.standard.string(forKey: "promi.visualPack")
            ?? PromiVisualPack.alveolesSignature.rawValue
        let storedMoodRaw = UserDefaults.standard.string(forKey: "promi.visualMood")
            ?? PromiColorMood.terrePromi.rawValue
        let pack = PromiVisualPack(rawValue: storedPackRaw) ?? .alveolesSignature
        let mood = PromiColorMood(rawValue: storedMoodRaw) ?? .terrePromi
        _liveSelectedPack = State(initialValue: pack)
        _liveSelectedMood = State(initialValue: mood)
    }

    private let sections: [(PromiVisualPack, [PromiColorMood])] = [
        (.alveolesSignature, [.terrePromi, .nuitCobalt, .ivoireCorail]),
        (.galets, [.terrePromi, .ivoireCorail, .nuitCobalt]),
        (.cristal, [.auroreFraise, .foretSousBois, .neonMidi]),
        (.mosaicFlat, [.craieMarine, .sableMenthe, .mineralPrune]),
        (.spectrumSoft, [.jardinPromi, .auroreCobalt, .citrusBrume]),
        (.vitrailChrome, [.vitrailCathédrale, .vitrailAube, .vitrailNuit])
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let fullHeight = proxy.size.height
                    + proxy.safeAreaInsets.top
                    + proxy.safeAreaInsets.bottom
                ZStack {
                    // Layer 0: fond inconditionnel qui empêche toute bande noire
                    // de transparaître, quelle que soit la façon dont les layers
                    // du dessus se comportent avec la safe area.
                    liveSelectedMood.homeBackground
                        .ignoresSafeArea()

                    // Layer 1: aperçu pack × mood, étendu aux safe areas via
                    // un container qui ignore la safe area puis reframe à
                    // la taille totale. Plus propre qu'un offset négatif.
                    ZStack {
                        PromiFieldPreviewView(
                            pack: liveSelectedPack,
                            mood: liveSelectedMood,
                            size: CGSize(width: proxy.size.width, height: fullHeight),
                            promis: [],
                            languageCode: "fr_FR",
                            sortOption: .inspiration
                        )
                    }
                    .frame(width: proxy.size.width, height: fullHeight)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                    // Layer 2: voile de lisibilité. Les cartes de preview
                    // passent AU-DESSUS de ce voile (elles sont dans le
                    // ScrollView qui vient après), donc leurs couleurs ne
                    // sont jamais délavées par le voile. Le voile n'agit
                    // que sur le background pleine page derrière les cartes.
                    Rectangle()
                        .fill(liveSelectedMood.prefersDarkChrome
                            ? Color.black.opacity(0.72)
                            : Color.white.opacity(0.78))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    // Layer 3: contenu scrollable. Le padding bas compense
                    // explicitement la safe area pour que ActiveMoodFooter
                    // ne soit jamais caché derrière le Home Indicator.
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 32) {
                            StudioHeader(prefersDarkChrome: liveSelectedMood.prefersDarkChrome)

                            ForEach(sections, id: \.0.rawValue) { section in
                                StudioPackSection(
                                    pack: section.0,
                                    moods: section.1,
                                    selectedPack: liveSelectedPack,
                                    selectedMood: liveSelectedMood,
                                    prefersDarkChrome: liveSelectedMood.prefersDarkChrome
                                ) { pack, mood in
                                    liveSelectedPack = pack
                                    liveSelectedMood = mood
                                    Haptics.shared.tinyPop()
                                }
                            }

                            ActiveMoodFooter(
                                pack: liveSelectedPack,
                                mood: liveSelectedMood,
                                prefersDarkChrome: liveSelectedMood.prefersDarkChrome
                            )
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 64 + proxy.safeAreaInsets.bottom)
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(Color.orange.opacity(0.92))
                        .font(.system(size: 15, weight: .regular))
                }
            }
        }
        // Sync live state → AppStorage so the home view picks up the change.
        // onChange fires synchronously after the @State mutation, so the
        // AppStorage write happens in the same runloop tick as the visual
        // update. The home re-renders on the next frame.
        .onChange(of: liveSelectedPack) { _, newValue in
            visualPackRawValue = newValue.rawValue
        }
        .onChange(of: liveSelectedMood) { _, newValue in
            visualMoodRawValue = newValue.rawValue
        }
    }
}

// MARK: - Header

private struct StudioHeader: View {
    let prefersDarkChrome: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Promi · Le Studio")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(textPrimary.opacity(0.92))
                .tracking(0.2)

            Text("Vertical pour la structure.\nHorizontal pour l’ambiance couleur.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(textPrimary.opacity(0.56))
                .lineSpacing(3)
        }
        .padding(.top, 12)
    }

    private var textPrimary: Color {
        prefersDarkChrome ? .white : .black
    }
}

// MARK: - Pack section

private struct StudioPackSection: View {
    let pack: PromiVisualPack
    let moods: [PromiColorMood]
    let selectedPack: PromiVisualPack
    let selectedMood: PromiColorMood
    let prefersDarkChrome: Bool
    let onSelect: (PromiVisualPack, PromiColorMood) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(studioDisplayTitle(for: pack))
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(textPrimary.opacity(0.92))

                if selectedPack == pack {
                    Circle()
                        .fill(Color.orange.opacity(0.92))
                        .frame(width: 6, height: 6)
                        .offset(y: -2)
                }

                Spacer()
            }

            Text(pack.studioSubtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(textPrimary.opacity(0.55))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(moods) { mood in
                        StudioMoodCard(
                            pack: pack,
                            mood: mood,
                            isSelected: selectedPack == pack && selectedMood == mood,
                            prefersDarkChrome: prefersDarkChrome
                        ) {
                            onSelect(pack, mood)
                        }
                    }
                }
                .padding(.trailing, 8)
                .padding(.vertical, 4)
            }
        }
    }

    private var textPrimary: Color {
        prefersDarkChrome ? .white : .black
    }

    /// Surcharge locale du titre d'affichage des packs dans le Studio,
    /// sans modifier l'enum PromiVisualPack (qui vit dans un autre fichier
    /// et sert à d'autres usages dans l'app).
    private func studioDisplayTitle(for pack: PromiVisualPack) -> String {
        switch pack {
        case .vitrailChrome:
            return "Chrome × Vitrail"
        default:
            return pack.studioTitle
        }
    }
}

// MARK: - Mood card (live preview via PromiFieldPreviewView)

private struct StudioMoodCard: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let isSelected: Bool
    let prefersDarkChrome: Bool
    let action: () -> Void

    private static let previewSize = CGSize(width: 294, height: 168)

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                PromiFieldPreviewView(
                    pack: pack,
                    mood: mood,
                    size: Self.previewSize,
                    promis: [],
                    languageCode: "fr_FR",
                    sortOption: .inspiration
                )
                .frame(width: Self.previewSize.width, height: Self.previewSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            isSelected ? Color.orange.opacity(0.92) : textPrimary.opacity(0.10),
                            lineWidth: isSelected ? 1.6 : 0.6
                        )
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(mood.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(textPrimary.opacity(0.92))

                    Text(mood.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(textPrimary.opacity(0.55))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: Self.previewSize.width, alignment: .leading)
                .padding(.horizontal, 4)
            }
            // Force toute la zone (aperçu + texte) à être tactile pour le tap.
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var textPrimary: Color {
        prefersDarkChrome ? .white : .black
    }
}

// MARK: - Active mood footer (discreet pill)

private struct ActiveMoodFooter: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let prefersDarkChrome: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.orange.opacity(0.92))
                .frame(width: 7, height: 7)

            Text("Actif")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(textPrimary.opacity(0.50))

            Text("·")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(textPrimary.opacity(0.32))

            Text(pack == .vitrailChrome ? "Chrome × Vitrail" : pack.studioTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(textPrimary.opacity(0.84))

            Text("—")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(textPrimary.opacity(0.32))

            Text(mood.title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(textPrimary.opacity(0.62))

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(pillBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(textPrimary.opacity(0.10), lineWidth: 0.6)
        )
    }

    private var textPrimary: Color {
        prefersDarkChrome ? .white : .black
    }

    private var pillBackground: Color {
        prefersDarkChrome ? Color.white.opacity(0.10) : Color.white.opacity(0.50)
    }
}
