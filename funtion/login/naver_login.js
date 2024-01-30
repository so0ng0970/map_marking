const naverRequestMeUrl = "https://openapi.naver.com/v1/nid/me";

exports.naverCustomAuth = functions
  .region("asia-northeast3")
  .https.onRequest((req, res) => {
    functions.logger.log("네이버 로그인 시작 body", req.body);
    const token = req.body.token;
    if (!token)
      return res
        .status(400)
        .send({ error: "There is no token." })
        .send({ message: "Access token is a required parameter." });

    console.log(`Verifying naver token: ${token}`);
    createNaverFirebaseToken(token).then((firebaseToken) => {
      console.log(`Returning firebase token to user: ${firebaseToken}`);
      res.send({ firebase_token: firebaseToken });
    });

    return;
  });
function naverRequestMe(naverAccessToken) {
  console.log("Requesting user profile from Naver API server.");
  return request({
    method: "GET",
    headers: {
      Authorization: "Bearer " + naverAccessToken,
      "X-Naver-Client-Id": "본인의 client id~~~~~~~~~~~~",
      "X-Naver-Client-Secret": "본인의 client Secret~~~~~~~~~~~~",
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
  updateParams["email"] = email; //22.02.22 추가함
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
exports.naverCustomAuth = naverCustomAuth;
