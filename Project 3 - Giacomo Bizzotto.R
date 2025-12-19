setwd("C:/Users/giaco/OneDrive/Desktop/UNH/COURSES/Business Forecasting/Week 13")
options(digits = 3, scipen = 9999, stringAsFactors = FALSE)
remove(list = ls())
graphics.off()


#=======================#  
suppressPackageStartupMessages({
  suppressWarnings({
    library(tidyverse)
    library(lubridate)
    library(ggthemes)
    library(tsbox) #convert xts to tsibble
    library(TSstudio)
    library(cowplot)
    library(pdfetch)
    library(dplyr)
    library(lubridate)
    library(pdfetch)
    library(zoo)
    library(xts)
    library(vars)
    library(ggplot2)
    library(scales)
    library(tseries)
    library(tsutils)
    library(rio)
    library(forecast)
    library(quantmod)
    library(forecastHybrid)
    library(vars)
    library(randomForest)
    library(e1071)  #for SVMs
    
    #devtools::install_github("Techtonique/ahead")
    library(ahead)
  })})
#=======================#`  


# 1. DOWNLOAD ALL SERIES USING pdfetch_FRED()
imports      <- pdfetch_FRED("IMPGS")              # Imports of goods & services
duties       <- pdfetch_FRED("B235RC1Q027SBEA")    # Customs Duties
employment_m <- pdfetch_FRED("PAYEMS")             # Employment (monthly)
interest_m   <- pdfetch_FRED("IRLTLT01USM156N")    # Interest rate (monthly)
gdp          <- pdfetch_FRED("GDP")                # GDP (quarterly)

dim(imports)
dim(duties)
dim(employment_m)
dim(interest_m)
dim(gdp)


# Convert to quarterly ts 

# Quarterly series
imports_q <- ts(imports, start = c(1947, 1), frequency = 4)
duties_q  <- ts(duties,  start = c(1959, 1), frequency = 4)
gdp_q <- ts(gdp, start = c(1947, 1), frequency = 4)


# Monthly → quarterly using as.yearqtr
employment_q <- aggregate(employment_m, as.yearqtr, mean)
employment_q <- ts(employment_q, start = c(1939, 1), frequency = 4)

interest_q <- aggregate(interest_m, as.yearqtr, mean)
interest_q <- ts(interest_q, start = c(1953, 2), frequency = 4)

ts_info(imports_q)
ts_info(duties_q)
ts_info(employment_q)
ts_info(interest_q)
ts_info(gdp_q)


#Let's make all the ts match
common_start <- c(1959, 1)
common_end   <- c(2025, 2)

imports_w    <- window(imports_q,    start = common_start, end = common_end)
duties_w     <- window(duties_q,     start = common_start, end = common_end)
employment_w <- window(employment_q, start = common_start, end = common_end)
interest_w   <- window(interest_q,   start = common_start, end = common_end)
gdp_w        <- window(gdp_q,        start = common_start, end = common_end)


#Plot all the ts
all_ts <- cbind(imports_w, duties_w, employment_w, interest_w, gdp_w)
colnames(all_ts) <- c("Imports","Duties","Employment","Interest","GDP")

par(mfrow = c(5,1), mar = c(3,4,2,1))
for(i in 1:ncol(all_ts)) {
  plot(all_ts[,i], main = colnames(all_ts)[i], ylab = "", xlab = "")
}


#Tariff Rate (%)
tariff_rate <- (duties_w / imports_w) * 100
tariff_rate <- ts(tariff_rate,
                  start = start(duties_w),
                  frequency = 4)


#Tariff Revenues as % of GDP
tariff_gdp <- (duties_w / gdp_w) * 100
tariff_gdp <- ts(tariff_gdp,
                 start = start(duties_w),
                 frequency = 4)


#Plot
par(mfrow=c(2,1))
plot(tariff_rate, main="Tariff Rate (%)", ylab="", xlab="")
plot(tariff_gdp,  main="Tariff Revenues (% of GDP)", ylab="", xlab="")


