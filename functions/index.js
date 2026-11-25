const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

// ————————————————————————————————
// Notificació quan s'afegeix un càstig nou
// ————————————————————————————————
exports.nouCastig = onDocumentCreated("castigs/{castigId}", async (event) => {
  const castig = event.data.data();
  const grupoId = castig.grupoId;
  const textCastig = castig.text;

  const grupDoc = await admin.firestore()
    .collection("grupos")
    .doc(grupoId)
    .get();

  if (!grupDoc.exists) return null;

  const membres = grupDoc.data().miembros || [];

  const tokens = [];
  for (const uid of membres) {
    const usuariDoc = await admin.firestore()
      .collection("usuaris")
      .doc(uid)
      .get();
    if (usuariDoc.exists && usuariDoc.data().fcmToken) {
      tokens.push(usuariDoc.data().fcmToken);
    }
  }

  if (tokens.length === 0) return null;

  return admin.messaging().sendEachForMulticast({
    notification: {
      title: "💀 Nou càstig proposat!",
      body: textCastig,
    },
    tokens: tokens,
  });
});

// ————————————————————————————————
// Notificació cada diumenge a les 20:00
// ————————————————————————————————
exports.resumSetmanal = onSchedule(
  { schedule: "0 20 * * 0", timeZone: "Europe/Madrid" },
  async (event) => {
    const ara = new Date();
    const iniciSetmana = new Date(ara);
    iniciSetmana.setDate(ara.getDate() - ara.getDay() + 1);
    iniciSetmana.setHours(0, 0, 0, 0);

    const grups = await admin.firestore().collection("grupos").get();

    for (const grupDoc of grups.docs) {
      const grup = grupDoc.data();
      const membres = grup.miembros || [];
      const noms = grup.nombresMiembros || {};

      const entrenos = await admin.firestore()
        .collection("entrenos")
        .where("grupoId", "==", grupDoc.id)
        .where("computa", "==", true)
        .where("fecha", ">=", admin.firestore.Timestamp.fromDate(iniciSetmana))
        .get();

      // Comptem dies únics per membre
      const diesUnics = {};
      for (const entDoc of entrenos.docs) {
        const ent = entDoc.data();
        const uid = ent.usuariId;
        const data = ent.fecha.toDate();
        const clau = `${data.getFullYear()}-${data.getMonth()}-${data.getDate()}`;
        if (!diesUnics[uid]) diesUnics[uid] = new Set();
        diesUnics[uid].add(clau);
      }

      // Trobem el perdedor
      let perdedorId = null;
      let minDies = Infinity;
      for (const uid of membres) {
        const dies = diesUnics[uid]?.size || 0;
        if (dies < minDies) {
          minDies = dies;
          perdedorId = uid;
        }
      }

      if (!perdedorId) continue;
      const nomPerdedor = noms[perdedorId] || "algú";

      const tokens = [];
      for (const uid of membres) {
        const usuariDoc = await admin.firestore()
          .collection("usuaris")
          .doc(uid)
          .get();
        if (usuariDoc.exists && usuariDoc.data().fcmToken) {
          tokens.push(usuariDoc.data().fcmToken);
        }
      }

      if (tokens.length === 0) continue;

      await admin.messaging().sendEachForMulticast({
        notification: {
          title: "😅 Final de setmana!",
          body: `${nomPerdedor} ha perdut aquesta setmana amb només ${minDies} dies. Voteu el càstig!`,
        },
        tokens: tokens,
      });
    }

    return null;
  }
);