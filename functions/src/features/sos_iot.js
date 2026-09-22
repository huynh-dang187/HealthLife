
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

      const data = {
        type: 'sos_alert',
        alertId: alertRef.id,
        deviceId: deviceId,
        deviceName: deviceData.deviceName || 'Nút SOS Khẩn Cấp',
        batteryLevel: String(effectiveBattery),
        triggeredAt: new Date().toISOString(),
      };

      if (deviceData.emergencyPhone != null) {
        data.emergencyPhone = String(deviceData.emergencyPhone);
      }
      if (typeof deviceData.latitude === 'number' && !Number.isNaN(deviceData.latitude)) {
        data.latitude = String(deviceData.latitude);
      }
      if (typeof deviceData.longitude === 'number' && !Number.isNaN(deviceData.longitude)) {
        data.longitude = String(deviceData.longitude);
      }

      const pushResponse = await messaging.sendEachForMulticast({
        tokens,
        data,
        android: { priority: 'high' },
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
