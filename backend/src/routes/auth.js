const express = require("express");
const router = express.Router();
const { db } = require("../config/firebaseAdmin");
const authenticateToken = require("../middleware/auth");

// POST /api/auth/register - Sync new user into Firestore
router.post("/register", async (req, res) => {
  const { uid, email, firstName, lastName, role } = req.body;

  if (!uid || !email || !firstName || !lastName) {
    return res.status(400).json({ error: "Missing required fields: uid, email, firstName, lastName." });
  }

  const finalRole = role === "HR_ADMIN" ? "HR_ADMIN" : "EMPLOYEE";

  try {
    const userRef = db.collection("users").doc(uid);
    const employeeRef = db.collection("employees").doc(uid);

    // Save user role configuration
    await userRef.set({
      uid,
      email,
      role: finalRole,
      createdAt: new Date().toISOString()
    });

    // Save employee profile configurations
    await employeeRef.set({
      uid,
      firstName,
      lastName,
      phone: "",
      department: "",
      jobTitle: finalRole === "HR_ADMIN" ? "HR Manager" : "Software Developer",
      joinDate: new Date().toISOString(),
      baseSalary: finalRole === "HR_ADMIN" ? 8000 : 5000,
      avatarUrl: ""
    });

    res.status(201).json({ message: "User synced successfully.", uid, role: finalRole });
  } catch (error) {
    console.error("Failed to sync user:", error.message);
    res.status(500).json({ error: "Internal server error syncing user details." });
  }
});

// GET /api/auth/role - Fetch verified role of the current user
router.get("/role", authenticateToken, (req, res) => {
  res.status(200).json({ uid: req.user.uid, email: req.user.email, role: req.user.role });
});

module.exports = router;
