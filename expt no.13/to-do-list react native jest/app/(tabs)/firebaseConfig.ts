// firebaseConfig.ts
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";


const firebaseConfig = {
  apiKey: "AIzaSyCv3u9Iw33YkuZh0Ssrt2wQm1P4Fm86eSk",
  authDomain: "todofirestore-8b9d0.firebaseapp.com",
  projectId: "todofirestore-8b9d0",
  storageBucket: "todofirestore-8b9d0.firebasestorage.app",
  messagingSenderId: "496806525271",
  appId: "1:496806525271:web:c29980b6af7bf60c6c6612",
  measurementId: "G-09SNJHS3ZF"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
