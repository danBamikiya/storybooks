const express = require("express");
const router = express.Router();
const { ensureAuth, ensureGuest } = require("../middlewares/auth");

// @desc        Login/Landing page
// @route       GET /
router.get("/", ensureGuest, (req, res) => {
  res.render("login", {
    layout: "login"
  });
});

// @desc        Dashboard
// @route       Get /dashboard
router.get("/dashboard", ensureAuth, (req, res) => {
  res.render("dashboard", {
    name: req.user.firstName
  });
});

module.exports = router;
