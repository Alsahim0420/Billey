package com.billey.app

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {
    // Same channel and protocol as the iOS inbox (AppDelegate.swift).
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "billey/apple_pay")
        PaymentEvents.onReceived = { channel.invokeMethod("received", null) }
        channel.setMethodCallHandler { call, result ->
            val inbox = PaymentInbox.get(this)
            try {
                when (call.method) {
                    "capabilities" -> result.success(true)
                    "permission" -> result.success(hasNotificationAccess())
                    "openPermissionSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    "session" -> { inbox.sessionChanged(call.argument<String>("owner")); result.success(null) }
                    "configure" -> {
                        inbox.configure(call.argument<String>("owner"), call.argument<String>("currency"))
                        result.success(null)
                    }
                    "snapshot" -> {
                        val owner = call.argument<String>("owner") ?: throw PaymentInboxException("Inicia sesión.")
                        result.success(inbox.snapshot(owner) + ("permission" to hasNotificationAccess()))
                    }
                    "acknowledge" -> {
                        val owner = call.argument<String>("owner")
                        val id = call.argument<String>("id")
                        if (owner == null || id == null) throw PaymentInboxException("Entrada inválida.")
                        inbox.acknowledge(owner, id)
                        result.success(null)
                    }
                    "test" -> {
                        val id = UUID.randomUUID().toString()
                        inbox.receive(
                            ParsedPayment("12500.5", "PRUEBA · Café Billey", "Tarjeta de ejemplo"),
                            "test", System.currentTimeMillis(), id, test = true,
                        )
                        result.success(id)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("PAYMENT_INBOX", e.message ?: "Error en la bandeja de pagos.", null)
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        PaymentEvents.onReceived = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun hasNotificationAccess(): Boolean {
        val enabled = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: return false
        val component = ComponentName(this, BilleyNotificationListener::class.java)
        return enabled.split(':').mapNotNull(ComponentName::unflattenFromString).any { it == component }
    }
}
