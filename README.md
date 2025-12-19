# Tariffs and Employment: A VAR Analysis of the U.S. Economy

## 📌 Project Overview
This project examines the dynamic relationship between U.S. tariffs and employment using Vector Autoregression (VAR) models. Two alternative tariff measures are analyzed to assess their impact on employment over time:

1. **Tariff Revenues as a Percentage of GDP**
2. **Tariff Rate (%) – Customs Duties relative to Imports**

The analysis focuses on causal relationships, impulse responses, and employment forecasts using quarterly U.S. macroeconomic data from FRED.

---

## 📊 Data Sources (FRED)
All data are obtained from the Federal Reserve Economic Data (FRED) database.

| Series ID | Description | Frequency |
|---------|-------------|-----------|
| IMPGS | Imports of Goods and Services | Quarterly |
| B235RC1Q027SBEA | Customs Duties | Quarterly |
| PAYEMS | Total Nonfarm Payroll Employment | Monthly → Quarterly |
| IRLTLT01USM156N | Long-Term Interest Rate | Monthly → Quarterly |
| GDP | Gross Domestic Product | Quarterly |

Monthly series are converted to quarterly frequency by taking quarterly averages.

---

## 🧠 Methodology
- Sample period: **1959Q1 – 2025Q2**
- Monthly data aggregated to quarterly frequency
- Lag length selected using Akaike Information Criterion (AIC)
- VAR models estimated using:
  - `vars` for inference, Granger causality, and impulse responses
  - `ahead` for multi-step forecasting
- Interest rates included as a control variable

---

## 📈 Models
### Model A: Tariff Revenues (% of GDP)
A VAR model including:
- Tariff revenues as a share of GDP
- Employment
- Interest rates

This model evaluates how changes in tariff revenues affect employment dynamics.

### Model B: Tariff Rate (%)
A VAR model including:
- Tariff rate (customs duties divided by imports)
- Employment
- Interest rates

This model captures the employment response to changes in effective tariff rates.

---

## 🔍 Analysis Components
- Time series visualization of all variables
- Granger causality tests
- Impulse response functions (IRFs)
- Employment forecasts up to 16 quarters ahead
- Comparison of forecast paths across models

---

## 📈 Key Outputs
- Evidence on whether tariffs Granger-cause employment
- Dynamic employment responses to tariff shocks
- Medium-term employment forecasts from VAR models

---

## 🛠️ Software Requirements
- R (version 4.0 or higher)

Required packages:
```r
tidyverse
vars
forecast
quantmod
pdfetch
ahead
cowplot
tseries
zoo
xts
