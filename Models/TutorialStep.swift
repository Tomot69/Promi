import Foundation

// MARK: - Tutorial positioning model

enum TutorialPosition {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    case bottomCenter
    case center
}

/// Which chrome icon the arrow should point at. Used to compute the
/// exact x-coordinate of the arrow tip so it lands on the icon center.
enum TutorialTarget {
    case addButton        // "+" top-right
    case nuéesButton      // hex grid top-right (left of +)
    case karmaButton      // eye in bottom dock, 2nd from left
    case promiListButton  // pinky promise in bottom dock, center
    case studioButton     // 2×2 grid in bottom dock, 4th from left
    case settingsButton   // "Promi" title top-left (opens Settings)
}

enum ArrowDirection {
    case up
    case down
    case left
    case right
    case none
}

struct TutorialStep: Identifiable {
    let id: Int
    let title: String
    let message: String
    let position: TutorialPosition
    let arrowDirection: ArrowDirection
    let target: TutorialTarget
}

// MARK: - Canonical tutorial content (5 steps)
//
// Aligned to the current home chrome layout:
//   Top-right cluster: [Nuées hex 46pt] [+ 46pt]
//   Bottom dock: [tri] [karma/eye] [pinky 54pt center] [studio 2×2] [share]

enum TutorialContent {
    static func getSteps(language: String) -> [TutorialStep] {
        let fr = !language.lowercased().starts(with: "en")

        return [
            TutorialStep(
                id: 0,
                title: fr ? "Créer un Promi" : "Create a Promi",
                message: fr
                    ? "Appuie sur + pour poser ta première promesse"
                    : "Tap + to make your first promise",
                position: .bottomCenter,
                arrowDirection: .down,
                target: .addButton
            ),
            TutorialStep(
                id: 1,
                title: fr ? "Regrouper une Nuée" : "Gather a Nuée",
                message: fr
                    ? "Crée un essaim de promesses partagées avec tes proches"
                    : "Create a swarm of shared promises with your people",
                position: .topTrailing,
                arrowDirection: .up,
                target: .nuéesButton
            ),
            TutorialStep(
                id: 2,
                title: fr ? "Ton Karma" : "Your Karma",
                message: fr
                    ? "Tiens tes Promis pour augmenter ton score"
                    : "Keep your Promis to raise your score",
                position: .bottomLeading,
                arrowDirection: .down,
                target: .karmaButton
            ),
            TutorialStep(
                id: 3,
                title: fr ? "Retrouver ses Promi" : "Find your Promis",
                message: fr
                    ? "Toutes tes promesses, d'un geste"
                    : "All your promises, one tap away",
                position: .topTrailing,
                arrowDirection: .up,
                target: .promiListButton
            ),
            TutorialStep(
                id: 4,
                title: fr ? "Rendez Promi à votre image" : "Make Promi yours",
                message: fr
                    ? "Explorez les packs et les couleurs dans le Studio"
                    : "Explore packs and colors in the Studio",
                position: .bottomTrailing,
                arrowDirection: .down,
                target: .studioButton
            ),
            TutorialStep(
                id: 5,
                title: fr ? "Réglages" : "Settings",
                message: fr
                    ? "Appuie sur Promi pour ton nom, ta langue, ton compte"
                    : "Tap Promi for your name, language, account",
                position: .topLeading,
                arrowDirection: .up,
                target: .settingsButton
            )
        ]
    }
}
