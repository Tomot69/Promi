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
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(titleText.replacingOccurrences(of: "Promi", with: ""))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.5))
                        
                        Text("Promi")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Brand.orange.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        TextField("", text: $title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .padding(.vertical, 16)
                            .overlay(
                                Rectangle()
                                    .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.06))
                                    .frame(height: 0.15),
                                alignment: .bottom
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "When" : "Quand")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(Brand.orange.opacity(0.85))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "For whom" : "Pour qui")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                            
                            TextField("", text: $assignee)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                                .padding(.vertical, 16)
                                .overlay(
                                    Rectangle()
                                        .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.05))
                                        .frame(height: 0.15),
                                    alignment: .bottom
                                )
                        }
                        
                        MinimalIntensityGaugeView(
                            intensity: $intensity,
                            question: intensityQuestion,
                            textColor: userStore.selectedPalette.textSecondaryColor
                        )
                        
                        Spacer(minLength: 140)
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: saveChanges) {
                        Text(userStore.selectedLanguage.starts(with: "en") ? "Save changes" : "Enregistrer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Brand.orange.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Brand.orange.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                    
                    Button(action: toggleStatus) {
                        Text(buttonText)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Brand.orange.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            
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
            
            withAnimation(Animation.easeOut(duration: 0.3)) {
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
