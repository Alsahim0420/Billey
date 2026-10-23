import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var walletObserver: NSObjectProtocol?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
      let channel = FlutterMethodChannel(name: "billey/apple_pay", binaryMessenger: engineBridge.applicationRegistrar.messenger())
      walletObserver = NotificationCenter.default.addObserver(forName: Notification.Name("BilleyWalletReceived"), object: nil, queue: .main) { _ in
        channel.invokeMethod("received", arguments: nil)
      }
      channel.setMethodCallHandler { call, result in
        let args = call.arguments as? [String: Any] ?? [:]
        do {
          switch call.method {
          case "capabilities":
            if #available(iOS 17.0, *) { result(true) } else { result(false) }
          case "session":
            try ApplePayInbox.shared.sessionChanged(owner: args["owner"] as? String)
            result(nil)
          case "configure":
            try ApplePayInbox.shared.configure(owner: args["owner"] as? String, currency: args["currency"] as? String)
            result(nil)
          case "snapshot":
            guard let owner = args["owner"] as? String else { throw WalletImportError.invalid("Inicia sesión.") }
            result(try ApplePayInbox.shared.snapshot(owner: owner))
          case "acknowledge":
            guard let owner = args["owner"] as? String, let id = args["id"] as? String else { throw WalletImportError.invalid("Entrada inválida.") }
            try ApplePayInbox.shared.acknowledge(owner: owner, id: id)
            result(nil)
          case "test":
            guard let currency = args["currency"] as? String else { throw WalletImportError.invalid("Falta moneda.") }
            result(try ApplePayInbox.shared.receive(amount: "12500.50", currency: currency, merchant: "PRUEBA · Café Billey", date: nil, card: "Tarjeta de ejemplo", eventID: nil, test: true))
          default: result(FlutterMethodNotImplemented)
          }
        } catch {
          result(FlutterError(code: "APPLE_PAY_INBOX", message: error.localizedDescription, details: nil))
        }
      }
  }
}
