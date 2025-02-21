import Combine
import SwiftUI

// Toast Position enum with custom spacing
public enum ToastPosition: Equatable {
  case top
  case bottom
  case center
  case custom(BasePosition, spacing: CGFloat)
  
  public enum BasePosition: Equatable {
    case top
    case bottom
    case center
  }
  
  var spacing: CGFloat {
    switch self {
    case .top:
      return 32
    case .bottom:
      return 32
    case .center:
      return 0
    case .custom(_, let spacing):
      return spacing
    }
  }
  
  var basePosition: BasePosition {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    case .center:
      return .center
    case .custom(let base, _):
      return base
    }
  }
}

public enum ToastStyle: Equatable {
  case info
  case success
  case warning
  case error

  var backgroundColor: Color {
    switch self {
    case .info: return Color.blue.opacity(0.9)
    case .success: return Color.green.opacity(0.9)
    case .warning: return Color.yellow.opacity(0.9)
    case .error: return Color.red.opacity(0.9)
    }
  }

  var icon: String {
    switch self {
    case .info: return "info.circle.fill"
    case .success: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .error: return "xmark.circle.fill"
    }
  }
}

public struct Toast: Equatable {
  public let style: ToastStyle
  public let message: String
  public let duration: Double
  public let position: ToastPosition
}

@MainActor
final class ToastManager: ObservableObject {
     static let shared = ToastManager()

  @Published var currentToast: Toast?
  private var task: Task<Void, Never>?

  private init() {}

  func show(
    _ message: String, style: ToastStyle = .info, duration: Double = 3.0,
    position: ToastPosition = .bottom
  ) {
    task?.cancel()
    currentToast = Toast(style: style, message: message, duration: duration, position: position)

    task = Task {
      try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
      await MainActor.run {
        withAnimation {
          currentToast = nil
        }
      }
    }
  }
}

struct ToastView: View {
  let toast: Toast

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: toast.style.icon)
        .foregroundColor(.white)

      Text(toast.message)
        .font(.system(size: 14))
        .foregroundColor(.white)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(toast.style.backgroundColor)
    .cornerRadius(8)
    .shadow(radius: 4)
  }
}

struct ToastModifier: ViewModifier {
  @StateObject private var toastManager = ToastManager.shared

  func body(content: Content) -> some View {
    content
      .overlay(
        ZStack {
          if let toast = toastManager.currentToast {
            Group {
              switch toast.position.basePosition {
              case .top:
                VStack {
                  ToastView(toast: toast)
                    .transition(.move(edge: .top))
                    .padding(.top, toast.position.spacing)
                  Spacer()
                }
              case .center:
                ToastView(toast: toast)
                  .transition(.opacity)
              case .bottom:
                VStack {
                  Spacer()
                  ToastView(toast: toast)
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, toast.position.spacing)
                }
              }
            }
          }
        }
        .animation(.easeInOut, value: toastManager.currentToast)
      )
  }
}

extension View {
  func toast() -> some View {
    modifier(ToastModifier())
  }
}

@MainActor
public enum SharedToast {
  static public func show(
    _ message: String, style: ToastStyle = .info, duration: Double = 3.0,
    position: ToastPosition = .bottom
  ) {
    ToastManager.shared.show(message, style: style, duration: duration, position: position)
  }

  static public func info(
    _ message: String, duration: Double = 3.0, position: ToastPosition = .bottom
  ) {
    show(message, style: .info, duration: duration, position: position)
  }

  static public func success(
    _ message: String, duration: Double = 3.0, position: ToastPosition = .bottom
  ) {
    show(message, style: .success, duration: duration, position: position)
  }

  static public func warning(
    _ message: String, duration: Double = 3.0, position: ToastPosition = .bottom
  ) {
    show(message, style: .warning, duration: duration, position: position)
  }

  static public func error(
    _ message: String, duration: Double = 3.0, position: ToastPosition = .bottom
  ) {
    show(message, style: .error, duration: duration, position: position)
  }
}

