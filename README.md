#  Global Terrorism – Big Data Analysis Project (Databricks + PySpark)

## 1.  Project Overview

This project performs an end-to-end Big Data analysis of worldwide terrorist incidents using the **Global Terrorism Database** in **Databricks (Free Edition)** with **PySpark**, **Spark SQL**, and **Lakeview Dashboards**.

The main objectives are to:

- Analyze how terrorist attacks have evolved over time  
- Compare casualties across regions and attack types  
- Visualize high-casualty events on a map  
- Provide an interactive dashboard with global filters on year, region, and attack type  

The pipeline includes:

- Data ingestion  
- Cleaning & feature engineering  
- Analytical exploration (PySpark + SQL)  
- Dashboard creation (line chart, stacked bar, map/scatter)  
- GitHub-based documentation  

---

## 2.  Dataset Description

Source file: `globalterrorismdb_0718dist.csv`

A subset of key columns used:

- `eventid` – Unique event identifier  
- `iyear`, `imonth`, `iday` – Date components  
- `country`, `country_txt` – Country code & name  
- `region`, `region_txt` – Region code & name  
- `provstate` – State/Province  
- `city` – City  
- `latitude`, `longitude` – Location coordinates  
- `attacktype1`, `attacktype1_txt` – Primary attack type  
- `gname` – Primary perpetrator group  
- `nkill` – Number of people killed  
- `nwound` – Number of people wounded  
- `weaptype1_txt` – Primary weapon type  
- `targtype1_txt` – Primary target type  
- `success` – 1 if attack succeeded, 0 otherwise  
- `suicide` – 1 if suicide attack, 0 otherwise  

---

## 3.  Tools & Technologies

- Databricks (Free Edition)
- PySpark
- Spark SQL
- Databricks Lakeview Dashboard
- GitHub

---

## 4.  Data Pipeline

### 4.1 📥 Ingestion

Notebook: `01_ingest_and_clean_terror.ipynb`

Steps:

1. Upload `globalterrorismdb_0718dist.csv` into Databricks.
2. Create raw table:

sql
bigdata_finals.default.raw_terror

### 4.2 🧹 Cleaning & Feature Engineering
Also in 01_ingest_and_clean_terror.ipynb.

Key transformations:

Selected relevant columns for analysis & dashboard.

Casted numeric fields:

iyear, imonth, iday

latitude, longitude

nkill, nwound

success, suicide

Constructed an incident_date from iyear, imonth, iday when valid.

Replaced null nkill/nwound with 0.

Created casualties = nkill + nwound.

Defined decade:

1970s, 1980s, 1990s, 2000s, 2010s, 2020s+

Defined high_casualty:

High (>=10) if casualties >= 10

Low/Medium (<10) otherwise.

Final cleaned table:

sql
Copy code
bigdata_finals.default.clean_terror
This single clean table is used for all dashboard tiles and filters, ensuring global, consistent filtering.

## 5. 📊 Exploratory Analysis
Notebook: 02_analysis_notebook.ipynb

### 5.1 PySpark Examples
Attacks per year (trend)

python
Copy code
df_attacks_year = (
    df.groupBy("iyear")
      .agg(count("*").alias("num_attacks"))
      .orderBy("iyear")
)
Casualties by region

python
Copy code
df_casualties_region = (
    df.groupBy("region_txt")
      .agg(
          spark_sum("casualties").alias("total_casualties"),
          spark_sum("nkill").alias("total_killed"),
          spark_sum("nwound").alias("total_wounded")
      )
      .orderBy("total_casualties", ascending=False)
)
Top 10 countries by casualties

python
Copy code
df_top_countries = (
    df.groupBy("country_txt")
      .agg(spark_sum("casualties").alias("total_casualties"))
      .orderBy(col("total_casualties").desc())
      .limit(10)
)
Suicide rate and casualties by attack type

