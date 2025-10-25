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
    @State private var selectedSort: SortOption = .date
    
    // Tutorial
    @State private var showTutorial = false
    @State private var currentTutorialStep = 0
    
    var body: some View {
        ZStack {
            // Background (avec animation de changement)
            userStore.selectedPalette.backgroundColor
                .ignoresSafeArea()
                .animation(AnimationPreset.easeOut, value: userStore.selectedPalette)
            
            VStack(spacing: 0) {
                // Header (logo + Promi + bouton +)
                NewHeaderView(
                    textColor: userStore.selectedPalette.textPrimaryColor,
                    onAddTap: { showAddPromi = true }
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
                
                // Roast Strip (Karma)
                Button(action: { showKarma = true }) {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(karmaColor)
                            .frame(width: 8, height: 8)
                        
                        Text(karmaStore.getRoast(language: userStore.selectedLanguage))
                            .font(Typography.callout)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(karmaStore.karmaState.percentage)%")
                            .font(Typography.caption)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                
                // Sort Tabs
                SortTabsView(
                    selectedSort: $selectedSort,
                    textColor: userStore.selectedPalette.textSecondaryColor,
                    accentColor: userStore.selectedPalette.accentColor
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                
                // Promi List
                if sortedPromis.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        Text("👋")
                            .font(.system(size: 60))
                        
                        Text("Aucun Promi pour le moment")
                            .font(Typography.body)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                        
                        Text("Tape sur + pour commencer")
                            .font(Typography.caption)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            ForEach(sortedPromis) { promi in
                                PromiCardView(promi: promi)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xxxl)
                    }
                }
            }
            
            // Bottom Icons (floating)
            VStack {
                Spacer()
                HStack(spacing: Spacing.lg) {
                    Spacer()
                    
                    // Palette
                    IconButton(icon: "paintpalette", color: userStore.selectedPalette.accentColor) {
                        showPalette = true
                    }
                    
                    // Karma
                    IconButton(icon: "chart.bar.fill", color: Brand.orange) {
                        showKarma = true
                    }
                    
                    // Settings
                    IconButton(icon: "gearshape.fill", color: userStore.selectedPalette.textSecondaryColor) {
                        showSettings = true
                    }
                    
                    Spacer()
                }
                .padding(.bottom, Spacing.xl)
            }
            
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
        .onAppear {
            karmaStore.updateKarma(basedOn: promiStore.promis)
            
            // Afficher le tutoriel si jamais complété
            if !userStore.hasCompletedTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(AnimationPreset.easeOut) {
                        showTutorial = true
                    }
                }
            }
        }
        .onChange(of: showTutorial) { newValue in
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
            let order: [Importance: Int] = [.urgent: 0, .normal: 1, .low: 2]
            return openPromis.sorted { (order[$0.importance] ?? 99) < (order[$1.importance] ?? 99) }
        case .karma:
            return openPromis.sorted { $0.intensity > $1.intensity }
        case .inspiration:
            return openPromis.shuffled()
        }
    }
    
    private var karmaColor: Color {
        let karma = karmaStore.karmaState.percentage
        if karma >= 90 {
            return Brand.karmaExcellent
        } else if karma >= 70 {
            return Brand.karmaGood
        } else if karma >= 50 {
            return Brand.karmaAverage
        } else {
            return Brand.karmaPoor
        }
    }
}

enum SortOption: String, CaseIterable {
    case date = "Date"
    case urgency = "Urgence"
    case person = "Personne"
    case importance = "Important"
    case karma = "Karma"
    case inspiration = "Inspi"
}