#MODEL A — EFFECT OF TARIFF REVENUES (% GDP) ON EMPLOYMENT

modA_data <- cbind(
  tariff_gdp,
  employment_w,
  interest_w
)

head(modA_data)
dim(modA_data)

modA_data <- na.omit(modA_data)

# Lag selection
VARselect(modA_data, lag.max = 6)   #LAG 2 has the lowest AI

# Estimate VAR (using lags = 2 based on AIC)
VAR_A <- ahead::varf(modA_data, lags = 2, h = 16, level = 95)



#MODEL B — EFFECT OF TARIFF RATE (%) ON EMPLOYMENT

modB_data <- cbind(
  tariff_rate,
  employment_w,
  interest_w
)

modB_data <- na.omit(modB_data)

# Lag selection
VARselect(modB_data, lag.max = 6)

# Estimate VAR
VAR_B <- ahead::varf(modB_data, lags = 2, h = 16, level = 95)



#FINAL SECTION: Answer Assignment Questions



# 🎯 DELIVERABLE 1: Model B — Tariff Rates (%) → Employment
VAR_B_old <- VAR(modB_data, p = 2)  # Use lag = 2 from AIC

# Granger causality tests
bv.cause_tariffB <- causality(VAR_B_old, cause = "tariff_rate")
bv.cause_empB    <- causality(VAR_B_old, cause = "employment_w")
bv.cause_tariffB
bv.cause_empB

# IRF: impact of a shock in tariff rates on employment
irf_emp_B <- irf(
  VAR_B_old,
  impulse = "tariff_rate",
  response = "employment_w",
  n.ahead = 24,
  boot = TRUE
)
plot(irf_emp_B,
     ylab = "Employment Response",
     main = "Impact on Employment from Shock in Tariff Rate (%)")



# 🎯 DELIVERABLE 2: Model A — Tariff Revenues (% GDP) → Employment
VAR_A_old <- VAR(modA_data, p = 2)  # Use lag = 2 from AIC

# Granger causality tests
bv.cause_tariffA <- causality(VAR_A_old, cause = "tariff_gdp")
bv.cause_empA    <- causality(VAR_A_old, cause = "employment_w")
bv.cause_tariffA
bv.cause_empA

# IRF: impact of a shock in tariff revenues on employment
irf_emp_A <- irf(
  VAR_A_old,
  impulse = "tariff_gdp",
  response = "employment_w",
  n.ahead = 24,  # 24 quarters
  boot = TRUE
)
plot(irf_emp_A,
     ylab = "Employment Response",
     main = "Impact on Employment from Shock in Tariff Revenues (% GDP)")



# 🎯 DELIVERABLE 3: VAR Employment Series Forecast
# (Forecasts for both Model A and Model B)

# --- 1. Employment Forecast for MODEL A (Tariff Revenues % GDP) ---
p_emp_A <- autoplot(employment_w) + 
  autolayer(VAR_A$mean[,"employment_w"], series="Forecast") + 
  xlim(2015, 2030) + 
  ylim(120000,180000)+
  theme(legend.position = "bottom") + 
  labs(title = "Employment Forecast (Model A: Tariff Revenues % GDP)", 
       y = "Employment (Thousands)", 
       x = "Quarter")

# --- 2. Employment Forecast for MODEL B (Tariff Rate %) ---
p_emp_B <- autoplot(employment_w) + 
  autolayer(VAR_B$mean[,"employment_w"], series="Forecast") + 
  xlim(2015, 2030) + 
  ylim(120000,180000)+
  theme(legend.position = "bottom") + 
  labs(title = "Employment Forecast (Model B: Tariff Rate %)", 
       y = "Employment (Thousands)", 
       x = "Quarter")

# Combine the two employment forecasts into one plot for comparison (Optional, but useful)
cowplot::plot_grid(p_emp_A, p_emp_B, ncol = 1)








