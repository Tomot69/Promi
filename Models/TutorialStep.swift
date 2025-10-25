//
//  TutorialStep.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Tutorial Step Model
struct TutorialStep: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let position: TutorialPosition
    let arrowDirection: ArrowDirection
}

enum TutorialPosition {
    case topLeading
    case topTrailing
    case bottomCenter
    case center
}

enum ArrowDirection {
    case up
    case down
    case left
    case right
    case none
}

// MARK: - Tutorial Content
struct TutorialContent {
    static func getSteps(language: String) -> [TutorialStep] {
        if language.starts(with: "fr") {
            return [
                TutorialStep(
                    title: "Créer un Promi",
                    message: "Tape sur + pour créer ta première promesse",
                    position: .topTrailing,
                    arrowDirection: .up
                ),
                TutorialStep(
                    title: "Ton Karma",
                    message: "Tiens tes Promis pour augmenter ton score",
                    position: .topLeading,
                    arrowDirection: .up
                ),
                TutorialStep(
                    title: "Change d'ambiance",
                    message: "Débloque des palettes en gagnant du Karma",
                    position: .bottomCenter,
                    arrowDirection: .down
                )
            ]
        } else {
            return [
                TutorialStep(
                    title: "Create a Promi",
                    message: "Tap + to create your first promise",
                    position: .topTrailing,
                    arrowDirection: .up
                ),
                TutorialStep(
                    title: "Your Karma",
                    message: "Keep your Promis to increase your score",
                    position: .topLeading,
                    arrowDirection: .up
                ),
                TutorialStep(
                    title: "Change the vibe",
                    message: "Unlock palettes by earning Karma",
                    position: .bottomCenter,
                    arrowDirection: .down
                )
            ]
        }
    }
}
