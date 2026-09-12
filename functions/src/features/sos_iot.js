
import { onRequest } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';
import { db, messaging } from '../config/firebase.js';

export const triggerSosAlert = onRequest(
  {
    region: 'asia-southeast1',
    cors: true,
    invoker: 'public',
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method Not Allowed' });
      return;
    }

    const { deviceId, batteryLevel } = req.body || {};
    if (!deviceId) {
      res.status(400).json({ error: 'Missing required field: deviceId' });
      return;
    }

    try {
      const deviceRef = db.collection('sos_devices').doc(deviceId);
      const deviceDoc = await deviceRef.get();

      if (!deviceDoc.exists) {
        res.status(404).json({ error: `Device '${deviceId}' not found` });
        return;
      }

      const deviceData = deviceDoc.data() || {};
      const recipientIds = deviceData.recipientIds || [];

      if (!Array.isArray(recipientIds) || recipientIds.length === 0) {
        res.status(400).json({ error: 'No recipients registered for this device' });
        return;
      }

      const lastTriggered = deviceData.lastTriggeredAt?.toMillis() || 0;
      if (Date.now() - lastTriggered < 10000) {
        res.status(429).json({ warning: 'Rate limited: Alert already sent in last 10s' });
        return;
      }

      const effectiveBattery = batteryLevel ?? deviceData.batteryLevel ?? 100;

      const alertRef = await db.collection('sos_alerts').add({
        deviceId,
        deviceName: deviceData.deviceName || 'Nút SOS Khẩn Cấp',
        triggeredAt: FieldValue.serverTimestamp(),
        status: 'pending',
        batteryLevel: effectiveBattery,
      });

      await deviceRef.update({
        lastTriggeredAt: FieldValue.serverTimestamp(),
        batteryLevel: effectiveBattery,
        isOnline: true,
      });

      const tokens = [];
      const userQueries = recipientIds.slice(0, 3).map((uid) =>
        db.collection('users').doc(uid).get()
      );
      const userDocs = await Promise.all(userQueries);

      for (const uDoc of userDocs) {
        if (uDoc.exists) {
          const token = uDoc.data()?.fcmToken;
          if (token && typeof token === 'string') tokens.push(token);
        }
      }

      if (tokens.length === 0) {
        res.status(200).json({
          success: true,
          alertId: alertRef.id,
          message: 'Alert created, but no FCM tokens found',
        });
        return;
      }

      const pushResponse = await messaging.sendEachForMulticast({
        tokens,
        notification: {
          title: '🚨 BÁO ĐỘNG KHẨN CẤP SOS!',
          body: `${deviceData.deviceName || 'Thiết bị'} vừa được kích hoạt! Nhấn để xem ngay.`,
        },
        data: {
          type: 'SOS_ALERT',
          alertId: alertRef.id,
          deviceId: deviceId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'sos_emergency_v3', 
            sound: 'sos_sound',
            priority: 'max',
          },
        },
        apns: {
          payload: { aps: { sound: 'sos_sound.aiff', critical: true } },
        },
      });

      res.status(200).json({
        success: true,
        alertId: alertRef.id,
        sentCount: pushResponse.successCount,
      });
    } catch (err) {
      console.error('Lỗi SOS:', err);
      res.status(500).json({ error: 'Internal server error', details: err.message });
    }
  }
);
