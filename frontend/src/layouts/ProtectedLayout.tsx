import React from "react";
import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import Navbar from "./Navbar";
import Sidebar from "./Sidebar";

interface ProtectedLayoutProps {
  allowedRoles?: Array<"EMPLOYEE" | "HR_ADMIN">;
}

const ProtectedLayout: React.FC<ProtectedLayoutProps> = ({ allowedRoles }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="flex items-center justify-center" style={{ minHeight: "100vh", backgroundColor: "var(--bg-app)" }}>
        <div style={{ textAlign: "center" }}>
          <div 
            style={{ 
              width: "40px", 
              height: "40px", 
              border: "3px solid var(--border-color)", 
              borderTopColor: "var(--primary)", 
              borderRadius: "50%", 
              animation: "spin 1s linear infinite",
              margin: "0 auto 16px"
            }} 
          />
          <style>{`
            @keyframes spin {
              to { transform: rotate(360deg); }
            }
          `}</style>
          <p>Loading application...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return (
      <div className="flex items-center justify-center flex-col" style={{ minHeight: "100vh", backgroundColor: "var(--bg-app)", padding: "24px", textAlign: "center" }}>
        <h1 style={{ color: "var(--danger)" }}>⚠️ Access Denied</h1>
        <p style={{ marginBottom: "20px" }}>You do not have permission to view this page.</p>
        <Navigate to={user.role === "HR_ADMIN" ? "/admin/dashboard" : "/employee/dashboard"} replace />
      </div>
    );
  }

  return (
    <div className="app-container">
      <Sidebar />
      <div className="main-content">
        <Navbar />
        <main className="content-body">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default ProtectedLayout;
