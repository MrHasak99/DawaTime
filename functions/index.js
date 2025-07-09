const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const fetch = require("node-fetch");
const geoip = require("geoip-lite");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  host: "smtppro.zoho.com",
  port: 465,
  secure: true,
  auth: {
    user: "admin@dawatime.com",
    pass: "P6&Ee$kr#p29",
  },
});

const blockedCountries = ["IL"];

exports.emailAdminsOnContactMessage = functions.firestore
    .document("ContactMessages/{messageId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const mailOptions = {
        from: "admin@dawatime.com",
        to: "help@dawatime.com",
        replyTo: data.userEmail || "admin@dawatime.com",
        subject: `New Contact Message from ${data.userEmail || "Unknown"}`,
        text: `Message: ${data.message}`,
      };
      await transporter.sendMail(mailOptions);
    });

exports.requestAccountDeletion = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }
  if (req.method !== "POST") return res.status(405).send("Method Not Allowed");
  const {email, password, reason} = req.body;
  if (!email || !password) {
    return res.status(400).send("Email and password required");
  }

  try {
    const apiKey = "AIzaSyAqewZt32r_IYN59KCrrP90qYitKDz1wZE";
    const signInResp = await fetch(
        `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
        {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({email, password, returnSecureToken: true}),
        },
    );
    const signInData = await signInResp.json();
    if (!signInData.localId) {
      return res.status(401).send("Invalid email or password");
    }
    const uid = signInData.localId;

    try {
      await admin.firestore().collection("Users").doc(uid).delete();
    } catch (e) {
      console.warn("User doc not found or already deleted:", e);
    }
    try {
      const snapshot = await admin.firestore().collection(uid).get();
      const batch = admin.firestore().batch();
      snapshot.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    } catch (e) {
      console.warn("User collection not found or already deleted:", e);
    }

    try {
      await admin.auth().deleteUser(uid);
    } catch (error) {
      if (error.code === "auth/user-not-found") {
        console.warn("User already deleted from Firebase Auth.");
      } else {
        throw error;
      }
    }

    await admin
        .firestore()
        .collection("deletion_requests")
        .add({
          email,
          reason: reason || "",
          requestedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

    return res.status(200).send("Account and data deleted");
  } catch (error) {
    console.error(error);
    return res.status(500).send("Error processing deletion");
  }
});

exports.blockAccessFromCertainCountries = functions.https.onRequest(
    (req, res) => {
      const ip = req.headers["x-forwarded-for"] || req.connection.remoteAddress;
      const geo = geoip.lookup(ip);
      if (geo && blockedCountries.includes(geo.country)) {
        return res.status(403).send("Access denied in your country.");
      }
      res.status(200).send("Access granted.");
    },
);
