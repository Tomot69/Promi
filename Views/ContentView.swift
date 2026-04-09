import SwiftUI

// MARK: - Sort options

enum PromiFieldSortOption: String, CaseIterable {
    case date = "Date"
    case urgency = "Urgence"
    case person = "Personne"
    case importance = "Intensité"
    case inspiration = "Inspi"

    var visualHintTitle: String {
        switch self {
        case .date: return "Tri date"
        case .urgency: return "Tri urgence"
        case .person: return "Tri personne"
        case .importance: return "Tri intensité"
        case .inspiration: return "Tri libre"
        }
    }

    var visualHintSubtitle: String {
        switch self {
        case .date: return "les plus proches dans le temps montent"
        case .urgency: return "les plus urgents se densifient devant"
        case .person: return "les groupes se lisent latéralement"
        case .importance: return "les plus forts prennent le centre"
        case .inspiration: return "répartition libre et organique"
        }
    }
}

// MARK: - Visual packs

enum PromiVisualPack: String, CaseIterable, Identifiable {
    // Migration silencieuse : la rawValue reste "onboardingSignature" pour
    // préserver les choix utilisateurs déjà persistés via @AppStorage.
    case galets = "onboardingSignature"
    case alveolesSignature
    case cristal
    case mosaicFlat
    case spectrumSoft

    var id: String { rawValue }

    var studioTitle: String {
        switch self {
        case .galets: return "Galets"
        case .alveolesSignature: return "Alvéoles"
        case .cristal: return "Cristal"
        case .mosaicFlat: return "Mosaïque"
        case .spectrumSoft: return "Spectrum"
        }
    }

    var studioSubtitle: String {
        switch self {
        case .galets:
            return "Pavage rond, couleurs primaires, ancre au centre"
        case .alveolesSignature:
            return "Vitrail organique plein écran, bordures épaisses"
        case .cristal:
            return "Tessellation dense, bordures noires nettes, palette aquarelle"
        case .mosaicFlat:
            return "Mosaïque nette, graphique, lecture immédiate"
        case .spectrumSoft:
            return "Champ polygonal atmosphérique, gradients soufflés"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var karmaStore: KarmaStore
    @EnvironmentObject var draftStore: DraftStore
    @EnvironmentObject var nuéeStore: NuéeStore

    @State private var showAddPromi = false
    @State private var showSettings = false
    @State private var showStudio = false
    @State private var showKarma = false
    @State private var showDrafts = false
    @State private var showPromiList = false
    @State private var showMesNuées = false
    @State private var showCompositionShare = false
    @State private var selectedSort: PromiFieldSortOption = .inspiration
    @State private var selectedPromi: PromiItem?
    @State private var selectedNuée: Nuée?
    @State private var isSortMenuExpanded = false
    @State private var isAddMenuExpanded = false

    // Tutorial overlay (shown once, on first landing on the home if the
    // user has not yet completed it). The currentTutorialStep tracks the
    // active step inside TutorialOverlayView; when the user finishes the
    // last step, tutorialBinding flips to false AND calls
    // userStore.completeTutorial() so the flag is persisted and the
    // tutorial never re-triggers.
    @State private var showTutorial = false
    @State private var currentTutorialStep = 0

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    private var visualPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var visualMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private let sideInset: CGFloat = 18

    var body: some View {
        ZStack {
            backgroundLayer
            fieldLayer

            if isSortMenuExpanded || isAddMenuExpanded {
                dismissLayer
            }

            homeChrome()

            // Tutorial overlay — sits on top of everything when active.
            // Soft chrome card with arrow pointing at the element being
            // explained, dim 0.58 over the home so the Voronoï stays
            // visible as the learning context.
            if showTutorial {
                TutorialOverlayView(
                    isPresented: tutorialBinding,
                    currentStep: $currentTutorialStep,
                    steps: TutorialContent.getSteps(language: userStore.selectedLanguage)
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showAddPromi) {
            AddPromiView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStudio) {
            PaletteView()
        }
        .sheet(isPresented: $showKarma) {
            KarmaView()
        }
        .sheet(isPresented: $showDrafts) {
            DraftsView()
        }
        .sheet(isPresented: $showPromiList) {
            PromiListView(
                sortOption: $selectedSort,
                selectedPromi: $selectedPromi
            )
            .environmentObject(userStore)
            .environmentObject(promiStore)
        }
        .sheet(isPresented: $showMesNuées) {
            MesNuéesView()
        }
        .sheet(isPresented: $showCompositionShare) {
            PromiCompositionShareView(
                pack: visualPack,
                mood: visualMood,
                sortOption: selectedSort
            )
            .environmentObject(userStore)
            .environmentObject(promiStore)
        }
        .sheet(item: $selectedPromi) { promi in
            EditPromiView(promi: promi)
        }
        .sheet(item: $selectedNuée) { nuée in
            NuéeDetailView(nuéeId: nuée.id)
        }
        .onAppear {
            karmaStore.updateKarma(basedOn: promiStore.promis)

            // First-landing tutorial trigger. The 0.6s delay lets the home
            // Voronoï finish its appear animation before we dim the screen,
            // so the user sees the field "settle" before being asked to
            // learn it. Once the tutorial completes (or is dismissed),
            // userStore.hasCompletedTutorial flips to true and this branch
            // never fires again.
            if !userStore.hasCompletedTutorial && !showTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.32)) {
                        showTutorial = true
                    }
                }
            }
        }
    }

