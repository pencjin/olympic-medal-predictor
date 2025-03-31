🏅 Olympic Medal Predictor (R & Shiny Project)
This project analyzes Olympic athlete data from 1980 to 2016 and builds statistical models to predict the number of medals an athlete might win based on physical characteristics and contextual variables. It combines rigorous data cleaning, exploratory data analysis, and multivariable linear modeling, with an interactive Shiny app that brings the model to life.

📌 Project Summary  
**Goal:** To understand what factors are associated with Olympic success and to predict individual athlete medal counts based on variables such as age, height, weight, and host country status.

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
- Derived variables include host country status, experience, top-5 historical performance, total medals per athlete per Olympics, and more

🧠 Key Insights  
- **Host Country Effect:** Athletes from host countries tend to win significantly more medals  
- **Experience Matters:** Athletes who competed in previous Olympics perform better on average  
- **Age, Height, Weight:** These physical variables have weak but observable associations with medal outcomes  
- **Country Context:** Athletes from historically strong countries with large delegations and many events generally perform better

📁 File Structure  
| File                 | Description                              |
|----------------------|------------------------------------------|
| Olympic Project.Rmd  | Full R Markdown analysis report          |
| Olympic Report.html  | Rendered HTML report with visuals        |
| app.R                | Shiny app for predicting medals based on input |
| README.md            | This file!                               |

🚀 Run the Shiny App  
The Shiny App allows users to enter values for age, height, weight, and select host country status to predict expected medal count.

**To run locally:**
- Open `app.R` in RStudio
- Click “Run App” (requires shiny, tidyverse, bslib)

**Hosted App Link:**  
🔗 [Olympic Medal Predictor on shinyapps.io](https://7ioj6d-pencjin.shinyapps.io/OlympicMedalPredictor/)

📈 Final Model Performance  
The final model uses interaction terms between host country and athlete attributes (age, height, weight) to predict total medals per athlete per Olympics.

- **Adjusted R²:** 1.06%  
- **RMSE:** 0.4573

While individual characteristics show weak correlations with medal count, host country status stands out as the strongest predictor.

📦 Required R Packages
```r
library(tidyverse)
library(tidymodels)
library(GGally)
library(ggplot2)
library(shiny)
library(bslib)
```

---

## ✍️ Author

**Pen Jin**  
University of Washington  
Double major in Anthropology & Informatics: Data Science  
Data Engineer Intern at Refonte Learning
GitHub: [pencjin](https://github.com/pencjin)  
LinkedIn: [www.linkedin.com/in/peng-jin-74b53a231](https://www.linkedin.com/in/peng-jin-74b53a231)  
Last updated: 2025-03-31
