//
//  Loc.swift
//  Promi
//
//  Localisation centralisée — 14 langues européennes.
//  FR, EN, ES, DE, AT (→DE), IT, PT, SV, NB, DA, PL, HU, HR, SR
//
//  Usage :  Text(Loc.close)
//           Text(Loc.kept(12))
//

import Foundation

enum Loc {

    // MARK: - Engine

    private static var code: String {
        let raw = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "fr"
        let c = String(raw.prefix(2)).lowercased()
        // Autrichien → mêmes traductions que l'allemand
        return c == "at" ? "de" : c
    }

    private static func t(_ d: [String: String]) -> String {
        d[code] ?? d["en"] ?? d["fr"] ?? ""
    }

    // MARK: - Common

    static var close: String { t(["fr":"Fermer","en":"Close","es":"Cerrar","de":"Schließen","it":"Chiudi","pt":"Fechar","sv":"Stäng","nb":"Lukk","da":"Luk","pl":"Zamknij","hu":"Bezárás","hr":"Zatvori","sr":"Zatvori"]) }
    static var cancel: String { t(["fr":"Annuler","en":"Cancel","es":"Cancelar","de":"Abbrechen","it":"Annulla","pt":"Cancelar","sv":"Avbryt","nb":"Avbryt","da":"Annuller","pl":"Anuluj","hu":"Mégse","hr":"Odustani","sr":"Otkaži"]) }
    static var save: String { t(["fr":"Enregistrer","en":"Save","es":"Guardar","de":"Speichern","it":"Salva","pt":"Salvar","sv":"Spara","nb":"Lagre","da":"Gem","pl":"Zapisz","hu":"Mentés","hr":"Spremi","sr":"Sačuvaj"]) }
    static var delete: String { t(["fr":"Supprimer","en":"Delete","es":"Eliminar","de":"Löschen","it":"Elimina","pt":"Excluir","sv":"Radera","nb":"Slett","da":"Slet","pl":"Usuń","hu":"Törlés","hr":"Obriši","sr":"Obriši"]) }
    static var next: String { t(["fr":"Suivant","en":"Next","es":"Siguiente","de":"Weiter","it":"Avanti","pt":"Seguinte","sv":"Nästa","nb":"Neste","da":"Næste","pl":"Dalej","hu":"Tovább","hr":"Dalje","sr":"Dalje"]) }
    static var done: String { t(["fr":"OK","en":"Done","es":"Listo","de":"Fertig","it":"Fatto","pt":"Pronto","sv":"Klar","nb":"Ferdig","da":"Færdig","pl":"Gotowe","hu":"Kész","hr":"Gotovo","sr":"Gotovo"]) }
    static var share: String { t(["fr":"Partager","en":"Share","es":"Compartir","de":"Teilen","it":"Condividi","pt":"Partilhar","sv":"Dela","nb":"Del","da":"Del","pl":"Udostępnij","hu":"Megosztás","hr":"Podijeli","sr":"Podeli"]) }
    static var continueBtn: String { t(["fr":"Continuer","en":"Continue","es":"Continuar","de":"Weiter","it":"Continua","pt":"Continuar","sv":"Fortsätt","nb":"Fortsett","da":"Fortsæt","pl":"Kontynuuj","hu":"Folytatás","hr":"Nastavi","sr":"Nastavi"]) }
    static var skip: String { t(["fr":"Passer","en":"Skip","es":"Saltar","de":"Überspringen","it":"Salta","pt":"Saltar","sv":"Hoppa över","nb":"Hopp over","da":"Spring over","pl":"Pomiń","hu":"Kihagyás","hr":"Preskoči","sr":"Preskoči"]) }
    static var gotIt: String { t(["fr":"Terminé","en":"Got it","es":"Entendido","de":"Verstanden","it":"Capito","pt":"Entendi","sv":"Fattat","nb":"Forstått","da":"Forstået","pl":"Rozumiem","hu":"Értem","hr":"Razumijem","sr":"Razumem"]) }
    static var bravo: String { "Bravo" }

    // MARK: - Home / Murmur

    static var canvasWaiting: String { t(["fr":"la toile attend","en":"the canvas is waiting","es":"el lienzo espera","de":"die Leinwand wartet","it":"la tela attende","pt":"a tela espera","sv":"duken väntar","nb":"lerretet venter","da":"lærredet venter","pl":"płótno czeka","hu":"a vászon vár","hr":"platno čeka","sr":"platno čeka"]) }
    static var canvasQuiet: String { t(["fr":"la toile est calme","en":"the canvas is quiet","es":"el lienzo está en calma","de":"die Leinwand ruht","it":"la tela è calma","pt":"a tela está calma","sv":"duken vilar","nb":"lerretet er stille","da":"lærredet er stille","pl":"płótno w spokoju","hu":"a vászon csendes","hr":"platno miruje","sr":"platno miruje"]) }
    static var legendary: String { t(["fr":"légendaire","en":"legendary","es":"legendario","de":"legendär","it":"leggendario","pt":"lendário","sv":"legendarisk","nb":"legendarisk","da":"legendarisk","pl":"legendarny","hu":"legendás","hr":"legendarno","sr":"legendarno"]) }
    static var solid: String { t(["fr":"solide","en":"solid","es":"sólido","de":"solide","it":"solido","pt":"sólido","sv":"solid","nb":"solid","da":"solid","pl":"solidnie","hu":"stabil","hr":"čvrsto","sr":"čvrsto"]) }
    static var stillUp: String { t(["fr":"encore debout ?","en":"still up?","es":"¿aún despierto?","de":"noch wach?","it":"ancora sveglio?","pt":"ainda acordado?","sv":"fortfarande vaken?","nb":"fortsatt våken?","da":"stadig vågen?","pl":"jeszcze nie śpisz?","hu":"még ébren?","hr":"još budan?","sr":"još budan?"]) }
    static var goodMorning: String { t(["fr":"bon matin","en":"good morning","es":"buenos días","de":"guten Morgen","it":"buongiorno","pt":"bom dia","sv":"god morgon","nb":"god morgen","da":"godmorgen","pl":"dzień dobry","hu":"jó reggelt","hr":"dobro jutro","sr":"dobro jutro"]) }
    static var yourWordYourCanvas: String { t(["fr":"ta parole, ta toile","en":"your word, your canvas","es":"tu palabra, tu lienzo","de":"dein Wort, deine Leinwand","it":"la tua parola, la tua tela","pt":"a tua palavra, a tua tela","sv":"ditt ord, din duk","nb":"ditt ord, ditt lerret","da":"dit ord, dit lærred","pl":"twoje słowo, twoje płótno","hu":"a szavad, a vásznod","hr":"tvoja riječ, tvoje platno","sr":"tvoja reč, tvoje platno"]) }

    static func promisesToday(_ n: Int) -> String {
        let c = code
        let word: String = {
            switch c {
            case "en": return n == 1 ? "promise" : "promises"
            case "es": return n == 1 ? "promesa" : "promesas"
            case "de": return n == 1 ? "Versprechen" : "Versprechen"
            case "it": return n == 1 ? "promessa" : "promesse"
            case "pt": return n == 1 ? "promessa" : "promessas"
            case "sv": return n == 1 ? "löfte" : "löften"
            case "nb": return n == 1 ? "løfte" : "løfter"
            case "da": return n == 1 ? "løfte" : "løfter"
            case "pl": return n == 1 ? "obietnica" : (n < 5 ? "obietnice" : "obietnic")
            case "hu": return "ígéret"
            case "hr": return n == 1 ? "obećanje" : "obećanja"
            case "sr": return n == 1 ? "obećanje" : "obećanja"
            default:   return n == 1 ? "promesse" : "promesses"
            }
        }()
        let today: String = {
            switch c {
            case "en": return "today"
            case "es": return "hoy"
            case "de": return "heute"
            case "it": return "oggi"
            case "pt": return "hoje"
            case "sv": return "idag"
            case "nb": return "i dag"
            case "da": return "i dag"
            case "pl": return "dzisiaj"
            case "hu": return "ma"
            case "hr": return "danas"
            case "sr": return "danas"
            default:   return "aujourd'hui"
            }
        }()
        return "\(n) \(word) \(today)"
    }

    // MARK: - Empreinte

