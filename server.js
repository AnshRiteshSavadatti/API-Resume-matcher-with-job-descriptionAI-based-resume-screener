const express = require("express");
const bodyParser = require("body-parser");
const { spawn } = require("child_process");

const PORT = process.env.PORT || 5000;

const app = express();
app.use(bodyParser.json());

app.post("/api/compare", (req, res) => {
  const { resume, jobDescription } = req.body;

  if (!resume || !jobDescription) {
    return res.status(400).json({
      error: "Missing resume or job description in the request body.",
    });
  }

  const python = spawn("python", [
    "similarity.py",
    JSON.stringify(resume),
    JSON.stringify(jobDescription),
  ]);

  let output = "";
  let errorOutput = "";

  python.stdout.on("data", (data) => {
    output += data.toString();
  });

  python.stderr.on("data", (data) => {
    errorOutput += data.toString();
  });

  python.on("close", (code) => {
    if (code !== 0) {
      console.error("Python script error:", errorOutput);
      return res.status(500).json({
        error: "An error occurred while processing the Python script.",
        details: errorOutput,
      });
    }

    const similarityScore = parseFloat(output);
    if (isNaN(similarityScore)) {
      return res.status(500).json({
        error: "Failed to parse similarity score.",
        details: output,
      });
    }

    return res.status(200).json({ similarityScore });
  });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
