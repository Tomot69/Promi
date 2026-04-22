import SwiftUI

// MARK: - Sort options

enum PromiFieldSortOption: String, CaseIterable {
    case date = "Date"
    case urgency = "Urgence"
    case person = "Personne"
    case importance = "Intensité"
    case inspiration = "Inspi"
    case nuée = "Nuée"

    var displayLabel: String {
        let en = Locale.current.language.languageCode?.identifier.starts(with: "en") == true
        switch self {
        case .date: return "Date"
        case .urgency: return en ? "Urgency" : "Urgence"
        case .person: return en ? "Person" : "Personne"
        case .importance: return en ? "Intensity" : "Intensité"
        case .inspiration: return "Inspi"
        case .nuée: return "Nuée"
        }
    }

    var visualHintTitle: String {
        let en = Locale.current.language.languageCode?.identifier.starts(with: "en") == true
        switch self {
        case .date: return en ? "Sort by date" : "Tri date"
        case .urgency: return en ? "Sort by urgency" : "Tri urgence"
        case .person: return en ? "Sort by person" : "Tri personne"
        case .importance: return en ? "Sort by intensity" : "Tri intensité"
        case .inspiration: return en ? "Free sort" : "Tri libre"
        case .nuée: return en ? "Sort by Nuée" : "Tri nuée"
        }
    }

