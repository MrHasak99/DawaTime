const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const fetch = require("node-fetch");
const geoip = require("geoip-lite");

admin.initializeApp();

exports.notifyOnVersionUpdate = functions
    .runWith({memory: "512MB", timeoutSeconds: 300})
    .firestore
    .document("AppConfig/Version")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      const iosUpdated = before.ios !== after.ios;
      const androidUpdated = before.android !== after.android;

      if (!iosUpdated && !androidUpdated) return null;

      try {
        const users = [];
        const pageSize = 100;
        let lastDoc = null;
        let hasMore = true;

        while (hasMore) {
          let query = admin
              .firestore()
              .collection("Users")
              .limit(pageSize);

          if (lastDoc) {
            query = query.startAfter(lastDoc);
          }

          const snapshot = await query.get();

          if (snapshot.empty) {
            hasMore = false;
            break;
          }

          snapshot.forEach((doc) => {
            const data = doc.data();
            if (data.fcmToken) {
              users.push({
                token: data.fcmToken,
                language: data.preferredLanguage || "en",
              });
            }
          });

          lastDoc = snapshot.docs[snapshot.docs.length - 1];

          if (snapshot.size < pageSize) {
            hasMore = false;
          }
        }

        if (users.length === 0) {
          console.log("No FCM tokens found");
          return null;
        }

        console.log(`Found ${users.length} FCM tokens`);

        const arabicUsers = users.filter((u) => u.language === "ar");
        const englishUsers = users.filter((u) => u.language !== "ar");

        const promises = [];
        const batchSize = 500;

        for (let i = 0; i < arabicUsers.length; i += batchSize) {
          const batch = arabicUsers.slice(i, i + batchSize).map((u) => u.token);
          const message = {
            data: {
              type: "update_available",
              iosVersion: after.ios || "",
              androidVersion: after.android || "",
              title: "تحديث جديد متوفر!",
              body: "إصدار جديد من دواء تايم متاح. اضغط للتحديث الآن.",
            },
            apns: {
              payload: {
                aps: {
                  "content-available": 1,
                  "mutable-content": 1,
                },
              },
            },
            android: {
              priority: "high",
            },
            tokens: batch,
          };
          promises.push(admin.messaging().sendEachForMulticast(message));
        }
        for (let i = 0; i < englishUsers.length; i += batchSize) {
          const batch =
            englishUsers.slice(i, i + batchSize).map((u) => u.token);
          const message = {
            data: {
              type: "update_available",
              iosVersion: after.ios || "",
              androidVersion: after.android || "",
              title: "New Update Available!",
              body:
                "A new version of DawaTime is available. " +
                "Tap to update now.",
            },
            apns: {
              payload: {
                aps: {
                  "content-available": 1,
                  "mutable-content": 1,
                },
              },
            },
            android: {
              priority: "high",
            },
            tokens: batch,
          };
          promises.push(admin.messaging().sendEachForMulticast(message));
        }

        const results = await Promise.all(promises);
        let successCount = 0;
        let failureCount = 0;

        results.forEach((result) => {
          successCount += result.successCount;
          failureCount += result.failureCount;
        });

        console.log(
            "Update notification sent: " +
            `${successCount} success, ${failureCount} failures`,
        );

        return null;
      } catch (error) {
        console.error("Error sending update notifications:", error);
        return null;
      }
    });

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

exports.emailAdminsOnContactMessage = functions
    .runWith({memory: "512MB", timeoutSeconds: 60})
    .firestore
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
      try {
        await transporter.sendMail(mailOptions);
        console.log(
            `Email sent successfully for message from ${data.userEmail}`,
        );
      } catch (error) {
        console.error("Error sending email:", error);
        throw error;
      }
    });

exports.requestAccountDeletion = functions
    .runWith({memory: "512MB", timeoutSeconds: 120})
    .https.onRequest(async (req, res) => {
      res.set("Access-Control-Allow-Origin", "*");
      if (req.method === "OPTIONS") {
        res.set("Access-Control-Allow-Methods", "POST");
        res.set("Access-Control-Allow-Headers", "Content-Type");
        res.status(204).send("");
        return;
      }
      if (req.method !== "POST") {
        return res.status(405).send("Method Not Allowed");
      }
      const {email, password, reason} = req.body;
      if (!email || !password) {
        return res.status(400).send("Email and password required");
      }

      try {
        const apiKey = "AIzaSyAqewZt32r_IYN59KCrrP90qYitKDz1wZE";
        const signInResp = await fetch(
            // eslint-disable-next-line max-len
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
          console.log(`Deleted Users doc for ${uid}`);
        } catch (e) {
          console.warn("User doc not found or already deleted:", e);
        }
        try {
          const snapshot = await admin.firestore().collection(uid).get();
          const batch = admin.firestore().batch();
          snapshot.forEach((doc) => batch.delete(doc.ref));
          await batch.commit();
          console.log(`Deleted user collection for ${uid}`);
        } catch (e) {
          console.warn("User collection not found or already deleted:", e);
        }

        try {
          await admin.auth().deleteUser(uid);
          console.log(`Deleted auth user ${uid}`);
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

        console.log(`Account deletion completed for ${email}`);
        return res.status(200).send("Account and data deleted");
      } catch (error) {
        console.error("Error processing deletion:", error);
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