    /// Tutorial isPresented binding with a side-effect: when the overlay
    /// flips to false (user finished the last step or tapped through),
    /// we persist the completion in UserStore so the tutorial never
    /// re-triggers on subsequent app launches.
    private var tutorialBinding: Binding<Bool> {
        Binding(
            get: { showTutorial },
            set: { newValue in
                showTutorial = newValue
                if !newValue {
                    userStore.completeTutorial()
                }
            }
        )
    }

    // MARK: Layers

    private var backgroundLayer: some View {
        visualMood.homeBackground
            .ignoresSafeArea()
    }

    private var fieldLayer: some View {
        PromiFieldRootView(
            pack: visualPack,
            mood: visualMood,
            promis: sortedPromis,
            nuées: nuéeStore.activeNuées(for: userStore.localUserId),
            languageCode: userStore.selectedLanguage,
            sortOption: selectedSort,
            onTapPromi: { promi in
                closeFloatingMenusIfNeeded()
                selectedPromi = promi
            },
            onTapNuée: { nuée in
                closeFloatingMenusIfNeeded()
                selectedNuée = nuée
            }
        )
    }

    private var dismissLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .onTapGesture {
                Haptics.shared.lightTap()
                // Close BOTH menus on tap-outside, not just one. The
                // dismissLayer is shown whenever EITHER menu is open
                // (see line above), so its tap handler must mirror that
                // by closing both via the existing helper.
                closeFloatingMenusIfNeeded()
            }
            .zIndex(10)
    }

    // MARK: Chrome (passation §12)

    private func homeChrome() -> some View {
        let inset = symmetricChromeInset
        let isDarkField = visualMood.prefersDarkChrome

        return ZStack {
            topLeftBrand(topInset: inset, isDarkField: isDarkField)
            topRightAdd(topInset: inset, isDarkField: isDarkField)

            bottomDock(bottomInset: inset, isDarkField: isDarkField)
        }
        .ignoresSafeArea()
        .zIndex(20)
    }

    // MARK: Chrome inset (symmetric, clears status bar + home indicator)

    private var screenSafeAreaInsets: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first

        let window = scene?.windows.first(where: { $0.isKeyWindow })
            ?? scene?.windows.first

        return window?.safeAreaInsets ?? UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0)
    }

    private var symmetricChromeInset: CGFloat {
        let insets = screenSafeAreaInsets
        return max(60, max(insets.top, insets.bottom) + 14)
    }

    private func topLeftBrand(topInset: CGFloat, isDarkField: Bool) -> some View {
        VStack {
            HStack {
                Button(action: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.lightTap()
                    showSettings = true
                }) {
                    Text("Promi")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(isDarkField ? .white.opacity(0.94) : .black.opacity(0.84))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.45)
                        .onEnded { _ in
                            closeFloatingMenusIfNeeded()
                            Haptics.shared.tinyPop()
                            showDrafts = true
                        }
                )

                Spacer()
            }
            .padding(.horizontal, sideInset)
            .padding(.top, topInset)

            Spacer()
        }
    }

    private func topRightAdd(topInset: CGFloat, isDarkField: Bool) -> some View {
        VStack {
            HStack(spacing: 10) {
                Spacer()

                // Mes Nuées — relocated from the bottom dock to live at
                // the top, immediately to the left of the + button.
                // Reads as a "top-right meta-navigation cluster":
                //   • the + creates a Promi
                //   • the Nuées browse the swarms
                // Both actions are about WHAT exists / WHAT is created
                // in the app, while the bottom dock holds tools to DO
                // things (sort, browse, share, study, etc.).
                IconOnlyCircleButton(
                    isDarkField: isDarkField,
                    size: 46,
                    action: {
                        closeFloatingMenusIfNeeded()
                        Haptics.shared.lightTap()
                        showMesNuées = true
                    },
                    glyph: {
                        NuéeHexGlyph(isDarkField: isDarkField)
                            .frame(width: 24, height: 24)
                    }
                )

                AddActionControl(
                    isExpanded: $isAddMenuExpanded,
                    isDarkField: isDarkField,
                    draftCount: draftStore.drafts.count,
                    onNewPromi: {
                        closeFloatingMenusIfNeeded()
                        Haptics.shared.tinyPop()
                        showAddPromi = true
                    },
                    onOpenDrafts: {
                        closeFloatingMenusIfNeeded()
                        Haptics.shared.tinyPop()
                        showDrafts = true
                    }
                )
            }
            .padding(.horizontal, sideInset)
            .padding(.top, topInset)

            Spacer()
        }
    }

    private func bottomDock(bottomInset: CGFloat, isDarkField: Bool) -> some View {
        VStack {
            Spacer()

            BottomDockRow(
                selectedSort: $selectedSort,
                isSortMenuExpanded: $isSortMenuExpanded,
                isDarkField: isDarkField,
                onOpenPromiList: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.lightTap()
                    showPromiList = true
                },
                onOpenKarma: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.lightTap()
                    showKarma = true
                },
                onOpenStudio: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.lightTap()
                    showStudio = true
                },
                onOpenComposition: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.lightTap()
                    showCompositionShare = true
                }
            )
            .padding(.horizontal, sideInset)
            .padding(.bottom, bottomInset)
        }
    }

    // MARK: Promis sorting (home field)

    private var visiblePromis: [PromiItem] {
        promiStore.promis.filter { $0.status != .done }
    }

    private var sortedPromis: [PromiItem] {
        switch selectedSort {
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
                stablePromiShuffleRank(lhs) < stablePromiShuffleRank(rhs)
            }
        }
    }

    private func stablePromiShuffleRank(_ promi: PromiItem) -> Int {
        var hasher = Hasher()
        hasher.combine(promi.id)
        hasher.combine(promi.createdAt.timeIntervalSinceReferenceDate)
        return abs(hasher.finalize())
    }

    private func closeFloatingMenusIfNeeded() {
        if isSortMenuExpanded {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                isSortMenuExpanded = false
            }
        }
        if isAddMenuExpanded {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                isAddMenuExpanded = false
            }
        }
    }
}

