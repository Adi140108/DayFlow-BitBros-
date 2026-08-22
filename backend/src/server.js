const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Load Firebase Admin (it will validate the key existence)
const { db, auth } = require("./config/firebaseAdmin");

// Mount routes
const authRouter = require("./routes/auth");
app.use("/api/auth", authRouter);

// Simple health check route
app.get("/api/health", (req, res) => {
  res.status(200).json({ status: "OK", message: "Dayflow HRMS API is running." });
});

// Start listening
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
