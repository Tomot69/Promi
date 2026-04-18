import SwiftUI

// MARK: - Bottom dock
//
// 5 buttons in a single row: tri / karma / + (center, 54pt) / studio / share.
// The + is the central hub — it opens a dropdown with "Nouveau Promi",
// "Nouvelle Nuée", and "Brouillons". The dropdown pops UP (above the dock),
// same spring animation as the sort menu on the left.

struct BottomDockRow: View {
    @Binding var selectedSort: PromiFieldSortOption
    @Binding var isSortMenuExpanded: Bool
    @Binding var isAddMenuExpanded: Bool
    let isDarkField: Bool
    let draftCount: Int
    let isPremium: Bool
    let onOpenKarma: () -> Void
    let onOpenStudio: () -> Void
    let onOpenComposition: () -> Void
    let onNewPromi: () -> Void
    let onNewNuée: () -> Void
    let onOpenDrafts: () -> Void
    let onOpenPaywall: () -> Void

    private let baseSize: CGFloat = 46
    private let centerSize: CGFloat = 54

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Tri — leftmost bookend
            PromiFieldSortControl(
                selectedSort: $selectedSort,
                isExpanded: $isSortMenuExpanded,
                isDarkField: isDarkField
            )

            Spacer(minLength: 8)

            // Karma — eye glyph (introspective gaze on one's promises)
            IconOnlyCircleButton(
                isDarkField: isDarkField,
                size: baseSize,
                action: onOpenKarma,
                glyph: {
                    EyeGlyph(isDarkField: isDarkField)
                        .frame(width: 24, height: 24)
                }
            )

            Spacer(minLength: 8)

            // + — central hub, slightly larger (54pt). Opens a dropdown
            // with create actions (Promi, Nuée) and drafts access.
            DockAddControl(
                isExpanded: $isAddMenuExpanded,
                isDarkField: isDarkField,
                size: centerSize,
                draftCount: draftCount,
                isPremium: isPremium,
                onNewPromi: onNewPromi,
                onNewNuée: onNewNuée,
                onOpenDrafts: onOpenDrafts,
                onOpenPaywall: onOpenPaywall
            )

            Spacer(minLength: 8)

            // Studio — visual identity / pack & mood selection
            IconOnlyCircleButton(
                isDarkField: isDarkField,
                size: baseSize,
                action: onOpenStudio,
                glyph: {
                    StudioGlyph(isDarkField: isDarkField)
                        .frame(width: 24, height: 24)
                }
            )

            Spacer(minLength: 8)

            // Composition / share — rightmost bookend
            IconOnlyCircleButton(
                isDarkField: isDarkField,
                size: baseSize,
                action: onOpenComposition,
                glyph: {
                    CompositionGlyph(isDarkField: isDarkField)
                        .frame(width: 24, height: 24)
                }
            )
        }
    }
}

// MARK: - Dock add control (center "+" with pop-up menu)
//
// The + button sits at the center of the dock. When tapped, a dropdown
// menu pops UP above the dock (offset y -58) listing the create actions.
// The + rotates 45° when expanded (becomes ×). Same spring animation
// as the sort menu.

struct DockAddControl: View {
    @Binding var isExpanded: Bool
    let isDarkField: Bool
    let size: CGFloat
    let draftCount: Int
    let isPremium: Bool
    let onNewPromi: () -> Void
    let onNewNuée: () -> Void
    let onOpenDrafts: () -> Void
    let onOpenPaywall: () -> Void

    private let menuWidth: CGFloat = 230

    var body: some View {
        ZStack(alignment: .bottom) {
            if isExpanded {
                AddActionMenu(
                    draftCount: draftCount,
                    isDarkField: isDarkField,
                    isPremium: isPremium,
                    onNewPromi: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                        onNewPromi()
                    },
                    onNewNuée: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                        onNewNuée()
                    },
                    onOpenDrafts: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                        onOpenDrafts()
                    },
                    onOpenPaywall: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                        onOpenPaywall()
                    }
                )
                .frame(width: menuWidth)
                .offset(y: -62)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(1)
            }

            Button(action: {
                Haptics.shared.tinyPop()
                withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    FloatingChromeCircle(isDarkField: isDarkField)
                    AddPlusGlyph(isDarkField: isDarkField)
                        .frame(width: 26, height: 26)
                        .rotationEffect(.degrees(isExpanded ? 45 : 0))
                }
                .frame(width: size, height: size)
            }
            .buttonStyle(.plain)
            .zIndex(2)
        }
        .frame(width: size, height: size, alignment: .bottom)
    }
}

