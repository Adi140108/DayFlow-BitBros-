import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const Register: React.FC = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [role, setRole] = useState<"EMPLOYEE" | "HR_ADMIN">("EMPLOYEE");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const { register } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password || !firstName || !lastName) {
      setError("Please fill in all fields.");
      return;
    }

    setError("");
    setSubmitting(true);

    try {
      await register(email, password, firstName, lastName, role);
      if (role === "HR_ADMIN") {
        navigate("/admin/dashboard");
      } else {
        navigate("/employee/dashboard");
      }
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Failed to create account. Please try again.");
    } finally {
      setSubmitting(false);
    }
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
          maxWidth: "450px", 
          textAlign: "center" 
        }}
      >
        <h2 style={{ marginBottom: "8px", fontWeight: 700, color: "var(--primary)" }}>Create Account</h2>
        <p style={{ marginBottom: "24px", fontSize: "0.875rem" }}>Sign up to register a new profile</p>

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
          <div className="grid grid-cols-2" style={{ gap: "12px", marginBottom: "0px" }}>
            <div className="form-group">
              <label className="form-label" htmlFor="firstName">First Name</label>
              <input 
                className="form-control" 
                type="text" 
                id="firstName" 
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                placeholder="John" 
                required
              />
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="lastName">Last Name</label>
              <input 
                className="form-control" 
                type="text" 
                id="lastName" 
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                placeholder="Doe" 
                required
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="email">Email Address</label>
            <input 
              className="form-control" 
              type="email" 
              id="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="john.doe@company.com" 
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="password">Password</label>
            <input 
              className="form-control" 
              type="password" 
              id="password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Min. 6 characters" 
              minLength={6}
              required
            />
          </div>

          <div className="form-group" style={{ marginBottom: "24px" }}>
            <label className="form-label" htmlFor="role">User Role</label>
            <select 
              className="form-control" 
              id="role"
              value={role}
              onChange={(e) => setRole(e.target.value as "EMPLOYEE" | "HR_ADMIN")}
              style={{ cursor: "pointer" }}
            >
              <option value="EMPLOYEE">Employee (Standard View)</option>
              <option value="HR_ADMIN">HR Admin / Administrator</option>
            </select>
          </div>

          <button 
            type="submit" 
            className="btn btn-primary" 
            style={{ width: "100%", padding: "12px" }}
            disabled={submitting}
          >
            {submitting ? "Creating account..." : "Sign Up"}
          </button>
        </form>

        <p style={{ marginTop: "20px", fontSize: "0.875rem" }}>
          Already have an account? <Link to="/login" style={{ color: "var(--primary)", fontWeight: 600 }}>Log in here</Link>
        </p>
      </div>
    </div>
  );
};

export default Register;
