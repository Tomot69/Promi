import WidgetKit
import SwiftUI

struct PromiEntry: TimelineEntry {
    let date: Date
    let nextPromiTitle: String?
    let nextPromiDate: Date?
    let streak: Int
    let karmaPercentage: Int
}

struct PromiProvider: TimelineProvider {
    func placeholder(in context: Context) -> PromiEntry {
        PromiEntry(date: Date(), nextPromiTitle: "Promi", nextPromiDate: nil, streak: 3, karmaPercentage: 78)
    }

    func getSnapshot(in context: Context, completion: @escaping (PromiEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PromiEntry>) -> Void) {
        let defaults = UserDefaults.standard
        let streak = defaults.integer(forKey: "promi.streak.current")
        let karma = (try? JSONDecoder().decode(KarmaData.self,
            from: defaults.data(forKey: "karmaState") ?? Data()))?.percentage ?? 0

        // Lire les prochains Promi depuis UserDefaults (partagé via App Group)
        var nextTitle: String? = nil
        var nextDate: Date? = nil

        let entry = PromiEntry(
            date: Date(),
            nextPromiTitle: nextTitle,
            nextPromiDate: nextDate,
            streak: streak,
            karmaPercentage: karma
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct KarmaData: Codable {
    let percentage: Int
}

struct PromiWidgetEntryView: View {
    var entry: PromiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Promi")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Color(red: 0.98, green: 0.56, blue: 0.22))
                Spacer()
                Text("\(entry.karmaPercentage)%")
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundColor(.secondary)
            }

            if entry.streak > 0 {
                HStack(spacing: 4) {
                    Text(entry.streak >= 7 ? "🔥" : "⚡")
                        .font(.system(size: 12))
                    Text("\(entry.streak)j")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }
            }

            Spacer()

            if let title = entry.nextPromiTitle {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            } else {
                Text("Rien en vue")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
    }
}

@main
struct PromiWidget: Widget {
    let kind: String = "PromiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PromiProvider()) { entry in
            PromiWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Promi")
        .description("Ton prochain Promi et ton streak.")
        .supportedFamilies([.systemSmall])
    }
}
