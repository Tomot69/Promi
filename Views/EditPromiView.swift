//
//  EditPromiView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct EditPromiView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promi: PromiItem
    
    @State private var title: String
    @State private var dueDate: Date
    @State private var assignee: String
    @State private var intensity: Int
    @State private var showValidationAnimation = false
    @State private var showDeleteConfirmation = false
    
    init(promi: PromiItem) {
        self.promi = promi
        _title = State(initialValue: promi.title)
        _dueDate = State(initialValue: promi.dueDate)
        _assignee = State(initialValue: promi.assignee ?? "")
        _intensity = State(initialValue: promi.intensity)
    }
    
    private var titleText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Edit your Promi" : "Modifie ton Promi"
    }
    
    private var buttonText: String {
        if promi.status == .open {
            return userStore.selectedLanguage.starts(with: "en") ? "Mark as done" : "Marquer terminé"
        } else {
            return userStore.selectedLanguage.starts(with: "en") ? "Reopen" : "Réouvrir"
        }
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(titleText.replacingOccurrences(of: "Promi", with: ""))
                            .font(Typography.callout)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                        
                        Text("Promi")
                            .font(Typography.callout)
                            .foregroundColor(Brand.orange)
                    }
                    
                    Spacer()
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.lg)
                
                // Content scrollable
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Title field
                        TextField("", text: $title)
                            .font(Typography.body)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .padding(.vertical, Spacing.md)
                            .overlay(
                                Rectangle()
                                    .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.1))
                                    .frame(height: 0.5),
                                alignment: .bottom
                            )
                        
                        // Date & Time
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "When" : "Quand")
                                .font(Typography.caption)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(Brand.orange)
                        }
                        
                        // Person
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "For whom" : "Pour qui")
                                .font(Typography.caption)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                            
                            TextField("", text: $assignee)
                                .font(Typography.body)
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                                .padding(.vertical, Spacing.md)
                                .overlay(
                                    Rectangle()
                                        .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.1))
                                        .frame(height: 0.5),
                                    alignment: .bottom
                                )
                        }
                        
                        // Intensity gauge
                        MinimalIntensityGaugeView(
                            intensity: $intensity,
                            question: intensityQuestion,
                            textColor: userStore.selectedPalette.textSecondaryColor
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                
                Spacer()
                
                // Bottom buttons
                VStack(spacing: Spacing.md) {
                    // Save changes
                    Button(action: saveChanges) {
                        Text(userStore.selectedLanguage.starts(with: "en") ? "Save changes" : "Enregistrer")
                            .font(Typography.bodyEmphasis)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.xs)
                                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    
                    // Mark as done / Reopen
                    Button(action: toggleStatus) {
                        Text(buttonText)
                            .font(Typography.callout)
                            .foregroundColor(Brand.orange.opacity(0.8))
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
            
            // Validation Animation
            if showValidationAnimation {
                PinkyPromiseSlightSlapView(isPresented: $showValidationAnimation)
                    .transition(.opacity)
            }
        }
        .confirmationDialog("Supprimer ce Promi ?", isPresented: $showDeleteConfirmation) {
            Button(userStore.selectedLanguage.starts(with: "en") ? "Delete" : "Supprimer", role: .destructive) {
                promiStore.deletePromi(promi)
                dismiss()
            }
            Button(userStore.selectedLanguage.starts(with: "en") ? "Cancel" : "Annuler", role: .cancel) {}
        }
    }
    
    private func saveChanges() {
        var updatedPromi = promi
        updatedPromi.title = title
        updatedPromi.dueDate = dueDate
        updatedPromi.assignee = assignee.isEmpty ? nil : assignee
        updatedPromi.intensity = intensity
        
        promiStore.updatePromi(updatedPromi)
        
        Haptics.shared.success()
        dismiss()
    }
    
    private func toggleStatus() {
        if promi.status == .open {
            promiStore.markAsDone(promi)
            
            withAnimation(AnimationPreset.easeOut) {
                showValidationAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            promiStore.markAsOpen(promi)
            dismiss()
        }
    }
}
