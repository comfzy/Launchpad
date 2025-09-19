import SwiftUI
import AppKit

struct AppIconView: View {
    let app: AppModel
    let onLaunch: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.08)) {
                    isPressed = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = false
                    }
                    onLaunch()
                }
            }) {
                Group {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.1, green: 0.1, blue: 0.1),
                                    Color(red: 0.3, green: 0.3, blue: 0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .overlay(
                                Image(systemName: "app")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.05 : 1.0))
                .shadow(
                    color: .black.opacity(isHovered ? 0.4 : 0.2),
                    radius: isHovered ? 12 : 6,
                    x: 0,
                    y: isHovered ? 6 : 3
                )
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }

            Text(app.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 90)
                .opacity(isHovered ? 1.0 : 0.9)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .padding(4)
    }
}