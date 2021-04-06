const express = require("express");
const router = express.Router();

const { ensureAuth } = require("../middlewares/auth");
const Story = require("../models/Story");

// @desc        Show add page
// @route       GET /stories/add
router.get("/add", ensureAuth, (req, res) => {
  res.render("stories/add");
});

module.exports = router;
