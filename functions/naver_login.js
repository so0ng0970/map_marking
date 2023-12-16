const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const Async = require("async");
admin.initializeApp();

const naverRequestMeUrl = "https://openapi.naver.com/v1/nid/me";
exports.createFirebaseToken = functions.https.onRequest((req, res) => {
  const naverAccessToken = req.body.token;

  Async.waterfall(
    [
      (next) => {
        axios
          .get(naverRequestMeUrl, {
            headers: { Authorization: "Bearer " + naverAccessToken },
          })
          .then((result) => {
            const body = result.data.response;
            const userId = `naver:${body.id}`;
            const nickname = null;

            const updateParams = {
              uid: userId,
              email: body.email,
              provider: "NAVER",
              displayName: body.nickname || body.email,
              photoURL: body.profile_image,
            };

            next(null, updateParams);
          })
          .catch((error) => {
            res.status(404).send({
              message: "There was no user with the given access token.",
            });
          });
      },
      (userRecord, next) => {
        admin
          .auth()
          .getUserByEmail(userRecord.email)
          .then((userRecord) => {
            next(null, userRecord);
          })
          .catch((error) => {
            admin
              .auth()
              .createUser(userRecord)
              .then((user) => {
                next(null, user);
              });
          });
      },
      (userRecord, next) => {
        const userId = userRecord.uid;
        admin
          .auth()
          .createCustomToken(userId, { provider: "NAVER" })
          .then((token) => {
            next(null, token);
          });
      },
    ],
    (err, token) => {
      if (err) {
        res
          .status(500)
          .send({ error: "Error creating custom token", details: err });
      } else {
        res.send({ token });
      }
    }
  );
});
