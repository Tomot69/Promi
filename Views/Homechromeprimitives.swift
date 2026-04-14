import SwiftUI

// MARK: - Chrome primitives
//
// Reusable chrome building blocks (surfaces, buttons, glyphs) extracted
// from ContentView for compilation-unit reduction. All types were already
// internal (non-fileprivate), so moving them is a zero-impact refactor.

struct FloatingChromeCircle: View {
    let isDarkField: Bool

    var body: some View {
        ChromeCircleSurface(isDarkField: isDarkField)
    }
}

struct FloatingGlyphButton: View {
    let symbol: String
    let isDarkField: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                FloatingChromeCircle(isDarkField: isDarkField)

                Text(symbol)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white.opacity(0.96))
            }
            .frame(width: 46, height: 46)
        }
        .buttonStyle(.plain)
    }
}

struct IconOnlyCircleButton<Glyph: View>: View {
    let isDarkField: Bool
    let size: CGFloat
    let action: () -> Void
    let glyph: Glyph

    init(
        isDarkField: Bool,
        size: CGFloat = 46,
        action: @escaping () -> Void,
        @ViewBuilder glyph: () -> Glyph
    ) {
        self.isDarkField = isDarkField
        self.size = size
        self.action = action
        self.glyph = glyph()
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                FloatingChromeCircle(isDarkField: isDarkField)
                glyph
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Surfaces

struct ChromeCapsuleSurface: View {
    let isDarkField: Bool

    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)

            Capsule(style: .continuous)
                .fill(Color.white.opacity(isDarkField ? 0.10 : 0.18))

            Capsule(style: .continuous)
                .stroke(
                    isDarkField ? Color.white.opacity(0.18) : Color.white.opacity(0.10),
                    lineWidth: 0.6
                )
        }
        .shadow(
            color: .black.opacity(isDarkField ? 0.22 : 0.10),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

struct ChromeCircleSurface: View {
    let isDarkField: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)

            Circle()
                .fill(Color.white.opacity(isDarkField ? 0.10 : 0.18))

            Circle()
                .stroke(
                    isDarkField ? Color.white.opacity(0.18) : Color.white.opacity(0.10),
                    lineWidth: 0.6
                )
        }
        .shadow(
            color: .black.opacity(isDarkField ? 0.22 : 0.10),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

struct CompactMenuSurface: View {
    let isDarkField: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(isDarkField ? 0.18 : 0.10))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
        }
    }
}

// MARK: - Glyphs

struct PromiFieldSortGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.5
            let w = size.width
            let h = size.height

            // Two arrows side by side — universal sort metaphor.
            // Left arrow: pointing UP. Right arrow: pointing DOWN.

            // LEFT arrow (up)
            var leftStem = Path()
            leftStem.move(to: CGPoint(x: w * 0.30, y: h * 0.20))
            leftStem.addLine(to: CGPoint(x: w * 0.30, y: h * 0.80))
            context.stroke(
                leftStem,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            var leftHead = Path()
            leftHead.move(to: CGPoint(x: w * 0.18, y: h * 0.34))
            leftHead.addLine(to: CGPoint(x: w * 0.30, y: h * 0.20))
            leftHead.addLine(to: CGPoint(x: w * 0.42, y: h * 0.34))
            context.stroke(
                leftHead,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )

            // RIGHT arrow (down)
            var rightStem = Path()
            rightStem.move(to: CGPoint(x: w * 0.70, y: h * 0.20))
            rightStem.addLine(to: CGPoint(x: w * 0.70, y: h * 0.80))
            context.stroke(
                rightStem,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            var rightHead = Path()
            rightHead.move(to: CGPoint(x: w * 0.58, y: h * 0.66))
            rightHead.addLine(to: CGPoint(x: w * 0.70, y: h * 0.80))
            rightHead.addLine(to: CGPoint(x: w * 0.82, y: h * 0.66))
            context.stroke(
                rightHead,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

struct StudioGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.4
            let w = size.width
            let h = size.height

            // 2×2 grid of small squares — universal "themes / tile picker" metaphor.
            let cell = w * 0.30
            let gap = w * 0.10
            let originX = (w - (cell * 2 + gap)) / 2
            let originY = (h - (cell * 2 + gap)) / 2

            for row in 0..<2 {
                for col in 0..<2 {
                    let rect = CGRect(
                        x: originX + CGFloat(col) * (cell + gap),
                        y: originY + CGFloat(row) * (cell + gap),
                        width: cell,
                        height: cell
                    )
                    let path = Path(roundedRect: rect, cornerRadius: 2, style: .continuous)
                    context.stroke(
                        path,
                        with: .color(stroke),
                        style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round)
                    )
                }
            }
        }
    }
}

