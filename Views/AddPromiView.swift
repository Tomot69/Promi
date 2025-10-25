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
    @EnvironmentObject var userStore: UserStore
    
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var importance: Importance = .normal
    @State private var assignee = ""
    @State private var urgencyIntensity = 50 // Jauge unique 0-100
    @State private var showValidationAnimation = false
    
    private var buttonText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Make it happen" : "Valider ce Promi"
    }
    
    private var urgencyQuestion: String {
        if userStore.selectedLanguage.starts(with: "en") {
            return "How badly do you want this Promi to happen?"
        } else {
            return "À quel point veux-tu tenir ce Promi ?"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
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
                        VStack(alignment: .leading, spacing: Spacing.xs) {  // ✅ CORRIGÉ ICI
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
                        
                        // Importance (simple selector)
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
                        
                        // Urgency Intensity (jauge unique avec cœur progressif)
                        UrgencyIntensityView(
                            intensity: $urgencyIntensity,
                            question: urgencyQuestion
                        )
                        
                        Spacer(minLength: Spacing.xl)
                    }
                    .padding(Spacing.lg)
                }
                
                // Validation Animation Overlay
                if showValidationAnimation {
                    PromiValidationAnimationView(isPresented: $showValidationAnimation)
                        .transition(.opacity)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Brand.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createPromi) {
                        Text(buttonText)
                            .font(Typography.bodyEmphasis)
                            .foregroundColor(Brand.orange)
                    }
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
            intensity: urgencyIntensity
        )
        
        promiStore.addPromi(newPromi)
        
        // Animation de validation
        withAnimation(AnimationPreset.easeOut) {
            showValidationAnimation = true
        }
        
        // Fermeture après animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
}
