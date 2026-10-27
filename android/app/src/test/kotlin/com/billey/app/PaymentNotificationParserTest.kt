package com.billey.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class PaymentNotificationParserTest {
    @Test
    fun amounts() {
        mapOf(
            "$ 18.900" to "18900", "$18.900,00" to "18900", "$ 18.900" to "18900",
            "COP 18.900" to "18900", "12.500" to "12500", "12,500.50" to "12500.5",
            "US$12.50" to "12.5", "R$ 1.234,56" to "1234.56", "1.234.567" to "1234567",
        ).forEach { (raw, expected) -> assertEquals(raw, expected, PaymentAmount.normalize(raw)) }
        listOf("", "0", "-12", "$", "1,23,4", "1.234,567", "1e3", "1000000000001")
            .forEach { assertNull(it, PaymentAmount.normalize(it)) }
    }

    @Test
    fun bancolombiaSms() {
        val p = PaymentNotificationParser.parse(
            "com.google.android.apps.messaging", "85540",
            "Bancolombia: Compraste \$18.900,00 en R61 CREPESYWAFFLES E con tu T.Deb *9929, el 26/10/2026 a las 18:33. Si tienes dudas, encuentranos aqui: 6045109095",
        )!!
        assertEquals("18900", p.amount)
        assertEquals("R61 CREPESYWAFFLES E", p.merchant)
        assertEquals("T.Deb *9929", p.card)
    }

    @Test
    fun googleWallet() {
        val p = PaymentNotificationParser.parse(
            PaymentNotificationParser.GOOGLE_WALLET, "R61 Crepesywaffles Eco. Mosquera", "$ 18.900 con Visa •••• 9929",
        )!!
        assertEquals("18900", p.amount)
        assertEquals("R61 Crepesywaffles Eco. Mosquera", p.merchant)
        assertEquals("Visa •••• 9929", p.card)
    }

    @Test
    fun ignoresNonPurchases() {
        assertNull(PaymentNotificationParser.parse("com.google.android.apps.messaging", "Mamá", "Te mando \$20.000 mañana"))
        assertNull(PaymentNotificationParser.parse(PaymentNotificationParser.GOOGLE_WALLET, "Tarjeta lista", "Ya puedes pagar con tu teléfono"))
        assertNull(PaymentNotificationParser.parse("com.whatsapp", "Banco", "Compraste \$10.000 en Tienda"))
    }
}
