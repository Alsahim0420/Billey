import AppIntents
import Foundation

@available(iOS 16.0, *)
struct RegisterWalletExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar gasto en Billey"
    static var description = IntentDescription("Recibe un gasto desde Atajos en la bandeja local. Billey lo importa al abrirse. Requiere configurar la recepción en Billey.")
    static var openAppWhenRun: Bool = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @Parameter(title: "Monto", description: "Acepta el monto tal cual llega de la transacción ($ 18.900) o texto como 18900, 12.500,50 o 12,500.50.")
    var amount: String
    @Parameter(title: "Moneda ISO", description: "COP, USD, EUR, MXN o BRL. Configúrala explícitamente si la entrada no ofrece moneda.")
    var currency: String
    @Parameter(title: "Comercio") var merchant: String?
    @Parameter(title: "Fecha de compra", description: "Opcional. Si falta se usa la fecha de recepción, indicada en las notas.") var date: Date?
    @Parameter(title: "Alias de tarjeta", description: "Opcional. No envíes números completos ni códigos de seguridad.") var card: String?
    @Parameter(title: "Referencia del evento", description: "UUID opcional. Genera uno por pago y conserva el mismo en sus reintentos.") var eventID: String?
    @Parameter(title: "Es una prueba", default: false) var test: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Registrar \(\.$amount) \(\.$currency) en Billey") {
            \.$merchant
            \.$date
            \.$card
            \.$eventID
            \.$test
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let id = try ApplePayInbox.shared.receive(amount: amount, currency: currency, merchant: merchant, date: date, card: card, eventID: eventID, test: test)
        NotificationCenter.default.post(name: Notification.Name("BilleyWalletReceived"), object: nil)
        return .result(value: id, dialog: "Recibido en Billey. Se importará al abrir la app. Las pruebas no afectan tu saldo.")
    }
}
