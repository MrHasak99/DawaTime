const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const fetch = require("node-fetch");
const geoip = require("geoip-lite");

admin.initializeApp();

const {migrateMedicationsToSubcollections} =
  require("./migrate-to-subcollections");

exports.migrateMedicationsToSubcollections = migrateMedicationsToSubcollections;

exports.notifyOnVersionUpdate = functions
    .runWith({memory: "512MB", timeoutSeconds: 300})
    .firestore
    .document("AppConfig/Version")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      const versionUpdated = before.version !== after.version;

      if (!versionUpdated) return null;

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

        const uniqueTokens = new Set();
        const deduplicatedUsers = users.filter((user) => {
          if (uniqueTokens.has(user.token)) {
            console.log(
                `Skipping duplicate token: ` +
                `${user.token.substring(0, 20)}...`,
            );
            return false;
          }
          uniqueTokens.add(user.token);
          return true;
        });

        console.log(
            `Found ${users.length} FCM tokens ` +
            `(${deduplicatedUsers.length} unique)`,
        );

        const arabicUsers = deduplicatedUsers.filter(
            (u) => u.language === "ar",
        );
        const englishUsers = deduplicatedUsers.filter(
            (u) => u.language !== "ar",
        );

        const promises = [];
        const batchSize = 500;

        for (let i = 0; i < arabicUsers.length; i += batchSize) {
          const batch = arabicUsers.slice(i, i + batchSize);
          const message = {
            notification: {
              title: "تحديث جديد متوفر!",
              body: "إصدار جديد من دواء تايم متاح. اضغط للتحديث الآن.",
            },
            data: {
              type: "update_available",
              version: after.version || "",
              title: "تحديث جديد متوفر!",
              body: "إصدار جديد من دواء تايم متاح. اضغط للتحديث الآن.",
            },
            apns: {
              headers: {
                "apns-priority": "10",
                "apns-push-type": "alert",
              },
              payload: {
                aps: {
                  "alert": {
                    title: "تحديث جديد متوفر!",
                    body: "إصدار جديد من دواء تايم متاح. اضغط للتحديث الآن.",
                  },
                  "sound": "default",
                  "badge": 1,
                  "content-available": 1,
                  "mutable-content": 1,
                },
              },
            },
            android: {
              priority: "high",
              notification: {
                channelId: "updates",
                priority: "max",
                defaultSound: true,
                defaultVibrateTimings: true,
              },
            },
            tokens: batch.map((u) => u.token),
          };
          promises.push({
            promise: admin.messaging().sendEachForMulticast(message),
            users: batch,
          });
        }
        for (let i = 0; i < englishUsers.length; i += batchSize) {
          const batch = englishUsers.slice(i, i + batchSize);
          const message = {
            notification: {
              title: "New Update Available!",
              body:
                "A new version of DawaTime is available. " +
                "Tap to update now.",
            },
            data: {
              type: "update_available",
              version: after.version || "",
              title: "New Update Available!",
              body:
                "A new version of DawaTime is available. " +
                "Tap to update now.",
            },
            apns: {
              headers: {
                "apns-priority": "10",
                "apns-push-type": "alert",
              },
              payload: {
                aps: {
                  "alert": {
                    title: "New Update Available!",
                    body:
                      "A new version of DawaTime is available. " +
                      "Tap to update now.",
                  },
                  "sound": "default",
                  "badge": 1,
                  "content-available": 1,
                  "mutable-content": 1,
                },
              },
            },
            android: {
              priority: "high",
              notification: {
                channelId: "updates",
                priority: "max",
                defaultSound: true,
                defaultVibrateTimings: true,
              },
            },
            tokens: batch.map((u) => u.token),
          };
          promises.push({
            promise: admin.messaging().sendEachForMulticast(message),
            users: batch,
          });
        }

        const results = await Promise.all(
            promises.map((p) => p.promise),
        );
        let successCount = 0;
        let failureCount = 0;
        const tokensToDelete = [];

        results.forEach((result, batchIndex) => {
          successCount += result.successCount;
          failureCount += result.failureCount;

          if (result.responses) {
            result.responses.forEach((response, tokenIndex) => {
              if (!response.success) {
                const error = response.error;
                const userBatch = promises[batchIndex].users;
                const token = userBatch[tokenIndex].token;

                console.error(
                    `Failed to send to token ${token.substring(0, 20)}...`,
                    error && error.code,
                    error && error.message,
                );

                if (
                  error && (
                    error.code === "messaging/invalid-registration-token" ||
                    error.code === "messaging/registration-token-not-registered"
                  )
                ) {
                  tokensToDelete.push(token);
                }
              }
            });
          }
        });

        console.log(
            "Update notification sent: " +
            `${successCount} success, ${failureCount} failures`,
        );


        if (tokensToDelete.length > 0) {
          console.log(`Cleaning up ${tokensToDelete.length} invalid tokens`);
          const deletePromises = [];

          for (const token of tokensToDelete) {
            const userQuery = admin
                .firestore()
                .collection("Users")
                .where("fcmToken", "==", token)
                .limit(1);

            deletePromises.push(
                userQuery.get().then((snapshot) => {
                  if (!snapshot.empty) {
                    const doc = snapshot.docs[0];
                    return doc.ref.update({
                      fcmToken: admin.firestore.FieldValue.delete(),
                    });
                  }
                  return null;
                }),
            );
          }

          await Promise.all(deletePromises);
          console.log(`✓ Cleaned up ${tokensToDelete.length} invalid tokens`);
        }

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

