import SwiftUI

struct MinimalPromiCardView: View {
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promi: PromiItem
    
    @State private var showEditView = false
    @State private var showComments = false
    
    private var commentsCount: Int {
        promiStore.comments.filter { $0.promiId == promi.id }.count
    }
    
    var body: some View {
        Button(action: {
            Haptics.shared.lightTap()
            showEditView = true
        }) {
            ZStack(alignment: .topLeading) {
                mainShape
                
                if promi.kind == .floating {
                    Circle()
                        .fill(Color.orange.opacity(0.12))
                        .frame(width: 78, height: 78)
                        .offset(x: cardWidth * 0.54, y: cardHeight * 0.52)
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.orange.opacity(0.07))
                        .frame(width: 84, height: 54)
                        .offset(x: cardWidth * 0.52, y: cardHeight * 0.56)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    topLine
                    titleBlock
                    bottomLine
                }
                .padding(16)
            }
            .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEditView) {
            EditPromiView(promi: promi)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(promiId: promi.id)
        }
    }
    
    private var topLine: some View {
        HStack(alignment: .top) {
            Text(kindLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(kindAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(kindAccent.opacity(0.10))
                )
            
            Spacer()
            
            if promi.kind != .floating {
                Text(dateText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.black.opacity(0.46))
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(promi.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black.opacity(0.88))
                .multilineTextAlignment(.leading)
                .lineLimit(4)
            
            if let assignee = promi.assignee, !assignee.isEmpty {
                Text("pour \(assignee)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black.opacity(0.54))
            }
        }
    }
    
    private var bottomLine: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(kindAccent)
                    .frame(width: 6, height: 6)
                
                Text(intensityLabel)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black.opacity(0.54))
            }
            
            Spacer()
            
            Button(action: {
                Haptics.shared.tinyPop()
                showComments = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 12, weight: .regular))
                    Text("\(commentsCount)")
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundColor(.black.opacity(0.48))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var mainShape: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
    
    private var cardWidth: CGFloat {
        switch promi.kind {
        case .precise:
            return 176
        case .emotional:
            return 194
        case .floating:
            return 214
        }
    }
    
    private var cardHeight: CGFloat {
        switch promi.kind {
        case .precise:
            return 156 + CGFloat(promi.intensity) * 0.22
        case .emotional:
            return 172 + CGFloat(promi.intensity) * 0.24
        case .floating:
            return 164 + CGFloat(promi.intensity) * 0.18
        }
    }
    
    private var cornerRadius: CGFloat {
        switch promi.kind {
        case .precise:
            return 30
        case .emotional:
            return 38
        case .floating:
            return 48
        }
    }
    
    private var fillColor: Color {
        switch promi.kind {
        case .precise:
            return Color.white.opacity(0.34)
        case .emotional:
            return Color(red: 1.0, green: 0.78, blue: 0.84).opacity(0.18)
        case .floating:
            return Color.orange.opacity(0.12)
        }
    }
    
    private var strokeColor: Color {
        switch promi.kind {
        case .precise:
            return Color.orange.opacity(0.24)
        case .emotional:
            return Color(red: 0.12, green: 0.44, blue: 0.95).opacity(0.22)
        case .floating:
            return Color.orange.opacity(0.22)
        }
    }
    
    private var kindAccent: Color {
        switch promi.kind {
        case .precise:
            return .black.opacity(0.76)
        case .emotional:
            return Color(red: 0.12, green: 0.44, blue: 0.95)
        case .floating:
            return Color.orange.opacity(0.94)
        }
    }
    
    private var kindLabel: String {
        if userStore.selectedLanguage.starts(with: "en") {
            switch promi.kind {
            case .precise: return "Precise"
            case .emotional: return "Linked"
            case .floating: return "In the air"
            }
        } else {
            switch promi.kind {
            case .precise: return "Précis"
            case .emotional: return "Lié"
            case .floating: return "En l’air"
            }
        }
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: userStore.selectedLanguage.starts(with: "en") ? "en_US" : "fr_FR")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: promi.dueDate)
    }
    
    private var intensityLabel: String {
        if promi.intensity >= 80 { return userStore.selectedLanguage.starts(with: "en") ? "very present" : "très présent" }
        if promi.intensity >= 50 { return userStore.selectedLanguage.starts(with: "en") ? "present" : "présent" }
        return userStore.selectedLanguage.starts(with: "en") ? "light" : "léger"
    }
}
