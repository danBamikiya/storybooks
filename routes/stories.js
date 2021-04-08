const express = require("express");
const router = express.Router();

const { ensureAuth } = require("../middlewares/auth");
const Story = require("../models/Story");

// @desc        Show add page
// @route       GET /stories/add
router.get("/add", ensureAuth, (req, res) => {
  res.render("stories/add");
});

// @desc        Process add form
// @route       POST /stories
router.post("/", ensureAuth, async (req, res) => {
  try {
    req.body.user = req.user.id;
    await Story.create(req.body);
    res.redirect("/dashboard");
  } catch (err) {
    console.error(err);
    res.render("error/500");
  }
});

// @desc        Show all stories
// @route       GET /stories/add
router.get("/", ensureAuth, async (req, res) => {
  try {
    const stories = await Story.find({ status: "public" })
      .populate("user")
      .sort({ createdAt: "desc" })
      .lean();

    res.render("stories/index", {
      stories
    });
  } catch (error) {
    console.error(error);
    res.render("error/500");
  }
});

// @desc  Show edit page
// @route GET/stories/:id
router.get("/edit/:id", ensureAuth, async (req, res) => {
  const story = await Story.findOne({
    _id: req.params.id
  }).lean();

  if (!story) {
    return res.render("error/404");
  }

  if (story.user !== req.user.id) {
    res.redirect("/stories");
  } else {
    res.render("/stories/edit", {
      story
    });
  }
});

module.exports = router;