    static func kept(_ n: Int) -> String {
        switch code {
        case "en": return "\(n) kept"
        case "es": return "\(n) \(n == 1 ? "cumplida" : "cumplidas")"
        case "de": return "\(n) gehalten"
        case "it": return "\(n) \(n == 1 ? "mantenuta" : "mantenute")"
        case "pt": return "\(n) \(n == 1 ? "cumprida" : "cumpridas")"
        case "sv": return "\(n) \(n == 1 ? "hållet" : "hållna")"
        case "nb": return "\(n) holdt"
        case "da": return "\(n) holdt"
        case "pl": return "\(n) \(n == 1 ? "dotrzymana" : "dotrzymanych")"
        case "hu": return "\(n) betartva"
        case "hr": return "\(n) \(n == 1 ? "ispunjeno" : "ispunjenih")"
        case "sr": return "\(n) \(n == 1 ? "ispunjeno" : "ispunjenih")"
        default:   return "\(n) \(n == 1 ? "tenue" : "tenues")"
        }
    }

    // MARK: - Sort menu

    static var sortDate: String { "Date" }
    static var sortUrgency: String { t(["fr":"Urgence","en":"Urgency","es":"Urgencia","de":"Dringlichkeit","it":"Urgenza","pt":"Urgência","sv":"Brådska","nb":"Hast","da":"Hast","pl":"Pilność","hu":"Sürgősség","hr":"Hitnost","sr":"Hitnost"]) }
    static var sortPerson: String { t(["fr":"Personne","en":"Person","es":"Persona","de":"Person","it":"Persona","pt":"Pessoa","sv":"Person","nb":"Person","da":"Person","pl":"Osoba","hu":"Személy","hr":"Osoba","sr":"Osoba"]) }
    static var sortIntensity: String { t(["fr":"Intensité","en":"Intensity","es":"Intensidad","de":"Intensität","it":"Intensità","pt":"Intensidade","sv":"Intensitet","nb":"Intensitet","da":"Intensitet","pl":"Intensywność","hu":"Intenzitás","hr":"Intenzitet","sr":"Intenzitet"]) }
    static var sortInspi: String { "Inspi" }
    static var sortNuee: String { "Nuée" }

    static var sortByDate: String { t(["fr":"Tri date","en":"Sort by date","es":"Ordenar por fecha","de":"Nach Datum","it":"Ordina per data","pt":"Ordenar por data","sv":"Sortera efter datum","nb":"Sorter etter dato","da":"Sortér efter dato","pl":"Wg daty","hu":"Dátum szerint","hr":"Po datumu","sr":"Po datumu"]) }
    static var sortByUrgency: String { t(["fr":"Tri urgence","en":"Sort by urgency","es":"Ordenar por urgencia","de":"Nach Dringlichkeit","it":"Ordina per urgenza","pt":"Ordenar por urgência","sv":"Sortera efter brådska","nb":"Sorter etter hast","da":"Sortér efter hast","pl":"Wg pilności","hu":"Sürgősség szerint","hr":"Po hitnosti","sr":"Po hitnosti"]) }
    static var sortByPerson: String { t(["fr":"Tri personne","en":"Sort by person","es":"Ordenar por persona","de":"Nach Person","it":"Ordina per persona","pt":"Ordenar por pessoa","sv":"Sortera efter person","nb":"Sorter etter person","da":"Sortér efter person","pl":"Wg osoby","hu":"Személy szerint","hr":"Po osobi","sr":"Po osobi"]) }
    static var sortByIntensity: String { t(["fr":"Tri intensité","en":"Sort by intensity","es":"Ordenar por intensidad","de":"Nach Intensität","it":"Ordina per intensità","pt":"Ordenar por intensidade","sv":"Sortera efter intensitet","nb":"Sorter etter intensitet","da":"Sortér efter intensitet","pl":"Wg intensywności","hu":"Intenzitás szerint","hr":"Po intenzitetu","sr":"Po intenzitetu"]) }
    static var sortFree: String { t(["fr":"Tri libre","en":"Free sort","es":"Orden libre","de":"Freie Sortierung","it":"Ordine libero","pt":"Ordem livre","sv":"Fri sortering","nb":"Fri sortering","da":"Fri sortering","pl":"Dowolna kolejność","hu":"Szabad rendezés","hr":"Slobodan raspored","sr":"Slobodan raspored"]) }
    static var sortByNuee: String { t(["fr":"Tri nuée","en":"Sort by Nuée","es":"Ordenar por Nuée","de":"Nach Nuée","it":"Ordina per Nuée","pt":"Ordenar por Nuée","sv":"Sortera efter Nuée","nb":"Sorter etter Nuée","da":"Sortér efter Nuée","pl":"Wg Nuée","hu":"Nuée szerint","hr":"Po Nuée","sr":"Po Nuée"]) }

    static var sortHintDate: String { t(["fr":"les plus proches dans le temps montent","en":"closest in time rise to the top","es":"los más próximos en el tiempo suben","de":"die zeitlich nächsten steigen auf","it":"i più vicini nel tempo salgono","pt":"os mais próximos no tempo sobem","sv":"de närmaste i tid stiger upp","nb":"de nærmeste i tid stiger opp","da":"de nærmeste i tid stiger op","pl":"najbliższe w czasie idą na górę","hu":"a legközelebbiek kerülnek felülre","hr":"najbliži po vremenu idu gore","sr":"najbliži po vremenu idu gore"]) }
    static var sortHintUrgency: String { t(["fr":"les plus urgents se densifient devant","en":"most urgent ones densify in front","es":"los más urgentes se agrupan delante","de":"die dringendsten verdichten sich vorne","it":"i più urgenti si addensano davanti","pt":"os mais urgentes adensam-se à frente","sv":"de mest brådskande tätnar framtill","nb":"de mest presserende fortettes foran","da":"de mest presserende fortættes foran","pl":"najpilniejsze zagęszczają się z przodu","hu":"a legsürgősebbek sűrűsödnek elöl","hr":"najhitniji se zgušnjavaju sprijeda","sr":"najhitniji se zgušnjavaju spreda"]) }
    static var sortHintPerson: String { t(["fr":"les groupes se lisent latéralement","en":"groups read laterally","es":"los grupos se leen lateralmente","de":"Gruppen lesen sich seitlich","it":"i gruppi si leggono lateralmente","pt":"os grupos leem-se lateralmente","sv":"grupperna läses i sidled","nb":"gruppene leses sideveis","da":"grupperne læses sideværts","pl":"grupy czyta się na boki","hu":"a csoportok oldalra rendeződnek","hr":"grupe se čitaju bočno","sr":"grupe se čitaju bočno"]) }
    static var sortHintIntensity: String { t(["fr":"les plus forts prennent le centre","en":"strongest ones take the center","es":"los más fuertes toman el centro","de":"die stärksten nehmen die Mitte ein","it":"i più forti prendono il centro","pt":"os mais fortes ocupam o centro","sv":"de starkaste tar mitten","nb":"de sterkeste tar midten","da":"de stærkeste tager midten","pl":"najsilniejsze zajmują środek","hu":"a legerősebbek középre kerülnek","hr":"najjači zauzimaju sredinu","sr":"najjači zauzimaju sredinu"]) }
    static var sortHintInspi: String { t(["fr":"répartition libre et organique","en":"free and organic layout","es":"distribución libre y orgánica","de":"freie und organische Verteilung","it":"disposizione libera e organica","pt":"distribuição livre e orgânica","sv":"fri och organisk fördelning","nb":"fri og organisk fordeling","da":"fri og organisk fordeling","pl":"swobodny, organiczny układ","hu":"szabad, organikus elrendezés","hr":"slobodan i organski raspored","sr":"slobodan i organski raspored"]) }
    static var sortHintNuee: String { t(["fr":"les Promi se regroupent par essaim","en":"Promis group by swarm","es":"los Promi se agrupan por enjambre","de":"Promis gruppieren sich nach Schwarm","it":"i Promi si raggruppano per sciame","pt":"os Promi agrupam-se por enxame","sv":"Promis grupperas i svärmar","nb":"Promier grupperes i sverm","da":"Promier grupperes i sværm","pl":"Promi grupują się w roje","hu":"a Promik rajokba csoportosulnak","hr":"Promi se grupiraju po roju","sr":"Promi se grupišu po roju"]) }

    // MARK: - Add / Create

