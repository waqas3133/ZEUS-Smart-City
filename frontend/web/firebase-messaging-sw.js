// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's FirebaseConfig object.
firebase.initializeApp({
  apiKey: 'AIzaSyCQqdm4aCkVLpJjTfjYEmkMg2Rh5zbt4Sg',
  appId: '1:376711787348:web:f34a59549c19fafc290ec1',
  messagingSenderId: '376711787348',
  projectId: 'zeus-smart-city',
  authDomain: 'zeus-smart-city.firebaseapp.com',
  storageBucket: 'zeus-smart-city.firebasestorage.app',
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification ? payload.notification.title : 'ZEUS Smart City Alert';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : 'New emergency or weather update.',
    icon: '/favicon.png',
    data: payload.data
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
