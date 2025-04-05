🏅 Olympic Medal Predictor (R & Shiny Project)
This project analyzes Olympic athlete data from 1980 to 2016 and builds statistical models to predict the number of medals an athlete might win based on physical and contextual variables. It combines rigorous data cleaning, exploratory data analysis, and multivariable linear modeling with an interactive Shiny dashboard.

📌 Project Summary  
**Goal:** To understand what factors contribute to Olympic medal success and predict medal counts at both the individual athlete and country levels.

**Approach:**
- Built multiple linear regression models using R and tidymodels, incorporating main effects and interaction terms
- Evaluated model performance using adjusted R² and RMSE
- Visualized relationships between variables with ggplot2 and GGally
- Developed a Shiny dashboard for interactive medal prediction

📊 Dataset  
**Source:** Kaggle – 120 Years of Olympic History: Athletes and Results

**Scope:**
- Covers Summer Olympics from 1980 to 2016
- Includes athlete-level data: name, sex, age, height, weight, NOC (country), sport, event, medal outcome
- Engineered variables: host country status, top-5 country status, medals per athlete per year, total athletes, and events by country-year

🧠 Key Insights  
- **Host Country Effect:** Athletes from host countries tend to win significantly more medals  
- **Experience Matters:** Athletes who competed in previous Olympics perform better on average  
- **Age, Height, Weight:** These physical variables have weak but observable associations with medal outcomes  
- **Country Context:** Athletes from historically strong countries with large delegations and many events generally perform better
- **Final Model Summary:** The best model uses total_events_country_year, total_athletes_country_year, and top_5_ever to predict medals per athlete. While these predictors have relatively small coefficients, they reflect structural patterns in country-level Olympic success.

📁 File Structure  
| File                 | Description                              |
|----------------------|------------------------------------------|
| Olympic Project.Rmd  | Full R Markdown analysis report          |
| Olympic Report.html  | Rendered HTML report with visuals        |
| app.R                | Shiny app for predicting medals based on input |
| README.md            | This file!                               |

🚀 Run the Shiny App  
The app includes two prediction tools:

- **Athlete-Level Predictor** – Predicts total medals for an athlete based on physical attributes and host country status.

- **Country-Level Model** – Uses total events, number of athletes, and historical strength to predict average medals per athlete.

**To run locally:**
- Open `app.R` in RStudio
- Click “Run App” (requires shiny, tidyverse, bslib)

**Hosted App Link:**  
🔗 [Olympic Medal Predictor on shinyapps.io](https://7ioj6d-pencjin.shinyapps.io/OlympicMedalPredictor/)

📈 Final Model Performance  
- **Model:** total_medals_per_athlete ~ total_events + total_athletes + top_5_ever
- **Adjusted R²:** 4.189%  
- **RMSE:** 0.621

- **Summary:** The factors influencing medal count of this model include the number of athletes per country, the number of events per country, and historical performance (Top 5 Ever status). Countries with a higher number of athletes perform better overall, while those in countries that have been top 5 tend to see fewer medals per athlete, possibly due to greater competition. The effect of the number of events suggests that increased competition from more events can dilute medal outcomes.

📦 Required R Packages
```r
library(tidyverse)
library(tidymodels)
library(GGally)
library(ggplot2)
library(shiny)
library(bslib)
library(DT)
```

---

## ✍️ Author

**Pen Jin**  
University of Washington  
Double major in Anthropology & Informatics: Data Science  
Data Engineer Intern at Refonte Learning
GitHub: [pencjin](https://github.com/pencjin)  
LinkedIn: [www.linkedin.com/in/peng-jin-74b53a231](https://www.linkedin.com/in/peng-jin-74b53a231)  
Last updated: 2025-04-04