exports.blockAccessFromCertainCountries = functions
    .runWith({memory: "512MB", timeoutSeconds: 30})
    .https.onRequest((req, res) => {
      const ip =
        req.headers["x-forwarded-for"] || req.connection.remoteAddress;
      const geo = geoip.lookup(ip);
      if (geo && blockedCountries.includes(geo.country)) {
        console.log(`Blocked access from ${geo.country} (IP: ${ip})`);
        return res.status(403).send("Access denied in your country.");
      }
      res.status(200).send("Access granted.");
    });

exports.migrateLegalAcceptanceFields = functions
    .runWith({memory: "512MB", timeoutSeconds: 540})
    .https.onCall(async (data, context) => {
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated to run migration",
        );
      }

      const defaultTermsVersion = "1.0";
      const defaultPrivacyVersion = "1.0";
      const defaultAcceptanceDate = "2025-07-10T00:00:00.000Z";

      const results = {
        success: 0,
        alreadyMigrated: 0,
        failed: 0,
        errors: [],
      };

      try {
        const usersRef = admin.firestore().collection("Users");
        const snapshot = await usersRef.get();

        if (snapshot.empty) {
          return {
            message: "No users found to migrate",
            results,
          };
        }

        const batchSize = 500;
        let batch = admin.firestore().batch();
        let operationCount = 0;

        for (const doc of snapshot.docs) {
          const userData = doc.data();

          if (
            userData.acceptedTermsVersion &&
            userData.acceptedPrivacyVersion &&
            userData.legalAcceptanceDate
          ) {
            results.alreadyMigrated++;
            continue;
          }

          try {
            batch.update(doc.ref, {
              acceptedTermsVersion: defaultTermsVersion,
              acceptedPrivacyVersion: defaultPrivacyVersion,
              legalAcceptanceDate: defaultAcceptanceDate,
            });

            operationCount++;
            results.success++;

            if (operationCount >= batchSize) {
              await batch.commit();
              batch = admin.firestore().batch();
              operationCount = 0;
            }
          } catch (error) {
            results.failed++;
            results.errors.push({
              userId: doc.id,
              error: error.message,
            });
          }
        }

        if (operationCount > 0) {
          await batch.commit();
        }

        return {
          message: "Migration completed",
          results,
          totalProcessed: snapshot.size,
        };
      } catch (error) {
        console.error("Migration error:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Migration failed: " + error.message,
        );
      }
    });


