const { auth, db } = require("../config/firebaseAdmin");

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ error: "Access token required." });
  }

  try {
    // Verify ID Token with Firebase
    const decodedToken = await auth.verifyIdToken(token);
    const { uid, email } = decodedToken;

    // Fetch user role from Firestore users collection
    const userDoc = await db.collection("users").doc(uid).get();
    let role = "EMPLOYEE"; // default fallback

    if (userDoc.exists) {
      role = userDoc.data().role;
    }

    req.user = { uid, email, role };
    next();
  } catch (error) {
    console.error("Token verification failed:", error.message);
    return res.status(403).json({ error: "Invalid or expired access token." });
  }
};

module.exports = authenticateToken;