    static var createPromi: String { t(["fr":"Créer ce Promi","en":"Create Promi","es":"Crear Promi","de":"Promi erstellen","it":"Crea Promi","pt":"Criar Promi","sv":"Skapa Promi","nb":"Opprett Promi","da":"Opret Promi","pl":"Utwórz Promi","hu":"Promi létrehozása","hr":"Stvori Promi","sr":"Napravi Promi"]) }
    static var createNuee: String { t(["fr":"Créer la Nuée","en":"Create the Nuée","es":"Crear la Nuée","de":"Nuée erstellen","it":"Crea la Nuée","pt":"Criar a Nuée","sv":"Skapa Nuée","nb":"Opprett Nuée","da":"Opret Nuée","pl":"Utwórz Nuée","hu":"Nuée létrehozása","hr":"Stvori Nuée","sr":"Napravi Nuée"]) }
    static var newPromi: String { t(["fr":"Nouveau Promi","en":"New Promi","es":"Nuevo Promi","de":"Neuer Promi","it":"Nuovo Promi","pt":"Novo Promi","sv":"Nytt Promi","nb":"Nytt Promi","da":"Nyt Promi","pl":"Nowy Promi","hu":"Új Promi","hr":"Novi Promi","sr":"Novi Promi"]) }
    static var newNuee: String { t(["fr":"Nouvelle Nuée","en":"New Nuée","es":"Nueva Nuée","de":"Neue Nuée","it":"Nuova Nuée","pt":"Nova Nuée","sv":"Ny Nuée","nb":"Ny Nuée","da":"Ny Nuée","pl":"Nowa Nuée","hu":"Új Nuée","hr":"Nova Nuée","sr":"Nova Nuée"]) }
    static var createPromiseNow: String { t(["fr":"Créer une promesse maintenant","en":"Create a promise now","es":"Crear una promesa ahora","de":"Jetzt ein Versprechen erstellen","it":"Crea una promessa ora","pt":"Criar uma promessa agora","sv":"Skapa ett löfte nu","nb":"Lag et løfte nå","da":"Opret et løfte nu","pl":"Utwórz obietnicę teraz","hu":"Hozz létre egy ígéretet most","hr":"Stvori obećanje sad","sr":"Napravi obećanje sad"]) }
    static var createSharedGroup: String { t(["fr":"Créer un essaim partagé","en":"Create a shared group","es":"Crear un grupo compartido","de":"Gemeinsame Gruppe erstellen","it":"Crea un gruppo condiviso","pt":"Criar um grupo partilhado","sv":"Skapa en delad grupp","nb":"Lag en delt gruppe","da":"Opret en delt gruppe","pl":"Utwórz wspólną grupę","hu":"Közös csoport létrehozása","hr":"Stvori zajedničku grupu","sr":"Napravi zajedničku grupu"]) }
    static var modifyPromi: String { t(["fr":"Modifier un Promi","en":"Modify a Promi","es":"Modificar un Promi","de":"Promi bearbeiten","it":"Modifica un Promi","pt":"Modificar um Promi","sv":"Ändra Promi","nb":"Endre Promi","da":"Ændre Promi","pl":"Edytuj Promi","hu":"Promi szerkesztése","hr":"Uredi Promi","sr":"Izmeni Promi"]) }
    static var saveChanges: String { t(["fr":"Enregistrer","en":"Save changes","es":"Guardar cambios","de":"Änderungen speichern","it":"Salva modifiche","pt":"Guardar alterações","sv":"Spara ändringar","nb":"Lagre endringer","da":"Gem ændringer","pl":"Zapisz zmiany","hu":"Mentés","hr":"Spremi promjene","sr":"Sačuvaj izmene"]) }
    static var whatDoYouPromise: String { t(["fr":"Ce que tu promets","en":"What do you promise","es":"Lo que prometes","de":"Was versprichst du","it":"Cosa prometti","pt":"O que prometes","sv":"Vad lovar du","nb":"Hva lover du","da":"Hvad lover du","pl":"Co obiecujesz","hu":"Mit ígérsz","hr":"Što obećaješ","sr":"Šta obećavaš"]) }

    // MARK: - Promi fields

    static var forWhom: String { t(["fr":"Pour qui","en":"For whom","es":"Para quién","de":"Für wen","it":"Per chi","pt":"Para quem","sv":"För vem","nb":"For hvem","da":"For hvem","pl":"Dla kogo","hu":"Kinek","hr":"Za koga","sr":"Za koga"]) }
    static var forWhomQ: String { t(["fr":"Pour qui ?","en":"For whom?","es":"¿Para quién?","de":"Für wen?","it":"Per chi?","pt":"Para quem?","sv":"För vem?","nb":"For hvem?","da":"For hvem?","pl":"Dla kogo?","hu":"Kinek?","hr":"Za koga?","sr":"Za koga?"]) }
    static var withWhomQ: String { t(["fr":"Avec qui ?","en":"With whom?","es":"¿Con quién?","de":"Mit wem?","it":"Con chi?","pt":"Com quem?","sv":"Med vem?","nb":"Med hvem?","da":"Med hvem?","pl":"Z kim?","hu":"Kivel?","hr":"S kim?","sr":"Sa kim?"]) }
    static var when: String { t(["fr":"Quand","en":"When","es":"Cuándo","de":"Wann","it":"Quando","pt":"Quando","sv":"När","nb":"Når","da":"Hvornår","pl":"Kiedy","hu":"Mikor","hr":"Kada","sr":"Kada"]) }
    static var intensity: String { t(["fr":"Intensité","en":"Intensity","es":"Intensidad","de":"Intensität","it":"Intensità","pt":"Intensidade","sv":"Intensitet","nb":"Intensitet","da":"Intensitet","pl":"Intensywność","hu":"Intenzitás","hr":"Intenzitet","sr":"Intenzitet"]) }
    static var someone: String { t(["fr":"quelqu'un…","en":"Someone…","es":"Alguien…","de":"Jemand…","it":"Qualcuno…","pt":"Alguém…","sv":"Någon…","nb":"Noen…","da":"Nogen…","pl":"Ktoś…","hu":"Valaki…","hr":"Netko…","sr":"Neko…"]) }
    static var precise: String { t(["fr":"Précis","en":"Precise","es":"Preciso","de":"Genau","it":"Preciso","pt":"Preciso","sv":"Exakt","nb":"Presis","da":"Præcis","pl":"Dokładnie","hu":"Pontos","hr":"Precizno","sr":"Precizno"]) }
    static var inTheAir: String { t(["fr":"En l'air","en":"In the air","es":"En el aire","de":"In der Luft","it":"Nell'aria","pt":"No ar","sv":"I luften","nb":"I luften","da":"I luften","pl":"W powietrzu","hu":"A levegőben","hr":"U zraku","sr":"U vazduhu"]) }
    static var ephemeral: String { t(["fr":"Éphémère","en":"Ephemeral","es":"Efímero","de":"Flüchtig","it":"Effimero","pt":"Efémero","sv":"Flyktig","nb":"Flyktig","da":"Flygtig","pl":"Ulotne","hu":"Múlékony","hr":"Prolazno","sr":"Prolazno"]) }
    static var permanent: String { t(["fr":"Permanente","en":"Permanent","es":"Permanente","de":"Dauerhaft","it":"Permanente","pt":"Permanente","sv":"Permanent","nb":"Permanent","da":"Permanent","pl":"Trwałe","hu":"Állandó","hr":"Trajno","sr":"Trajno"]) }
    static var linked: String { t(["fr":"Lié","en":"Linked","es":"Vinculado","de":"Verknüpft","it":"Collegato","pt":"Ligado","sv":"Länkad","nb":"Koblet","da":"Forbundet","pl":"Powiązane","hu":"Kapcsolt","hr":"Povezano","sr":"Povezano"]) }

    // MARK: - Promi actions