exports.migrateLegalAcceptanceFieldsHTTP = functions
    .runWith({memory: "512MB", timeoutSeconds: 540})
    .https.onRequest(async (req, res) => {
      const providedSecret = req.query.secret ||
        (req.body && req.body.secret);
      const expectedSecret = process.env.MIGRATION_SECRET ||
        "dawatime-migration-2025";

      if (providedSecret !== expectedSecret) {
        return res.status(403).json({
          error: "Unauthorized. Invalid secret key.",
        });
      }

      const defaultTermsVersion = "1.0";
      const defaultPrivacyVersion = "1.0";
      const defaultAcceptanceDate = "2025-07-10T00:00:00.000Z";

      const results = {
        success: 0,
        alreadyMigrated: 0,
        failed: 0,
        errors: [],
      };

      try {
        const usersRef = admin.firestore().collection("Users");
        const snapshot = await usersRef.get();

        if (snapshot.empty) {
          return res.status(200).json({
            message: "No users found to migrate",
            results,
          });
        }

        const batchSize = 500;
        let batch = admin.firestore().batch();
        let operationCount = 0;

        for (const doc of snapshot.docs) {
          const userData = doc.data();

          if (
            userData.acceptedTermsVersion &&
            userData.acceptedPrivacyVersion &&
            userData.legalAcceptanceDate
          ) {
            results.alreadyMigrated++;
            continue;
          }

          try {
            batch.update(doc.ref, {
              acceptedTermsVersion: defaultTermsVersion,
              acceptedPrivacyVersion: defaultPrivacyVersion,
              legalAcceptanceDate: defaultAcceptanceDate,
            });

            operationCount++;
            results.success++;

            if (operationCount >= batchSize) {
              await batch.commit();
              batch = admin.firestore().batch();
              operationCount = 0;
            }
          } catch (error) {
            results.failed++;
            results.errors.push({
              userId: doc.id,
              error: error.message,
            });
          }
        }

        if (operationCount > 0) {
          await batch.commit();
        }

        return res.status(200).json({
          message: "Migration completed successfully",
          results,
          totalProcessed: snapshot.size,
          timestamp: new Date().toISOString(),
        });
      } catch (error) {
        console.error("Migration error:", error);
        return res.status(500).json({
          error: "Migration failed",
          message: error.message,
          results,
        });
      }
    });

/**
 * Check version adoption across users
 * GET https://us-central1-medication-cd9b8.cloudfunctions.net/checkVersionAdoption?secret=dawatime-admin-2025
 */
exports.checkVersionAdoption = functions.https.onRequest(async (req, res) => {
  // Security check
  if (req.query.secret !== "dawatime-admin-2025") {
    return res.status(403).json({error: "Unauthorized"});
  }

  try {
    console.log("Starting version adoption check...");
    const usersSnapshot = await admin.firestore().collection("Users").get();
    console.log(`Found ${usersSnapshot.size} users`);

    const versionCounts = {};
    const nullVersionUsers = [];
    let totalUsers = 0;
    let usersWithVersion = 0;
    let oldStructureCount = 0;
    let newStructureCount = 0;

    for (const doc of usersSnapshot.docs) {
      totalUsers++;
      const data = doc.data();
      const version = data.lastAppVersion || null;

      if (version) {
        usersWithVersion++;
        versionCounts[version] = (versionCounts[version] || 0) + 1;
      } else {
        nullVersionUsers.push(doc.id);
      }

      // Check which structure they're using
      const oldMeds = await admin
          .firestore()
          .collection(doc.id)
          .limit(1)
          .get();
      const newMeds = await admin
          .firestore()
          .collection("Users")
          .doc(doc.id)
          .collection("medications")
          .limit(1)
          .get();

      if (!oldMeds.empty) oldStructureCount++;
      if (!newMeds.empty) newStructureCount++;
    }

    // Sort versions
    const sortedVersions = Object.entries(versionCounts).sort((a, b) => {
      const [majorA = 0, minorA = 0, patchA = 0] =
        a[0].split(".").map(Number);
      const [majorB = 0, minorB = 0, patchB = 0] =
        b[0].split(".").map(Number);
      if (majorB !== majorA) return majorB - majorA;
      if (minorB !== minorA) return minorB - minorA;
      return patchB - patchA;
    });

    const result = {
      timestamp: new Date().toISOString(),
      summary: {
        totalUsers,
        usersWithVersion,
        usersWithVersionPercent:
          ((usersWithVersion / totalUsers) * 100).toFixed(1),
        usersWithoutVersion: nullVersionUsers.length,
      },
      versions: sortedVersions.map(([version, count]) => ({
        version,
        count,
        percentage: ((count / totalUsers) * 100).toFixed(1),
      })),
      database: {
        oldStructure: oldStructureCount,
        newStructure: newStructureCount,
        bothStructures: Math.max(
            0,
            oldStructureCount + newStructureCount - totalUsers,
        ),
      },
      usersWithoutVersion: nullVersionUsers.slice(0, 20), // Limit to 20
    };

    console.log("Version adoption check complete");
    return res.status(200).json(result);
  } catch (error) {
    console.error("Error checking version adoption:", error);
    console.error("Error stack:", error.stack);
    return res.status(500).json({
      error: error.message,
      stack: error.stack,
    });
  }
});