python
Copy code
df_suicide_attacktype = (
    df.groupBy("attacktype1_txt")
      .agg(
          avg("suicide").alias("suicide_rate"),
          avg("casualties").alias("avg_casualties")
      )
      .orderBy(col("suicide_rate").desc())
)

### 5.2 SQL Examples (in sql_queries.sql)
Attacks by year & region

sql
Copy code
SELECT
  iyear,
  region_txt,
  COUNT(*) AS num_attacks
FROM bigdata_finals.default.clean_terror
GROUP BY iyear, region_txt
ORDER BY iyear, num_attacks DESC;
Total casualties by weapon type

sql
Copy code
SELECT
  weaptype1_txt,
  SUM(nkill + nwound) AS total_casualties
FROM bigdata_finals.default.clean_terror
GROUP BY weaptype1_txt
ORDER BY total_casualties DESC;

## 6. 📈 Dashboard (Global Terrorism Dashboard)
All tiles and filters use the same dataset:

sql
Copy code
bigdata_finals.default.clean_terror

### 6.1 Tile 1 – Number of Attacks per Year (Line Chart)
Data source: clean_terror

Chart type: Line

X-axis: iyear

Y-axis: COUNT(*) (number of events)

Title: “Number of Attacks per Year”

### 6.2 Tile 2 – Casualties by Region & Attack Type (Stacked Bar)
Data source: clean_terror

Chart type: Stacked bar

X-axis: region_txt

Y-axis: SUM(casualties)

Series/Color: attacktype1_txt

Title: “Casualties by Region and Attack Type”

### 6.3 Tile 3 – High-Casualty Events (Map / Scatter)
Data source: clean_terror

Chart type: Map (if available) or Scatter

Latitude: latitude

Longitude: longitude

Bubble size: casualties

Suggested filter inside tile: high_casualty = 'High (>=10)'

Title: “High-Casualty Events (10+ Casualties)”

This visualization is visually impressive and geographically informative.

## 7. Global Dashboard Filters
All filters are created on main.default.clean_terror and applied to all three tiles.

 Filter 1 – Year
Data source: clean_terror

Field: iyear

Name: Year

Type: Dropdown / numeric range

Applies to:

Tile 1

Tile 2

Tile 3

 Filter 2 – Region
Data source: clean_terror

Field: region_txt

Name: Region

Type: Dropdown

Applies to:

Tile 1

Tile 2

Tile 3

 Filter 3 – Attack Type
Data source: clean_terror

Field: attacktype1_txt

Name: Attack Type

Type: Dropdown

Applies to:

Tile 1

Tile 2

Tile 3

These filters are:

Global

Relevant to all KPIs

Fully consistent with the data source used by all tiles

## 8. ▶️ How to Run This Project
Import the notebooks into Databricks:

01_ingest_and_clean_terror.ipynb

02_analysis_notebook.ipynb

03_dashboard_notebook.ipynb (optional)

Attach a running cluster.

Run 01_ingest_and_clean_terror to build clean_terror.

Run 02_analysis_notebook to reproduce analysis.

In Lakeview:

Create Global Terrorism Dashboard

Add the 3 tiles as described

Add global filters for Year, Region, Attack Type

## 9.  Repository Structure
text
Copy code
global-terrorism-bigdata-final/
│
├── 01_ingest_and_clean_terror.ipynb
├── 02_analysis_notebook.ipynb
├── 03_dashboard_notebook.ipynb   (optional)
├── sql_queries.sql
└── README.md


## 10. Conclusion
This project demonstrates:

A complete Big Data processing pipeline on a complex real-world dataset

Rich feature engineering (casualties, decade, high casualty flags)

Interesting analysis of temporal, regional, and tactical patterns

A visually appealing dashboard with line, stacked bar, and map-style visualizations

Consistent global filters based on year, region, and attack type

It provides a strong foundation for further research into global terrorism patterns and is suitable as a high-quality Big Data final assignment.
