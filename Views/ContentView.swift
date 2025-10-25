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
    
    @State private var showTutorial = false
    @State private var currentTutorialStep = 0
    
    var body: some View {
        ZStack {
            userStore.selectedPalette.backgroundColor
                .ignoresSafeArea()
                .animation(Animation.easeOut(duration: 0.3), value: userStore.selectedPalette)
            
            VStack(spacing: 0) {
                // Header
                MinimalHeaderView(
                    textColor: userStore.selectedPalette.textPrimaryColor,
                    onAddTap: { showAddPromi = true }
                )
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                // Roast Strip
                Button(action: { showKarma = true }) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(karmaColor.opacity(0.5))
                            .frame(width: 4, height: 4)
                        
                        Text(karmaStore.getRoast(language: userStore.selectedLanguage))
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.3))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                
                // Sort Tabs
                MinimalSortTabsView(
                    selectedSort: $selectedSort,
                    textColor: userStore.selectedPalette.textSecondaryColor,
                    accentColor: userStore.selectedPalette.textPrimaryColor
                )
                .padding(.top, 24)
                .padding(.bottom, 24)
                
                // Promi List
                if sortedPromis.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Circle()
                            .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.08), lineWidth: 0.5)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("🤍")
                                    .font(.system(size: 32))
                            )
                        
                        Text("Aucun Promi pour le moment")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                        
                        Text("Tape sur + pour commencer")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.25))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(sortedPromis) { promi in
                                MinimalPromiCardView(promi: promi)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 140)
                    }
                }
            }
            
            // Bottom Icons Bar
            BottomIconsBar(
                textColor: userStore.selectedPalette.textPrimaryColor,
                onDraftTap: { showDrafts = true },
                onPaletteTap: { showPalette = true },
                onKarmaTap: { showKarma = true },
                onSettingsTap: { showSettings = true }
            )
            
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
                    withAnimation(Animation.easeOut(duration: 0.3)) {
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
            return openPromis
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
    case groups = "Groupes"
}
