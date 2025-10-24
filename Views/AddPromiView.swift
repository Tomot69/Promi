//
//  AddPromiView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct AddPromiView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var importance: Importance = .normal
    @State private var assignee = ""
    @State private var intensity = 50
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Title
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Titre *")
                                .font(Typography.callout)
                                .foregroundColor(Brand.textSecondary)
                            
                            TextField("Appeler Maman", text: $title)
                                .font(Typography.body)
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Date & Time
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Date & Heure *")
                                .font(Typography.callout)
                                .foregroundColor(Brand.textSecondary)
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        
                        // Person
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Personne")
                                .font(Typography.callout)
                                .foregroundColor(Brand.textSecondary)
                            
                            TextField("Maman", text: $assignee)
                                .font(Typography.body)
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Importance
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Importance *")
                                .font(Typography.callout)
                                .foregroundColor(Brand.textSecondary)
                            
                            HStack(spacing: Spacing.md) {
                                ForEach(Importance.allCases, id: \.self) { level in
                                    Button(action: {
                                        importance = level
                                        Haptics.shared.lightTap()
                                    }) {
                                        Text(level.rawValue.capitalized)
                                            .font(Typography.callout)
                                            .foregroundColor(importance == level ? .white : Brand.textPrimary)
                                            .padding(.horizontal, Spacing.md)
                                            .padding(.vertical, Spacing.xs)
                                            .background(
                                                RoundedRectangle(cornerRadius: CornerRadius.xs)
                                                    .fill(importance == level ? Brand.orange : Color.gray.opacity(0.2))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Heart Intensity
                        HeartIntensityView(intensity: $intensity)
                        
                        Spacer()
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("Envoyer un Promi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(Brand.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Créer") {
                        createPromi()
                    }
                    .foregroundColor(Brand.orange)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func createPromi() {
        let newPromi = PromiItem(
            title: title,
            dueDate: dueDate,
            importance: importance,
            assignee: assignee.isEmpty ? nil : assignee,
            intensity: intensity
        )
        
        promiStore.addPromi(newPromi)
        dismiss()
    }
}