// MARK: - Bottom dock (5 buttons: tri ... karma ... œil(big, center) ... studio ... share)

struct BottomDockRow: View {
    @Binding var selectedSort: PromiFieldSortOption
    @Binding var isSortMenuExpanded: Bool
    let isDarkField: Bool
    let onOpenPromiList: () -> Void
    let onOpenKarma: () -> Void
    let onOpenStudio: () -> Void
    let onOpenComposition: () -> Void

    /// Standard size for side dock buttons. The four bookend actions
    /// (tri, karma, studio, share) all use this baseline diameter.
    private let baseSize: CGFloat = 46

    /// Center button (Pinky Promise → Mes Promi) is slightly larger
    /// than the side buttons. The +8pt diameter (≈17%) makes it read
    /// as the visual hub of the dock without dominating, perfectly
    /// balanced by the symmetry of the four side actions around it.
    /// The user explicitly asked for "à peine plus grosse" — barely
    /// bigger — so we keep the differential subtle.
    private let centerSize: CGFloat = 54

    var body: some View {
        // alignment: .center — every dock item is vertically centered
        // on the same midline. The slightly larger center button (Pinky
        // Promise) extends an equal amount above and below the side
        // buttons' midline, reading as a symmetric hub. The four side
        // buttons (tri, karma, studio, share) bracket it on both sides.
        //
        // Why .center and not .bottom: with .center the bigger button
        // feels like a hub with the others orbiting around it. With
        // .bottom, it would just look "taller", less balanced.
        //
        // The 4pt vertical extension below the side buttons' baseline
        // is well within the safe-area padding (bottomInset includes
        // a 14pt safety margin in ContentView).
        HStack(alignment: .center, spacing: 0) {
            // Tri — leftmost bookend
            PromiFieldSortControl(
                selectedSort: $selectedSort,
                isExpanded: $isSortMenuExpanded,
                isDarkField: isDarkField
            )

            Spacer(minLength: 8)

            // Karma — uses the eye glyph now (relocated from Mes Promi).
            // Rationale: Karma is the user's relationship with their
            // promises kept/broken — what they SEE about themselves.
            // The eye is the perfect metaphor for that introspective
            // gaze. The previous star icon was generic and detached
            // from the Promi soul.
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

            // Pinky Promise — the central hub of the dock.
            // Opens Mes Promi (the personal list of one's own engagements).
            // The two-hands-with-linked-pinkies glyph IS the brand:
            // Promi is built around the universal childlike gesture of
            // sincere commitment. Putting this gesture at the center of
            // the dock makes it the visual signature of the home screen.
            //
            // Slightly larger (54pt vs 46pt baseline) to mark its
            // primacy as the principal action: "show me my promises,
            // the heart of the app".
            IconOnlyCircleButton(
                isDarkField: isDarkField,
                size: centerSize,
                action: onOpenPromiList,
                glyph: {
                    PinkyPromiseGlyph(isDarkField: isDarkField)
                        .frame(width: 30, height: 30)
                }
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

// MARK: - Chrome primitives

struct FloatingChromeCircle: View {
    let isDarkField: Bool

    var body: some View {
        ChromeCircleSurface(isDarkField: isDarkField)
    }
}

struct FloatingGlyphButton: View {
    let symbol: String
    let isDarkField: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                FloatingChromeCircle(isDarkField: isDarkField)

                Text(symbol)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white.opacity(0.96))
            }
            .frame(width: 46, height: 46)
        }
        .buttonStyle(.plain)
    }
}

