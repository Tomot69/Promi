//
//  NuéePalette.swift
//  Promi
//
//  Standalone palette of hex swatches used by Nuées. Lives outside Nuée.swift
//  so the data model itself stays Foundation-only (CloudKit-compatible) while
//  this file imports SwiftUI for the Color helper.
//

import SwiftUI

// MARK: - NuéeSwatch

/// A single named hex color in the Nuée palette. Stored on the Nuée model
/// via `moodHintRawValue` and used by NuéeDetailView, MesNuéesView, and the
/// home Voronoï to give each Nuée its own visual identity.
struct NuéeSwatch: Equatable {
    let hex: String
    let name: String
}

// MARK: - NuéePalette

/// Curated palette of 24 hand-picked hex colors spanning the full hue
/// spectrum. Replaces the previous selection-from-PromiColorMood approach
/// (which was too narrow — only 12 closely-related gradient moods).
/// Each Nuée picks one swatch as its visual identity; the palette covers
/// reds → ochers → greens → teals → blues → purples → pinks → neutrals
/// so any group can find a color that matches its true vibe.
enum NuéePalette {
    static let swatches: [NuéeSwatch] = [
        // Warm reds & corals
        NuéeSwatch(hex: "C44545", name: "Crimson"),
        NuéeSwatch(hex: "E55B3C", name: "Vermilion"),
        NuéeSwatch(hex: "F08C5A", name: "Coral"),
        NuéeSwatch(hex: "F2B57E", name: "Peach"),
        // Yellows & ochers
        NuéeSwatch(hex: "E8AC4C", name: "Saffron"),
        NuéeSwatch(hex: "C99748", name: "Mustard"),
        // Earths & olives
        NuéeSwatch(hex: "8E9648", name: "Olive"),
        NuéeSwatch(hex: "8B5E3C", name: "Chestnut"),
        // Greens
        NuéeSwatch(hex: "94B454", name: "Fern"),
        NuéeSwatch(hex: "5DA66E", name: "Emerald"),
        NuéeSwatch(hex: "4A8C7A", name: "Pine"),
        // Teals
        NuéeSwatch(hex: "3E8E92", name: "Teal"),
        NuéeSwatch(hex: "5BAEC4", name: "Sky teal"),
        // Blues
        NuéeSwatch(hex: "4A8AC4", name: "Azure"),
        NuéeSwatch(hex: "3E6BB0", name: "Cobalt"),
        // Purples
        NuéeSwatch(hex: "4F4FA8", name: "Indigo"),
        NuéeSwatch(hex: "6A4FA8", name: "Violet"),
        NuéeSwatch(hex: "8E5BAE", name: "Lavender"),
        // Pinks
        NuéeSwatch(hex: "B85F9E", name: "Magenta"),
        NuéeSwatch(hex: "D1689B", name: "Rose"),
        NuéeSwatch(hex: "A6446F", name: "Burgundy"),
        // Earths & neutrals
        NuéeSwatch(hex: "5C4A3E", name: "Espresso"),
        NuéeSwatch(hex: "5E6068", name: "Slate"),
        NuéeSwatch(hex: "C8C0B6", name: "Pearl")
    ]

    /// Convert a 6-character RGB hex string (with or without leading '#')
    /// into a SwiftUI Color. Returns nil for malformed or nil input —
    /// caller is responsible for providing a sensible fallback. Defensive
    /// by design because hex strings come from persisted Nuée data which
    /// can in theory be corrupted across migrations.
    static func color(fromHex hex: String?) -> Color? {
        guard let hex else { return nil }

        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        guard cleaned.count == 6,
              let rgbValue = UInt32(cleaned, radix: 16) else {
            return nil
        }

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
