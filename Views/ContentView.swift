//
//  ContentView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var karmaStore: KarmaStore
    
    @State private var showAddPromi = false
    @State private var showPalette = false
    @State private var showSettings = false
    @State private var showKarma = false
    @State private var showDrafts = false
    @State private var selectedSort: SortOption = .date
    
    // Tutorial
    @State private var showTutorial = false
    @State private var currentTutorialStep = 0
    
    var body: some View {
        ZStack {
            // Background minimaliste
            userStore.selectedPalette.backgroundColor
                .ignoresSafeArea()
                .animation(AnimationPreset.easeOut, value: userStore.selectedPalette)
            
            VStack(spacing: 0) {
                // Header minimaliste
                MinimalHeaderView(
                    textColor: userStore.selectedPalette.textPrimaryColor,
                    onAddTap: { showAddPromi = true }
                )
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                
                // Roast Strip (ultra-discret)
                Button(action: { showKarma = true }) {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(karmaColor)
                            .frame(width: 6, height: 6)
                        
                        Text(karmaStore.getRoast(language: userStore.selectedLanguage))
                            .font(Typography.caption)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.6))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(karmaStore.karmaState.percentage)%")
                            .font(Typography.caption2)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.sm)
                
                // Sort Tabs (ultra-minimalistes)
                MinimalSortTabsView(
                    selectedSort: $selectedSort,
                    textColor: userStore.selectedPalette.textSecondaryColor,
                    accentColor: userStore.selectedPalette.textPrimaryColor
                )
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.lg)
                
                // Promi List
                if sortedPromis.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        Text("🤍")
                            .font(.system(size: 48))
                        
                        Text("Aucun Promi pour le moment")
                            .font(Typography.callout)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.6))
                        
                        Text("Tape sur + pour commencer")
                            .font(Typography.caption)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.lg) {
                            ForEach(sortedPromis) { promi in
                                MinimalPromiCardView(promi: promi)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, 120) // Espace pour les icônes du bas
                    }
                }
            }
            
            // Bottom Icons Bar (fixe, centré, plus bas)
            BottomIconsBar(
                textColor: userStore.selectedPalette.textPrimaryColor,
                onDraftTap: { showDrafts = true },
                onPaletteTap: { showPalette = true },
                onKarmaTap: { showKarma = true },
                onSettingsTap: { showSettings = true }
            )
            
            // Tutorial Overlay
            if showTutorial {
                TutorialOverlayView(
                    isPresented: $showTutorial,
                    currentStep: $currentTutorialStep,
                    steps: TutorialContent.getSteps(language: userStore.selectedLanguage)
                )
            }
        }
        .sheet(isPresented: $showAddPromi) {
            AddPromiView()
        }
        .sheet(isPresented: $showPalette) {
            PaletteView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showKarma) {
            KarmaView()
        }
        .sheet(isPresented: $showDrafts) {
            DraftsView()
        }
        .onAppear {
            karmaStore.updateKarma(basedOn: promiStore.promis)
            
            if !userStore.hasCompletedTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(AnimationPreset.easeOut) {
                        showTutorial = true
                    }
                }
            }
        }
        .onChange(of: showTutorial) { _, newValue in
            if !newValue && !userStore.hasCompletedTutorial {
                userStore.completeTutorial()
            }
        }
    }
    
    private var sortedPromis: [PromiItem] {
        let openPromis = promiStore.promis.filter { $0.status == .open }
        
        switch selectedSort {
        case .date:
            return openPromis.sorted { $0.dueDate < $1.dueDate }
        case .urgency:
            let now = Date()
            return openPromis.sorted { abs($0.dueDate.timeIntervalSince(now)) < abs($1.dueDate.timeIntervalSince(now)) }
        case .person:
            return openPromis.sorted { ($0.assignee ?? "") < ($1.assignee ?? "") }
        case .importance:
            return openPromis.sorted { $0.intensity > $1.intensity }
        case .karma:
            return openPromis.sorted { $0.intensity > $1.intensity }
        case .inspiration:
            return openPromis.shuffled()
        case .groups:
            return openPromis // TODO: Implémenter groupes premium
        }
    }
    
    private var karmaColor: Color {
        let karma = karmaStore.karmaState.percentage
        if karma >= 90 { return Brand.karmaExcellent }
        else if karma >= 70 { return Brand.karmaGood }
        else if karma >= 50 { return Brand.karmaAverage }
        else { return Brand.karmaPoor }
    }
}

enum SortOption: String, CaseIterable {
    case date = "Date"
    case urgency = "Urgence"
    case person = "Personne"
    case importance = "Intensité"
    case karma = "Karma"
    case inspiration = "Inspi"
    case groups = "Groupes" // Premium
}
