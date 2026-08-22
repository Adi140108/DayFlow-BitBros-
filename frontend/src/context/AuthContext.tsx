import React, { createContext, useContext, useState, useEffect } from "react";
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged
} from "firebase/auth";
import { auth as firebaseAuth } from "../config/firebase";

// Define User Interface
export interface UserProfile {
  uid: string;
  email: string | null;
  role: "EMPLOYEE" | "HR_ADMIN";
  firstName?: string;
  lastName?: string;
}

interface AuthContextType {
  user: UserProfile | null;
  token: string | null;
  loading: boolean;
  isMock: boolean;
  login: (email: string, password: string) => Promise<UserProfile>;
  register: (email: string, password: string, firstName: string, lastName: string, role?: "EMPLOYEE" | "HR_ADMIN") => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:5000/api";
const isFirebasePlaceholder = import.meta.env.VITE_FIREBASE_API_KEY === "placeholder-api-key" || !import.meta.env.VITE_FIREBASE_API_KEY;

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Helper to fetch user role from Express backend
  const fetchUserRole = async (authToken: string): Promise<"EMPLOYEE" | "HR_ADMIN"> => {
    try {
      const response = await fetch(`${API_URL}/auth/role`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      if (response.ok) {
        const data = await response.json();
        return data.role;
      }
    } catch (e) {
      console.error("Failed to fetch role from backend:", e);
    }
    return "EMPLOYEE"; // default fallback
  };

  useEffect(() => {
    if (isFirebasePlaceholder) {
      // Local Mock Auth Initialization
      const mockToken = localStorage.getItem("mock_auth_token");
      const mockUid = localStorage.getItem("mock_auth_uid");
      const mockEmail = localStorage.getItem("mock_auth_email");
      const mockRole = localStorage.getItem("mock_auth_role") as "EMPLOYEE" | "HR_ADMIN" | null;

      if (mockToken && mockUid && mockEmail && mockRole) {
        setToken(mockToken);
        setUser({ uid: mockUid, email: mockEmail, role: mockRole });
      }
      setLoading(false);
    } else {
      // Real Firebase Auth Initialization
      const unsubscribe = onAuthStateChanged(firebaseAuth, async (firebaseUser) => {
        if (firebaseUser) {
          const idToken = await firebaseUser.getIdToken(true);
          const role = await fetchUserRole(idToken);
          setToken(idToken);
          setUser({
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            role: role
          });
        } else {
          setUser(null);
          setToken(null);
        }
        setLoading(false);
      });
      return unsubscribe;
    }
  }, []);

  const login = async (email: string, password: string): Promise<UserProfile> => {
    if (isFirebasePlaceholder) {
      // Mock Login Mode
      let role: "EMPLOYEE" | "HR_ADMIN" = "EMPLOYEE";
      let mockToken = "mock-employee-token";
      let mockUid = "mock-employee-uid";

      if (email === "admin@dayflow.com") {
        role = "HR_ADMIN";
        mockToken = "mock-admin-token";
        mockUid = "mock-admin-uid";
      }

      localStorage.setItem("mock_auth_token", mockToken);
      localStorage.setItem("mock_auth_uid", mockUid);
      localStorage.setItem("mock_auth_email", email);
      localStorage.setItem("mock_auth_role", role);

      const loggedUser: UserProfile = { uid: mockUid, email, role };
      setToken(mockToken);
      setUser(loggedUser);
      return loggedUser;
    } else {
      // Real Firebase Login
      const userCredential = await signInWithEmailAndPassword(firebaseAuth, email, password);
      const idToken = await userCredential.user.getIdToken(true);
      const role = await fetchUserRole(idToken);
      const loggedUser: UserProfile = {
        uid: userCredential.user.uid,
        email: userCredential.user.email,
        role: role
      };
      setToken(idToken);
      setUser(loggedUser);
      return loggedUser;
    }
  };

  const register = async (email: string, password: string, firstName: string, lastName: string, role: "EMPLOYEE" | "HR_ADMIN" = "EMPLOYEE") => {
    if (isFirebasePlaceholder) {
      // Mock Registration Mode
      const mockUid = `mock-uid-${Math.random().toString(36).substring(2, 9)}`;
      const mockToken = role === "HR_ADMIN" ? "mock-admin-token" : "mock-employee-token";

      // Register with the backend sync endpoint
      const response = await fetch(`${API_URL}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ uid: mockUid, email, firstName, lastName, role })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to register user on mock backend.");
      }

      localStorage.setItem("mock_auth_token", mockToken);
      localStorage.setItem("mock_auth_uid", mockUid);
      localStorage.setItem("mock_auth_email", email);
      localStorage.setItem("mock_auth_role", role);

      setToken(mockToken);
      setUser({ uid: mockUid, email, role });
    } else {
      // Real Firebase Registration
      const userCredential = await createUserWithEmailAndPassword(firebaseAuth, email, password);
      const idToken = await userCredential.user.getIdToken();

      // Sync user profile parameters on the backend Express router
      const response = await fetch(`${API_URL}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          uid: userCredential.user.uid,
          email,
          firstName,
          lastName,
          role
        })
      });

      if (!response.ok) {
        // Cleanup firebase account if backend synchronization fails
        await userCredential.user.delete();
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to sync profile. Firebase registration aborted.");
      }

      setToken(idToken);
      setUser({
        uid: userCredential.user.uid,
        email,
        role
      });
    }
  };

  const logout = async () => {
    if (isFirebasePlaceholder) {
      localStorage.removeItem("mock_auth_token");
      localStorage.removeItem("mock_auth_uid");
      localStorage.removeItem("mock_auth_email");
      localStorage.removeItem("mock_auth_role");
      setUser(null);
      setToken(null);
    } else {
      await signOut(firebaseAuth);
      setUser(null);
      setToken(null);
    }
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, isMock: isFirebasePlaceholder, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
