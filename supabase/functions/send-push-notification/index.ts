import { createClient } from 'npm:@supabase/supabase-js@2.39.0';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

// دالة الحصول على Access Token من Firebase
async function getFirebaseAccessToken() {
  const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')!;
  const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')!;
  
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };
  
  const header = { alg: 'RS256', typ: 'JWT' };
  
  const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, '');
  const payloadB64 = btoa(JSON.stringify(payload)).replace(/=/g, '');
  const toSign = `${headerB64}.${payloadB64}`;
  
  // توقيع JWT (مبسط)
  const privateKeyPem = privateKey.replace(/\\n/g, '\n');
  const privateKeyBuffer = pemToBuffer(privateKeyPem);
  
  const key = await crypto.subtle.importKey(
    'pkcs8',
    privateKeyBuffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign(
    { name: 'RSASSA-PKCS1-v1_5' },
    key,
    new TextEncoder().encode(toSign)
  );
  
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
  
  const jwt = `${toSign}.${signatureB64}`;
  
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  
  const data = await response.json();
  return data.access_token;
}

function pemToBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\n/g, '')
    .replace(/\\n/g, '');
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

async function sendToDevice(fcmToken: string, notification: any) {
  try {
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID')!;
    const accessToken = await getFirebaseAccessToken();
    
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            data: {
              type: notification.type,
              notification_id: notification.id.toString(),
              post_id: notification.post_id?.toString() || '',
              comment_id: notification.comment_id?.toString() || '',
            },
            android: { priority: 'high' },
            apns: {
              payload: {
                aps: { sound: 'default' },
              },
            },
          },
        }),
      }
    );
    
    const result = await response.json();
    console.log('FCM Response:', result);
    return response.ok;
  } catch (error) {
    console.error('Error sending FCM:', error);
    return false;
  }
}

async function sendToUser(userId: string, notification: any) {
  const { data: devices, error } = await supabase
    .from('user_devices')
    .select('fcm_token')
    .eq('user_id', userId)
    .eq('is_active', true);
  
  if (error || !devices?.length) {
    console.log('No active devices for user:', userId);
    return;
  }
  
  await Promise.all(devices.map(d => sendToDevice(d.fcm_token, notification)));
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' },
    });
  }
  
  try {
    const { notification_id } = await req.json();
    
    const { data: notification, error } = await supabase
      .from('notifications')
      .select('*, profiles!actor_id(username)')
      .eq('id', notification_id)
      .single();
    
    if (error || !notification) {
      return new Response(JSON.stringify({ error: 'Notification not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      });
    }
    
    let title = '🔔 New Notification';
    let body = `${notification.profiles.username} interacted with you`;
    
    switch (notification.type) {
      case 'upvote':
        title = '⬆️ New Upvote!';
        body = `${notification.profiles.username} upvoted your post`;
        break;
      case 'downvote':
        title = '⬇️ New Downvote';
        body = `${notification.profiles.username} downvoted your post`;
        break;
      case 'comment':
        title = '💬 New Comment';
        body = `${notification.profiles.username} commented on your post`;
        break;
      case 'reply':
        title = '↩️ New Reply';
        body = `${notification.profiles.username} replied to your comment`;
        break;
      case 'follow':
        title = '👤 New Follower';
        body = `${notification.profiles.username} started following you`;
        break;
    }
    
    await sendToUser(notification.user_id, {
      id: notification.id,
      title,
      body,
      type: notification.type,
      post_id: notification.post_id,
      comment_id: notification.comment_id,
    });
    
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
    
  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
