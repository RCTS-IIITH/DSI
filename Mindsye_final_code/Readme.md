
This project includes both **Node.js backend** and **Flutter frontend** code. It uses MongoDB for the database and integrates with **Twilio** for OTP functionality.

---

## 🚀 Backend Setup (Node.js)

### Prerequisites:
- Node.js and npm installed
- MongoDB Atlas or local instance

### Steps:
1. Install dependencies:

   ```bash
   npm install

### Set up your environment:

Rename .env.example to .env (if applicable)
 
### Add the necessary variables like:

1. PORT

2. MONGO_URI


### Start the backend server:
npm start

💡Frontend Setup (Flutter)
### Prerequisites:
-- Flutter SDK installed

-- Android Studio / VS Code with Flutter extension

### Steps:
Get dependencies and run the app:
 flutter pub get
 flutter run


### Configure Twilio credentials:

### Open lib/sendotp.dart and update the following:


const String accountSid = '<YOUR_ACCOUNT_SID>';      // Replace with your Twilio Account SID
const String authToken = '<YOUR_AUTH_TOKEN>';        // Replace with your Twilio Auth Token
const String twilioNumber = '+91XXXXXXXXXX';         // Replace with your Twilio phone number
### 📦 Tech Stack
-- Flutter (Frontend)

-- Node.js + Express (Backend)

-- MongoDB (Database)

-- Twilio API (SMS/OTP)

### 🛠️ Developer Notes
Ensure backend server is running before using the app.

Use real phone numbers for Twilio to work in live environments.

Check .env and sendotp.dart for credentials setup.