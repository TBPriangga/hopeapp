const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();

exports.sendDailyWordNotification = onSchedule("0 5 * * *", {
    timeZone: "Asia/Jakarta",
    maxInstances: 1,
    memory: "256MiB",
}, async (context) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        logger.info("Starting daily word notification process", {
            date: today.toISOString(),
            structuredData: true,
        });

        const dailyWordSnapshot = await admin.firestore()
            .collection("daily_words")
            .where("date", ">=", today)
            .where("date", "<", tomorrow)
            .where("isActive", "==", true)
            .limit(1)
            .get();

        if (!dailyWordSnapshot.empty) {
            const dailyWord = dailyWordSnapshot.docs[0].data();

            const message = {
                notification: {
                    title: "Renungan Hari Ini",
                    body: dailyWord.verse,
                },
                data: {
                    type: "daily_word",
                    verse: dailyWord.verse,
                    content: dailyWord.content,
                    description: dailyWord.description,
                    bibleUrl: dailyWord.bibleUrl,
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                android: {
                    notification: {
                        channelId: "daily_word_channel",
                        priority: "high",
                        sound: "default",
                    },
                },
                topic: "daily_word",
            };

            await admin.messaging().send(message);
            logger.info("Daily word notification sent successfully", {
                verse: dailyWord.verse,
                structuredData: true,
            });

            await admin.firestore().collection("notification_logs").add({
                type: "daily_word",
                verse: dailyWord.verse,
                content: dailyWord.content,
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                success: true,
            });
        } else {
            logger.warn("No daily word found for today");

            await admin.firestore().collection("notification_logs").add({
                type: "daily_word",
                error: "No daily word found",
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                success: false,
            });
        }

        return null;
    } catch (error) {
        logger.error("Error sending daily word notification:", error);

        await admin.firestore().collection("notification_logs").add({
            type: "daily_word",
            error: error.message,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            success: false,
        });

        throw error;
    }
});

exports.checkAndSendEventNotifications = onSchedule("0 9 * * *", {
    timeZone: "Asia/Jakarta",
    maxInstances: 1,
    memory: "256MiB",
}, async (context) => {
    try {
        const now = new Date();
        const threeDaysFromNow = new Date(now);
        threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);
        const oneDayFromNow = new Date(now);
        oneDayFromNow.setDate(oneDayFromNow.getDate() + 1);

        now.setHours(0, 0, 0, 0);
        threeDaysFromNow.setHours(0, 0, 0, 0);
        oneDayFromNow.setHours(0, 0, 0, 0);

        const eventsSnapshot = await admin.firestore()
            .collection("events")
            .where("isActive", "==", true)
            .where("date", ">=", now)
            .where("date", "<=", threeDaysFromNow)
            .get();

        for (const doc of eventsSnapshot.docs) {
            const event = doc.data();
            const eventDate = event.date.toDate();
            eventDate.setHours(0, 0, 0, 0);

            let notificationTitle = "";
            let notificationBody = "";

            if (eventDate.getTime() === threeDaysFromNow.getTime()) {
                notificationTitle = "📅 Event dalam 3 hari";
                notificationBody = `${event.title} akan berlangsung 3 hari lagi`;
            } else if (eventDate.getTime() === oneDayFromNow.getTime()) {
                notificationTitle = "📅 Event besok!";
                notificationBody = `${event.title} akan berlangsung besok`;
            } else if (eventDate.getTime() === now.getTime()) {
                notificationTitle = "🎉 Event hari ini!";
                notificationBody = `${event.title} berlangsung hari ini`;
            }

            if (notificationTitle && notificationBody) {
                const message = {
                    notification: {
                        title: notificationTitle,
                        body: notificationBody,
                    },
                    data: {
                        type: "event",
                        eventId: doc.id,
                        title: event.title,
                        date: event.date.toDate().toISOString(),
                        location: event.location,
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    android: {
                        notification: {
                            channelId: "event_channel",
                            priority: "high",
                            sound: "default",
                        },
                    },
                    topic: "events",
                };

                await admin.messaging().send(message);
                logger.info("Event notification sent:", {
                    eventId: doc.id,
                    title: event.title,
                    notificationType: notificationTitle,
                });

                await admin.firestore().collection("notification_logs").add({
                    type: "event",
                    eventId: doc.id,
                    eventTitle: event.title,
                    notificationTitle,
                    notificationBody,
                    sentAt: admin.firestore.FieldValue.serverTimestamp(),
                    success: true,
                });
            }
        }

        return null;
    } catch (error) {
        logger.error("Error sending event notifications:", error);

        await admin.firestore().collection("notification_logs").add({
            type: "event",
            error: error.message,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            success: false,
        });

        throw error;
    }
});

exports.sendBirthdayNotifications = onSchedule("0 7 * * *", {  // Jam 7 pagi
    timeZone: "Asia/Jakarta",
    maxInstances: 1,
    memory: "256MiB",
}, async (context) => {
    try {
        const today = new Date();
        const month = today.getMonth() + 1; // JavaScript months are 0-based
        const day = today.getDate();

        // Query users yang berulang tahun hari ini
        const usersSnapshot = await admin.firestore()
            .collection("users")
            .where("birthMonth", "==", month)
            .where("birthDay", "==", day)
            .get();

        if (!usersSnapshot.empty) {
            // Kumpulkan nama-nama yang ulang tahun
            const birthdayUsers = usersSnapshot.docs.map(doc => {
                const userData = doc.data();
                return {
                    id: doc.id,
                    name: userData.name,
                };
            });

            // Jika ada yang berulang tahun, kirim notifikasi ke semua user
            if (birthdayUsers.length > 0) {
                const names = birthdayUsers.map(user => user.name).join(", ");
                const message = {
                    notification: {
                        title: "🎂 Selamat Ulang Tahun!",
                        body: birthdayUsers.length === 1
                            ? `Hari ini adalah ulang tahun ${names}! Mari doakan bersama!`
                            : `Hari ini adalah ulang tahun ${names}! Mari doakan mereka bersama!`,
                    },
                    data: {
                        type: "birthday",
                        userIds: JSON.stringify(birthdayUsers.map(u => u.id)),
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    android: {
                        notification: {
                            channelId: "birthday_channel",
                            priority: "high",
                            sound: "default",
                        },
                    },
                    topic: "birthdays", // Semua user akan subscribe ke topic ini
                };

                await admin.messaging().send(message);
                logger.info("Birthday notifications sent for:", {
                    users: names,
                    structuredData: true,
                });

                // Log notifikasi
                await admin.firestore().collection("notification_logs").add({
                    type: "birthday",
                    users: birthdayUsers,
                    sentAt: admin.firestore.FieldValue.serverTimestamp(),
                    success: true,
                });
            }
        }

        return null;
    } catch (error) {
        logger.error("Error sending birthday notifications:", error);

        await admin.firestore().collection("notification_logs").add({
            type: "birthday",
            error: error.message,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            success: false,
        });

        throw error;
    }
});