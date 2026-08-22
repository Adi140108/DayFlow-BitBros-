# Dayflow — Enterprise Human Resource Management System (HRMS)

> **Every workday, perfectly aligned.**

Dayflow is a modern, production-grade **Human Resource Management System (HRMS)** engineered with **Flutter Web** and **Firebase**. It provides an intuitive, highly secure, and unified workspace for educational institutes, corporate enterprises, and organizations to seamlessly manage employee lifecycles, attendance, leaves, payroll processing, and operational reporting.

---

## 🌟 Key Features & Functional Modules

### 1. 🔐 Job-Specific Multi-Level Authentication & Authorization
- **Role-Based Access Control (RBAC)**: Fine-grained permissions across three primary tiers:
  - **Institute / Organization Admin**: Full organizational control, workforce policies, administrative settings, and department governance.
  - **HR Manager / HR Officer**: Employee lifecycle management, specific shift timing configuration, leave approvals with comments, payroll calculation, and report exports.
  - **Employee**: Self-service portal for profile viewing/editing, daily check-in/check-out, leave applications, personal attendance history, and monthly payslips.
- **Multi-Level Enforcement**:
  - **Navigation Level**: Dynamic sidebar menu displaying only role-authorized modules.
  - **Route Guards**: `GoRouter` redirection preventing unauthorized manual URL navigation.
  - **Database Security**: Firestore Security Rules enforcing strict tenancy and field-level permissions.

### 2. 👤 Comprehensive Employee Lifecycle Management
- **Full Field Editing**: Authorized administrators can update every employee data attribute:
  - *Personal Information*: Full Name, Display Name, Work Email, Phone, Date of Birth, Gender, Address, Emergency Contact, Profile Photo URL.
  - *Job Details*: Employee ID, Department, Designation, Work Location, Reporting Manager, Date of Joining, Employment Type (Full Time, Part Time, Contract, Intern), and Status (Active, Onboarding, Suspended, Exited).
- **Self-Service Updates**: Employees can update personal contact details, residential addresses, and avatars independently.
- **Sequential Employee ID Generation**: Atomic transaction-backed ID allocation (e.g. `EMP-001`, `EMP-002`).

### 3. 📂 Employee Document Management (End-to-End)
- **Document Categories**: Identity Verification, Educational Certificates, Experience Letters, Contracts & Offer Letters, Tax Documents, and Certifications.
- **Document Actions**:
  - **Upload Modal**: Upload document metadata with validation, content-type detection, and simulated Backblaze B2 secure keys.
  - **Preview Modal**: View document details, encryption status, and metadata.
  - **Browser Download**: Direct in-browser downloading of document files via universal web file handlers.
  - **Deletion**: Secure removal with confirmation dialogs.

### 4. ⏱️ Attendance Engine & Specific Work Timing Configuration
- **Specific Timing Configuration (Institute / HR)**:
  - Define custom shift start and end times (e.g., `08:30` to `16:30`).
  - Configure allowed grace periods (e.g., 15 minutes).
  - Toggle overnight / cross-midnight shifts.
  - Set active default organizational schedules dynamically.
- **Deterministic Metric Engine**:
  - Automatically calculates worked minutes, late arrival flags, early departure minutes, overtime hours, and attendance statuses (`Present`, `Half-day`, `Absent`).
- **Correction Requests**: Employees can submit attendance correction requests with justifications; HR reviews and approves/rejects with a single click.

### 5. 🏖️ Leave & Time-Off Management
- **Leave Types**: Paid Annual Leave, Sick Leave, and Unpaid Leave.
- **Balance Tracking**: Real-time leave balance computation and policy checks.
- **Review Workflow**: HR review modal with custom comment submission upon approving or rejecting leave applications.

### 6. 💰 Payroll Processing & Payslip Statements
- **Automated Salary Calculation**:
  - Computes earnings (*Basic Salary*, *House Rent Allowance*, *Overtime Pay* derived from attendance logs).
  - Computes deductions (*Provident Fund*, *Prorated Unpaid Leave Deductions*).
- **Pay Period Workflow**: Create pay periods, run batch payroll calculation across active employees, and publish payslips.
- **Payslip Statements**: Employees can view compensation summaries and trigger instant browser downloads of their published payslips.

### 7. 📊 Reports & Real Browser CSV Exports
- **Employee Directory CSV**: Exports full workforce roster with complete contact and organizational fields.
- **Attendance Records Log CSV**: Exports attendance history, check-in/out timestamps, overtime, and punctuality flags.
- **Workforce Operational Metrics CSV**: Exports aggregate organization headcount and operational statistics.
- **Direct Web File Download**: Utilizes native Blob + Anchor element mechanics to trigger immediate browser downloads.

### 8. 🔔 Real-Time Notification Center
- Integrated topbar notification bell displaying published payslips, leave approval decisions, and operational alerts.

---

## 🛠️ Technology Stack

