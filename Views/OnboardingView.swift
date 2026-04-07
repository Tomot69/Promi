import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userStore: UserStore
    
    @State private var currentPage = 0
    
    private var slides: [OnboardingSlideData] {
        OnboardingContent.getSlides(language: userStore.selectedLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.963, blue: 0.947)
                .ignoresSafeArea()
            
            PromiEntryBackground(progress: CGFloat(currentPage + 1) / CGFloat(max(slides.count, 1)))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        PromiOnboardingSlideView(slide: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                indicators
                
                Button(action: handleNext) {
                    Text(buttonText)
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
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Text("Promi")
                .font(.system(size: 22, weight: .light))
                .foregroundColor(.black.opacity(0.82))
            
            Spacer()
            
            Button(action: skipToLast) {
                Text(skipText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.black.opacity(0.46))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 8)
    }
    
    private var indicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.black.opacity(0.82) : Color.black.opacity(0.12))
                    .frame(width: index == currentPage ? 26 : 8, height: 8)
            }
        }
        .padding(.top, 8)
    }
    
    private var skipText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Skip" : "Passer"
    }
    
    private var buttonText: String {
        if currentPage < slides.count - 1 {
            return userStore.selectedLanguage.starts(with: "en") ? "Next" : "Suivant"
        } else {
            return userStore.selectedLanguage.starts(with: "en") ? "Enter Promi" : "Entrer dans Promi"
        }
    }
    
    private func skipToLast() {
        Haptics.shared.lightTap()
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            currentPage = max(slides.count - 1, 0)
        }
    }
    
    private func handleNext() {
        Haptics.shared.lightTap()
        
        if currentPage < slides.count - 1 {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                currentPage += 1
            }
        } else {
            Haptics.shared.success()
            userStore.completeOnboarding()
        }
    }
}

struct PromiOnboardingSlideView: View {
    let slide: OnboardingSlideData
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)
            
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color.white.opacity(0.28))
                    .frame(width: 220, height: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                
                onboardingShape(for: slide.type)
            }
            
            VStack(spacing: 14) {
                Text(slide.title)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.black.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                
                Text(slide.body)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.58))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
            
            if let examples = slide.examples, !examples.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(examples, id: \.self) { example in
                        Text(example)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.black.opacity(0.52))
                    }
                }
                .padding(.horizontal, 34)
                .padding(.top, 6)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func onboardingShape(for type: OnboardingSlideData.SlideType) -> some View {
        switch type {
        case .concept:
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.40, blue: 0.06).opacity(0.92))
                    .frame(width: 108, height: 92)
                    .offset(x: -30, y: -34)
                
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.44, blue: 0.95).opacity(0.90))
                    .frame(width: 102, height: 104)
                    .offset(x: 34, y: 16)
                
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 74, height: 74)
            }
            
        case .karma:
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.84, blue: 0.08).opacity(0.95))
                    .frame(width: 132, height: 92)
                    .offset(x: 12, y: -26)
                
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 80, height: 80)
                
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.75, blue: 0.48).opacity(0.92))
                    .frame(width: 118, height: 82)
                    .offset(x: -18, y: 48)
            }
            
        case .premium:
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.78, blue: 0.84).opacity(0.82))
                    .frame(width: 112, height: 136)
                    .offset(x: -20, y: -10)
                
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.40, blue: 0.06).opacity(0.92))
                    .frame(width: 100, height: 92)
                    .offset(x: 34, y: 40)
                
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 72, height: 72)
            }
            
        case .account:
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.75, blue: 0.48).opacity(0.92))
                    .frame(width: 120, height: 92)
                    .offset(x: -26, y: 38)
                
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.44, blue: 0.95).opacity(0.92))
                    .frame(width: 106, height: 126)
                    .offset(x: 28, y: -12)
                
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 76, height: 76)
            }
        }
    }
}