    var visualHintSubtitle: String {
        let en = Locale.current.language.languageCode?.identifier.starts(with: "en") == true
        switch self {
        case .date: return en ? "closest in time rise to the top" : "les plus proches dans le temps montent"
        case .urgency: return en ? "most urgent ones densify in front" : "les plus urgents se densifient devant"
        case .person: return en ? "groups read laterally" : "les groupes se lisent latéralement"
        case .importance: return en ? "strongest ones take the center" : "les plus forts prennent le centre"
        case .inspiration: return en ? "free and organic layout" : "répartition libre et organique"
        case .nuée: return en ? "Promis group by swarm" : "les Promi se regroupent par essaim"
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
    case vitrailChrome
    case trame

    var id: String { rawValue }

    var studioTitle: String {
        switch self {
        case .galets: return "Galets"
        case .alveolesSignature: return "Alvéoles"
        case .cristal: return "Cristal"
        case .mosaicFlat: return "Mosaïque"
        case .spectrumSoft: return "Spectrum"
        case .vitrailChrome: return "Vitrail"
        case .trame: return "Trame"
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
        case .vitrailChrome:
            return "Vitraux d'église, plombs chrome liquide, reflets parallax"
        case .trame:
            return "Trame dense, contours nets, points au cœur des cellules"
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
    @EnvironmentObject var contactsStore: ContactsStore

    @State private var showAddPromi = false
    @State private var showSettings = false
    @State private var showStudio = false
    @State private var showKarma = false
    @State private var showDrafts = false
    @State private var showPromiList = false
    @State private var showMesNuées = false
    @State private var showCompositionShare = false
    @State private var showCreateNuée = false
    @State private var selectedSort: PromiFieldSortOption = .inspiration
    @State private var selectedPromi: PromiItem?
    @State private var selectedNuée: Nuée?
    @State private var reportPromi: PromiItem?
    @State private var showPaywall = false
    @State private var homeFieldSize: CGSize = .zero
    @State private var pinkyPulseActive = false
    @State private var karmaPulseIntensity: CGFloat = 0
    @State private var shakeDetected = false
    @State private var isSortMenuExpanded = false
    @State private var isAddMenuExpanded = false
    @State private var canvasOpacity: Double = 0
    @State private var hasPlayedEntrance = false

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

            tutorialLayer
        }
        .ignoresSafeArea()
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
        .sheet(isPresented: $showCreateNuée) {
            CreateNuéeView()
        }
        .sheet(isPresented: $showCompositionShare) {
            PromiCompositionShareView(
                pack: visualPack,
                mood: visualMood,
                sortOption: selectedSort,
                homeSize: homeFieldSize
            )
            .environmentObject(userStore)
            .environmentObject(promiStore)
        }
        .sheet(item: $selectedPromi) { promi in
            EditPromiView(promi: promi)
        }
        .sheet(isPresented: $showPaywall) {
            PromiPlusPaywallView()
                .environmentObject(userStore)
                .environmentObject(promiStore)
        }
        .sheet(item: $reportPromi) { promi in
            ReportSheet(
                promi: promi,
                senderName: contactsStore.contact(id: promi.senderContactId ?? "")?.displayName ?? "?"
            )
            .environmentObject(userStore)
            .environmentObject(contactsStore)
        }
        .sheet(item: $selectedNuée) { nuée in
            NuéeDetailView(nuéeId: nuée.id)
        }
        .onReceive(NotificationCenter.default.publisher(for: .promiDeepLink)) { notif in
            if let idStr = notif.userInfo?["promiId"] as? String,
               let promi = promiStore.promis.first(where: { $0.id.uuidString == idStr }) {
                selectedPromi = promi
            }
        }
        .onChange(of: karmaStore.karmaState.percentage) { oldVal, newVal in
            if let threshold = Brand.karmaJustCrossedThreshold(old: oldVal, new: newVal) {
                let intensity: CGFloat = threshold == 100 ? 1.0 : (threshold == 75 ? 0.6 : 0.35)
                karmaPulseIntensity = intensity
                let soft = UIImpactFeedbackGenerator(style: .soft)
                soft.impactOccurred(intensity: 0.3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    karmaPulseIntensity = 0
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .promiShakeDetected)) { _ in
            guard visualPackRawValue != PromiVisualPack.vitrailChrome.rawValue else { return }
            if promiStore.shakeToReorganize() {
                Haptics.shared.success()
                shakeDetected.toggle()
            }
        }
        .onAppear(perform: handleOnAppear)
    }

    // MARK: Tutorial

    /// Tutorial overlay — sits on top of everything when active.
    /// Extracted as a computed property for type-check relief.
    @ViewBuilder
    private var tutorialLayer: some View {
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
                    // Animation d'entrée : chaque dalle respire puis se stabilise
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: .promiCanvasEntrance, object: nil)
                    }
                }
            }
        )
    }

    /// First-landing tutorial trigger + karma refresh. Extracted from
    /// body for type-check relief.
    private func handleOnAppear() {
        karmaStore.updateKarma(basedOn: promiStore.promis)

        // The 0.6s delay lets the home Voronoï finish its appear animation
        // before we dim the screen, so the user sees the field "settle"
        // before being asked to learn it.
        if !userStore.hasCompletedTutorial && !showTutorial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.32)) {
                    showTutorial = true
                }
            }
        }
    }

    // MARK: Layers

    private var backgroundLayer: some View {
        visualMood.homeBackground
            .ignoresSafeArea()
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Promi canvas")
    }

    private var fieldLayer: some View {
        GeometryReader { geo in
            PromiFieldRootView(
            pack: visualPack,
            mood: visualMood,
            promis: sortedPromis,
            nuées: nuéeStore.activeNuées(for: userStore.localUserId),
            languageCode: userStore.selectedLanguage,
            sortOption: selectedSort,
            onTapPromi: { promi in
                closeFloatingMenusIfNeeded()
                Haptics.shared.packTap(visualPackRawValue)
                selectedPromi = promi
            },
            onTapNuée: { nuée in
                closeFloatingMenusIfNeeded()
                Haptics.shared.packTap(visualPackRawValue)
                selectedNuée = nuée
            },
            onLongPressPromi: { promi in
                closeFloatingMenusIfNeeded()
                reportPromi = promi
            }
        )
        .onAppear {
            homeFieldSize = geo.size
            withAnimation(.easeOut(duration: 0.3)) {
                canvasOpacity = 1
            }
            // Utilisateurs récurrents : animation d'entrée des dalles
            if userStore.hasCompletedTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NotificationCenter.default.post(name: .promiCanvasEntrance, object: nil)
                }
            }
        }
        .opacity(canvasOpacity)
        .onChange(of: geo.size) { _, newSize in homeFieldSize = newSize }
        .overlay(
            Circle()
                .fill(Brand.orange.opacity(0.06 * karmaPulseIntensity))
                .scaleEffect(1.0 + karmaPulseIntensity * 0.3)
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 1.2), value: karmaPulseIntensity)
        )
        }
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
        // Chrome × Vitrail affiche toujours un fond de vitrail blanc (les
        // cellules chrome réelles sont sur fond clair), donc on force le
        // chrome sombre (icônes + texte noirs) quel que soit le mood, pour
        // que le titre "Promi" et les glyphs soient lisibles.
        let isDarkField = visualPack == .vitrailChrome
            ? false
            : visualMood.prefersDarkChrome

        return ZStack {
            topLeftBrand(topInset: inset, isDarkField: isDarkField)
            topRightCluster(topInset: inset, isDarkField: isDarkField)

            // Empreinte — nombre total de promesses tenues, gravé dans la toile
            if karmaStore.karmaState.completedPromis > 0 {
                VStack {
                    Spacer()
                    Text("\(karmaStore.karmaState.completedPromis) \(userStore.selectedLanguage.starts(with: "en") ? "kept" : (karmaStore.karmaState.completedPromis == 1 ? "tenue" : "tenues"))")
                        .font(.system(size: 9, weight: .regular))
                        .tracking(1.2)
                        .foregroundColor(isDarkField ? .white.opacity(0.16) : .black.opacity(0.12))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, inset + 52)
                }
                .allowsHitTesting(false)
                .ignoresSafeArea()
            }

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
                VStack(alignment: .leading, spacing: 2) {
                    Text("Promi")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(isDarkField ? .white.opacity(0.94) : .black.opacity(0.84))

                    Text(canvasMurmur)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(isDarkField ? .white.opacity(0.72) : .black.opacity(0.58))
                        .tracking(0.3)
                        .animation(.easeInOut(duration: 1.2), value: canvasMurmur)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        pinkyPulseActive = true
                        let soft = UIImpactFeedbackGenerator(style: .soft)
                        soft.impactOccurred(intensity: 0.4)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            pinkyPulseActive = false
                        }
                    }
                    .onTapGesture(count: 1) {
                        closeFloatingMenusIfNeeded()
                        Haptics.shared.lightTap()
                        showSettings = true
                    }
                    .onLongPressGesture(minimumDuration: 0.45) {
                        closeFloatingMenusIfNeeded()
                        Haptics.shared.tinyPop()
                        showDrafts = true
                    }
                    .accessibilityLabel("Promi")
                    .accessibilityHint(userStore.selectedLanguage.starts(with: "en")
                        ? "Tap to open settings, long press for drafts"
                        : "Toucher pour les réglages, appui long pour les brouillons")

                Spacer()
            }
            .padding(.horizontal, sideInset)
            .padding(.top, topInset)

            Spacer()
        }
    }

    private func topRightCluster(topInset: CGFloat, isDarkField: Bool) -> some View {
        VStack {
            HStack(spacing: 10) {
                Spacer()

                // Mes Nuées — hexagonal grid icon.
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

                // Mes Promi — pinky promise glyph, the brand gesture.
                // Opens the personal list of all one's promises.
                IconOnlyCircleButton(
                    isDarkField: isDarkField,
                    size: 46,
                    action: {
                        closeFloatingMenusIfNeeded()
                        Haptics.shared.lightTap()
                        showPromiList = true
                    },
                    glyph: {
                        PinkyPromiseGlyph(isDarkField: isDarkField)
                            .frame(width: 24, height: 24)
                            .scaleEffect(pinkyPulseActive ? 1.15 : 1.0)
                            .opacity(pinkyPulseActive ? 0.6 : 1.0)
                            .animation(.easeInOut(duration: 0.15).repeatCount(4, autoreverses: true), value: pinkyPulseActive)
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
                isAddMenuExpanded: $isAddMenuExpanded,
                isDarkField: isDarkField,
                draftCount: draftStore.totalDraftCount,
                isPremium: userStore.isPremium,
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
                },
                onNewPromi: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.tinyPop()
                    showAddPromi = true
                },
                onNewNuée: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.tinyPop()
                    showCreateNuée = true
                },
                onOpenDrafts: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.tinyPop()
                    showDrafts = true
                },
                onOpenPaywall: {
                    closeFloatingMenusIfNeeded()
                    Haptics.shared.lightTap()
                    showPaywall = true
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

        case .nuée:
            // Group Promis by their nuéeId — Promis belonging to the same
            // Nuée cluster together. Promis without a Nuée (personal, no
            // swarm) come last. Within each group, sorted by createdAt
            // (oldest first → stable left-to-right reading order).
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

    private func stablePromiShuffleRank(_ promi: PromiItem) -> Int {
        var hasher = Hasher()
        hasher.combine(promi.id)
        hasher.combine(promi.createdAt.timeIntervalSinceReferenceDate)
        return abs(hasher.finalize())
    }

    private var canvasMurmur: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let en = userStore.selectedLanguage.starts(with: "en")
        let streak = karmaStore.currentStreak
        let todayCount = promiStore.promis.filter {
            $0.status == .open && Calendar.current.isDateInToday($0.dueDate)
        }.count
        let total = promiStore.promis.count

        // Priorité : événement > heure > état
        if total == 0 {
            return en ? "the canvas is waiting" : "la toile attend"
        }
        if todayCount > 0 {
            return en
                ? "\(todayCount) \(todayCount == 1 ? "promise" : "promises") today"
                : "\(todayCount) \(todayCount == 1 ? "promesse" : "promesses") aujourd'hui"
        }
        if streak >= 30 { return en ? "legendary" : "légendaire" }
        if streak >= 7 { return en ? "solid" : "solide" }
        if hour >= 22 || hour < 6 { return en ? "still up?" : "encore debout ?" }
        if hour < 12 { return en ? "good morning" : "bon matin" }
        return en ? "your word, your canvas" : "ta parole, ta toile"
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
