# Banking User Behavior Analysis

## Project Overview
This project analyzes **user behavior in banking transactions** using SQL for data exploration and transformation.  
The results are summarized into a presentation and an interactive dashboard built with Looker Studio.

Deliverables include:
- SQL Queries (ETL & analysis)
- README documentation
- Presentation slides
- Looker Studio dashboard

---

## How to Run the Code

1. **Database Setup**
   - Import the dataset into PostgreSQL.
   - Example command (psql):
     ```bash
     \copy transactions FROM 'path/to/transactions.csv' DELIMITER ',' CSV HEADER;
     ```

2. **Run SQL Queries**
   - All queries are available in [`Banking_User_Behavior_Analysis.sql`](./Banking_User_Behavior_Analysis.sql).
   - Open the file and execute the queries sequentially in PostgreSQL.

3. **Export Fact Table**
   - After transformation, export the final aggregated/fact table to CSV:
     ```bash
     \copy fact_user_behavior TO 'fact_user_behavior.csv' DELIMITER ',' CSV HEADER;
     ```
   - This file will be used as input for Looker Studio.

---

## Dashboard
The interactive dashboard is available here:  
👉 [Looker Studio Dashboard](https://lookerstudio.google.com/u/1/reporting/3c56f161-64da-4172-b06e-5057572bb099/page/EVNVF)

It summarizes:
- Total transactions over time  
- Active users trend  
- Average transaction value  

---

## 🎤 Presentation
The presentation provides insights and highlights key findings.  
👉 [`Banking_User_Behavior_Analysis.pdf`](./Banking_User_Behavior_Analysis.pdf)

---
Nabila Yasmine Az Zahra
