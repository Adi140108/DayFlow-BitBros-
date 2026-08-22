import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/AuthContext";
import ProtectedLayout from "./layouts/ProtectedLayout";
import Login from "./pages/Login";
import Register from "./pages/Register";

// Employee Pages
import EmployeeDashboard from "./pages/employee/Dashboard";
import EmployeeProfile from "./pages/employee/Profile";
import EmployeeAttendance from "./pages/employee/Attendance";
import EmployeeLeaves from "./pages/employee/Leaves";
import EmployeePayroll from "./pages/employee/Payroll";

// Admin Pages
import AdminDashboard from "./pages/admin/Dashboard";
import AdminEmployees from "./pages/admin/Employees";
import AdminAttendance from "./pages/admin/Attendance";
import AdminLeaves from "./pages/admin/Leaves";
import AdminPayroll from "./pages/admin/Payroll";

function RootRedirect() {
  const { user, loading } = useAuth();
  if (loading) return null;
  if (!user) return <Navigate to="/login" replace />;
  return <Navigate to={user.role === "HR_ADMIN" ? "/admin/dashboard" : "/employee/dashboard"} replace />;
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Employee Protected Routes */}
          <Route element={<ProtectedLayout allowedRoles={["EMPLOYEE"]} />}>
            <Route path="/employee/dashboard" element={<EmployeeDashboard />} />
            <Route path="/employee/profile" element={<EmployeeProfile />} />
            <Route path="/employee/attendance" element={<EmployeeAttendance />} />
            <Route path="/employee/leaves" element={<EmployeeLeaves />} />
            <Route path="/employee/payroll" element={<EmployeePayroll />} />
          </Route>

          {/* Admin Protected Routes */}
          <Route element={<ProtectedLayout allowedRoles={["HR_ADMIN"]} />}>
            <Route path="/admin/dashboard" element={<AdminDashboard />} />
            <Route path="/admin/employees" element={<AdminEmployees />} />
            <Route path="/admin/attendance" element={<AdminAttendance />} />
            <Route path="/admin/leaves" element={<AdminLeaves />} />
            <Route path="/admin/payroll" element={<AdminPayroll />} />
          </Route>

          {/* Catch-all redirect */}
          <Route path="*" element={<RootRedirect />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
