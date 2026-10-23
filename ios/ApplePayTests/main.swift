// Portable native inbox tests; compile with ApplePayInbox.swift (no Flutter).
import Foundation
import Dispatch

func check(_ condition: @autoclosure () throws -> Bool, _ message: String) {
    precondition(try! condition(), message)
}
func rejects(_ body: () throws -> Void) {
    do { try body(); fatalError("Expected rejection") } catch { }
}
let directory = FileManager.default.temporaryDirectory.appendingPathComponent("billey-inbox-tests-" + UUID().uuidString)
defer { try? FileManager.default.removeItem(at: directory) }
let inbox = ApplePayInbox(directory: directory)
for raw in ["12.500,50", "12,500.50", "12500.50", "12500,50"] {
    check(try! WalletAmount.normalize(raw) == "12500.5", "Locale amount: " + raw)
}
for raw in ["", "0", "-12", "NaN", "Infinity", "$12", "12.500", "12,500", "1,23,4", "1.234,567", "1000000000001", "1e3"] {
    rejects { _ = try WalletAmount.normalize(raw) }
}
check(try! WalletAmount.normalize("1.234.567") == "1234567", "Grouped integer")
rejects { _ = try inbox.receive(amount: "12", currency: "COP", merchant: nil, date: nil, card: nil, eventID: nil) }
try inbox.configure(owner: "account-a", currency: "COP")
rejects { _ = try inbox.receive(amount: "12", currency: "$", merchant: nil, date: nil, card: nil, eventID: nil) }
rejects { _ = try inbox.receive(amount: "12", currency: "USD", merchant: nil, date: nil, card: nil, eventID: nil) }
rejects { _ = try inbox.receive(amount: "12", currency: "COP", merchant: nil, date: Date().addingTimeInterval(600), card: nil, eventID: nil) }
let id = UUID().uuidString
func receive(_ id: String?) throws -> String {
    try inbox.receive(amount: "12.500,50", currency: "COP", merchant: "Café", date: nil, card: "Alias", eventID: id)
}
let received = try receive(id)
check(try receive(id) == received, "Stable retry")
let reopened = ApplePayInbox(directory: directory)
func entries(_ store: ApplePayInbox, _ owner: String = "account-a") throws -> [[String: Any]] {
    try store.snapshot(owner: owner)["entries"] as! [[String: Any]]
}
check(try entries(reopened).count == 1, "Survives restart")
try reopened.acknowledge(owner: "account-b", id: received)
check(try entries(reopened).count == 1, "Wrong account cannot ack")
try reopened.acknowledge(owner: "account-a", id: received)
_ = try receive(id)
check(try entries(reopened).isEmpty, "Acknowledged retry stays completed")
_ = try receive(nil)
_ = try receive(nil)
check(try entries(reopened).count == 2, "Same amount is not a duplicate")
DispatchQueue.concurrentPerform(iterations: 40) { _ in _ = try! receive(nil) }
check(try entries(reopened).count == 42, "Concurrent writes must not be lost")
check(try entries(reopened, "account-b").isEmpty, "Account isolation")
try inbox.sessionChanged(owner: "account-b")
rejects { _ = try receive(nil) }
try inbox.configure(owner: "account-b", currency: "USD")
_ = try inbox.receive(amount: "12.50", currency: "USD", merchant: nil, date: nil, card: nil, eventID: nil, test: true)
check(try inbox.snapshot(owner: "account-b")["lastReceived"] is NSNull, "Test must not change real receipt time")
let before = try Data(contentsOf: directory.appendingPathComponent("inbox.json"))
try Data("broken".utf8).write(to: directory.appendingPathComponent("inbox.json"))
rejects { try inbox.configure(owner: "account-c", currency: "COP") }
check(try Data(contentsOf: directory.appendingPathComponent("inbox.json")) == Data("broken".utf8), "Corruption must not silently reset inbox")
try before.write(to: directory.appendingPathComponent("inbox.json"))
check(try entries(reopened).count == 42, "Pending entries survive account changes")
print("Native inbox: amount validation, restart, retry, acknowledgment, concurrency, account isolation and corruption checks passed.")
