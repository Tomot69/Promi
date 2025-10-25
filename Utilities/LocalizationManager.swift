//
//  LocalizationManager.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation

// MARK: - Localization Manager
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    // Langues disponibles avec leurs codes et emojis
    let availableLanguages: [(code: String, name: String, emoji: String)] = [
        // Langues principales
        ("fr", "Français", "🇫🇷"),
        ("en", "English", "🇬🇧"),
        ("es", "Español", "🇪🇸"),
        ("de", "Deutsch", "🇩🇪"),
        ("de-AT", "Österreichisch", "🇦🇹"),
        ("it", "Italiano", "🇮🇹"),
        ("pt", "Português", "🇵🇹"),
        ("nl", "Nederlands", "🇳🇱"),
        
        // Dialectes français (easter eggs)
        ("fr-savoy", "Savoyard", "⛷️"),
        ("fr-corse", "Corsu", "🏝️"),
        ("fr-provence", "Provençal", "🌻"),
        ("fr-breton", "Brezhoneg", "🥨"),
        ("fr-alsace", "Elsässisch", "🍷"),
        ("fr-ch", "Suisse Romand", "🇨🇭"),
        ("fr-be", "Belge", "🇧🇪"),
        ("fr-qc", "Québécois", "🇨🇦")
    ]
    
    func getLocalizedString(_ key: String, language: String) -> String {
        // Mapping des phrases clés
        let translations: [String: [String: String]] = [
            // Splash Screen
            "splash.welcome": [
                "fr": "Bienvenue dans l'art des petites promesses",
                "en": "Welcome to the art of small promises",
                "es": "Bienvenido al arte de las pequeñas promesas",
                "de": "Willkommen in der Kunst kleiner Versprechen",
                "de-AT": "Grüß Gott bei der Kunst kleiner Versprechen",
                "it": "Benvenuto nell'arte delle piccole promesse",
                "pt": "Bem-vindo à arte das pequenas promessas",
                "nl": "Welkom bij de kunst van kleine beloftes",
                "fr-savoy": "Bienvenue dins l'art des p'tites promesses",
                "fr-corse": "Benvenuti in l'arte di e piccule prumesse",
                "fr-provence": "Benvengudo dins l'art dei petitos promessas",
                "fr-breton": "Degemer mat en arz ar promesaoù bihan",
                "fr-alsace": "Willkumme in d'r Konscht vu klaine Verspräche",
                "fr-ch": "Bienvenue dans l'art des p'tites promesses",
                "fr-be": "Bienvenue dans l'art des p'tites promesses, une fois",
                "fr-qc": "Bienvenue dans l'art des p'tites promesses, là"
            ],
            
            // Language Selection
            "language.title": [
                "fr": "Choisissez votre langue",
                "en": "Choose your language",
                "es": "Elige tu idioma",
                "de": "Wähle deine Sprache",
                "de-AT": "Wähl deine Sprache",
                "it": "Scegli la tua lingua",
                "pt": "Escolha seu idioma",
                "nl": "Kies je taal",
                "fr-savoy": "Choisis ta langue",
                "fr-corse": "Sceglie a to lingua",
                "fr-provence": "Chausis ta lengo",
                "fr-breton": "Dibab da yezh",
                "fr-alsace": "Wähl dyy Sproch",
                "fr-ch": "Choisis ta langue",
                "fr-be": "Choisis ta langue",
                "fr-qc": "Choisis ta langue"
            ],
            
            "language.subtitle": [
                "fr": "Cela affectera toute l'expérience",
                "en": "This will affect the entire experience",
                "es": "Esto afectará toda la experiencia",
                "de": "Dies wird das gesamte Erlebnis beeinflussen",
                "de-AT": "Des wird des ganze Erlebnis beeinflussen",
                "it": "Questo influenzerà l'intera esperienza",
                "pt": "Isso afetará toda a experiência",
                "nl": "Dit zal de hele ervaring beïnvloeden",
                "fr-savoy": "Ça changera toute l'expérience",
                "fr-corse": "Questu cambiarà tutta l'esperienza",
                "fr-provence": "Aquò cambiara tota l'experiéncia",
                "fr-breton": "Se cheñcho pep tra",
                "fr-alsace": "Des ändert alles",
                "fr-ch": "Ça changera toute l'expérience",
                "fr-be": "Ça changera toute l'expérience",
                "fr-qc": "Ça va changer toute l'expérience"
            ]
        ]
        
        return translations[key]?[language] ?? translations[key]?["en"] ?? key
    }
}