struct IconOnlyCircleButton<Glyph: View>: View {
    let isDarkField: Bool
    let size: CGFloat
    let action: () -> Void
    let glyph: Glyph

    init(
        isDarkField: Bool,
        size: CGFloat = 46,
        action: @escaping () -> Void,
        @ViewBuilder glyph: () -> Glyph
    ) {
        self.isDarkField = isDarkField
        self.size = size
        self.action = action
        self.glyph = glyph()
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                FloatingChromeCircle(isDarkField: isDarkField)
                glyph
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
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

// MARK: - Add action control + menu (top-right "+" button with dropdown)
//
// Mirrors PromiFieldSortControl/CompactSortMenu but flipped vertically: the
// menu drops DOWN from the button (offset y +58) and aligns to its trailing
// edge (since the button sits at the top-right of the screen).

struct AddActionControl: View {
    @Binding var isExpanded: Bool
    let isDarkField: Bool
    let draftCount: Int
    let onNewPromi: () -> Void
    let onOpenDrafts: () -> Void

    private let menuWidth: CGFloat = 220
    private let buttonSize: CGFloat = 46

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                Haptics.shared.tinyPop()
                withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    FloatingChromeCircle(isDarkField: isDarkField)
                    AddPlusGlyph(isDarkField: isDarkField)
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(isExpanded ? 45 : 0))
                }
                .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .zIndex(2)