    static var iKeptIt: String { t(["fr":"Tenu","en":"I kept it","es":"Cumplida","de":"Gehalten","it":"Mantenuta","pt":"Cumprida","sv":"Hållet","nb":"Holdt","da":"Holdt","pl":"Dotrzymane","hu":"Betartva","hr":"Ispunjeno","sr":"Ispunjeno"]) }
    static var reopenPromise: String { t(["fr":"Réouvrir la promesse","en":"Reopen promise","es":"Reabrir la promesa","de":"Versprechen erneut öffnen","it":"Riapri la promessa","pt":"Reabrir a promessa","sv":"Öppna löftet igen","nb":"Åpne løftet igjen","da":"Genåbn løftet","pl":"Otwórz ponownie","hu":"Újranyitás","hr":"Ponovo otvori","sr":"Ponovo otvori"]) }
    static var reopen: String { t(["fr":"Réouvrir","en":"Reopen","es":"Reabrir","de":"Erneut öffnen","it":"Riapri","pt":"Reabrir","sv":"Öppna igen","nb":"Åpne igjen","da":"Genåbn","pl":"Otwórz ponownie","hu":"Újranyitás","hr":"Ponovo otvori","sr":"Ponovo otvori"]) }
    static var markAsKept: String { t(["fr":"Marquer comme tenu","en":"Mark as kept","es":"Marcar como cumplida","de":"Als gehalten markieren","it":"Segna come mantenuta","pt":"Marcar como cumprida","sv":"Markera som hållet","nb":"Merk som holdt","da":"Markér som holdt","pl":"Oznacz jako dotrzymane","hu":"Megjelölés betartottként","hr":"Označi kao ispunjeno","sr":"Označi kao ispunjeno"]) }
    static var addToCalendar: String { t(["fr":"Ajouter au calendrier","en":"Add to Calendar","es":"Añadir al calendario","de":"Zum Kalender hinzufügen","it":"Aggiungi al calendario","pt":"Adicionar ao calendário","sv":"Lägg till i kalender","nb":"Legg til i kalender","da":"Tilføj til kalender","pl":"Dodaj do kalendarza","hu":"Hozzáadás naptárhoz","hr":"Dodaj u kalendar","sr":"Dodaj u kalendar"]) }
    static var added: String { t(["fr":"Ajouté","en":"Added","es":"Añadido","de":"Hinzugefügt","it":"Aggiunto","pt":"Adicionado","sv":"Tillagd","nb":"Lagt til","da":"Tilføjet","pl":"Dodano","hu":"Hozzáadva","hr":"Dodano","sr":"Dodato"]) }
    static var deleteThisPromiQ: String { t(["fr":"Supprimer ce Promi ?","en":"Delete this Promi?","es":"¿Eliminar este Promi?","de":"Diesen Promi löschen?","it":"Eliminare questo Promi?","pt":"Excluir este Promi?","sv":"Radera detta Promi?","nb":"Slette dette Promi?","da":"Slet dette Promi?","pl":"Usunąć ten Promi?","hu":"Törli ezt a Promit?","hr":"Obrisati ovaj Promi?","sr":"Obrisati ovaj Promi?"]) }

    // MARK: - Nuée

    static var thematic: String { t(["fr":"Thématique","en":"Thematic","es":"Temática","de":"Thematisch","it":"Tematica","pt":"Temática","sv":"Tematisk","nb":"Tematisk","da":"Tematisk","pl":"Tematyczna","hu":"Tematikus","hr":"Tematska","sr":"Tematska"]) }
    static var intimate: String { t(["fr":"Intime","en":"Intimate","es":"Íntimo","de":"Privat","it":"Intimo","pt":"Íntimo","sv":"Privat","nb":"Privat","da":"Privat","pl":"Prywatna","hu":"Bensőséges","hr":"Intimna","sr":"Intimna"]) }
    static var deleteNuee: String { t(["fr":"Supprimer la Nuée","en":"Delete the Nuée","es":"Eliminar la Nuée","de":"Nuée löschen","it":"Elimina la Nuée","pt":"Excluir a Nuée","sv":"Radera Nuée","nb":"Slett Nuée","da":"Slet Nuée","pl":"Usuń Nuée","hu":"Nuée törlése","hr":"Obriši Nuée","sr":"Obriši Nuée"]) }
    static var deleteThisNueeQ: String { t(["fr":"Supprimer cette Nuée ?","en":"Delete this Nuée?","es":"¿Eliminar esta Nuée?","de":"Diese Nuée löschen?","it":"Eliminare questa Nuée?","pt":"Excluir esta Nuée?","sv":"Radera denna Nuée?","nb":"Slette denne Nuée?","da":"Slette denne Nuée?","pl":"Usunąć tę Nuée?","hu":"Törli ezt a Nuée-t?","hr":"Obrisati ovu Nuée?","sr":"Obrisati ovu Nuée?"]) }
    static var leaveNuee: String { t(["fr":"Quitter la Nuée","en":"Leave the Nuée","es":"Abandonar la Nuée","de":"Nuée verlassen","it":"Lascia la Nuée","pt":"Sair da Nuée","sv":"Lämna Nuée","nb":"Forlat Nuée","da":"Forlad Nuée","pl":"Opuść Nuée","hu":"Kilépés a Nuée-ből","hr":"Napusti Nuée","sr":"Napusti Nuée"]) }
    static var leaveThisNueeQ: String { t(["fr":"Quitter cette Nuée ?","en":"Leave this Nuée?","es":"¿Abandonar esta Nuée?","de":"Diese Nuée verlassen?","it":"Lasciare questa Nuée?","pt":"Sair desta Nuée?","sv":"Lämna denna Nuée?","nb":"Forlate denne Nuée?","da":"Forlade denne Nuée?","pl":"Opuścić tę Nuée?","hu":"Kilép ebből a Nuée-ből?","hr":"Napustiti ovu Nuée?","sr":"Napustiti ovu Nuée?"]) }
    static var leave: String { t(["fr":"Quitter","en":"Leave","es":"Abandonar","de":"Verlassen","it":"Lascia","pt":"Sair","sv":"Lämna","nb":"Forlat","da":"Forlad","pl":"Opuść","hu":"Kilépés","hr":"Napusti","sr":"Napusti"]) }
    static var addPeople: String { t(["fr":"Ajouter des personnes","en":"Add people","es":"Añadir personas","de":"Personen hinzufügen","it":"Aggiungi persone","pt":"Adicionar pessoas","sv":"Lägg till personer","nb":"Legg til personer","da":"Tilføj personer","pl":"Dodaj osoby","hu":"Személyek hozzáadása","hr":"Dodaj osobe","sr":"Dodaj osobe"]) }
    static var creator: String { t(["fr":"créateur·ice","en":"creator","es":"creador/a","de":"Ersteller·in","it":"creatore","pt":"criador/a","sv":"skapare","nb":"oppretteren","da":"skaberen","pl":"twórca","hu":"létrehozó","hr":"tvorac","sr":"tvorac"]) }

    // MARK: - Drafts

