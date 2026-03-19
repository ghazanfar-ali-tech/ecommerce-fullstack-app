const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");

const { initializeApp } = require("firebase-admin/app");

const { getFirestore } = require("firebase-admin/firestore");

const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();

// ─── Triggered when a new order is created ───────────────────────────────────

exports.onOrderPlaced = onDocumentCreated("orders/{userId}/userOrders/{orderId}", async (event) => {

  const order = event.data.data();

  const { userId } = event.params;

  // 1. Fetch the user's FCM token

  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) return;

  const fcmToken = userDoc.data() ? userDoc.data().fcmToken : null;

  if (!fcmToken) return;

  // 2. Build notification payload

  const itemCount = order.items ? order.items.length : 0;

  const total = order.totalAmount !== undefined ? order.totalAmount : 0;

  const orderId = order.orderId ? order.orderId : event.params.orderId;

  const message = {

    token: fcmToken,

    notification: {

      title: "🛍️ Order Placed Successfully!",

      body: `Your order ${orderId} (${itemCount} item${itemCount > 1 ? "s" : ""}) worth $${total} is confirmed.`,

    },

    data: {

      orderId: orderId,

      screen: "orders",               // Flutter uses this to navigate

      status: "active",

    },

    android: {

      notification: {

        channelId: "order_updates",

        priority: "high",

        color: "#E91E8C",

      },

    },

    apns: {

      payload: {

        aps: {

          sound: "default",

          badge: 1,

        },

      },

    },

  };

  await getMessaging().send(message);

  console.log(`[onOrderPlaced] Notification sent to user ${userId} for order ${orderId}`);

});

// ─── Triggered when order status changes (active → shipped → completed etc.) ─

exports.onOrderStatusChanged = onDocumentUpdated("orders/{userId}/userOrders/{orderId}", async (event) => {

  const before = event.data.before.data();

  const after  = event.data.after.data();

  // Only fire when status actually changes

  if (before.status === after.status) return;

  const { userId } = event.params;

  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) return;

  const fcmToken = userDoc.data()?.fcmToken;

  if (!fcmToken) return;

  const STATUS_MESSAGES = {

    shipped:   { title: "📦 Order Shipped!",     body: `Your order ${after.orderId} is on its way.` },

    delivered: { title: "✅ Order Delivered!",    body: `Your order ${after.orderId} has been delivered.` },

    completed: { title: "🎉 Order Completed!",    body: `Thanks for shopping! Order ${after.orderId} is complete.` },

    cancelled: { title: "❌ Order Cancelled",     body: `Your order ${after.orderId} has been cancelled.` },

  };

  const notif = STATUS_MESSAGES[after.status];

  if (!notif) return;  // Unknown status — skip

  const message = {

    token: fcmToken,

    notification: {

      title: notif.title,

      body:  notif.body,

    },

    data: {

      orderId: after.orderId,

      screen:  "orders",

      status:  after.status,

    },

    android: {

      notification: {

        channelId: "order_updates",

        priority: "high",

        color: "#E91E8C",

      },

    },

    apns: {

      payload: { aps: { sound: "default" } },

    },

  };

  await getMessaging().send(message);

  console.log(`[onOrderStatusChanged] Sent "${after.status}" notification → user ${userId}`);

});