            if isExpanded {
                AddActionMenu(
                    draftCount: draftCount,
                    isDarkField: isDarkField,
                    onNewPromi: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                        onNewPromi()
                    },
                    onOpenDrafts: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                        onOpenDrafts()
                    }
                )
                .frame(width: menuWidth)
                .offset(y: 58)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(1)
            }
        }
        .frame(width: buttonSize, height: buttonSize, alignment: .topTrailing)
    }
}

struct AddActionMenu: View {
    let draftCount: Int
    let isDarkField: Bool
    let onNewPromi: () -> Void
    let onOpenDrafts: () -> Void

    private var draftLabel: String {
        draftCount > 1 ? "Drafts" : "Draft"
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
            menuRow(
                title: "Nouveau Promi",
                subtitle: "Créer une promesse maintenant",
                accent: true,
                action: onNewPromi
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


// MARK: - Surfaces

struct ChromeCapsuleSurface: View {
    let isDarkField: Bool

    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)

            Capsule(style: .continuous)
                .fill(Color.white.opacity(isDarkField ? 0.10 : 0.18))

            Capsule(style: .continuous)
                .stroke(
                    isDarkField ? Color.white.opacity(0.18) : Color.white.opacity(0.10),
                    lineWidth: 0.6
                )
        }
        .shadow(
            color: .black.opacity(isDarkField ? 0.22 : 0.10),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

struct ChromeCircleSurface: View {
    let isDarkField: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)

            Circle()
                .fill(Color.white.opacity(isDarkField ? 0.10 : 0.18))

            Circle()
                .stroke(
                    isDarkField ? Color.white.opacity(0.18) : Color.white.opacity(0.10),
                    lineWidth: 0.6
                )
        }
        .shadow(
            color: .black.opacity(isDarkField ? 0.22 : 0.10),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

struct CompactMenuSurface: View {
    let isDarkField: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(isDarkField ? 0.18 : 0.10))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
        }
    }
}

// MARK: - Glyphs

struct PromiFieldSortGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.5
            let w = size.width
            let h = size.height

            // Two arrows side by side — universal sort metaphor.
            // Left arrow: pointing UP. Right arrow: pointing DOWN.

            // LEFT arrow (up)
            var leftStem = Path()
            leftStem.move(to: CGPoint(x: w * 0.30, y: h * 0.20))
            leftStem.addLine(to: CGPoint(x: w * 0.30, y: h * 0.80))
            context.stroke(
                leftStem,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            var leftHead = Path()
            leftHead.move(to: CGPoint(x: w * 0.18, y: h * 0.34))
            leftHead.addLine(to: CGPoint(x: w * 0.30, y: h * 0.20))
            leftHead.addLine(to: CGPoint(x: w * 0.42, y: h * 0.34))
            context.stroke(
                leftHead,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )

            // RIGHT arrow (down)
            var rightStem = Path()
            rightStem.move(to: CGPoint(x: w * 0.70, y: h * 0.20))
            rightStem.addLine(to: CGPoint(x: w * 0.70, y: h * 0.80))
            context.stroke(
                rightStem,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            var rightHead = Path()
            rightHead.move(to: CGPoint(x: w * 0.58, y: h * 0.66))
            rightHead.addLine(to: CGPoint(x: w * 0.70, y: h * 0.80))
            rightHead.addLine(to: CGPoint(x: w * 0.82, y: h * 0.66))
            context.stroke(
                rightHead,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

struct StudioGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.4
            let w = size.width
            let h = size.height

            // 2×2 grid of small squares — universal "themes / tile picker" metaphor.
            let cell = w * 0.30
            let gap = w * 0.10
            let originX = (w - (cell * 2 + gap)) / 2
            let originY = (h - (cell * 2 + gap)) / 2

            for row in 0..<2 {
                for col in 0..<2 {
                    let rect = CGRect(
                        x: originX + CGFloat(col) * (cell + gap),
                        y: originY + CGFloat(row) * (cell + gap),
                        width: cell,
                        height: cell
                    )
                    let path = Path(roundedRect: rect, cornerRadius: 2, style: .continuous)
                    context.stroke(
                        path,
                        with: .color(stroke),
                        style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round)
                    )
                }
            }
        }
    }
}

