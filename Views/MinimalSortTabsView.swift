import SwiftUI

enum SortOption: String, CaseIterable {
    case date = "Date"
    case urgency = "Urgence"
    case person = "Personne"
    case importance = "Intensité"
    case karma = "Karma"
    case inspiration = "Inspi"
    case groups = "Groupes"
}

struct MinimalSortTabsView: View {
    @Binding var selectedSort: SortOption
    @State private var isExpanded = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: {
                Haptics.shared.tinyPop()
                withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
                    isExpanded.toggle()
                }
            }) {
                BauhausSortGlyph()
                    .frame(width: 34, height: 34)
                    .foregroundColor(.black.opacity(0.82))
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            selectedSort = option
                            Haptics.shared.lightTap()
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                                isExpanded = false
                            }
                        }) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(selectedSort == option ? Color.orange.opacity(0.92) : Color.black.opacity(0.18))
                                    .frame(width: 6, height: 6)
                                
                                Text(option.rawValue)
                                    .font(.system(size: 13, weight: selectedSort == option ? .medium : .regular))
                                    .foregroundColor(selectedSort == option ? .black.opacity(0.86) : .black.opacity(0.58))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 2)
                .offset(x: 0, y: 40)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct BauhausSortGlyph: View {
    var body: some View {
        Canvas { context, size in
            let lineColor = Color.black.opacity(0.76)
            
            var longLine = Path()
            longLine.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.30))
            longLine.addLine(to: CGPoint(x: size.width * 0.82, y: size.height * 0.30))
            
            var shortLine = Path()
            shortLine.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.54))
            shortLine.addLine(to: CGPoint(x: size.width * 0.64, y: size.height * 0.54))
            
            var tinyLine = Path()
            tinyLine.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.78))
            tinyLine.addLine(to: CGPoint(x: size.width * 0.48, y: size.height * 0.78))
            
            context.stroke(longLine, with: .color(lineColor), lineWidth: 1.4)
            context.stroke(shortLine, with: .color(lineColor), lineWidth: 1.4)
            context.stroke(tinyLine, with: .color(lineColor), lineWidth: 1.4)
            
            let circleRects = [
                CGRect(x: size.width * 0.62, y: size.height * 0.18, width: 7, height: 7),
                CGRect(x: size.width * 0.46, y: size.height * 0.42, width: 7, height: 7),
                CGRect(x: size.width * 0.32, y: size.height * 0.66, width: 7, height: 7)
            ]
            
            for rect in circleRects {
                context.fill(Path(ellipseIn: rect), with: .color(Color.orange.opacity(0.92)))
            }
        }
    }
}
