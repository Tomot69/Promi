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
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(titleText.replacingOccurrences(of: "Promi", with: ""))
                            .font(Typography.callout)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.6))
                        
                        Text("Promi")
                            .font(Typography.callout)
                            .foregroundColor(Brand.orange.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 16, height: 16)
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.top, Spacing.xxl)
                .padding(.bottom, Spacing.xl)
                
                // Content scrollable
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xxl) {
                        // Title field (ultra-minimal)
                        TextField(placeholderText, text: $title)
                            .font(Typography.body)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .padding(.vertical, Spacing.md)
                            .overlay(
                                Rectangle()
                                    .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.06))
                                    .frame(height: 0.2),
                                alignment: .bottom
                            )
                        
                        // Date & Time
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "When" : "Quand")
                                .font(Typography.caption)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(Brand.orange.opacity(0.8))
                        }
                        
                        // Person
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "For whom" : "Pour qui")
                                .font(Typography.caption)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                            
                            TextField(userStore.selectedLanguage.starts(with: "en") ? "Someone..." : "Quelqu'un...", text: $assignee)
                                .font(Typography.body)
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                                .padding(.vertical, Spacing.md)
                                .overlay(
                                    Rectangle()
                                        .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.06))
                                        .frame(height: 0.2),
                                    alignment: .bottom
                                )
                        }
                        
                        // Audio button (ultra-discret)
                        Button(action: {
                            Haptics.shared.tinyPop()
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "mic")
                                    .font(.system(size: 12))
                                Text(userStore.selectedLanguage.starts(with: "en") ? "Add audio" : "Ajouter audio")
                                    .font(Typography.caption2)
                            }
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                        }
                        
                        // Intensity gauge
                        MinimalIntensityGaugeView(
                            intensity: $intensity,
                            question: intensityQuestion,
                            textColor: userStore.selectedPalette.textSecondaryColor
                        )
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, Spacing.xxl)
                }
                
                Spacer()
                
                // Bottom button (ultra-minimal)
                Button(action: createPromi) {
                    Text(buttonText)
                        .font(Typography.bodyEmphasis)
                        .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(title.isEmpty ? 0.3 : 0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.1), lineWidth: 0.2)
                        )
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, Spacing.xxl)
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
