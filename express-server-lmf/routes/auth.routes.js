const router = require("express").Router();
const authController = require("../controllers/auth.controller");

router.post("/login", authController.login);
router.get("/refresh-token", authController.refreshToken);
router.get("/logout", authController.logout);

module.exports = router;
