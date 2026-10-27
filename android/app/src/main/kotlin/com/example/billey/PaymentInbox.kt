package com.billey.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.util.UUID

class PaymentInboxException(message: String) : Exception(message)

/**
 * Android counterpart of ApplePayInbox.swift, using the same snapshot shape so
 * the Flutter importer is shared. Lives in app-private storage; a failed
 * decode never replaces existing data.
 */
class PaymentInbox private constructor(private val file: File) {
    companion object {
        private const val DUPLICATE_WINDOW_MS = 10 * 60 * 1000L
        @Volatile private var instance: PaymentInbox? = null

        fun get(context: Context): PaymentInbox = instance ?: synchronized(this) {
            instance ?: PaymentInbox(
                File(File(context.applicationContext.filesDir, "payment_inbox").apply { mkdirs() }, "inbox.json")
            ).also { instance = it }
        }
    }

    private fun <T> access(body: (JSONObject) -> T): T = synchronized(this) {
        val state = if (file.exists()) {
            try { JSONObject(file.readText()) } catch (e: Exception) {
                throw PaymentInboxException("No se pudo leer la bandeja de pagos. No se modificó.")
            }
        } else JSONObject().put("version", 1)
        if (state.optInt("version") != 1) throw PaymentInboxException("Actualiza Billey para leer esta bandeja.")
        val result = body(state)
        val tmp = File(file.parentFile, "inbox.json.tmp")
        tmp.writeText(state.toString())
        if (!tmp.renameTo(file)) throw PaymentInboxException("No se pudo guardar la bandeja de pagos.")
        result
    }

    private fun JSONObject.array(name: String): JSONArray =
        optJSONArray(name) ?: JSONArray().also { put(name, it) }

    fun configure(owner: String?, currency: String?) = access { state ->
        if (!owner.isNullOrEmpty() && currency in PaymentAmount.currencies) {
            state.put("owner", owner).put("currency", currency)
        } else {
            state.remove("owner"); state.remove("currency")
        }
    }

    fun sessionChanged(owner: String?) = access { state ->
        if (state.optString("owner", "") != owner) { state.remove("owner"); state.remove("currency") }
    }

    fun isReceiving(): Boolean = access { it.has("owner") }

    /** Returns false when the payment was already received (same event or the
     * same purchase announced by another app, e.g. Wallet and the bank SMS). */
    fun receive(payment: ParsedPayment, source: String, postedAt: Long, eventId: String, test: Boolean = false): Boolean =
        access { state ->
            val owner = state.optString("owner", "").ifEmpty {
                throw PaymentInboxException("Activa la recepción en Billey.")
            }
            val currency = state.getString("currency")
            val id = UUID.fromString(eventId).toString().lowercase()
            val key = "$owner:$id"
            val entries = state.array("entries")
            val completed = state.array("completed")
            if ((0 until completed.length()).any { completed.getString(it) == key }) return@access false
            if ((0 until entries.length()).any { entries.getJSONObject(it).getString("id") == id }) return@access false
            val now = System.currentTimeMillis()
            val recent = state.array("recent")
            val kept = JSONArray()
            var duplicate = false
            for (i in 0 until recent.length()) {
                val r = recent.getJSONObject(i)
                if (now - r.getLong("at") > DUPLICATE_WINDOW_MS) continue
                kept.put(r)
                if (!test && r.getString("owner") == owner && r.getString("amount") == payment.amount &&
                    r.getString("source") != source) duplicate = true
            }
            state.put("recent", kept)
            if (duplicate) return@access false
            if (entries.length() >= 500) throw PaymentInboxException("Bandeja llena. Abre Billey para importar los gastos pendientes.")
            entries.put(
                JSONObject()
                    .put("id", id).put("owner", owner).put("amount", payment.amount).put("currency", currency)
                    .put("merchant", payment.merchant ?: "Compra con tarjeta")
                    .put("date", postedAt / 1000.0).put("receivedAt", now / 1000.0)
                    .put("dateIsReceipt", false).put("card", payment.card ?: JSONObject.NULL)
                    .put("test", test).put("source", "android_notification")
            )
            if (!test) {
                kept.put(JSONObject().put("owner", owner).put("amount", payment.amount).put("source", source).put("at", now))
                state.put("lastReceived_$owner", now / 1000.0)
            }
            true
        }

    fun snapshot(owner: String): Map<String, Any?> = access { state ->
        val entries = state.array("entries")
        val list = (0 until entries.length()).map { entries.getJSONObject(it) }
            .filter { it.getString("owner") == owner }
            .map { e -> e.keys().asSequence().associateWith { k -> e.get(k).takeUnless { it == JSONObject.NULL } } }
        val receiving = state.optString("owner", "") == owner
        mapOf(
            "entries" to list,
            "receiving" to receiving,
            "lastReceived" to (if (state.has("lastReceived_$owner")) state.getDouble("lastReceived_$owner") else null),
            "currency" to (if (receiving) state.optString("currency", "").ifEmpty { null } else null),
        )
    }

    fun acknowledge(owner: String, id: String) = access { state ->
        val entries = state.array("entries")
        val remaining = JSONArray()
        var found = false
        for (i in 0 until entries.length()) {
            val e = entries.getJSONObject(i)
            if (e.getString("owner") == owner && e.getString("id") == id) found = true else remaining.put(e)
        }
        if (!found) return@access
        state.put("entries", remaining)
        val completed = state.array("completed")
        completed.put("$owner:$id")
        // Receipts only need to outlive retries of the same notification.
        while (completed.length() > 2000) completed.remove(0)
    }
}