    static func draftLabel(_ n: Int) -> String {
        switch code {
        case "en": return n > 1 ? "Drafts" : "Draft"
        case "es": return n > 1 ? "Borradores" : "Borrador"
        case "de": return n > 1 ? "Entwürfe" : "Entwurf"
        case "it": return n > 1 ? "Bozze" : "Bozza"
        case "pt": return n > 1 ? "Rascunhos" : "Rascunho"
        case "sv": return "Utkast"
        case "nb": return "Utkast"
        case "da": return n > 1 ? "Kladder" : "Kladde"
        case "pl": return n > 1 ? "Szkice" : "Szkic"
        case "hu": return n > 1 ? "Vázlatok" : "Vázlat"
        case "hr": return n > 1 ? "Skice" : "Skica"
        case "sr": return n > 1 ? "Skice" : "Skica"
        default:   return n > 1 ? "Brouillons" : "Brouillon"
        }
    }
    static var myDraftPrefixSingular: String { t(["fr":"Mon ","en":"My ","es":"Mi ","de":"Mein ","it":"La mia ","pt":"O meu ","sv":"Mitt ","nb":"Mitt ","da":"Mit ","pl":"Mój ","hu":"Az én ","hr":"Moja ","sr":"Moja "]) }
    static var myDraftPrefixPlural: String { t(["fr":"Mes ","en":"My ","es":"Mis ","de":"Meine ","it":"Le mie ","pt":"Os meus ","sv":"Mina ","nb":"Mine ","da":"Mine ","pl":"Moje ","hu":"Az én ","hr":"Moje ","sr":"Moje "]) }
    static var noDrafts: String { t(["fr":"Aucun brouillon","en":"No drafts","es":"Sin borradores","de":"Keine Entwürfe","it":"Nessuna bozza","pt":"Sem rascunhos","sv":"Inga utkast","nb":"Ingen utkast","da":"Ingen kladder","pl":"Brak szkiców","hu":"Nincsenek vázlatok","hr":"Nema skica","sr":"Nema skica"]) }
    static var noDraftsPending: String { t(["fr":"Aucun brouillon en cours","en":"No drafts","es":"Sin borradores pendientes","de":"Keine ausstehenden Entwürfe","it":"Nessuna bozza in attesa","pt":"Sem rascunhos pendentes","sv":"Inga väntande utkast","nb":"Ingen ventende utkast","da":"Ingen ventende kladder","pl":"Brak oczekujących szkiców","hu":"Nincsenek várakozó vázlatok","hr":"Nema skica na čekanju","sr":"Nema skica na čekanju"]) }
    static func draftsPending(_ n: Int) -> String {
        switch code {
        case "en": return "\(n) \(n == 1 ? "draft" : "drafts") pending"
        case "es": return "\(n) \(n == 1 ? "borrador" : "borradores") pendiente\(n == 1 ? "" : "s")"
        case "de": return "\(n) \(n == 1 ? "Entwurf" : "Entwürfe") ausstehend"
        case "it": return "\(n) \(n == 1 ? "bozza" : "bozze") in attesa"
        case "pt": return "\(n) \(n == 1 ? "rascunho" : "rascunhos") pendente\(n == 1 ? "" : "s")"
        case "sv": return "\(n) utkast väntar"
        case "nb": return "\(n) utkast venter"
        case "da": return "\(n) \(n == 1 ? "kladde" : "kladder") venter"
        case "pl": return "\(n) \(n == 1 ? "szkic" : "szkiców") w toku"
        case "hu": return "\(n) vázlat várakozik"
        case "hr": return "\(n) \(n == 1 ? "skica" : "skica") čeka"
        case "sr": return "\(n) \(n == 1 ? "skica" : "skica") čeka"
        default:   return "\(n) \(n == 1 ? "brouillon" : "brouillons") en cours"
        }
    }
    static var nothingPending: String { t(["fr":"rien en attente","en":"nothing pending","es":"nada pendiente","de":"nichts ausstehend","it":"nulla in attesa","pt":"nada pendente","sv":"inget väntar","nb":"ingenting venter","da":"intet venter","pl":"nic w toku","hu":"nincs várakozó","hr":"ništa na čekanju","sr":"ništa na čekanju"]) }
    static var discardDraftQ: String { t(["fr":"Jeter ce brouillon ?","en":"Discard this draft?","es":"¿Descartar este borrador?","de":"Entwurf verwerfen?","it":"Eliminare questa bozza?","pt":"Descartar este rascunho?","sv":"Kassera detta utkast?","nb":"Forkast dette utkastet?","da":"Kassér denne kladde?","pl":"Odrzucić ten szkic?","hu":"Elveti ezt a vázlatot?","hr":"Odbaciti ovu skicu?","sr":"Odbaciti ovu skicu?"]) }
    static var discard: String { t(["fr":"Jeter","en":"Discard","es":"Descartar","de":"Verwerfen","it":"Elimina","pt":"Descartar","sv":"Kassera","nb":"Forkast","da":"Kassér","pl":"Odrzuć","hu":"Elvetés","hr":"Odbaci","sr":"Odbaci"]) }
    static var saveDraftQ: String { t(["fr":"Sauvegarder en brouillon ?","en":"Save as draft?","es":"¿Guardar como borrador?","de":"Als Entwurf speichern?","it":"Salvare come bozza?","pt":"Guardar como rascunho?","sv":"Spara som utkast?","nb":"Lagre som utkast?","da":"Gem som kladde?","pl":"Zapisać jako szkic?","hu":"Mentés vázlatként?","hr":"Spremiti kao skicu?","sr":"Sačuvati kao skicu?"]) }
    static var saveDraft: String { t(["fr":"Sauvegarder","en":"Save draft","es":"Guardar borrador","de":"Entwurf speichern","it":"Salva bozza","pt":"Guardar rascunho","sv":"Spara utkast","nb":"Lagre utkast","da":"Gem kladde","pl":"Zapisz szkic","hu":"Vázlat mentése","hr":"Spremi skicu","sr":"Sačuvaj skicu"]) }
    static var draftsKeptHere: String { t(["fr":"Les Promis et Nuées commencés sans validation sont conservés ici.","en":"Promis and Nuées started without saving are kept here.","es":"Los Promis y Nuées empezados sin guardar se conservan aquí.","de":"Angefangene Promis und Nuées ohne Speicherung werden hier aufbewahrt.","it":"I Promi e le Nuée iniziati senza salvare sono conservati qui.","pt":"Os Promis e Nuées iniciados sem guardar ficam aqui.","sv":"Promis och Nuéer som påbörjats utan att sparas behålls här.","nb":"Promier og Nuéer påbegynt uten å lagre beholdes her.","da":"Promier og Nuéer påbegyndt uden at gemme opbevares her.","pl":"Promi i Nuée rozpoczęte bez zapisania są tu przechowywane.","hu":"A mentés nélkül megkezdett Promik és Nuée-k itt maradnak.","hr":"Promi i Nuée započeti bez spremanja čuvaju se ovdje.","sr":"Promi i Nuée započeti bez čuvanja čuvaju se ovde."]) }

    // MARK: - Karma

    static var keptLabel: String { t(["fr":"Tenus","en":"Kept","es":"Cumplidas","de":"Gehalten","it":"Mantenute","pt":"Cumpridas","sv":"Hållna","nb":"Holdt","da":"Holdt","pl":"Dotrzymane","hu":"Betartva","hr":"Ispunjene","sr":"Ispunjene"]) }
    static var missedLabel: String { t(["fr":"Ratés","en":"Missed","es":"Perdidas","de":"Verpasst","it":"Mancate","pt":"Perdidas","sv":"Missade","nb":"Misset","da":"Misset","pl":"Pominięte","hu":"Elmulasztva","hr":"Propuštene","sr":"Propuštene"]) }
    static var pendingLabel: String { t(["fr":"En cours","en":"Pending","es":"Pendientes","de":"Ausstehend","it":"In corso","pt":"Pendentes","sv":"Pågående","nb":"Pågående","da":"Igangværende","pl":"W toku","hu":"Folyamatban","hr":"U tijeku","sr":"U toku"]) }
    static var currentStreak: String { t(["fr":"Série en cours","en":"Current streak","es":"Racha actual","de":"Aktuelle Serie","it":"Serie in corso","pt":"Sequência atual","sv":"Nuvarande svit","nb":"Nåværende rekke","da":"Nuværende række","pl":"Aktualna seria","hu":"Jelenlegi sorozat","hr":"Trenutni niz","sr":"Trenutni niz"]) }
    static var best: String { t(["fr":"record","en":"best","es":"récord","de":"Rekord","it":"record","pt":"recorde","sv":"rekord","nb":"rekord","da":"rekord","pl":"rekord","hu":"rekord","hr":"rekord","sr":"rekord"]) }
    static var last30Days: String { t(["fr":"30 derniers jours","en":"Last 30 days","es":"Últimos 30 días","de":"Letzte 30 Tage","it":"Ultimi 30 giorni","pt":"Últimos 30 dias","sv":"Senaste 30 dagarna","nb":"Siste 30 dager","da":"Sidste 30 dage","pl":"Ostatnie 30 dni","hu":"Utolsó 30 nap","hr":"Zadnjih 30 dana","sr":"Poslednjih 30 dana"]) }
    static func dayWord(_ n: Int) -> String {
        switch code {
        case "en": return n == 1 ? "day" : "days"
        case "es": return n == 1 ? "día" : "días"
        case "de": return n == 1 ? "Tag" : "Tage"
        case "it": return n == 1 ? "giorno" : "giorni"
        case "pt": return n == 1 ? "dia" : "dias"
        case "sv": return n == 1 ? "dag" : "dagar"
        case "nb": return n == 1 ? "dag" : "dager"
        case "da": return n == 1 ? "dag" : "dage"
        case "pl": return n == 1 ? "dzień" : (n < 5 ? "dni" : "dni")
        case "hu": return "nap"
        case "hr": return n == 1 ? "dan" : "dana"
        case "sr": return n == 1 ? "dan" : "dana"
        default:   return n == 1 ? "jour" : "jours"
        }
    }

    // MARK: - PromiList

