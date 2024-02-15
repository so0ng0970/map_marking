const functions = require("firebase-functions");
const naverRequestMeUrl = "https://openapi.naver.com/v1/nid/me";
const { CLIENT_ID, CLIENT_SECRET } = require("../data/const");
exports.naverCustomAuth = functions
  .region("us-central1")
  .https.onCall((data, context) => {
    const token = data.token;
    if (!token) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Access token is a required parameter."
      );
    }

    console.log(`Verifying naver token: ${token}`);
    return createNaverFirebaseToken(token).then((firebaseToken) => {
      console.log(`Returning firebase token to user: ${firebaseToken}`);
      return { firebase_token: firebaseToken };
    });
  });
function naverRequestMe(naverAccessToken) {
  console.log("Requesting user profile from Naver API server.");
  return request({
    method: "GET",
    headers: {
      Authorization: "Bearer " + naverAccessToken,
      "X-Naver-Client-Id": CLIENT_ID,
      "X-Naver-Client-Secret": CLIENT_SECRET,
    },
    url: naverRequestMeUrl,
  });
}

async function updateOrCreateUserNaver(userId, email) {
  functions.logger.log("updating or creating a firebase user");

  const updateParams = {
    provider: "NAVER",
    displayName: userId,
  };
  updateParams["displayName"] = email;
  updateParams["email"] = email;
  functions.logger.log("updating or creating a firebase user,", updateParams);

  try {
    functions.logger.log("try updateUser ,");
    return await admin.auth().getUserByEmail(updateParams["email"]);
  } catch (error) {
    functions.logger.log("errorcode", error.code);
    if (error.code === "auth/user-not-found") {
      try {
        console.log("try createUser ");
        // updateParams['uid'] = userId;
        if (email) {
          updateParams["email"] = email;
        }
        return admin.auth().createUser(updateParams);
      } catch (error) {
        functions.logger.log("errorcode", error.code);
        return res
          .status(400)
          .send({ error: error.code })
          .send({ message: "Naver Login Error" });
        throw error;
      }
    }
    throw error;
  }
}
function createNaverFirebaseToken(naverAccessToken) {
  functions.logger.log("createNaverFirebaseToken", naverAccessToken);
  return naverRequestMe(naverAccessToken)
    .then((response) => {
      const body = JSON.parse(response);
      console.log(body);
      const userId = `naver:${body.response.id}`;
      if (!userId) {
        return res
          .status(404)
          .send({ message: "There was no user with the given access token." });
      }

      return updateOrCreateUserNaver(userId, body.response.email);
    })
    .then((userRecord) => {
      const userId = userRecord.uid;
      console.log(`creating a custom firebase token based on uid ${userId}`);
      return admin.auth().createCustomToken(userId, { provider: "NAVER" });
    });
}
