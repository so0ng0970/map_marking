const functions = require("firebase-functions");
const admin = require("firebase-admin");
require("dotenv").config();

let serviceAccount = {
  type: process.env.TYPE,
  project_id: process.env.PROJECT_ID,
  private_key_id: process.env.PRIVATE_KEY_ID,
  private_key: process.env.PRIVATE_KEY,
  client_email: process.env.CLIENT_EMAIL,
  client_id: process.env.CLIENT_ID,
  auth_uri: process.env.AUTH_URI,
  token_uri: process.env.TOKEN_URI,
  auth_provider_x509_cert_url: process.env.AUTH_PROVIDER_X_CERT_URL,
  client_x509_cert_url: process.env.CLIENT_X_CERT_URL,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://honeytip-deb2e.firebaseio.com",
});

const request = require("request-promise");

const naverRequestMeUrl = "https://openapi.naver.com/v1/nid/me";

function requestMe(naverAccessToken) {
  console.log("Requesting user profile from Naver API server.");
  return request({
    method: "GET",
    headers: {
      Authorization: "Bearer " + naverAccessToken,
      "X-Naver-Client-Id": "YYnLXjkdfl6W1vWNfOel",
      "X-Naver-Client-Secret": "GtJShppKea",
    },
    url: naverRequestMeUrl,
  });
}

function updateOrCreateUser(userId, email, displayName, photoURL) {
  console.log("updating or creating a firebase user");
  const updateParams = {
    provider: "NAVER",
    displayName: displayName,
  };
  if (displayName) {
    updateParams["displayName"] = displayName;
  } else {
    updateParams["displayName"] = email;
  }
  if (photoURL) {
    updateParams["photoURL"] = photoURL;
  }
  console.log(updateParams);
  return admin
    .auth()
    .updateUser(userId, updateParams)
    .catch((error) => {
      if (error.code === "auth/user-not-found") {
        updateParams["uid"] = userId;
        if (email) {
          updateParams["email"] = email;
        }
        return admin.auth().createUser(updateParams);
      }
      throw error;
    });
}

function createFirebaseToken(naverAccessToken) {
  return requestMe(naverAccessToken)
    .then((response) => {
      const body = JSON.parse(response);
      console.log(body);
      const userId = `naver:${body.response.id}`;
      if (!userId) {
        return res
          .status(404)
          .send({ message: "There was no user with the given access token." });
      }
      let name = null;
      let profileImage = null;
      if (body.properties) {
        name = body.response.name;
        profileImage = body.response.profile_image;
      }
      return updateOrCreateUser(
        userId,
        body.response.email,
        name,
        profileImage
      );
    })
    .then((userRecord) => {
      const userId = userRecord.uid;
      console.log(`creating a custom firebase token based on uid ${userId}`);
      return admin.auth().createCustomToken(userId, { provider: "KAKAO" });
    });
}

exports.naverCustomAuth = functions
  .region("us-central1")
  .https.onRequest((req, res) => {
    const token = req.body.token;
    if (!token)
      return res
        .status(400)
        .send({ error: "There is no token." })
        .send({ message: "Access token is a required parameter." });

    console.log(`Verifying naver token: ${token}`);
    createFirebaseToken(token).then((firebaseToken) => {
      console.log(`Returning firebase token to user: ${firebaseToken}`);
      res.send({ firebase_token: firebaseToken });
    });

    return;
  });