    static var upcoming: String { t(["fr":"À venir","en":"Upcoming","es":"Próximos","de":"Bevorstehend","it":"In arrivo","pt":"Próximos","sv":"Kommande","nb":"Kommende","da":"Kommende","pl":"Nadchodzące","hu":"Közelgő","hr":"Nadolazeći","sr":"Nadolazeći"]) }
    static var keptSegment: String { t(["fr":"Accomplis","en":"Kept","es":"Cumplidas","de":"Gehalten","it":"Mantenute","pt":"Cumpridas","sv":"Hållna","nb":"Holdt","da":"Holdt","pl":"Dotrzymane","hu":"Betartva","hr":"Ispunjene","sr":"Ispunjene"]) }
    static var noResults: String { t(["fr":"Aucun résultat","en":"No results","es":"Sin resultados","de":"Keine Ergebnisse","it":"Nessun risultato","pt":"Sem resultados","sv":"Inga resultat","nb":"Ingen resultater","da":"Ingen resultater","pl":"Brak wyników","hu":"Nincs találat","hr":"Nema rezultata","sr":"Nema rezultata"]) }
    static var noPromisesKeptYet: String { t(["fr":"Pas encore de promesses tenues","en":"No promises kept yet","es":"Aún no hay promesas cumplidas","de":"Noch keine gehaltenen Versprechen","it":"Ancora nessuna promessa mantenuta","pt":"Ainda sem promessas cumpridas","sv":"Inga hållna löften ännu","nb":"Ingen holdte løfter ennå","da":"Ingen holdte løfter endnu","pl":"Brak dotrzymanych obietnic","hu":"Még nincs betartott ígéret","hr":"Još nema ispunjenih obećanja","sr":"Još nema ispunjenih obećanja"]) }
    static var createNextPromise: String { t(["fr":"Crée ta prochaine promesse. La toile attend.","en":"Create your next promise. The canvas awaits.","es":"Crea tu próxima promesa. El lienzo espera.","de":"Erstelle dein nächstes Versprechen. Die Leinwand wartet.","it":"Crea la tua prossima promessa. La tela attende.","pt":"Cria a tua próxima promessa. A tela espera.","sv":"Skapa ditt nästa löfte. Duken väntar.","nb":"Lag ditt neste løfte. Lerretet venter.","da":"Opret dit næste løfte. Lærredet venter.","pl":"Utwórz kolejną obietnicę. Płótno czeka.","hu":"Hozd létre a következő ígéreted. A vászon vár.","hr":"Stvori sljedeće obećanje. Platno čeka.","sr":"Napravi sledeće obećanje. Platno čeka."]) }
    static var adjustSearch: String { t(["fr":"Ajuste la recherche ou le tri pour retrouver ton Promi.","en":"Adjust your search or sort to find your Promi.","es":"Ajusta la búsqueda o el orden para encontrar tu Promi.","de":"Passe Suche oder Sortierung an.","it":"Regola la ricerca o l'ordine.","pt":"Ajusta a pesquisa ou a ordem.","sv":"Justera sökning eller sortering.","nb":"Juster søk eller sortering.","da":"Juster søgning eller sortering.","pl":"Zmień wyszukiwanie lub sortowanie.","hu":"Módosítsd a keresést vagy rendezést.","hr":"Prilagodi pretragu ili sortiranje.","sr":"Prilagodi pretragu ili sortiranje."]) }
    static var everyPromiseKeptTrace: String { t(["fr":"Chaque promesse tenue laissera une trace ici.","en":"Every promise kept will leave a trace here.","es":"Cada promesa cumplida dejará una huella aquí.","de":"Jedes gehaltene Versprechen hinterlässt hier eine Spur.","it":"Ogni promessa mantenuta lascerà una traccia qui.","pt":"Cada promessa cumprida deixará um rasto aqui.","sv":"Varje hållet löfte lämnar ett spår här.","nb":"Hvert holdt løfte etterlater et spor her.","da":"Hvert holdt løfte efterlader et spor her.","pl":"Każda dotrzymana obietnica zostawi tu ślad.","hu":"Minden betartott ígéret nyomot hagy itt.","hr":"Svako ispunjeno obećanje ostavit će trag ovdje.","sr":"Svako ispunjeno obećanje ostaviće trag ovde."]) }
    static var adjustSearchKept: String { t(["fr":"Ajuste la recherche pour retrouver une promesse accomplie.","en":"Adjust your search to find a kept promise.","es":"Ajusta la búsqueda para encontrar una promesa cumplida.","de":"Passe die Suche an.","it":"Regola la ricerca.","pt":"Ajusta a pesquisa.","sv":"Justera sökningen.","nb":"Juster søket.","da":"Juster søgningen.","pl":"Zmień wyszukiwanie.","hu":"Módosítsd a keresést.","hr":"Prilagodi pretragu.","sr":"Prilagodi pretragu."]) }
    static var searchPlaceholder: String { t(["fr":"Rechercher un Promi ou une personne…","en":"Search a Promi or person…","es":"Buscar un Promi o persona…","de":"Promi oder Person suchen…","it":"Cerca un Promi o una persona…","pt":"Pesquisar Promi ou pessoa…","sv":"Sök Promi eller person…","nb":"Søk Promi eller person…","da":"Søg Promi eller person…","pl":"Szukaj Promi lub osoby…","hu":"Promi vagy személy keresése…","hr":"Traži Promi ili osobu…","sr":"Traži Promi ili osobu…"]) }
    static func keptCount(_ n: Int) -> String { kept(n) }
    static func aheadCount(_ n: Int) -> String {
        switch code {
        case "en": return "\(n) ahead"
        case "es": return "\(n) pendiente\(n > 1 ? "s" : "")"
        case "de": return "\(n) bevorstehend"
        case "it": return "\(n) in arrivo"
        case "pt": return "\(n) pendente\(n > 1 ? "s" : "")"
        case "sv": return "\(n) kommande"
        case "nb": return "\(n) kommende"
        case "da": return "\(n) kommende"
        case "pl": return "\(n) nadchodzące"
        case "hu": return "\(n) közelgő"
        case "hr": return "\(n) nadolazeći"
        case "sr": return "\(n) nadolazeći"
        default:   return "\(n) à venir"
        }
    }
    static var myPrefixSingular: String { t(["fr":"Mon ","en":"My ","es":"Mi ","de":"Mein ","it":"Il mio ","pt":"O meu ","sv":"Mitt ","nb":"Mitt ","da":"Mit ","pl":"Mój ","hu":"Az én ","hr":"Moj ","sr":"Moj "]) }
    static var myPrefixPlural: String { t(["fr":"Mes ","en":"My ","es":"Mis ","de":"Meine ","it":"I miei ","pt":"Os meus ","sv":"Mina ","nb":"Mine ","da":"Mine ","pl":"Moje ","hu":"Az én ","hr":"Moji ","sr":"Moji "]) }

    // MARK: - Settings

    static var sectionYou: String { t(["fr":"TOI","en":"YOU","es":"TÚ","de":"DU","it":"TU","pt":"TU","sv":"DU","nb":"DEG","da":"DIG","pl":"TY","hu":"TE","hr":"TI","sr":"TI"]) }
    static var sectionApp: String { "APP" }
    static var sectionDiscover: String { t(["fr":"DÉCOUVERTE","en":"DISCOVER","es":"DESCUBRIR","de":"ENTDECKEN","it":"SCOPRI","pt":"DESCOBRIR","sv":"UTFORSKA","nb":"UTFORSK","da":"UDFORSK","pl":"ODKRYJ","hu":"FELFEDEZÉS","hr":"OTKRIJ","sr":"OTKRIJ"]) }
    static var sectionSafety: String { t(["fr":"SÉCURITÉ","en":"SAFETY","es":"SEGURIDAD","de":"SICHERHEIT","it":"SICUREZZA","pt":"SEGURANÇA","sv":"SÄKERHET","nb":"SIKKERHET","da":"SIKKERHED","pl":"BEZPIECZEŃSTWO","hu":"BIZTONSÁG","hr":"SIGURNOST","sr":"BEZBEDNOST"]) }
    static var sectionLegal: String { t(["fr":"LÉGAL","en":"LEGAL","es":"LEGAL","de":"RECHT","it":"LEGALE","pt":"LEGAL","sv":"JURIDIK","nb":"JURIDISK","da":"JURIDISK","pl":"PRAWO","hu":"JOGI","hr":"PRAVNO","sr":"PRAVNO"]) }
    static var settingsName: String { t(["fr":"Nom","en":"Name","es":"Nombre","de":"Name","it":"Nome","pt":"Nome","sv":"Namn","nb":"Navn","da":"Navn","pl":"Imię","hu":"Név","hr":"Ime","sr":"Ime"]) }
    static var settingsApple: String { t(["fr":"Compte Apple","en":"Apple account","es":"Cuenta Apple","de":"Apple-Konto","it":"Account Apple","pt":"Conta Apple","sv":"Apple-konto","nb":"Apple-konto","da":"Apple-konto","pl":"Konto Apple","hu":"Apple-fiók","hr":"Apple račun","sr":"Apple nalog"]) }
    static var settingsLanguage: String { t(["fr":"Langue","en":"Language","es":"Idioma","de":"Sprache","it":"Lingua","pt":"Idioma","sv":"Språk","nb":"Språk","da":"Sprog","pl":"Język","hu":"Nyelv","hr":"Jezik","sr":"Jezik"]) }
    static var settingsStudio: String { t(["fr":"Le Studio","en":"The Studio","es":"El Estudio","de":"Das Studio","it":"Lo Studio","pt":"O Estúdio","sv":"Studion","nb":"Studioet","da":"Studiet","pl":"Studio","hu":"A Stúdió","hr":"Studio","sr":"Studio"]) }
    static var settingsReplay: String { t(["fr":"Revivre l'onboarding","en":"Replay the onboarding","es":"Revivir el tutorial","de":"Onboarding wiederholen","it":"Rivivi l'onboarding","pt":"Rever o tutorial","sv":"Spela om introduktionen","nb":"Spill av introduksjonen","da":"Afspil introduktionen","pl":"Powtórz wprowadzenie","hu":"Bemutató újrajátszása","hr":"Ponovi upoznavanje","sr":"Ponovi upoznavanje"]) }
    static var settingsBlocked: String { t(["fr":"Utilisateurs bloqués","en":"Blocked users","es":"Usuarios bloqueados","de":"Blockierte Benutzer","it":"Utenti bloccati","pt":"Utilizadores bloqueados","sv":"Blockerade användare","nb":"Blokkerte brukere","da":"Blokerede brugere","pl":"Zablokowani użytkownicy","hu":"Blokkolt felhasználók","hr":"Blokirani korisnici","sr":"Blokirani korisnici"]) }
    static var settingsTerms: String { t(["fr":"Conditions d'utilisation","en":"Terms of use","es":"Condiciones de uso","de":"Nutzungsbedingungen","it":"Condizioni d'uso","pt":"Termos de utilização","sv":"Användarvillkor","nb":"Brukervilkår","da":"Brugervilkår","pl":"Regulamin","hu":"Felhasználási feltételek","hr":"Uvjeti korištenja","sr":"Uslovi korišćenja"]) }
    static var settingsPrivacy: String { t(["fr":"Confidentialité","en":"Privacy","es":"Privacidad","de":"Datenschutz","it":"Privacy","pt":"Privacidade","sv":"Integritet","nb":"Personvern","da":"Privatliv","pl":"Prywatność","hu":"Adatvédelem","hr":"Privatnost","sr":"Privatnost"]) }
    static var settingsPublisher: String { t(["fr":"Éditeur","en":"Publisher","es":"Editor","de":"Herausgeber","it":"Editore","pt":"Editor","sv":"Utgivare","nb":"Utgiver","da":"Udgiver","pl":"Wydawca","hu":"Kiadó","hr":"Izdavač","sr":"Izdavač"]) }
    static var settingsSettings: String { t(["fr":"Réglages","en":"Settings","es":"Ajustes","de":"Einstellungen","it":"Impostazioni","pt":"Definições","sv":"Inställningar","nb":"Innstillinger","da":"Indstillinger","pl":"Ustawienia","hu":"Beállítások","hr":"Postavke","sr":"Podešavanja"]) }
    static var settingsConnected: String { t(["fr":"connecté","en":"connected","es":"conectado","de":"verbunden","it":"connesso","pt":"ligado","sv":"ansluten","nb":"tilkoblet","da":"tilsluttet","pl":"połączony","hu":"csatlakoztatva","hr":"povezan","sr":"povezan"]) }
    static var settingsLocalData: String { t(["fr":"données locales","en":"local data","es":"datos locales","de":"lokale Daten","it":"dati locali","pt":"dados locais","sv":"lokal data","nb":"lokale data","da":"lokale data","pl":"dane lokalne","hu":"helyi adatok","hr":"lokalni podaci","sr":"lokalni podaci"]) }

