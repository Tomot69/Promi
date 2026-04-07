import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    
    @State private var showLanguagePicker = false
    @State private var showStudio = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.955, blue: 0.94)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("Réglages")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.black.opacity(0.86))
                            .padding(.top, 12)
                        
                        settingRow(title: "Langue", value: userStore.selectedLanguage.uppercased()) {
                            showLanguagePicker = true
                        }
                        
                        settingRow(title: "Le Studio", value: "Visuels") {
                            showStudio = true
                        }
                        
                        settingRow(title: "Palette", value: userStore.selectedPalette.rawValue) {
                            showStudio = true
                        }
                        
                        settingRow(title: "Notifications", value: "Bientôt") {
                        }
                        .opacity(0.50)
                        
                        settingRow(title: "Premium", value: "Bientôt") {
                        }
                        .opacity(0.50)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(Color.orange.opacity(0.92))
                }
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguageSelectionView()
        }
        .sheet(isPresented: $showStudio) {
            PaletteView()
        }
    }
    
    private func settingRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            Haptics.shared.lightTap()
            action()
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.84))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.black.opacity(0.52))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.44))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }
}