struct EyeGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.94)
            let fill = isDarkField ? Color.white.opacity(0.90) : Color.white.opacity(0.92)

            var eye = Path()
            eye.move(to: CGPoint(x: size.width * 0.14, y: size.height * 0.50))
            eye.addQuadCurve(
                to: CGPoint(x: size.width * 0.86, y: size.height * 0.50),
                control: CGPoint(x: size.width * 0.50, y: size.height * 0.12)
            )
            eye.addQuadCurve(
                to: CGPoint(x: size.width * 0.14, y: size.height * 0.50),
                control: CGPoint(x: size.width * 0.50, y: size.height * 0.88)
            )

            context.stroke(eye, with: .color(stroke), lineWidth: 1.7)
            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.40, y: size.height * 0.35, width: size.width * 0.20, height: size.height * 0.20)),
                with: .color(fill)
            )
        }
    }
}

// MARK: - NuéeHexGlyph
//
// SF Symbol "circle.hexagongrid" wrapped in a styled View for consistency
// with the other dock glyphs. The hexagonal grid icon visually echoes the
// Voronoï tiling of the home field — a perfect identity match for the
// Nuée concept (a swarm of cells, a small group sharing a territory).
//
// Same symbol is used in the empty state of MesNuéesView, so the user
// experiences visual continuity: the icon they see when "no Nuées yet"
// is the exact same icon as the dock button that opens MesNuéesView.

struct NuéeHexGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Image(systemName: "circle.hexagongrid")
            .font(.system(size: 22, weight: .regular))
            .foregroundColor(Color.white.opacity(isDarkField ? 0.96 : 0.94))
    }
}

// MARK: - PinkyPromiseGlyph
//
// Two pinky fingers, side by side, hooked together at the top — the
// universal childlike gesture of sincere commitment.
//
// Drawing recipe:
//   1. Two small rounded fists at the bottom (the closed hands)
//   2. From the inner-top edge of each fist, a curved finger rises
//      upward and inward, meeting at the top center
//   3. A small dot at the meeting point seals the "hook" visually
//
// At 30×30pt (the size we use in the dock central button), the hooked
// pinkies read clearly even though the elements are small. At 24×24pt
// it still reads but with less detail in the fists.
//
// This glyph IS the brand. Promi is built around the universal childlike
// gesture of pinky-promise-as-sincere-commitment. Putting it at the
// center of the dock makes it the visual signature of the home screen.