// MARK: - Sort control + menu

struct PromiFieldSortControl: View {
    @Binding var selectedSort: PromiFieldSortOption
    @Binding var isExpanded: Bool
    let isDarkField: Bool

    private let menuWidth: CGFloat = 220
    private let buttonSize: CGFloat = 46

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if isExpanded {
                CompactSortMenu(
                    selectedSort: $selectedSort,
                    isDarkField: isDarkField,
                    close: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                    }
                )
                .frame(width: menuWidth)
                .offset(y: -58)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(1)
            }

            Button(action: {
                Haptics.shared.tinyPop()
                withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    FloatingChromeCircle(isDarkField: isDarkField)

                    PromiFieldSortGlyph(isDarkField: isDarkField)
                        .frame(width: 24, height: 24)
                }
                .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .zIndex(2)
        }
        .frame(width: buttonSize, height: buttonSize, alignment: .bottomLeading)
    }
}

struct CompactSortMenu: View {
    @Binding var selectedSort: PromiFieldSortOption
    let isDarkField: Bool
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(PromiFieldSortOption.allCases, id: \.self) { option in
                let isSelected = selectedSort == option

                Button(action: {
                    selectedSort = option
                    Haptics.shared.lightTap()
                    close()
                }) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.96) : Color.white.opacity(0.22))
                            .frame(width: 6, height: 6)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(option.rawValue)
                                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(.white.opacity(isSelected ? 0.96 : 0.78))

                            Text(option.visualHintSubtitle)
                                .font(.system(size: 9, weight: .regular))
                                .foregroundColor(.white.opacity(0.54))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? Color.white.opacity(0.08) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(
            CompactMenuSurface(isDarkField: isDarkField)
        )
    }
}

// MARK: - Add action menu (3 rows: Promi, Nuée, Drafts)

struct AddActionMenu: View {
    let draftCount: Int
    let isDarkField: Bool
    let isPremium: Bool
    let onNewPromi: () -> Void
    let onNewNuée: () -> Void
    let onOpenDrafts: () -> Void
    let onOpenPaywall: () -> Void

    private var draftLabel: String {
        draftCount > 1 ? "Brouillons" : "Brouillon"
    }

    private var draftSubtitle: String {
        if draftCount == 0 {
            return "Aucun brouillon en cours"
        } else if draftCount == 1 {
            return "1 brouillon en cours"
        } else {
            return "\(draftCount) brouillons en cours"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Promi Plus (seulement si pas encore Premium)
            if !isPremium {
                Button(action: {
                    Haptics.shared.lightTap()
                    onOpenPaywall()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Brand.orange.opacity(0.92))
                            .frame(width: 16)

                        HStack(spacing: 0) {
                            Text("Promi")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Brand.orange.opacity(0.92))
                            Text(" Plus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.86))
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Brand.orange.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Brand.orange.opacity(0.18), lineWidth: 0.6)
                    )
                }
                .buttonStyle(.plain)
            }

            menuRow(
                title: "Nouveau Promi",
                subtitle: "Créer une promesse maintenant",
                accent: true,
                action: onNewPromi
            )

            menuRow(
                title: "Nouvelle Nuée",
                subtitle: "Créer un essaim partagé",
                accent: false,
                action: onNewNuée
            )

            menuRow(
                title: draftLabel,
                subtitle: draftSubtitle,
                accent: false,
                action: onOpenDrafts
            )
        }
        .padding(10)
        .background(
            CompactMenuSurface(isDarkField: isDarkField)
        )
    }

    private func menuRow(
        title: String,
        subtitle: String,
        accent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            Haptics.shared.lightTap()
            action()
        }) {
            HStack(spacing: 10) {
                Circle()
                    .fill(accent ? Color.white.opacity(0.96) : Color.white.opacity(0.22))
                    .frame(width: 6, height: 6)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: accent ? .semibold : .regular))
                        .foregroundColor(.white.opacity(accent ? 0.96 : 0.78))

                    Text(subtitle)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.white.opacity(0.54))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent ? Color.white.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