| Layer | Technology | Description |
|---|---|---|
| **Frontend Framework** | **Flutter Web 3.x (Dart 3.x)** | Cross-platform, responsive UI targeting desktop, tablet, and mobile browsers |
| **State Management** | **Flutter Riverpod (`^3.3.2`)** | Reactive, testable, and modular dependency injection and state management |
| **Navigation & Routing** | **GoRouter (`^14.8.1`)** | Declarative URL routing with asynchronous authentication and role guards |
| **Backend & Database** | **Google Firebase** | Cloud Firestore (NoSQL), Firebase Authentication, Cloud Functions |
| **Security & Config** | **`flutter_dotenv` (`^6.0.1`)** | Runtime environment variable isolation decoupling secrets from source code |
| **Typography & Theme** | **Google Fonts (Inter)** | Clean corporate design system with responsive light and dark theme palettes |
| **Storage Architecture** | **Backblaze B2 & Cloudinary** | Scalable object storage for employee verification documents and profile avatars |

---

## 📁 Architecture & Codebase Structure

```text
lib/
├── core/
│   ├── analytics/          # Workforce metrics, attendance & payroll aggregations
│   ├── attendance/         # Shift models, attendance engine, and schedule repository
│   ├── auth/               # AppUser, roles, permissions policy, and auth notifier
│   ├── components/         # Design system: buttons, cards, tables, badges, app_logo
│   ├── employee/           # Employee domain model, document repository, and repository
│   ├── leave/              # Leave policy models, balance tracking, and leave engine
│   ├── notification/       # Notification model and notification center repository
│   ├── organization/       # Organization and membership domain models
│   ├── payroll/            # Payroll calculation engine, salary structure, and repository
│   ├── reports/            # Report engine, CSV formatting, and report repository
│   ├── routing/            # GoRouter configuration with multi-level role access guards
│   ├── shell/              # Responsive AppShell, AppSidebar, and AppTopBar
│   ├── storage/            # Cloudinary and Backblaze B2 integration boundaries
│   ├── theme/              # Colors, typography, spacing, radius, and ThemeData
│   └── utils/              # Universal cross-platform FileDownloadHelper
├── features/
│   ├── attendance/         # Employee attendance tracker & HR specific shift configuration
│   ├── auth_shell/         # Sign in, registration with role selection, verification
│   ├── dashboard/          # Tailored role-specific dashboards (Admin/HR vs Employee)
│   ├── employees/          # Employee directory, details screen, full edit form dialog
│   ├── leave/              # Leave application screen & HR approval dashboard
│   ├── notifications/      # Live notification center popup widget
│   ├── organization/       # Multi-tenant organization onboarding screen
│   ├── payroll/            # Employee payslip downloads & HR payroll processing
│   └── reports/            # Operational reports and live browser CSV exports
├── firebase_options.dart   # Dynamic Firebase options initialized from .env
└── main.dart               # Application bootstrap and Riverpod ProviderScope
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>=3.19.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: `>=3.3.0`
- **Web Browser**: Chrome, Edge, Safari, or Firefox

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Adi140108/DayFlow-BitBros-.git
   cd DayFlow-BitBros-
   ```

2. **Configure Environment Variables**:
   Create a `.env` file at the root of the project:
   ```env
   # Firebase Configuration
   FIREBASE_API_KEY=AIzaSy...
   FIREBASE_APP_ID=1:721525338638:web:...
   FIREBASE_MESSAGING_SENDER_ID=721525338638
   FIREBASE_PROJECT_NAME=DayFlow
   FIREBASE_PROJECT_ID=dayflow-bitbros
   FIREBASE_AUTH_DOMAIN=dayflow-bitbros.firebaseapp.com
   FIREBASE_STORAGE_BUCKET=dayflow-bitbros.firebasestorage.app
   FIREBASE_MEASUREMENT_ID=G-Q40EXW1G63

   # Cloudinary Configuration
   CLOUDINARY_API_KEY=...
   CLOUDINARY_CLOUD_NAME=...

   # BackBlaze Configuration
   B2_KEY_ID=...
   B2_APPLICATION_KEY=...
   B2_BUCKET_NAME=dayflow-production-files
   B2_ENDPOINT=s3.us-east-005.backblazeb2.com
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the Web Application**:
   ```bash
   flutter run -d web-server --web-port=8080 --web-hostname=localhost
   ```
   Open your browser and navigate to `http://localhost:8080`.

---

## 🔒 Security & Quality Assurance

- **Zero Hardcoded Secrets**: All API keys and environment variables are strictly loaded at runtime via `.env` and kept in `.gitignore`.
- **Static Analysis**: Clean Dart code maintaining 0 errors and 0 analyzer warnings (`flutter analyze`).
- **Database Rules**: Firestore security rules enforced across multi-tenant scopes to safeguard sensitive employee compensation and personal records.



---

**Dayflow — Human Resource Management System**  
*Every workday, perfectly aligned.*