struct PinkyPromiseGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.96) : Color.white.opacity(0.94)
            let lineWidth: CGFloat = 1.6
            let w = size.width
            let h = size.height

            // Two closed fists at the bottom — small rounded rectangles
            // suggesting hand silhouettes viewed from the side.
            let fistW: CGFloat = w * 0.26
            let fistH: CGFloat = h * 0.26
            let fistY: CGFloat = h * 0.58

            let leftFistRect = CGRect(
                x: w * 0.16,
                y: fistY,
                width: fistW,
                height: fistH
            )
            let rightFistRect = CGRect(
                x: w * 0.58,
                y: fistY,
                width: fistW,
                height: fistH
            )

            let leftFist = Path(roundedRect: leftFistRect, cornerRadius: fistW * 0.34)
            let rightFist = Path(roundedRect: rightFistRect, cornerRadius: fistW * 0.34)

            let style = StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            )

            context.stroke(leftFist, with: .color(stroke), style: style)
            context.stroke(rightFist, with: .color(stroke), style: style)

            // Two pinky fingers extending upward from the inner-top edge
            // of each fist, curving toward the center to hook together.
            //
            // Left pinky: starts at the right side of the left fist's
            // top edge, curves up-and-right to meet the top center.
            // Right pinky: mirrors the left, curves up-and-left to meet
            // the top center.
            //
            // The two curves meet at h * 0.18 (top area of the glyph),
            // creating the iconic "hook" of the linked pinkies.
            let topMeetingY: CGFloat = h * 0.18

            let leftPinkyStart = CGPoint(
                x: leftFistRect.maxX - fistW * 0.18,
                y: fistY
            )
            let leftPinkyEnd = CGPoint(x: w * 0.50, y: topMeetingY)
            let leftPinkyControl = CGPoint(
                x: leftFistRect.maxX - fistW * 0.05,
                y: h * 0.30
            )

            var leftPinky = Path()
            leftPinky.move(to: leftPinkyStart)
            leftPinky.addQuadCurve(to: leftPinkyEnd, control: leftPinkyControl)

            let rightPinkyStart = CGPoint(
                x: rightFistRect.minX + fistW * 0.18,
                y: fistY
            )
            let rightPinkyEnd = CGPoint(x: w * 0.50, y: topMeetingY)
            let rightPinkyControl = CGPoint(
                x: rightFistRect.minX + fistW * 0.05,
                y: h * 0.30
            )

            var rightPinky = Path()
            rightPinky.move(to: rightPinkyStart)
            rightPinky.addQuadCurve(to: rightPinkyEnd, control: rightPinkyControl)

            context.stroke(leftPinky, with: .color(stroke), style: style)
            context.stroke(rightPinky, with: .color(stroke), style: style)

            // Small dot at the meeting point — the "hook" / link seal.
            // Visually anchors the two curves so they read as joined,
            // not just adjacent.
            let hookR: CGFloat = 1.7
            context.fill(
                Path(ellipseIn: CGRect(
                    x: w * 0.50 - hookR,
                    y: topMeetingY - hookR,
                    width: hookR * 2,
                    height: hookR * 2
                )),
                with: .color(stroke)
            )
        }
    }
}

struct CompositionGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.5
            let w = size.width
            let h = size.height

            // Square (with bottom open) — the iOS share metaphor: a tray with
            // an arrow rising out of it.
            var tray = Path()
            tray.move(to: CGPoint(x: w * 0.22, y: h * 0.46))
            tray.addLine(to: CGPoint(x: w * 0.22, y: h * 0.84))
            tray.addLine(to: CGPoint(x: w * 0.78, y: h * 0.84))
            tray.addLine(to: CGPoint(x: w * 0.78, y: h * 0.46))
            context.stroke(tray, with: .color(stroke), lineWidth: lineWidth)

            // Vertical line (the arrow body)
            var stem = Path()
            stem.move(to: CGPoint(x: w * 0.50, y: h * 0.62))
            stem.addLine(to: CGPoint(x: w * 0.50, y: h * 0.16))
            context.stroke(stem, with: .color(stroke), lineWidth: lineWidth)

            // Arrow head (chevron pointing up)
            var head = Path()
            head.move(to: CGPoint(x: w * 0.34, y: h * 0.30))
            head.addLine(to: CGPoint(x: w * 0.50, y: h * 0.16))
            head.addLine(to: CGPoint(x: w * 0.66, y: h * 0.30))
            context.stroke(
                head,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

struct AddPlusGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.7
            let w = size.width
            let h = size.height

            // Simple "+" cross.
            var horizontal = Path()
            horizontal.move(to: CGPoint(x: w * 0.22, y: h * 0.50))
            horizontal.addLine(to: CGPoint(x: w * 0.78, y: h * 0.50))
            context.stroke(
                horizontal,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            var vertical = Path()
            vertical.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            vertical.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            context.stroke(
                vertical,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
        }
    }
}
