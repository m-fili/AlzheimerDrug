# Pharmaceutical Drug for Alzheimer's Disease Shiny App

## Overview
This Shiny application simulates data collection for a  pharmaceutical drug designed to treat Alzheimer's Disease. It generates sample data for capsule ingredients (Memorin, Galantamine, Vitamin E), applies quality control checks, and provides downloadable results. The app is designed for educational or demonstration purposes, mimicking a real-world pharmaceutical quality assurance process.

## Prerequisites
- **R**: Version 4.0.0 or higher recommended.
- **R Packages**:
  - `shiny`
  - `shinythemes`
  - `DT`
  - `jsonlite`
- The app automatically checks and installs these packages if missing (requires internet access).

## Run the app locally in R
```r
shiny::runGitHub("AlzheimerDrug", "m-fili")
```

## Usage
1. **Launch the App**:
   - Run this command in R `shiny::runGitHub("AlzheimerDrug", "m-fili")`.
2. **Enter Team Number**:
   - A modal will prompt for a team number (1–6). Submit to proceed.
3. **Generate Data**:
   - Enter a sample size (minimum 10) and click "Generate Sample." A progress bar will show during analysis.
4. **View Results**:
   - A table displays capsule data with Pass/Fail status and color-coded ranges.
   - Click "Compute Sample Statistics" to view summary stats (mean, SD, min, max).
5. **Download**:
   - Click "Download Data as CSV" to save the results.
