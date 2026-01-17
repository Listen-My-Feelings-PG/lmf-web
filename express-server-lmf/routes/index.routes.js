const { app } = require("../main");
const authRoutes = require("./auth.routes");
const finesRoutes = require("./fines.routes");
const appRoutes = require("./app.routes");
const jwt = require("../services/jwt.service");
const uploadRoutes = require("./upload.routes");

app.get('/test', (_, res) => { return res.status(200).json({ message: 'Test route is working!' }); });
app.use("/api/v1/auth", jwt.checkToken, authRoutes);

app.use("/app/v1", appRoutes);