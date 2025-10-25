//
//  AddPromiView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct AddPromiView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var draftStore: DraftStore
    
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var assignee = ""
    @State private var intensity = 50
    @State private var showValidationAnimation = false
    @State private var showExitConfirmation = false
    
    private var titleText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Create your Promi" : "Crée ton Promi"
    }
    
    private var placeholderText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Promi something..." : "Promets quelque chose..."
    }
    
    private var buttonText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Make it happen" : "Valider ce Promi"
    }
    
    private var intensityQuestion: String {
        if userStore.selectedLanguage.starts(with: "en") {
            return "How badly do you want this Promi to happen?"
        } else if userStore.selectedLanguage.starts(with: "es") {
            return "¿Cuánto quieres cumplir este Promi?"
        } else {
            return "À quel point veux-tu tenir ce Promi ?"
        }
    }
    
    var body: some View {
        ZStack {
            userStore.selectedPalette.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header ultra-minimal
                HStack {
                    Button(action: handleClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    // Titre avec "Promi" en orange
                    HStack(spacing: 4) {
                        Text(titleText.replacingOccurrences(of: "Promi", with: ""))
                            .font(Typography.callout)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.5))
                        
                        Text("Promi")
                            .font(Typography.callout)
                            .foregroundColor(Brand.orange.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 18, height: 18)
                }
                .padding(.horizontal, Spacing.xxxl)
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxl)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xxxl) {
                        // Title field
                        TextField(placeholderText, text: $title)
                            .font(Typography.body)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .padding(.vertical, Spacing.lg)
                            .overlay(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                userStore.selectedPalette.textPrimaryColor.opacity(0.08),
                                                userStore.selectedPalette.textPrimaryColor.opacity(0.02)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 0.15),
                                alignment: .bottom
                            )
                        
                        // Date
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "When" : "Quand")
                                .font(Typography.caption)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.35))
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(Brand.orange.opacity(0.85))
                        }
                        
                        // Person
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "For whom" : "Pour qui")
                                .font(Typography.caption)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.35))
                            
                            TextField(userStore.selectedLanguage.starts(with: "en") ? "Someone..." : "Quelqu'un...", text: $assignee)
                                .font(Typography.body)
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                                .padding(.vertical, Spacing.lg)
                                .overlay(
                                    Rectangle()
                                        .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.05))
                                        .frame(height: 0.15),
                                    alignment: .bottom
                                )
                        }
                        
                        // Audio button
                        Button(action: { Haptics.shared.tinyPop() }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "mic")
                                    .font(.system(size: 12))
                                Text(userStore.selectedLanguage.starts(with: "en") ? "Add audio" : "Ajouter audio")
                                    .font(Typography.caption2)
                            }
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.3))
                        }
                        
                        // Intensity gauge
                        MinimalIntensityGaugeView(
                            intensity: $intensity,
                            question: intensityQuestion,
                            textColor: userStore.selectedPalette.textSecondaryColor
                        )
                        
                        Spacer(minLength: 140)
                    }
                    .padding(.horizontal, Spacing.xxxl)
                }
                
                Spacer()
                
                // Bottom button (orange invitant)
                Button(action: createPromi) {
                    Text(buttonText)
                        .font(Typography.bodyEmphasis)
                        .foregroundColor(title.isEmpty ? userStore.selectedPalette.textPrimaryColor.opacity(0.25) : Brand.orange.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .stroke(
                                    title.isEmpty
                                    ? userStore.selectedPalette.textPrimaryColor.opacity(0.08)
                                    : Brand.orange.opacity(0.3),
                                    lineWidth: 0.5
                                )
                        )
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
            }
            
            if showValidationAnimation {
                PromiValidationAnimationView(isPresented: $showValidationAnimation)
                    .transition(.opacity)
            }
        }
        .confirmationDialog("Sauvegarder en brouillon ?", isPresented: $showExitConfirmation) {
            Button(userStore.selectedLanguage.starts(with: "en") ? "Save draft" : "Sauvegarder") {
                saveDraft()
                dismiss()
            }
            Button(userStore.selectedLanguage.starts(with: "en") ? "Discard" : "Supprimer", role: .destructive) {
                dismiss()
            }
            Button(userStore.selectedLanguage.starts(with: "en") ? "Cancel" : "Annuler", role: .cancel) {}
        }
    }
    
    private func handleClose() {
        if !title.isEmpty {
            showExitConfirmation = true
        } else {
            dismiss()
        }
    }
    
    private func saveDraft() {
        let draft = PromiDraft(
            title: title,
            dueDate: dueDate,
            assignee: assignee.isEmpty ? nil : assignee,
            intensity: intensity
        )
        draftStore.saveDraft(draft)
    }
    
    private func createPromi() {
        let newPromi = PromiItem(
            title: title,
            dueDate: dueDate,
            importance: intensity > 70 ? .urgent : (intensity > 40 ? .normal : .low),
            assignee: assignee.isEmpty ? nil : assignee,
            intensity: intensity
        )
        
        promiStore.addPromi(newPromi)
        
        withAnimation(AnimationPreset.easeOut) {
            showValidationAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
}