    // MARK: - Studio / Palette

    static var studioTitle: String { t(["fr":"Promi · Le Studio","en":"Promi · The Studio","es":"Promi · El Estudio","de":"Promi · Das Studio","it":"Promi · Lo Studio","pt":"Promi · O Estúdio","sv":"Promi · Studion","nb":"Promi · Studioet","da":"Promi · Studiet","pl":"Promi · Studio","hu":"Promi · A Stúdió","hr":"Promi · Studio","sr":"Promi · Studio"]) }
    static var studioDesc: String { t(["fr":"Vertical pour la structure.\nHorizontal pour l'ambiance couleur.","en":"Vertical for structure.\nHorizontal for color mood.","es":"Vertical para la estructura.\nHorizontal para el ambiente de color.","de":"Vertikal für die Struktur.\nHorizontal für die Farbstimmung.","it":"Verticale per la struttura.\nOrizzontale per l'atmosfera.","pt":"Vertical para a estrutura.\nHorizontal para o ambiente de cor.","sv":"Vertikalt för struktur.\nHorisontellt för färgstämning.","nb":"Vertikalt for struktur.\nHorisontalt for fargestemning.","da":"Vertikalt for struktur.\nHorisontalt for farvestemning.","pl":"Pionowo — struktura.\nPoziomo — nastrój koloru.","hu":"Függőleges a struktúrához.\nVízszintes a színhangulathoz.","hr":"Okomito za strukturu.\nVodoravno za ugođaj boje.","sr":"Vertikalno za strukturu.\nHorizontalno za atmosferu boje."]) }
    static var activeLabel: String { t(["fr":"Actif","en":"Active","es":"Activo","de":"Aktiv","it":"Attivo","pt":"Ativo","sv":"Aktiv","nb":"Aktiv","da":"Aktiv","pl":"Aktywny","hu":"Aktív","hr":"Aktivan","sr":"Aktivan"]) }

    // MARK: - Splash / Sign in

    static var tagline: String { t(["fr":"votre parole, rendue visible.","en":"your word, made visible.","es":"tu palabra, hecha visible.","de":"dein Wort, sichtbar gemacht.","it":"la tua parola, resa visibile.","pt":"a tua palavra, tornada visível.","sv":"ditt ord, synliggjort.","nb":"ditt ord, synliggjort.","da":"dit ord, synliggjort.","pl":"twoje słowo, uwidocznione.","hu":"a szavad, láthatóvá téve.","hr":"tvoja riječ, učinjena vidljivom.","sr":"tvoja reč, učinjena vidljivom."]) }
    static var welcomeTo: String { t(["fr":"Bienvenue sur ","en":"Welcome to ","es":"Bienvenido a ","de":"Willkommen bei ","it":"Benvenuto su ","pt":"Bem-vindo a ","sv":"Välkommen till ","nb":"Velkommen til ","da":"Velkommen til ","pl":"Witaj w ","hu":"Üdvözöl a ","hr":"Dobrodošli u ","sr":"Dobrodošli u "]) }
    static var signInWithApple: String { t(["fr":"Se connecter avec Apple","en":"Sign in with Apple","es":"Iniciar sesión con Apple","de":"Mit Apple anmelden","it":"Accedi con Apple","pt":"Iniciar sessão com Apple","sv":"Logga in med Apple","nb":"Logg inn med Apple","da":"Log ind med Apple","pl":"Zaloguj przez Apple","hu":"Bejelentkezés Apple-lel","hr":"Prijava s Appleom","sr":"Prijava sa Appleom"]) }
    static var enterPromi: String { t(["fr":"Entrer dans Promi","en":"Enter Promi","es":"Entrar en Promi","de":"Promi betreten","it":"Entra in Promi","pt":"Entrar no Promi","sv":"Gå in i Promi","nb":"Gå inn i Promi","da":"Gå ind i Promi","pl":"Wejdź do Promi","hu":"Belépés a Promiba","hr":"Uđi u Promi","sr":"Uđi u Promi"]) }

    // MARK: - Username

    static var yourName: String { t(["fr":"Ton nom","en":"Your name","es":"Tu nombre","de":"Dein Name","it":"Il tuo nome","pt":"O teu nome","sv":"Ditt namn","nb":"Ditt navn","da":"Dit navn","pl":"Twoje imię","hu":"A neved","hr":"Tvoje ime","sr":"Tvoje ime"]) }
    static var namePlaceholder: String { t(["fr":"Prénom ou surnom","en":"First name or nickname","es":"Nombre o apodo","de":"Vorname oder Spitzname","it":"Nome o soprannome","pt":"Nome ou apelido","sv":"Förnamn eller smeknamn","nb":"Fornavn eller kallenavn","da":"Fornavn eller kaldenavn","pl":"Imię lub pseudonim","hu":"Keresztnév vagy becenév","hr":"Ime ili nadimak","sr":"Ime ili nadimak"]) }

    // MARK: - Comments

    static var comments: String { t(["fr":"Commentaires","en":"Comments","es":"Comentarios","de":"Kommentare","it":"Commenti","pt":"Comentários","sv":"Kommentarer","nb":"Kommentarer","da":"Kommentarer","pl":"Komentarze","hu":"Megjegyzések","hr":"Komentari","sr":"Komentari"]) }
    static var noCommentYet: String { t(["fr":"Aucun commentaire","en":"No comment yet","es":"Aún sin comentarios","de":"Noch keine Kommentare","it":"Ancora nessun commento","pt":"Ainda sem comentários","sv":"Inga kommentarer ännu","nb":"Ingen kommentarer ennå","da":"Ingen kommentarer endnu","pl":"Brak komentarzy","hu":"Még nincs megjegyzés","hr":"Još nema komentara","sr":"Još nema komentara"]) }
    static var addComment: String { t(["fr":"ajouter un commentaire…","en":"Add a comment…","es":"añadir un comentario…","de":"Kommentar hinzufügen…","it":"aggiungi un commento…","pt":"adicionar um comentário…","sv":"lägg till en kommentar…","nb":"legg til en kommentar…","da":"tilføj en kommentar…","pl":"dodaj komentarz…","hu":"megjegyzés hozzáadása…","hr":"dodaj komentar…","sr":"dodaj komentar…"]) }

