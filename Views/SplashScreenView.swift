import SwiftUI

struct SplashScreenView: View {
    @State private var phase: CGFloat = 0.82
    
    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.963, blue: 0.947)
                .ignoresSafeArea()
            
            PromiEntryBackground(progress: 0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 26) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 132, height: 168)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                    
                    Image("LogoPromi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 110)
                }
                .scaleEffect(phase)
                .opacity(Double(phase))
                
                Text("Promi")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.black.opacity(0.84))
                    .tracking(0.8)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.82, dampingFraction: 0.82)) {
                phase = 1.0
            }
        }
    }
}

struct PromiEntryBackground: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.40, blue: 0.06).opacity(0.92))
                    .frame(width: w * 0.36, height: h * 0.13)
                    .position(x: w * 0.36, y: h * 0.16)
                
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.84, blue: 0.08).opacity(0.95))
                    .frame(width: w * 0.38, height: h * 0.15)
                    .position(x: w * 0.62, y: h * 0.15)
                
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.78, blue: 0.84).opacity(0.75))
                    .frame(width: w * 0.32, height: h * 0.18)
                    .position(x: w * 0.28, y: h * 0.28)
                
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.44, blue: 0.95).opacity(0.92))
                    .frame(width: w * 0.33, height: h * 0.20)
                    .position(x: w * 0.66, y: h * 0.30)
                
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.75, blue: 0.48).opacity(0.94))
                    .frame(width: w * 0.36, height: h * 0.16)
                    .position(x: w * 0.30, y: h * 0.44)
                
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.40, blue: 0.06).opacity(0.90))
                    .frame(width: w * 0.34, height: h * 0.15)
                    .position(x: w * 0.60, y: h * 0.45)
                
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: min(w, h) * 0.20)
                    .position(x: w * 0.50, y: h * 0.29)
                    .scaleEffect(0.92 + (0.08 * progress))
            }
            .blur(radius: 54)
            .opacity(0.18)
        }
    }
}
