package com.billey.app

import android.app.Notification
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import java.util.UUID

/** Lets a running Flutter engine import immediately after a receipt. */
object PaymentEvents {
    @Volatile var onReceived: (() -> Unit)? = null

    fun notifyReceived() {
        Handler(Looper.getMainLooper()).post { onReceived?.invoke() }
    }
}

/**
 * Reads only payment notifications from the apps listed in
 * PaymentNotificationParser.sources, and only while reception is enabled.
 * Everything else is ignored without being stored.
 */
class BilleyNotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName !in PaymentNotificationParser.sources) return
        val notification = sbn.notification ?: return
        if (notification.flags and Notification.FLAG_GROUP_SUMMARY != 0) return
        val extras = notification.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = (extras.getCharSequence(Notification.EXTRA_BIG_TEXT)
            ?: extras.getCharSequence(Notification.EXTRA_TEXT))?.toString().orEmpty()
        val payment = PaymentNotificationParser.parse(sbn.packageName, title, text) ?: return
        val inbox = PaymentInbox.get(this)
        try {
            if (!inbox.isReceiving()) return
            // Stable per notification, so updates of the same alert are not imported twice.
            val eventId = UUID.nameUUIDFromBytes("${sbn.packageName}|${sbn.key}|$title|$text".toByteArray()).toString()
            if (inbox.receive(payment, sbn.packageName, sbn.postTime, eventId)) PaymentEvents.notifyReceived()
        } catch (_: Exception) {
            // Never crash the listener; the purchase can still be added manually.
        }
    }
}
