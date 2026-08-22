const path = require("path");
const fs = require("fs");
require("dotenv").config();

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || "./serviceAccountKey.json";
const resolvedPath = path.resolve(process.cwd(), serviceAccountPath);

let useMock = false;
let admin, db, auth;

if (!fs.existsSync(resolvedPath)) {
  console.warn("==========================================================================");
  console.warn(`WARNING: Firebase Service Account Key not found at ${resolvedPath}`);
  console.warn("Using LOCAL MOCK DATABASE (JSON files) and MOCK AUTH for testing.");
  console.warn("Please place your serviceAccountKey.json file to connect to real Firebase.");
  console.warn("==========================================================================");
  useMock = true;
}

if (!useMock) {
  try {
    admin = require("firebase-admin");
    const serviceAccount = require(resolvedPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    db = admin.firestore();
    auth = admin.auth();
  } catch (error) {
    console.error("Failed to initialize Firebase Admin SDK. Falling back to mock.", error);
    useMock = true;
  }
}

if (useMock) {
  // Simple Mock Firestore and Auth implementation using local JSON files
  const mockDbDir = path.resolve(process.cwd(), "./data");
  if (!fs.existsSync(mockDbDir)) {
    fs.mkdirSync(mockDbDir);
  }

  const getCollectionPath = (col) => path.join(mockDbDir, `${col}.json`);
  
  const readCollection = (col) => {
    const filePath = getCollectionPath(col);
    if (!fs.existsSync(filePath)) {
      // Seed default mock records
      if (col === "users") {
        return {
          "mock-admin-uid": { uid: "mock-admin-uid", email: "admin@dayflow.com", role: "HR_ADMIN", createdAt: new Date().toISOString() },
          "mock-employee-uid": { uid: "mock-employee-uid", email: "employee@dayflow.com", role: "EMPLOYEE", createdAt: new Date().toISOString() }
        };
      }
      if (col === "employees") {
        return {
          "mock-admin-uid": { uid: "mock-admin-uid", firstName: "Alice", lastName: "Admin", jobTitle: "HR Manager", baseSalary: 8000, joinDate: new Date().toISOString(), phone: "123-456-7890" },
          "mock-employee-uid": { uid: "mock-employee-uid", firstName: "Bob", lastName: "Employee", jobTitle: "Software Developer", baseSalary: 5000, joinDate: new Date().toISOString(), phone: "987-654-3210" }
        };
      }
      return {};
    }
    try {
      return JSON.parse(fs.readFileSync(filePath, "utf8"));
    } catch (e) {
      return {};
    }
  };

  const writeCollection = (col, data) => {
    fs.writeFileSync(getCollectionPath(col), JSON.stringify(data, null, 2), "utf8");
  };

  db = {
    collection: (colName) => {
      return {
        doc: (docId) => {
          return {
            get: async () => {
              const data = readCollection(colName);
              const exists = !!data[docId];
              return {
                exists,
                id: docId,
                data: () => data[docId] || null
              };
            },
            set: async (docData) => {
              const data = readCollection(colName);
              data[docId] = { ...docData };
              writeCollection(colName, data);
              return { id: docId };
            },
            update: async (updateData) => {
              const data = readCollection(colName);
              data[docId] = { ...(data[docId] || {}), ...updateData };
              writeCollection(colName, data);
              return { id: docId };
            },
            delete: async () => {
              const data = readCollection(colName);
              delete data[docId];
              writeCollection(colName, data);
              return { id: docId };
            }
          };
        },
        where: (field, op, value) => {
          return {
            get: async () => {
              const data = readCollection(colName);
              const docs = Object.keys(data)
                .map(id => ({ id, ...data[id] }))
                .filter(doc => {
                  if (op === "==") return doc[field] === value;
                  if (op === ">=") return doc[field] >= value;
                  if (op === "<=") return doc[field] <= value;
                  return false;
                });
              return {
                docs: docs.map(doc => ({
                  id: doc.id,
                  data: () => doc
                }))
              };
            }
          };
        },
        get: async () => {
          const data = readCollection(colName);
          const docs = Object.keys(data).map(id => ({
            id,
            ...data[id]
          }));
          return {
            docs: docs.map(doc => ({
              id: doc.id,
              data: () => doc
            }))
          };
        },
        add: async (docData) => {
          const data = readCollection(colName);
          const docId = Math.random().toString(36).substring(2, 15);
          data[docId] = { id: docId, ...docData };
          writeCollection(colName, data);
          return { id: docId };
        }
      };
    }
  };

  auth = {
    verifyIdToken: async (token) => {
      if (token === "mock-admin-token") {
        return { uid: "mock-admin-uid", email: "admin@dayflow.com" };
      } else if (token === "mock-employee-token") {
        return { uid: "mock-employee-uid", email: "employee@dayflow.com" };
      }
      throw new Error("Invalid mock token");
    }
  };
}

module.exports = { admin, db, auth, isMock: useMock };
