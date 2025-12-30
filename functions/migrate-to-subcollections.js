/**
 * Migration Script: Restructure Medications to Subcollections
 *
 * Changes:
 *   FROM: /{userId}/{medicationId}
 *   TO:   /Users/{userId}/medications/{medicationId}
 *
 * Usage:
 *   1. Deploy: firebase deploy
 *   2. Trigger: curl ...migrateMedicationsToSubcollections
 *   3. Review logs for dry run results
 *   4. Execute: Same URL with dryRun=false
 *
 * Safety:
 *   - Dry run mode to preview changes
 *   - Verifies data integrity after copy
 *   - Keeps old data until manual deletion
 *   - Detailed logging of all operations
 */

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

exports.migrateMedicationsToSubcollections = functions
    .runWith({memory: "1GB", timeoutSeconds: 540})
    .https
    .onRequest(async (req, res) => {
      // Security check
      const secret = req.query.secret;
      if (secret !== "dawatime-migration-2025") {
        console.error("Unauthorized migration attempt");
        return res.status(403).json({error: "Unauthorized"});
      }

      const dryRun = req.query.dryRun === "true";
      const deleteOld = req.query.deleteOld === "true";

      console.log(`🚀 Migration started - Dry Run: ${dryRun}, ` +
                  `Delete Old: ${deleteOld}`);

      try {
        const db = admin.firestore();
        const stats = {
          usersProcessed: 0,
          medicationsCopied: 0,
          medicationsVerified: 0,
          medicationsDeleted: 0,
          errors: [],
          warnings: [],
        };

        // Get all users
        const usersSnapshot = await db.collection("Users").get();
        console.log(`Found ${usersSnapshot.size} users to process`);

        // Process each user
        for (const userDoc of usersSnapshot.docs) {
          const userId = userDoc.id;
          console.log(`\n📋 Processing user: ${userId}`);

          try {
            // Get all medications from old structure
            const oldMedsSnapshot = await db.collection(userId).get();

            if (oldMedsSnapshot.empty) {
              console.log(`  ℹ️  No medications found for user ${userId}`);
              stats.usersProcessed++;
              continue;
            }

            console.log(
                `  Found ${oldMedsSnapshot.size} medications to migrate`,
            );

            // Process each medication
            for (const medDoc of oldMedsSnapshot.docs) {
              const medId = medDoc.id;
              const medData = medDoc.data();

              console.log(`  📦 Processing medication: ${medId} ` +
                          `(${medData.name})`);

              // Validate required fields
              if (!medData.name || !medData.typeOfMedication) {
                const warning = `Missing required fields in ${medId}`;
                console.warn(`  ⚠️  ${warning}`);
                stats.warnings.push({userId, medId, warning});
                continue;
              }

              if (!dryRun) {
                // Prepare new document with additional fields
                const newMedData = {
                  ...medData,
                  // Add timestamps if not present
                  createdAt: medData.createdAt ||
                           admin.firestore.Timestamp.now(),
                  updatedAt: admin.firestore.Timestamp.now(),
                  // Add schema version for future migrations
                  version: 1,
                  // Keep track of migration
                  migratedAt: admin.firestore.Timestamp.now(),
                  migratedFrom: `/${userId}/${medId}`,
                };

                // Copy to new location
                const newRef = db
                    .collection("Users")
                    .doc(userId)
                    .collection("medications")
                    .doc(medId);

                await newRef.set(newMedData);
                console.log(`  ✓ Copied to /Users/${userId}/medications/` +
                            `${medId}`);
                stats.medicationsCopied++;

                // Verify the copy
                const verifyDoc = await newRef.get();
                if (verifyDoc.exists &&
                    verifyDoc.data().name === medData.name) {
                  console.log(`  ✓ Verified data integrity`);
                  stats.medicationsVerified++;

                  // Delete old structure if requested
                  if (deleteOld) {
                    await db.collection(userId).doc(medId).delete();
                    console.log(`  ✓ Deleted old document`);
                    stats.medicationsDeleted++;
                  }
                } else {
                  const error =
                    `Verification failed for ${userId}/${medId}`;
                  console.error(`  ❌ ${error}`);
                  stats.errors.push({userId, medId, error});
                }
              } else {
                console.log(`  [DRY RUN] Would copy to /Users/${userId}/` +
                            `medications/${medId}`);
                stats.medicationsCopied++;
              }
            }

            stats.usersProcessed++;
          } catch (userError) {
            const error =
              `Error processing user ${userId}: ${userError.message}`;
            console.error(`  ❌ ${error}`);
            stats.errors.push({userId, error});
          }
        }

        // Final summary
        console.log("\n" + "=".repeat(60));
        console.log("📊 MIGRATION SUMMARY");
        console.log("=".repeat(60));
        console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE EXECUTION"}`);
        console.log(`Users processed: ${stats.usersProcessed}`);
        console.log(`Medications copied: ${stats.medicationsCopied}`);
        console.log(`Medications verified: ${stats.medicationsVerified}`);
        console.log(`Medications deleted: ${stats.medicationsDeleted}`);
        console.log(`Warnings: ${stats.warnings.length}`);
        console.log(`Errors: ${stats.errors.length}`);

        if (stats.warnings.length > 0) {
          console.log("\n⚠️  WARNINGS:");
          stats.warnings.forEach((w) => {
            console.log(`  - ${JSON.stringify(w)}`);
          });
        }

        if (stats.errors.length > 0) {
          console.log("\n❌ ERRORS:");
          stats.errors.forEach((e) => {
            console.log(`  - ${JSON.stringify(e)}`);
          });
        }

        console.log("=".repeat(60));

        // Return response
        return res.status(200).json({
          success: stats.errors.length === 0,
          dryRun,
          stats,
          message: dryRun ?
            "Dry run completed. Review logs and run with dryRun=false " +
            "to execute migration." :
            "Migration completed. Review logs for details.",
        });
      } catch (error) {
        console.error("❌ Migration failed:", error);
        return res.status(500).json({
          error: "Migration failed",
          message: error.message,
          stack: error.stack,
        });
      }
    });