struct EyeGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.94)
            let fill = isDarkField ? Color.white.opacity(0.90) : Color.white.opacity(0.92)

            var eye = Path()
            eye.move(to: CGPoint(x: size.width * 0.14, y: size.height * 0.50))
            eye.addQuadCurve(
                to: CGPoint(x: size.width * 0.86, y: size.height * 0.50),
                control: CGPoint(x: size.width * 0.50, y: size.height * 0.12)
            )
            eye.addQuadCurve(
                to: CGPoint(x: size.width * 0.14, y: size.height * 0.50),
                control: CGPoint(x: size.width * 0.50, y: size.height * 0.88)
            )

            context.stroke(eye, with: .color(stroke), lineWidth: 1.7)
            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.40, y: size.height * 0.35, width: size.width * 0.20, height: size.height * 0.20)),
                with: .color(fill)
            )
        }
    }
}

// MARK: - NuéeHexGlyph
//
// SF Symbol "circle.hexagongrid" wrapped in a styled View for consistency
// with the other dock glyphs. The hexagonal grid icon visually echoes the
// Voronoï tiling of the home field — a perfect identity match for the
// Nuée concept (a swarm of cells, a small group sharing a territory).
//
// Same symbol is used in the empty state of MesNuéesView, so the user
// experiences visual continuity: the icon they see when "no Nuées yet"
// is the exact same icon as the dock button that opens MesNuéesView.

struct NuéeHexGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Image(systemName: "circle.hexagongrid")
            .font(.system(size: 22, weight: .regular))
            .foregroundColor(Color.white.opacity(isDarkField ? 0.96 : 0.94))
    }
}

// MARK: - PinkyPromiseGlyph
//
// Icône du logo Promi (deux mains avec auriculaires crochetés),
// chargée depuis l'asset "pinkypromise" dans Assets.xcassets.
// Teintée en blanc ou noir selon le fond chrome pour rester lisible
// sur tous les packs visuels.

struct PinkyPromiseGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Image("pinkypromise")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .scaleEffect(1.5)
            .foregroundColor(
                isDarkField
                    ? Color.white.opacity(0.96)
                    : Color.black.opacity(0.88)
            )
    }
}

struct CompositionGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.5
            let w = size.width
            let h = size.height

            // Square (with bottom open) — the iOS share metaphor: a tray with
            // an arrow rising out of it.
            var tray = Path()
            tray.move(to: CGPoint(x: w * 0.22, y: h * 0.46))
            tray.addLine(to: CGPoint(x: w * 0.22, y: h * 0.84))
            tray.addLine(to: CGPoint(x: w * 0.78, y: h * 0.84))
            tray.addLine(to: CGPoint(x: w * 0.78, y: h * 0.46))
            context.stroke(tray, with: .color(stroke), lineWidth: lineWidth)

            // Vertical line (the arrow body)
            var stem = Path()
            stem.move(to: CGPoint(x: w * 0.50, y: h * 0.62))
            stem.addLine(to: CGPoint(x: w * 0.50, y: h * 0.16))
            context.stroke(stem, with: .color(stroke), lineWidth: lineWidth)

            // Arrow head (chevron pointing up)
            var head = Path()
            head.move(to: CGPoint(x: w * 0.34, y: h * 0.30))
            head.addLine(to: CGPoint(x: w * 0.50, y: h * 0.16))
            head.addLine(to: CGPoint(x: w * 0.66, y: h * 0.30))
            context.stroke(
                head,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

struct AddPlusGlyph: View {
    let isDarkField: Bool

    var body: some View {
        Canvas { context, size in
            let stroke = isDarkField ? Color.white.opacity(0.94) : Color.white.opacity(0.92)
            let lineWidth: CGFloat = 1.7
            let w = size.width
            let h = size.height

            // Simple "+" cross.
            var horizontal = Path()
            horizontal.move(to: CGPoint(x: w * 0.22, y: h * 0.50))
            horizontal.addLine(to: CGPoint(x: w * 0.78, y: h * 0.50))
            context.stroke(
                horizontal,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )

            var vertical = Path()
            vertical.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            vertical.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            context.stroke(
                vertical,
                with: .color(stroke),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
        }
    }
}
