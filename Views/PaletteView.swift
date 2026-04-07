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
        }
    }

    var prefersDarkChrome: Bool {
        switch self {
        case .terrePromi, .nuitCobalt, .foretSousBois, .neonMidi:
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

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private let sections: [(PromiVisualPack, [PromiColorMood])] = [
        (.alveolesSignature, [.terrePromi, .nuitCobalt, .ivoireCorail]),
        (.galets, [.terrePromi, .ivoireCorail, .nuitCobalt]),
        (.cristal, [.auroreFraise, .foretSousBois, .neonMidi]),
        (.mosaicFlat, [.craieMarine, .sableMenthe, .mineralPrune]),
        (.spectrumSoft, [.jardinPromi, .auroreCobalt, .citrusBrume])
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.965, green: 0.963, blue: 0.947)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        StudioHeader()

                        ForEach(sections, id: \.0.rawValue) { section in
                            StudioPackSection(
                                pack: section.0,
                                moods: section.1,
                                selectedPack: currentPack,
                                selectedMood: currentMood
                            ) { pack, mood in
                                visualPackRawValue = pack.rawValue
                                visualMoodRawValue = mood.rawValue
                                Haptics.shared.tinyPop()
                            }
                        }

                        ActiveMoodFooter(pack: currentPack, mood: currentMood)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 36)
                }
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
    }
}

// MARK: - Header

private struct StudioHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Promi · Le Studio")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black.opacity(0.46))
                .tracking(0.6)

            Text("Vertical pour la structure.\nHorizontal pour l’ambiance couleur.")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.black.opacity(0.84))
                .lineSpacing(2)
        }
        .padding(.top, 12)
    }
}

// MARK: - Pack section

private struct StudioPackSection: View {
    let pack: PromiVisualPack
    let moods: [PromiColorMood]
    let selectedPack: PromiVisualPack
    let selectedMood: PromiColorMood
    let onSelect: (PromiVisualPack, PromiColorMood) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(pack.studioTitle)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(.black.opacity(0.86))

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
                .foregroundColor(.black.opacity(0.50))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(moods) { mood in
                        StudioMoodCard(
                            pack: pack,
                            mood: mood,
                            isSelected: selectedPack == pack && selectedMood == mood
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
}

// MARK: - Mood card (live preview via PromiFieldPreviewView)

private struct StudioMoodCard: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood
    let isSelected: Bool
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
                            isSelected ? Color.orange.opacity(0.92) : Color.black.opacity(0.06),
                            lineWidth: isSelected ? 1.6 : 0.6
                        )
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(mood.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black.opacity(0.86))

                    Text(mood.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black.opacity(0.50))
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
}

// MARK: - Active mood footer (discreet pill)

private struct ActiveMoodFooter: View {
    let pack: PromiVisualPack
    let mood: PromiColorMood

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.orange.opacity(0.92))
                .frame(width: 7, height: 7)

            Text("Actif")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black.opacity(0.46))

            Text("·")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black.opacity(0.30))

            Text(pack.studioTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.78))

            Text("—")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black.opacity(0.30))

            Text(mood.title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.black.opacity(0.58))

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.42))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.6)
        )
    }
}
