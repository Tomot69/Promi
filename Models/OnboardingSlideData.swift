//
//  OnboardingSlideData.swift
//  Promi
//
//  Created on 24/10/2025.
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

// MARK: - Onboarding Content
struct OnboardingContent {
    static func getSlides(language: String) -> [OnboardingSlideData] {
        switch language {
        case "fr", "fr-savoy", "fr-corse", "fr-provence", "fr-breton", "fr-alsace", "fr-ch", "fr-be", "fr-qc":
            return [
                OnboardingSlideData(
                    type: .concept,
                    title: "Qu'est-ce qu'un Promi ?",
                    body: "Une promesse simple, datée, tenue.\nPas de bruit. Juste l'essentiel.",
                    examples: [
                        "📱 Perso : « Appeler Maman dimanche 18h »",
                        "💼 Pro : « Envoyer rapport vendredi 17h »",
                        "🤝 Équipe : « Briefing client mardi 10h »"
                    ]
                ),
                OnboardingSlideData(
                    type: .karma,
                    title: "Ton Karma grandit",
                    body: "Chaque Promi tenu augmente ton score.\nDébloque des palettes, des badges, des récompenses.",
                    examples: [
                        "🟢 90-100% : Expert de la constance",
                        "🟡 70-89% : Fiable et régulier",
                        "🟠 50-69% : En progression",
                        "🔴 <50% : Fresh start possible"
                    ]
                ),
                OnboardingSlideData(
                    type: .premium,
                    title: "Promi Premium",
                    body: "Des Promis illimités, des packs exclusifs, zéro limite.\nSimple. Addictif. À toi de choisir.",
                    examples: [
                        "🆓 Gratuit : 5 Promis par jour",
                        "🎨 Premium : Promis illimités + packs exclusifs",
                        "💳 À partir de 2,99€/mois"
                    ]
                ),
                OnboardingSlideData(
                    type: .account,
                    title: "Crée ton compte",
                    body: "Sécurisé, rapide, fiable.\nTes Promis restent à toi.",
                    examples: nil
                )
            ]
            
        case "en", "en-GB", "en-US":
            return [
                OnboardingSlideData(
                    type: .concept,
                    title: "What's a Promi?",
                    body: "A simple promise, dated, kept.\nNo noise. Just the essentials.",
                    examples: [
                        "📱 Personal: 'Call Mom Sunday 6pm'",
                        "💼 Work: 'Send report Friday 5pm'",
                        "🤝 Team: 'Client briefing Tuesday 10am'"
                    ]
                ),
                OnboardingSlideData(
                    type: .karma,
                    title: "Your Karma grows",
                    body: "Every kept Promi increases your score.\nUnlock palettes, badges, rewards.",
                    examples: [
                        "🟢 90-100%: Master of consistency",
                        "🟡 70-89%: Reliable & steady",
                        "🟠 50-69%: Making progress",
                        "🔴 <50%: Fresh start available"
                    ]
                ),
                OnboardingSlideData(
                    type: .premium,
                    title: "Promi Premium",
                    body: "Unlimited Promis, exclusive packs, zero limits.\nSimple. Addictive. Your choice.",
                    examples: [
                        "🆓 Free: 5 Promis per day",
                        "🎨 Premium: Unlimited Promis + exclusive packs",
                        "💳 From $2.99/month"
                    ]
                ),
                OnboardingSlideData(
                    type: .account,
                    title: "Create your account",
                    body: "Secure, fast, reliable.\nYour Promis stay yours.",
                    examples: nil
                )
            ]
            
        default:
            return [
                OnboardingSlideData(
                    type: .concept,
                    title: "¿Qué es un Promi?",
                    body: "Una promesa simple, fechada, cumplida.\nSin ruido. Solo lo esencial.",
                    examples: [
                        "📱 Personal: 'Llamar a Mamá domingo 18h'",
                        "💼 Trabajo: 'Enviar informe viernes 17h'",
                        "🤝 Equipo: 'Briefing cliente martes 10h'"
                    ]
                ),
                OnboardingSlideData(
                    type: .karma,
                    title: "Tu Karma crece",
                    body: "Cada Promi cumplido aumenta tu puntuación.\nDesbloquea paletas, insignias, recompensas.",
                    examples: [
                        "🟢 90-100%: Maestro de la constancia",
                        "🟡 70-89%: Confiable y constante",
                        "🟠 50-69%: En progreso",
                        "🔴 <50%: Nuevo comienzo disponible"
                    ]
                ),
                OnboardingSlideData(
                    type: .premium,
                    title: "Promi Premium",
                    body: "Promis ilimitados, packs exclusivos, sin límites.\nSimple. Adictivo. Tú eliges.",
                    examples: [
                        "🆓 Gratis: 5 Promis por día",
                        "🎨 Premium: Promis ilimitados + packs exclusivos",
                        "💳 Desde 2,99€/mes"
                    ]
                ),
                OnboardingSlideData(
                    type: .account,
                    title: "Crea tu cuenta",
                    body: "Segura, rápida, confiable.\nTus Promis son tuyos.",
                    examples: nil
                )
            ]
        }
    }
}
