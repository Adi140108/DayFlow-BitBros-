import React from "react";
import { Link, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const Sidebar: React.FC = () => {
  const { user } = useAuth();
  const location = useLocation();

  if (!user) return null;

  const isAdmin = user.role === "HR_ADMIN";

  const menuItems = isAdmin
    ? [
        { label: "Dashboard", path: "/admin/dashboard", icon: "📊" },
        { label: "Employees", path: "/admin/employees", icon: "👥" },
        { label: "Attendance", path: "/admin/attendance", icon: "🕒" },
        { label: "Leave Approvals", path: "/admin/leaves", icon: "✉️" },
        { label: "Payroll Control", path: "/admin/payroll", icon: "💵" }
      ]
    : [
        { label: "Dashboard", path: "/employee/dashboard", icon: "📊" },
        { label: "My Profile", path: "/employee/profile", icon: "👤" },
        { label: "Attendance Log", path: "/employee/attendance", icon: "🕒" },
        { label: "Request Leave", path: "/employee/leaves", icon: "✉️" },
        { label: "My Payroll", path: "/employee/payroll", icon: "💵" }
      ];

  return (
    <aside
      style={{
        width: "var(--sidebar-width)",
        backgroundColor: "var(--bg-card)",
        borderRight: "1px solid var(--border-color)",
        height: "100vh",
        position: "fixed",
        top: 0,
        left: 0,
        display: "flex",
        flexDirection: "column",
        zIndex: 95,
        padding: "24px 16px"
      }}
    >
      <div style={{ padding: "0 8px 24px 8px", borderBottom: "1px solid var(--border-color)", marginBottom: "20px" }}>
        <h1 style={{ fontSize: "1.5rem", margin: 0 }}>Dayflow</h1>
        <p style={{ fontSize: "0.75rem", textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--text-muted)" }}>
          {isAdmin ? "Admin Portal" : "Employee Portal"}
        </p>
      </div>

      <nav style={{ display: "flex", flexDirection: "column", gap: "6px", flex: 1 }}>
        {menuItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <Link
              key={item.path}
              to={item.path}
              className="btn btn-secondary"
              style={{
                justifyContent: "flex-start",
                padding: "12px 16px",
                borderRadius: "var(--border-radius-sm)",
                backgroundColor: isActive ? "var(--primary-light)" : "transparent",
                color: isActive ? "var(--primary)" : "var(--text-main)",
                borderColor: "transparent",
                fontWeight: isActive ? 600 : 500,
                transition: "var(--transition)",
                gap: "12px"
              }}
            >
              <span style={{ fontSize: "1.1rem" }}>{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>

      <div style={{ padding: "12px 8px", borderTop: "1px solid var(--border-color)", fontSize: "0.8rem", color: "var(--text-muted)", textAlign: "center" }}>
        Dayflow HRMS v1.0.0
      </div>
    </aside>
  );
};

export default Sidebar;