    // MARK: - Misc

    static var all: String { t(["fr":"Tous","en":"All","es":"Todos","de":"Alle","it":"Tutti","pt":"Todos","sv":"Alla","nb":"Alle","da":"Alle","pl":"Wszystkie","hu":"Mind","hr":"Svi","sr":"Svi"]) }
    static var none: String { t(["fr":"Aucune","en":"None","es":"Ninguna","de":"Keine","it":"Nessuna","pt":"Nenhuma","sv":"Inga","nb":"Ingen","da":"Ingen","pl":"Brak","hu":"Nincs","hr":"Nijedna","sr":"Nijedna"]) }
    static var visible: String { t(["fr":"Visibles","en":"Visible","es":"Visibles","de":"Sichtbar","it":"Visibili","pt":"Visíveis","sv":"Synliga","nb":"Synlige","da":"Synlige","pl":"Widoczne","hu":"Látható","hr":"Vidljivi","sr":"Vidljivi"]) }
    static var hidden: String { t(["fr":"Masqués","en":"Hidden","es":"Ocultos","de":"Ausgeblendet","it":"Nascosti","pt":"Ocultos","sv":"Dolda","nb":"Skjulte","da":"Skjulte","pl":"Ukryte","hu":"Rejtett","hr":"Skriveni","sr":"Skriveni"]) }
    static var showAll: String { t(["fr":"Tout afficher","en":"Show all","es":"Mostrar todo","de":"Alle anzeigen","it":"Mostra tutto","pt":"Mostrar tudo","sv":"Visa alla","nb":"Vis alle","da":"Vis alle","pl":"Pokaż wszystko","hu":"Összes megjelenítése","hr":"Prikaži sve","sr":"Prikaži sve"]) }
    static var hideAll: String { t(["fr":"Tout masquer","en":"Hide all","es":"Ocultar todo","de":"Alle ausblenden","it":"Nascondi tutto","pt":"Ocultar tudo","sv":"Dölj alla","nb":"Skjul alle","da":"Skjul alle","pl":"Ukryj wszystko","hu":"Összes elrejtése","hr":"Sakrij sve","sr":"Sakrij sve"]) }
    static var preparing: String { t(["fr":"Préparation…","en":"Preparing…","es":"Preparando…","de":"Vorbereitung…","it":"Preparazione…","pt":"A preparar…","sv":"Förbereder…","nb":"Forbereder…","da":"Forbereder…","pl":"Przygotowywanie…","hu":"Előkészítés…","hr":"Priprema…","sr":"Priprema…"]) }
    static var pending: String { t(["fr":"en attente","en":"pending","es":"pendiente","de":"ausstehend","it":"in attesa","pt":"pendente","sv":"väntar","nb":"venter","da":"afventer","pl":"oczekuje","hu":"várakozik","hr":"na čekanju","sr":"na čekanju"]) }
    static var expired: String { t(["fr":"expirée","en":"expired","es":"expirada","de":"abgelaufen","it":"scaduta","pt":"expirada","sv":"utgånget","nb":"utløpt","da":"udløbet","pl":"wygasła","hu":"lejárt","hr":"isteklo","sr":"isteklo"]) }
    static var expiresOn: String { t(["fr":"expire le","en":"expires on","es":"expira el","de":"läuft ab am","it":"scade il","pt":"expira a","sv":"går ut","nb":"utløper","da":"udløber","pl":"wygasa","hu":"lejár","hr":"ističe","sr":"ističe"]) }
    static var publicChallenge: String { t(["fr":"Défi public","en":"Public challenge","es":"Reto público","de":"Öffentliche Herausforderung","it":"Sfida pubblica","pt":"Desafio público","sv":"Offentlig utmaning","nb":"Offentlig utfordring","da":"Offentlig udfordring","pl":"Wyzwanie publiczne","hu":"Nyilvános kihívás","hr":"Javni izazov","sr":"Javni izazov"]) }
    static var shareYourComposition: String { t(["fr":"partage ta composition","en":"share your composition","es":"comparte tu composición","de":"teile deine Komposition","it":"condividi la tua composizione","pt":"partilha a tua composição","sv":"dela din komposition","nb":"del din komposisjon","da":"del din komposition","pl":"udostępnij swoją kompozycję","hu":"oszd meg a kompozíciódat","hr":"podijeli svoju kompoziciju","sr":"podeli svoju kompoziciju"]) }
    static var visibleElements: String { t(["fr":"Éléments visibles","en":"Visible elements","es":"Elementos visibles","de":"Sichtbare Elemente","it":"Elementi visibili","pt":"Elementos visíveis","sv":"Synliga element","nb":"Synlige elementer","da":"Synlige elementer","pl":"Widoczne elementy","hu":"Látható elemek","hr":"Vidljivi elementi","sr":"Vidljivi elementi"]) }

    // MARK: - Time

    static func daysLeft(_ n: Int) -> String {
        switch code {
        case "en": return n == 1 ? "day left" : "days left"
        case "es": return n == 1 ? "día restante" : "días restantes"
        case "de": return n == 1 ? "Tag übrig" : "Tage übrig"
        case "it": return n == 1 ? "giorno rimasto" : "giorni rimasti"
        case "pt": return n == 1 ? "dia restante" : "dias restantes"
        case "sv": return n == 1 ? "dag kvar" : "dagar kvar"
        case "nb": return n == 1 ? "dag igjen" : "dager igjen"
        case "da": return n == 1 ? "dag tilbage" : "dage tilbage"
        case "pl": return n == 1 ? "dzień pozostał" : "dni pozostało"
        case "hu": return "nap van hátra"
        case "hr": return n == 1 ? "dan preostao" : "dana preostalo"
        case "sr": return n == 1 ? "dan preostao" : "dana preostalo"
        default:   return n == 1 ? "jour restant" : "jours restants"
        }
    }

    // MARK: - Celebration

    static var itsAStart: String { t(["fr":"c'est un début.","en":"it's a start.","es":"es un comienzo.","de":"ein Anfang.","it":"è un inizio.","pt":"é um começo.","sv":"det är en start.","nb":"det er en start.","da":"det er en start.","pl":"to dopiero początek.","hu":"ez még csak a kezdet.","hr":"to je početak.","sr":"to je početak."]) }
    static var oneHundredth: String { t(["fr":"centième. rien ne t'arrête.","en":"one hundredth. unstoppable.","es":"centésima. imparable.","de":"hundertste. nicht aufzuhalten.","it":"centesima. inarrestabile.","pt":"centésima. imparável.","sv":"hundrade. ostoppbar.","nb":"hundrede. ustoppelig.","da":"hundrede. ustoppelig.","pl":"setna. nie do zatrzymania.","hu":"századik. megállíthatatlan.","hr":"stota. nezaustavljivo.","sr":"stota. nezaustavljivo."]) }
    static var fiveHundred: String { t(["fr":"demi-millier. respect.","en":"five hundred. respect.","es":"quinientas. respeto.","de":"fünfhundert. Respekt.","it":"cinquecento. rispetto.","pt":"quinhentas. respeito.","sv":"femhundra. respekt.","nb":"fem hundre. respekt.","da":"fem hundrede. respekt.","pl":"pięćset. szacun.","hu":"ötszáz. respekt.","hr":"petsto. respekt.","sr":"petsto. respekt."]) }
    static var keptDot: String { t(["fr":"Tenu.","en":"Kept.","es":"Cumplida.","de":"Gehalten.","it":"Mantenuta.","pt":"Cumprida.","sv":"Hållet.","nb":"Holdt.","da":"Holdt.","pl":"Dotrzymane.","hu":"Betartva.","hr":"Ispunjeno.","sr":"Ispunjeno."]) }
    static var midnightPromi: String { t(["fr":"Promi de minuit","en":"Midnight Promi","es":"Promi de medianoche","de":"Mitternachts-Promi","it":"Promi di mezzanotte","pt":"Promi da meia-noite","sv":"Midnatts-Promi","nb":"Midnatts-Promi","da":"Midnats-Promi","pl":"Promi o północy","hu":"Éjféli Promi","hr":"Ponoćni Promi","sr":"Ponoćni Promi"]) }
}
