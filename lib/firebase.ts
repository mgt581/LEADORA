import { getApp, getApps, initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: 'AIzaSyDPqyqjdmbLaOr7x4MWQA9eYvgc5jT0F_I',
  authDomain: 'leadora-7b691.firebaseapp.com',
  projectId: 'leadora-7b691',
  storageBucket: 'leadora-7b691.firebasestorage.app',
  messagingSenderId: '818522168136',
  appId: '1:818522168136:web:6e0b79961bcfe42955317d',
  measurementId: 'G-NT7ZEG0T9L',
};

const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
export const firebaseAuth = getAuth(app);
