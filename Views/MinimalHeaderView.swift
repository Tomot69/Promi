import SwiftUI

struct MinimalHeaderView: View {
    let textColor: Color
    let onTitleTap: () -> Void
    let onAddTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                Haptics.shared.lightTap()
                onTitleTap()
            }) {
                Text("Promi")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(textColor)
                    .tracking(0.2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.90))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 0.6)
                            )
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: {
                Haptics.shared.tinyPop()
                onAddTap()
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.92))
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.08), lineWidth: 0.6)
                        )
                    
                    Text("+")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Color.orange.opacity(0.94))
                }
                .frame(width: 46, height: 46)
            }
            .buttonStyle(.plain)
        }
    }
}
