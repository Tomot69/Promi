//
//  ContentView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var karmaStore: KarmaStore
    
    @State private var showAddPromi = false
    @State private var showPalette = false
    @State private var showSettings = false
    @State private var selectedSort: SortOption = .date
    
    var body: some View {
        ZStack {
            // Background
            userStore.selectedPalette.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(
                    karma: karmaStore.karmaState.percentage,
                    roast: karmaStore.getRoast(language: userStore.selectedLanguage),
                    onAddTap: { showAddPromi = true }
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
                
                // Sort Tabs
                SortTabsView(selectedSort: $selectedSort)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                
                // Promi List
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(sortedPromis) { promi in
                            PromiCardView(promi: promi)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        FloatingButton(icon: "palette", color: userStore.selectedPalette.accentColor) {
                            showPalette = true
                        }
                        
                        FloatingButton(icon: "gear", color: Brand.textSecondary) {
                            showSettings = true
                        }
                    }
                    .padding(.trailing, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
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
        .onAppear {
            karmaStore.updateKarma(basedOn: promiStore.promis)
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
}

enum SortOption: String, CaseIterable {
    case date = "Date"
    case urgency = "Urgence"
    case person = "Personne"
    case importance = "Important"
    case karma = "Karma"
    case inspiration = "Inspi"
}
