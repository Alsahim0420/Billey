import Foundation
import Darwin

enum WalletImportError: LocalizedError {
    case invalid(String)
    var errorDescription: String? {
        if case let .invalid(message) = self { return message }
        return nil
    }
}

enum WalletAmount {
    static let currencies = ["COP", "USD", "EUR", "MXN", "BRL"]

    // No locale guessing: a single separator followed by 3 digits is ambiguous.
    static func normalize(_ raw: String) throws -> String {
        guard raw.count <= 100 else { throw WalletImportError.invalid("Monto demasiado largo.") }
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let formats = [
            (#"^[0-9]+$"#, "", ""),
            (#"^[0-9]+[.,][0-9]{1,2}$"#, "", ","),
            (#"^[0-9]{1,3}(\.[0-9]{3})+,[0-9]{1,2}$"#, ".", ","),
            (#"^[0-9]{1,3}(,[0-9]{3})+\.[0-9]{1,2}$"#, ",", "."),
            (#"^[0-9]{1,3}(\.[0-9]{3}){2,}$"#, ".", ""),
            (#"^[0-9]{1,3}(,[0-9]{3}){2,}$"#, ",", "")
        ]
        for (pattern, grouping, decimal) in formats where value.range(of: pattern, options: .regularExpression) != nil {
            var result = value
            if !grouping.isEmpty { result = result.replacingOccurrences(of: grouping, with: "") }
            if decimal == "," { result = result.replacingOccurrences(of: ",", with: ".") }
            guard let number = Decimal(string: result, locale: Locale(identifier: "en_US_POSIX")),
                  number > 0, number <= Decimal(1_000_000_000_000 as Int64) else { break }
            return NSDecimalNumber(decimal: number).stringValue
        }
        throw WalletImportError.invalid("Monto inválido o ambiguo. Usa 12500.50, 12.500,50 o 12,500.50, sin símbolo de moneda.")
    }
}

struct WalletEntry: Codable {
    let id: String
    let owner: String
    let amount: String
    let currency: String
    let merchant: String
    let date: Double
    let receivedAt: Double
    let dateIsReceipt: Bool
    let card: String?
    let test: Bool
}

private struct WalletInboxState: Codable {
    var version = 1
    var owner: String?
    var currency: String?
    var entries: [WalletEntry] = []
    // Receipts survive acknowledgment and deletion of the expense.
    var completed: [String] = []
    var lastReceived: [String: Double] = [:]
}

/// Independent of Flutter, Firebase and UserDefaults. All reads/writes are
/// serialized across processes; a failed decode never replaces existing data.
final class ApplePayInbox {
    static let shared = ApplePayInbox(directory: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("ApplePayInbox", isDirectory: true))
    private let directory: URL
    init(directory: URL) { self.directory = directory }

    private func access<T>(_ body: (inout WalletInboxState) throws -> T) throws -> T {
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        try fm.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directory.path)
        #if os(iOS)
        try fm.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: directory.path)
        #endif
        var excluded = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try excluded.setResourceValues(values)
        let fd = open(directory.appendingPathComponent("inbox.lock").path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard fd >= 0 else { throw WalletImportError.invalid("No se pudo abrir la bandeja. Desbloquea el iPhone e inténtalo de nuevo.") }
        defer { close(fd) }
        guard flock(fd, LOCK_EX) == 0 else { throw WalletImportError.invalid("Bandeja ocupada. Reintenta con la misma referencia de evento.") }
        defer { flock(fd, LOCK_UN) }
        let url = directory.appendingPathComponent("inbox.json")
        var state = fm.fileExists(atPath: url.path) ? try JSONDecoder().decode(WalletInboxState.self, from: Data(contentsOf: url)) : WalletInboxState()
        guard state.version == 1 else { throw WalletImportError.invalid("Actualiza Billey para leer esta bandeja.") }
        let result = try body(&state)
        let data = try JSONEncoder().encode(state)
        #if os(iOS)
        try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: url, options: .atomic)
        #endif
        try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
        let output = open(url.path, O_RDONLY)
        guard output >= 0 else { throw WalletImportError.invalid("No se pudo confirmar el guardado.") }
        defer { close(output) }
        guard fsync(output) == 0 else { throw WalletImportError.invalid("No se pudo confirmar el guardado. Reintenta con la misma referencia.") }
        return result
    }

    func configure(owner: String?, currency: String?) throws {
        try access { state in
            if let owner = owner, !owner.isEmpty, let currency = currency, WalletAmount.currencies.contains(currency) {
                state.owner = owner
                state.currency = currency
            } else {
                state.owner = nil
                state.currency = nil
            }
        }
    }

    func sessionChanged(owner: String?) throws {
        try access { state in
            if state.owner != owner { state.owner = nil; state.currency = nil }
        }
    }

    @discardableResult
    func receive(amount: String, currency: String, merchant: String?, date: Date?, card: String?, eventID: String?, test: Bool = false) throws -> String {
        let amount = try WalletAmount.normalize(amount)
        let currency = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard WalletAmount.currencies.contains(currency) else { throw WalletImportError.invalid("Indica una moneda admitida: COP, USD, EUR, MXN o BRL. No uses $ como código.") }
        let id: String
        if let supplied = eventID, !supplied.isEmpty {
            guard let uuid = UUID(uuidString: supplied) else { throw WalletImportError.invalid("La referencia del evento debe ser un UUID. Reutilízalo solo para reintentar el mismo pago.") }
            id = uuid.uuidString.lowercased()
        } else { id = UUID().uuidString.lowercased() }
        guard (merchant?.count ?? 0) <= 200, (card?.count ?? 0) <= 80 else { throw WalletImportError.invalid("Comercio o referencia de tarjeta demasiado largos. Usa un alias, nunca el número completo.") }
        let now = Date().timeIntervalSince1970
        if let date = date, date.timeIntervalSince1970 > now + 300 || date.timeIntervalSince1970 < 0 {
            throw WalletImportError.invalid("Fecha inválida. Omítela para usar la fecha de recepción.")
        }
        return try access { state in
            guard let owner = state.owner else { throw WalletImportError.invalid("Abre Billey y permite la recepción en Registrar compras con Apple Pay.") }
            guard state.currency == currency else { throw WalletImportError.invalid("La moneda no coincide con la configurada en Billey. No se convirtió ni registró el gasto.") }
            let key = owner + ":" + id
            if state.completed.contains(key) || state.entries.contains(where: { $0.owner == owner && $0.id == id }) { return id }
            guard state.entries.count < 500 else { throw WalletImportError.invalid("Bandeja llena. Abre Billey para importar los gastos pendientes.") }
            let title = merchant?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            state.entries.append(WalletEntry(id: id, owner: owner, amount: amount, currency: currency, merchant: title.isEmpty ? "Compra con Apple Pay" : title, date: date?.timeIntervalSince1970 ?? now, receivedAt: now, dateIsReceipt: date == nil, card: card, test: test))
            if !test { state.lastReceived[owner] = now }
            return id
        }
    }

    func snapshot(owner: String) throws -> [String: Any] {
        try access { state in
            let entries = state.entries.filter { $0.owner == owner }
            let data = try JSONEncoder().encode(entries)
            return ["entries": try JSONSerialization.jsonObject(with: data), "receiving": state.owner == owner, "lastReceived": state.lastReceived[owner] as Any? ?? NSNull(), "currency": state.owner == owner ? (state.currency as Any? ?? NSNull()) : NSNull()]
        }
    }

    func acknowledge(owner: String, id: String) throws {
        try access { state in
            guard state.entries.contains(where: { $0.owner == owner && $0.id == id }) else { return }
            state.entries.removeAll { $0.owner == owner && $0.id == id }
            state.completed.append(owner + ":" + id)
        }
    }
}
