# Mindsye Frontend (Flutter App)

## Overview
This is the Flutter frontend for the Mindsye Exam App. It provides dashboards and workflows for NGO Admins, Professionals, School Admins, Parents, and Teachers to manage, submit, and analyze mental health reports for children.

---

## Key Features
- Multi-role login (NGO Admin, Professional, School Admin, Parent, Teacher)
- Dashboards for each role
- Report submission (drawing capture, questionnaire, image upload)
- Per-school and personal (clinic) analytics for professionals
- Manual and model scoring
- Profile editing
- School and professional assignment flows
- Data persistence using SharedPreferences

---

## Main Screens & Flows

### Login & Registration
- Role-based login (phone number)
- NGO Admin can create Professional and School accounts
- Professional creation includes clinic name

### Dashboards
- **NGO Admin:**
  - View assigned schools, submissions summary, create/assign users
  - Edit profile
- **Professional:**
  - View per-school and personal submission counts
  - Submit reports (clinic/personal or for assigned schools)
  - Edit profile
- **School Admin/Teacher/Parent:**
  - View and submit reports for assigned children
  - View submission status
  - Edit profile

### Report Submission
- Drawing capture and upload
- Questionnaire (House, Person, Tree)
- For professionals: clinic name auto-filled from profile
- For parents/teachers: select child and school
- Data sent to backend via REST API

### Analytics & Filtering
- Filter reports by school, score, age, date, manual/model label
- View detailed report and manual scoring

### Profile Editing
- Edit name, phone, email, address (fields vary by role)
- Updates saved to backend and local storage

---

## Data Flow & Persistence
- **API Calls:** Uses `http` package to communicate with backend endpoints
- **Shared Preferences:**
  - Stores user details (role, phone, name, clinicName, etc.)
  - Stores selected child details for parent/teacher flows
- **State Management:**
  - Mostly local state in widgets; some screens use `setState` and controllers

---

## Known Issues & Areas for Improvement

- **Professional Name/Clinic Name:**
  - Ensure name and clinicName are always saved and loaded from shared preferences after login/registration.
  - If missing, dashboard may show "Welcome Unknown".
- **Profile Editing:**
  - Only show/edit fields that exist for the current role.
  - Some fields (workEmail, Address, class) are not present for all roles.
- **Report Submission Refresh:**
  - After submitting a report, dashboard counts may not refresh until logout/login. Use `Navigator.pop` with result and refresh on return.
- **Legacy Data:**
  - Some old reports may have missing or inconsistent fields (e.g., schoolId as empty string).
- **Error Handling:**
  - Improve error messages and validation for all forms and API calls.
- **UI Consistency:**
  - Some screens use different styles for cards, lists, and buttons.
- **Testing:**
  - Add more widget and integration tests.

---

## Features to Implement or Improve
- **Clinic Name Auto-fill:**
  - Always auto-fill clinic name for professionals from profile.
- **Profile Editing:**
  - Allow professionals to edit their clinic name (if needed).
- **Submission Analytics:**
  - Add more charts and trends (per child, per class, per date range).
- **Role-based UI:**
  - Hide/show features based on user role.
- **Data Refresh:**
  - Automatically refresh dashboard after report submission.
- **Error Handling:**
  - Show user-friendly error messages for all API/network failures.

---

## Setup Instructions

1. Install Flutter and dependencies:
   ```bash
   flutter pub get
   ```
2. Set up your `.env` file with the backend URL (if using `flutter_dotenv`).
3. Run the app:
   ```bash
   flutter run
   ```
4. The app expects the backend to be running at the URL specified in `.env` or hardcoded in the code.

---

## Integration Notes
- The app expects backend API responses to include fields like `clinicName`, `schoolName`, `manualScore`, etc.
- If you change backend models or endpoints, update the frontend accordingly.
- Keep API response formats consistent for smooth integration.

---

## Contact
For questions or issues, contact the frontend maintainer or open an issue in the project repository. 