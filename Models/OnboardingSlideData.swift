//
//  OnboardingSlideData.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation

// MARK: - Onboarding Slide Model
struct OnboardingSlideData: Identifiable {
    let id = UUID()
    let type: SlideType
    let title: String
    let body: String
    let examples: [String]?
    
    enum SlideType {
        case concept
        case karma
        case premium
        case account
    }
}

// MARK: - Onboarding Content (REFONTE COMPLÈTE)
struct OnboardingContent {
    static func getSlides(language: String) -> [OnboardingSlideData] {
        switch language {
        case "fr", "fr-savoy", "fr-corse", "fr-provence", "fr-breton", "fr-alsace", "fr-ch", "fr-be", "fr-qc":
            return [
                OnboardingSlideData(
                    type: .concept,
                    title: "Un Promi, c'est quoi ?",
                    body: "Une promesse claire. Une date fixée. Un engagement tenu.\nPas de blabla. Juste l'essentiel.",
                    examples: [
                        "« Appeler Maman dimanche 18h »",
                        "« Finir ce rapport vendredi 17h »",
                        "« Briefing client mardi 10h »"
                    ]
                ),
                OnboardingSlideData(
                    type: .karma,
                    title: "Ton Karma te juge",
                    body: "Chaque Promi tenu te rend meilleur.\nChaque Promi raté... bon, on ne va pas se mentir.",
                    examples: [
                        "90-100% : Tu es une légende",
                        "70-89% : Solide, régulier",
                        "50-69% : Ça va, ça vient",
                        "<50% : On en reparle ?"
                    ]
                ),
                OnboardingSlideData(
                    type: .premium,
                    title: "Promi Premium",
                    body: "Des Promis illimités. Des packs exclusifs. Zéro limite.\nSimple. Efficace. À toi de voir.",
                    examples: [
                        "🆓 Gratuit : 5 Promis / jour",
                        "✨ Premium : Illimité + packs exclusifs",
                        "💳 Dès 2,99€ / mois"
                    ]
                ),
                OnboardingSlideData(
                    type: .account,
                    title: "C'est parti",
                    body: "Crée ton compte. Tes Promis restent à toi.\nSimple, rapide, sécurisé.",
                    examples: nil
                )
            ]
            
        case "en", "en-GB", "en-US":
            return [
                OnboardingSlideData(
                    type: .concept,
                    title: "What's a Promi?",
                    body: "A clear promise. A set date. A kept word.\nNo fluff. Just what matters.",
                    examples: [
                        "'Call Mom Sunday 6pm'",
                        "'Finish report Friday 5pm'",
                        "'Client briefing Tuesday 10am'"
                    ]
                ),
                OnboardingSlideData(
                    type: .karma,
                    title: "Your Karma judges you",
                    body: "Every kept Promi makes you better.\nEvery missed one... well, let's not kid ourselves.",
                    examples: [
                        "90-100%: You're a legend",
                        "70-89%: Solid and steady",
                        "50-69%: It's complicated",
                        "<50%: Let's talk?"
                    ]
                ),
                OnboardingSlideData(
                    type: .premium,
                    title: "Promi Premium",
                    body: "Unlimited Promis. Exclusive packs. Zero limits.\nSimple. Effective. Your call.",
                    examples: [
                        "🆓 Free: 5 Promis / day",
                        "✨ Premium: Unlimited + exclusive packs",
                        "💳 From $2.99 / month"
                    ]
                ),
                OnboardingSlideData(
                    type: .account,
                    title: "Let's go",
                    body: "Create your account. Your Promis stay yours.\nSimple, fast, secure.",
                    examples: nil
                )
            ]
            
        default: // ES
            return [
                OnboardingSlideData(
                    type: .concept,
                    title: "¿Qué es un Promi?",
                    body: "Una promesa clara. Una fecha fijada. Un compromiso cumplido.\nSin rollos. Solo lo esencial.",
                    examples: [
                        "'Llamar a Mamá domingo 18h'",
                        "'Terminar informe viernes 17h'",
                        "'Briefing cliente martes 10h'"
                    ]
                ),
                OnboardingSlideData(
                    type: .karma,
                    title: "Tu Karma te juzga",
                    body: "Cada Promi cumplido te hace mejor.\nCada uno que fallas... bueno, no nos engañemos.",
                    examples: [
                        "90-100%: Eres una leyenda",
                        "70-89%: Sólido y constante",
                        "50-69%: Es complicado",
                        "<50%: ¿Hablamos?"
                    ]
                ),
                OnboardingSlideData(
                    type: .premium,
                    title: "Promi Premium",
                    body: "Promis ilimitados. Packs exclusivos. Sin límites.\nSimple. Efectivo. Tú decides.",
                    examples: [
                        "🆓 Gratis: 5 Promis / día",
                        "✨ Premium: Ilimitado + packs exclusivos",
                        "💳 Desde 2,99€ / mes"
                    ]
                ),
                OnboardingSlideData(
                    type: .account,
                    title: "Vamos",
                    body: "Crea tu cuenta. Tus Promis son tuyos.\nSimple, rápido, seguro.",
                    examples: nil
                )
            ]
        }
    }
}
