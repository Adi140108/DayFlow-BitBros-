import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const Login: React.FC = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const { login, isMock } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError("Please fill in all fields.");
      return;
    }

    setError("");
    setSubmitting(true);

    try {
      const loggedUser = await login(email, password);
      if (loggedUser.role === "HR_ADMIN") {
        navigate("/admin/dashboard");
      } else {
        navigate("/employee/dashboard");
      }
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Failed to log in. Please check your credentials.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleAutofill = (testEmail: string) => {
    setEmail(testEmail);
    setPassword("password");
  };

  return (
    <div 
      className="flex items-center justify-center" 
      style={{ 
        minHeight: "100vh", 
        backgroundColor: "var(--bg-app)",
        padding: "24px" 
      }}
    >
      <div 
        className="card" 
        style={{ 
          width: "100%", 
          maxWidth: "400px", 
          textAlign: "center" 
        }}
      >
        <h2 style={{ marginBottom: "8px", fontWeight: 700, color: "var(--primary)" }}>Dayflow HRMS</h2>
        <p style={{ marginBottom: "24px", fontSize: "0.875rem" }}>Log in to access your dashboard</p>

        {error && (
          <div 
            style={{ 
              backgroundColor: "var(--danger-light)", 
              color: "var(--danger)", 
              padding: "10px", 
              borderRadius: "var(--border-radius-sm)", 
              marginBottom: "16px",
              fontSize: "0.875rem",
              textAlign: "left"
            }}
          >
            ⚠️ {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label" htmlFor="email">Email Address</label>
            <input 
              className="form-control" 
              type="email" 
              id="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="e.g. employee@dayflow.com" 
              required
            />
          </div>

          <div className="form-group" style={{ marginBottom: "24px" }}>
            <label className="form-label" htmlFor="password">Password</label>
            <input 
              className="form-control" 
              type="password" 
              id="password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••" 
              required
            />
          </div>

          <button 
            type="submit" 
            className="btn btn-primary" 
            style={{ width: "100%", padding: "12px" }}
            disabled={submitting}
          >
            {submitting ? "Logging in..." : "Log In"}
          </button>
        </form>

        <p style={{ marginTop: "20px", fontSize: "0.875rem" }}>
          Don't have an account? <Link to="/register" style={{ color: "var(--primary)", fontWeight: 600 }}>Sign up here</Link>
        </p>

        {isMock && (
          <div 
            style={{ 
              marginTop: "24px", 
              padding: "16px", 
              border: "1px dashed var(--warning)", 
              borderRadius: "var(--border-radius)",
              backgroundColor: "var(--warning-light)",
              textAlign: "left"
            }}
          >
            <h4 style={{ color: "var(--warning-hover)", marginBottom: "8px", fontSize: "0.875rem" }}>💡 Mock Testing Accounts:</h4>
            <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
              <button 
                className="btn btn-secondary" 
                style={{ padding: "6px 10px", fontSize: "0.75rem", justifyContent: "flex-start", width: "100%" }}
                onClick={() => handleAutofill("employee@dayflow.com")}
              >
                👤 Employee: employee@dayflow.com
              </button>
              <button 
                className="btn btn-secondary" 
                style={{ padding: "6px 10px", fontSize: "0.75rem", justifyContent: "flex-start", width: "100%" }}
                onClick={() => handleAutofill("admin@dayflow.com")}
              >
                💼 HR Admin: admin@dayflow.com
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Login;
