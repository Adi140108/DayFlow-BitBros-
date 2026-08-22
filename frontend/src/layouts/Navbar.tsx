import React from "react";
import { useAuth } from "../context/AuthContext";

const Navbar: React.FC = () => {
  const { user, logout, isMock } = useAuth();

  return (
    <header 
      className="flex items-center justify-between shadow-sm"
      style={{
        height: "var(--navbar-height)",
        backgroundColor: "var(--bg-card)",
        borderBottom: "1px solid var(--border-color)",
        padding: "0 24px",
        position: "sticky",
        top: 0,
        zIndex: 90
      }}
    >
      <div className="flex items-center gap-2">
        <h2 style={{ margin: 0, fontSize: "1.25rem", fontWeight: 700, color: "var(--primary)" }}>
          Dayflow <span style={{ fontWeight: 300, color: "var(--text-muted)" }}>HRMS</span>
        </h2>
        {isMock && (
          <span 
            className="badge badge-warning" 
            style={{ 
              animation: "pulse 2s infinite",
              fontSize: "0.7rem",
              padding: "2px 8px" 
            }}
          >
            Mock Dev Mode
          </span>
        )}
      </div>

      <div className="flex items-center gap-4">
        {user && (
          <div className="flex items-center gap-2" style={{ textAlign: "right" }}>
            <span style={{ fontSize: "0.875rem", fontWeight: 500 }}>{user.email}</span>
            <span 
              className={`badge ${user.role === "HR_ADMIN" ? "badge-success" : "badge-warning"}`}
              style={{ fontSize: "0.7rem" }}
            >
              {user.role === "HR_ADMIN" ? "Admin / HR" : "Employee"}
            </span>
          </div>
        )}
        <button className="btn btn-secondary" style={{ padding: "6px 12px", fontSize: "0.8rem" }} onClick={logout}>
          Log Out
        </button>
      </div>
    </header>
  );
};

export default Navbar;
