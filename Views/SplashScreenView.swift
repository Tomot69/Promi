import SwiftUI

// MARK: - SplashScreenView
//
// Premier écran vu au lancement de l'app. Design chrome cohérent avec
// l'identité Promi : PromiChromePageBackground (mood-aware, même recette
// que les autres pages) + card chrome contenant le logo + « Promi » en
// orange en-dessous. Pour un nouvel utilisateur, le mood par défaut est
// terrePromi (chaudes tonalités orange/terre) via les @AppStorage. Pour
// un utilisateur récurrent, il voit IMMÉDIATEMENT son identité visuelle
// personnalisée depuis le splash — continuité parfaite avec son univers.
//
// Note: la struct `PromiEntryBackground` qui existait dans ce fichier a
// été supprimée. Elle fournissait un fond de formes abstraites beiges
// destiné à l'ancienne identité pré-Voronoï. Le chrome mood-aware la
// remplace entièrement avec plus de cohérence (même backdrop que le
// home courant + dropdown menus).

struct SplashScreenView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var phase: CGFloat = 0.82
    @State private var titleOpacity: Double = 0.0


    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    // MARK: Body

    var body: some View {
        ZStack {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 28) {
                logoCard
                    .scaleEffect(phase)
                    .opacity(Double(phase))

                titleBlock
                    .opacity(titleOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.82, dampingFraction: 0.82)) {
                phase = 1.0
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.22)) {
                titleOpacity = 1.0
            }
        }
    }

    // MARK: Logo card (chrome)

    private var logoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(width: 132, height: 168)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 0.6)
                .frame(width: 132, height: 168)

            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 110)
        }
    }

    // MARK: Title block (Promi in orange + tagline)

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text("Promi")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(Brand.orange)
                .tracking(0.8)

            Text(isEnglish
                 ? "your word, made visible."
                 : "votre parole, rendue visible.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.56))
                .tracking(0.2)
        }
    }
}
