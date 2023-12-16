const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const naverLogin = require("./naver_login.js");

exports.naverCustomAuth = naverLogin.naverCustomAuth;
