<h1 align="center">🧠 NCD-RisC Data Analysis – Formative Assignment</h1>

<p align="center">
  <b>R Markdown · Data Visualisation · Global Health · CRISP-DM</b><br>
  <a href="https://github.com/Rucyvar/Formative-Assignment/stargazers">
    <img src="https://img.shields.io/github/stars/Rucyvar/Formative-Assignment?color=gold" alt="Stars">
  </a>
  <a href="https://github.com/Rucyvar/Formative-Assignment/issues">
    <img src="https://img.shields.io/github/issues/Rucyvar/Formative-Assignment?color=red" alt="Issues">
  </a>
  <a href="https://github.com/Rucyvar/Formative-Assignment/commits/main">
    <img src="https://img.shields.io/github/last-commit/Rucyvar/Formative-Assignment?color=blue" alt="Last Commit">
  </a>
</p>

---

## 📘 Overview

This repository contains the R Markdown-based analysis for the **NCD-RisC (Non-Communicable Disease Risk Factor Collaboration)** dataset.  
The objective is to explore **global health trends** such as **BMI, blood pressure, and diabetes prevalence** across years and regions.

The project follows the **CRISP-DM framework** — from business understanding to deployment — to interpret long-term public-health trends and provide data-driven insights.

---

## 🧑‍💻 Authors

| Name |
|------|
| **Rushi Girdharbhai Vasoya** | 
| Rishabh Yadav | 
| Siram Hemanth | 

---

## 🎯 Objectives

- Analyse **trends (1990 – 2015)** in BMI, Blood Pressure, and Diabetes.  
- Compare **male vs female** differences globally and by region.  
- Identify **top 10 countries** for each indicator in the latest year.  
- Create reproducible **R Markdown report** with visual explanations.

---

## 🧩 Repository Structure

Formative-Assignment/
├── data/ # Raw and processed CSV datasets
│ ├── ncd_bmi.csv
│ ├── ncd_bp.csv
│ └── ncd_diabetes.csv
│
├── graphs/ # Output visualisations
│ ├── fig1_BMI_Trends.png
│ └── fig2_BP_Trends.png
│
├── reports/ # Final report and R Markdown source
│ ├── NCD_RisC_Report.Rmd
│ └── NCD_RisC_Report.pdf
│
├── scripts/ # Custom helper functions (optional)
│ └── utils.R
│
├── .Rproj # R Project configuration
├── requirements.txt # List of required R packages
└── README.md # This file
