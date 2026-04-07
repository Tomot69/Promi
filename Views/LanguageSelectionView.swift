import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var userStore: UserStore
    
    @State private var selectedLanguage = "fr"
    
    private let languages = [
        ("fr", "Français"),
        ("en", "English"),
        ("es", "Español")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.963, blue: 0.947)
                .ignoresSafeArea()
            
            PromiEntryBackground(progress: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 42)
                
                VStack(spacing: 18) {
                    Text("Promi")
                        .font(.system(size: 34, weight: .light))
                        .foregroundColor(.black.opacity(0.88))
                        .tracking(0.8)
                    
                    Text("Choisis la langue d’entrée.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.black.opacity(0.54))
                }
                
                Spacer(minLength: 44)
                
                languageField
                
                Spacer()
                
                Button(action: continueFlow) {
                    Text("Continuer")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.82))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.42))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 42)
            }
        }
    }
    
    private var languageField: some View {
        VStack(spacing: 0) {
            ForEach(Array(languages.enumerated()), id: \.element.0) { index, item in
                let isSelected = selectedLanguage == item.0
                
                Button {
                    selectedLanguage = item.0
                    Haptics.shared.lightTap()
                } label: {
                    HStack {
                        Text(item.1)
                            .font(.system(size: 18, weight: isSelected ? .medium : .regular))
                            .foregroundColor(.black.opacity(isSelected ? 0.88 : 0.62))
                        
                        Spacer()
                        
                        if isSelected {
                            Circle()
                                .fill(Color.black.opacity(0.84))
                                .frame(width: 10, height: 10)
                        } else {
                            Circle()
                                .stroke(Color.black.opacity(0.14), lineWidth: 1)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 22)
                    .contentShape(Rectangle())
                    .background(
                        isSelected
                        ? Color.white.opacity(0.32)
                        : Color.clear
                    )
                }
                .buttonStyle(.plain)
                
                if index < languages.count - 1 {
                    Rectangle()
                        .fill(Color.black.opacity(0.07))
                        .frame(height: 1)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    
    private func continueFlow() {
        Haptics.shared.success()
        userStore.chooseLanguage(selectedLanguage)
    }
}
