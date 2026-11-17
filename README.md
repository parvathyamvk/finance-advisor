<div align="center">

# 💰 Finance Advisor

### A Flutter-based personal finance app to track expenses, manage budgets, and understand spending habits.

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Cloud_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Cloud Firestore">
</p>

</div>

---

## 🌟 About the Project

**Finance Advisor** is a personal finance management application developed using **Flutter and Firebase**. It helps users record daily expenses, set monthly and category-wise budgets, review spending patterns, and monitor savings.

The app includes user authentication, a dashboard, expense history, analytics, a rewards page, and separate admin screens for managing users and expense categories.

## ✨ Features

- 🔐 **User authentication** – Sign up and log in using Firebase Authentication.
- 📊 **Finance dashboard** – View monthly budget and expense information.
- 💸 **Expense tracking** – Add expenses with amount, category, note, date, and detected location.
- 🗂️ **Expense categories** – Organise expenses such as Food, Travel, Shopping, Snacks, Bills, Health, Entertainment, and Others.
- 🎯 **Monthly budget** – Set and monitor a monthly budget.
- 📌 **Category-wise budgets** – Set spending limits for selected expense categories.
- 📈 **Analytics** – Review monthly spending with charts and category summaries.
- 🧾 **Expense history** – View recorded expenses for a selected month.
- ⚠️ **Spending insight** – Show a warning when a new expense is much higher than the average for that category.
- 🏅 **Rewards** – Display a monthly saver badge based on the budget and spending difference.
- 🛡️ **Admin section** – Separate admin login and screens for user management, category management, and statistics.
- 📍 **Location support** – Uses Geolocator and Geocoding to identify a readable location when adding an expense.

## 🛠️ Built With

<p>
  <img src="https://skillicons.dev/icons?i=flutter,dart,firebase" alt="Flutter, Dart and Firebase">
</p>

| Technology / Package | Purpose |
|---|---|
| Flutter | Cross-platform application UI |
| Dart | Application programming language |
| Firebase Authentication | User sign-up and login |
| Cloud Firestore | Store user, budget, and expense data |
| `fl_chart` | Display financial charts |
| `geolocator` | Retrieve device location |
| `geocoding` | Convert coordinates into readable place information |

## 📱 Application Sections

| Screen | Description |
|---|---|
| Login | Sign in to an existing account |
| Sign Up | Create a user account |
| Dashboard | View budget and expense summaries |
| Add Expense | Record an expense with category, date, note, and location |
| Expense History | Browse recorded expenses |
| Category Budgets | Set and view category spending limits |
| Analytics | View monthly expense insights and charts |
| Rewards | View the monthly saver badge |
| Admin Login | Access the admin area |
| Admin Dashboard | Navigate to admin tools |
| Admin Users | View and manage user records |
| Admin Categories | Manage expense categories |
| Admin Statistics | View application statistics |

## 📁 Project Structure

```text
finance-advisor/
│
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── signup_page.dart
│   │   ├── dashboard_page.dart
│   │   ├── add_expense_page.dart
│   │   ├── expense_history_page.dart
│   │   ├── category_budget_page.dart
│   │   ├── analytics_page.dart
│   │   ├── rewards_page.dart
│   │   ├── admin_login_page.dart
│   │   ├── admin_dashboard.dart
│   │   ├── admin_users_page.dart
│   │   ├── admin_category_page.dart
│   │   └── admin_stats_page.dart
│   │
│   └── services/
│       ├── auth_service.dart
│       └── firestore_service.dart
│
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── firebase.json            # Firebase configuration
├── pubspec.yaml             # Flutter dependencies
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (compatible with the Dart SDK constraint in `pubspec.yaml`)
- Android Studio or Visual Studio Code
- Android emulator or a physical device
- A Firebase project configured for the platforms you want to run

### 1. Clone the repository

```bash
git clone https://github.com/parvathyamvk/finance-advisor.git
cd finance-advisor
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The project uses Firebase Authentication and Cloud Firestore.

- Configure your Firebase project for the target platform.
- Ensure the Firebase app configuration matches the project.
- Review `lib/firebase_options.dart` and the platform-specific Firebase configuration files before running.

### 4. Run the application

```bash
flutter run
```

## 🔥 Firebase Services

The application uses:

- **Firebase Authentication** for user authentication.
- **Cloud Firestore** for storing and retrieving application data.

The Firestore service works with collections including `budgets`, `expenses`, `recurring_expenses`, and `category_budgets`. User and admin-related screens also read user records from the `users` collection.

## ⚙️ Permissions

The expense entry screen requests location permission to obtain the device's current location and convert it into a readable place name. Location access depends on the permission being granted and the device's location services being available.

## 🌐 Live Demo

Try the deployed web version:

<div align="center">

[![Open Finance Advisor](https://img.shields.io/badge/OPEN_FINANCE_ADVISOR-02569B?style=for-the-badge&logo=firebase&logoColor=white)](https://finance-advisor-stable.web.app/)

[https://finance-advisor-stable.web.app/](https://finance-advisor-stable.web.app/)

</div>

The project is also designed to run as a Flutter application on a supported emulator or device.

## 👩‍💻 Author

**Parvathy A**

[![GitHub](https://img.shields.io/badge/GitHub-parvathyamvk-181717?style=for-the-badge&logo=github)](https://github.com/parvathyamvk)

---

<div align="center">

**Made with ❤️ using Flutter and Firebase.**

</div>
