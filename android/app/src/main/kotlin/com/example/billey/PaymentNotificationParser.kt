package com.billey.app

import java.math.BigDecimal

/** Same rules as WalletAmount in ios/Runner/ApplePayInbox.swift. */
object PaymentAmount {
    val currencies = listOf("COP", "USD", "EUR", "MXN", "BRL")

    // None of the supported currencies uses 3 decimals, so a separator followed
    // by exactly 3 digits is always grouping (18.900 = 18900, never 18.9).
    private val formats = listOf(
        Triple(Regex("^[0-9]+$"), "", ""),
        Triple(Regex("^[0-9]+[.,][0-9]{1,2}$"), "", ","),
        Triple(Regex("^[0-9]{1,3}(\\.[0-9]{3})+,[0-9]{1,2}$"), ".", ","),
        Triple(Regex("^[0-9]{1,3}(,[0-9]{3})+\\.[0-9]{1,2}$"), ",", "."),
        Triple(Regex("^[0-9]{1,3}(\\.[0-9]{3})+$"), ".", ""),
        Triple(Regex("^[0-9]{1,3}(,[0-9]{3})+$"), ",", ""),
    )
    private val prefix = Regex("^(?:[A-Z]{1,3}\\s*)?[$€]?\\s*")
    private val suffix = Regex("\\s*(?:[$€]|[A-Z]{3})$")
    private val max = BigDecimal("1000000000000")

    fun normalize(raw: String): String? {
        if (raw.length > 100) return null
        val value = raw.replace(' ', ' ').replace(' ', ' ').trim()
            .replace(prefix, "").replace(suffix, "")
        for ((pattern, grouping, decimal) in formats) {
            if (!pattern.matches(value)) continue
            var result = value
            if (grouping.isNotEmpty()) result = result.replace(grouping, "")
            if (decimal == ",") result = result.replace(",", ".")
            val number = result.toBigDecimalOrNull() ?: return null
            if (number.signum() <= 0 || number > max) return null
            return number.stripTrailingZeros().toPlainString()
        }
        return null
    }
}

data class ParsedPayment(val amount: String, val merchant: String?, val card: String?)

/**
 * Extracts card purchases from payment notifications. Only notifications that
 * clearly describe a purchase are accepted; anything else is ignored.
 */
object PaymentNotificationParser {
    const val GOOGLE_WALLET = "com.google.android.apps.walletnfcrel"
    private val bankApps = setOf(
        "com.todo1.mobile", // Bancolombia
        "com.bancolombia.personas",
    )
    // Bank SMS alerts arrive as notifications of the messaging app; READ_SMS is
    // never requested.
    private val messagingApps = setOf(
        "com.google.android.apps.messaging",
        "com.samsung.android.messaging",
        "com.android.mms",
    )
    val sources = setOf(GOOGLE_WALLET) + bankApps + messagingApps

    private const val MONEY = "(?:[A-Z]{1,3}\\s?)?[$€]\\s?\\d(?:[\\d.,]*\\d)?"
    private val money = Regex(MONEY)
    private val purchase = Regex(
        "(?i)\\b(?:compraste|compra(?:\\s+aprobada)?(?:\\s+por)?|pagaste|pago(?:\\s+por)?|you\\s+paid|purchase\\s+of)" +
            "\\s+($MONEY)\\s+(?:en|at)\\s+(.+?)(?=\\s+con\\s+tu\\b|\\s+with\\b|[,.](?:\\s|$)|$)"
    )
    private val bankCard = Regex("(?i)con\\s+tu\\s+([^,]*?\\*\\s?\\d{4})")
    private val walletCard = Regex("(?i)(?:con|with)\\s+(.*?[•*·]+\\s?\\d{4})")

    fun parse(packageName: String, title: String, text: String): ParsedPayment? {
        val title = clean(title)
        val text = clean(text)
        if (packageName == GOOGLE_WALLET) return parseWallet(title, text)
        if (packageName !in sources) return null
        val match = purchase.find(text) ?: purchase.find("$title $text") ?: return null
        val amount = PaymentAmount.normalize(match.groupValues[1]) ?: return null
        val merchant = match.groupValues[2].trim().take(200).ifEmpty { null }
        val card = bankCard.find(text)?.groupValues?.get(1)?.trim()?.take(80)
        return ParsedPayment(amount, merchant, card)
    }

    // Google Wallet: the title is the merchant and the text holds the amount,
    // optionally followed by the card ("$ 18.900 con Visa •••• 9929").
    private fun parseWallet(title: String, text: String): ParsedPayment? {
        val inText = money.find(text)
        val token = inText ?: money.find(title) ?: return null
        val amount = PaymentAmount.normalize(token.value) ?: return null
        val merchant = (if (inText != null) title else text.ifEmpty { title.replace(token.value, "") })
            .trim().take(200).ifEmpty { null }
        val card = walletCard.find(text)?.groupValues?.get(1)?.trim()?.take(80)
        return ParsedPayment(amount, merchant, card)
    }

    private fun clean(value: String) =
        value.replace(' ', ' ').replace(' ', ' ').replace(Regex("\\s+"), " ").trim()
}
