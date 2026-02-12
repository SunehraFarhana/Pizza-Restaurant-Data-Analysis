# Pizza Restaurant Data Analysis
The orders dataset of a Little Caesars restaurant isn't simply a record of a it's transactions over a period of time. Pizza restaurant order data is highly valuable because it reveals customer demand patterns, seasonal trends, product performance, and ordering behavior.

This raw order data can be used to pinpoint the areas in which sales volume and revenue are highest, thus allowing restaurant stakeholders to make informed decisions around promotions, menu strategy, delivery operations, and customer retention programs.

**BUSINESS PROBLEM:** When are order volume and revenue the highest? Which menu items generate the most demand? Are there product trends that suggest promotional opportunities?

---
## Table of Contents
1. [Project Overview](#project-overview)
2. [Dataset Summary](#dataset-summary)
3. [Data Cleaning and Feature Engineering in **Python**](#data-cleaning-and-feature-engineering-in-python)
4. [Exploratory Data Analysis in **MySQL Workbench**](#exploratory-data-analysis-in-mysql-workbench)
5. [Visualizations in **Tableau Public**](#visualizations-in-tableau-public)
6. [Project Insight and Recommendations](#project-insight-and-recommendations)
7. [Conclusion](#conclusion)

---
## Project Overview
This project analyzes 2024 order data from a Little Caesars restaurant in Brooklyn, New York to uncover meaningful trends in customer preferences and ordering behavior. Raw transactional data was transformed into actionable insights that support strategic business decisions for this pizza restaurant, through data cleaning in Python, SQL querying, and an interactive Tableau dashboard visualization.

---
## Dataset Summary
The synthetic dataset can be found [**here**](https://github.com/SunehraFarhana/Pizza-Restaurant-Data-Analysis/blob/6dd22a54ee1f235bb2550b9235c5feff20fc96af/pizza_restaurant_dataset_raw.csv). Each row represents an order fulfilled by this Little Caesars restaurant in 2024, and contains information about that order.
* **Size (Before Cleaning):** 5,050 rows, 11 columns
	* **Size (After Cleaning):** 5,050 rows, 10 columns
* **Restaurant Data:** Order ID, Order Date, Menu Item Name, Menu Item Category, Menu Item Price, Menu Item Size, Menu Item Quantity, Customer First Name, Customer Last Name, Delivery, Delivery Address
	* **Feature Engineered Columns:** Customer Name (Customer First Name and Customer Last Name were combined into one column, then dropped from the dataset)

---
## Data Cleaning and Feature Engineering in Python
This dataset contained many typos and mistakes within the columns, which were corrected throughout the data cleaning process.

### 1. Some values in the **`menu_item_category`**, **`menu_item_size`**, and **`delivery`** columns have typos, or are recorded in an inconsistent manner. The values within these columns will be corrected and simplified, in order to ensure accurate data when querying and making visualizations:
* **`menu_item_category`** → Convert all records to either **`Pizza`**, **`Sides`**, **`Wings`**, or **`Beverage`**
* **`menu_item_size`** → Convert all records to either **`Regular`**, **`Large`**, **`Small`**, **`2L`**, **`20oz`**, or **`8pc`**
* **`delivery`** → Convert all records to either **`Yes`** or **`No`**
```python
# Correct and simplify values in menu_item_category column
df["menu_item_category"] = df["menu_item_category"].replace(["Piza", "pzza"], "Pizza")
df["menu_item_category"] = df["menu_item_category"].replace("Sidse", "Sides")
df["menu_item_category"] = df["menu_item_category"].replace("Wing", "Wings")
df["menu_item_category"] = df["menu_item_category"].replace("Bev", "Beverage")

# Correct and simplify values in menu_item_size column
df["menu_item_size"] = df["menu_item_size"].replace("reg", "Regular")
df["menu_item_size"] = df["menu_item_size"].replace("Lrage", "Large")
df["menu_item_size"] = df["menu_item_size"].replace("smll", "Small")
df["menu_item_size"] = df["menu_item_size"].replace("2l", "2L")
df["menu_item_size"] = df["menu_item_size"].replace("20 oz", "20oz")
df["menu_item_size"] = df["menu_item_size"].replace("8 pc", "8pc")

# Correct and simplify values in delivery column
df["delivery"] = df["delivery"].replace(["yes", "Y"], "Yes")
df["delivery"] = df["delivery"].replace(["no", "N"], "No")

# Make sure values in menu_item_category, menu_item_size, and delivery columns are now consistent
print("Unique Category Values: ", df["menu_item_category"].unique())
print("Unique Size Values: ", df["menu_item_size"].unique())
print("Unique Delivery Values: ", df["delivery"].unique())
```

### 2. Some values in the **`menu_item_name`**, **`customer_first_name`**, **`customer_last_name`**, and **`delivery_address`** columns have inconsistent capitalization, or random symbols that don't belong. This will be corrected, while preserving the descriptive text, in order to prevent parsing errors.
```python
# Identify the columns that require cleaning
cols_to_clean = [
    "menu_item_name",
    "customer_first_name",
    "customer_last_name",
    "delivery_address"
]

# Identify the symbols that must be removed
unwanted_symbols = r'[\/:;\(\)\-\"“”‘’\'\\%]'

# Define a function that cleans the columns
def clean_text(val):

    if pd.isna(val):
        return val
    
    # Remove unwanted symbols
    val = re.sub(unwanted_symbols, '', str(val))
    
    # Normalize extra spaces
    val = re.sub(r'\s+', ' ', val).strip()
    
    # Convert words to title case
    return val.title()

# Apply the function to the columns
for col in cols_to_clean:
    df[col] = df[col].apply(clean_text)

# Make sure text columns were cleaned
print(df[cols_to_clean].head())

# Fix strings that were undesirably altered during the cleaning process
df["menu_item_name"] = df["menu_item_name"].replace("2Liter", "2 Liter", regex=True)
df["menu_item_name"] = df["menu_item_name"].replace("Extramostbestest", "ExtraMostBestest", regex=True)
df["delivery_address"] = df["delivery_address"].replace("Ny", "NY", regex=True)
```

### 3. In order to simplify the dataset, combine each value in the **`customer_first_name`** and **`customer_last_name columns`**, to create one **`customer_name`** column that contains the customer's full name.
```python
# Combine customer_first_name and customer_last_name columns into customer_name
df["customer_name"] = (
    df["customer_first_name"].fillna("") + " " + df["customer_last_name"].fillna("")
).str.strip()

# Place new customer_name column into the correct position
insert_pos = df.columns.get_loc("menu_item_quantity") + 1
col_data = df.pop("customer_name")
df.insert(insert_pos, "customer_name", col_data)

# Drop unnecessary columns
df = df.drop(columns=["customer_first_name", "customer_last_name"])

# Inspect customer_name column
print(df["customer_name"].head(10))
```

An in-depth [**Jupyter Notebook**](https://github.com/SunehraFarhana/Pizza-Restaurant-Data-Analysis/blob/6dd22a54ee1f235bb2550b9235c5feff20fc96af/pizza_restaurant_dataset_cleaning.ipynb) detailing every step of the data cleaning process is available in this repository.

---
## Exploratory Data Analysis in MySQL Workbench
These SQL queries were used to reveal data trends and give guidance towards assembling visualizations.

### 1. What is the total number of orders and total revenue?
```sql
SELECT 
    COUNT(*) AS total_orders,
    SUM(menu_item_quantity) AS total_units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS total_revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned;
```
<img width="252" height="60" alt="pizza_restaurant_sql_1" src="https://github.com/user-attachments/assets/c9980fce-c45a-4bf3-9464-ab81cd39e469" />

### 2. What is the total number of orders per delivery status? What percent of orders are delivery?
```sql
SELECT
    CASE
        WHEN delivery = 'Yes' THEN 'Yes'
        WHEN delivery = 'No' THEN 'No'
        ELSE 'Unknown'
    END AS delivery_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) 
         FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned),
    2) AS pct_of_orders
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY delivery_status;
```
<img width="254" height="76" alt="pizza_restaurant_sql_2" src="https://github.com/user-attachments/assets/bf65822c-71d3-4987-bb06-7d247765cdbf" />

### 3. What is the order count, units sold, and revenue by month? Which month had the highest revenue?
```sql
SELECT
    MONTHNAME(order_date) AS month,
    COUNT(*) AS order_count,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY month
ORDER BY revenue DESC;
```
<img width="270" height="225" alt="pizza_restaurant_sql_3" src="https://github.com/user-attachments/assets/41f0812c-b6f2-46bb-891e-92c0cf61e30e" />

### 4. Which menu item sold the most units? Which menu item generated the most revenue?
```sql
SELECT
    menu_item_name,
    SUM(menu_item_quantity) AS units_sold,
    ROUND(SUM(menu_item_price * menu_item_quantity), 2) AS revenue
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY menu_item_name
ORDER BY revenue DESC;
```
<img width="287" height="316" alt="pizza_restaurant_sql_4" src="https://github.com/user-attachments/assets/403c41d3-2f19-428f-9360-d40bcf58076a" />

### 5. Who are the most frequent customers, and how much money have they spent on orders?
```sql
SELECT
    customer_name,
    COUNT(*) AS order_count,
    ROUND(SUM(menu_item_price * menu_item_quantity),2) AS total_money_spent
FROM pizza_restaurant_schema.pizza_restaurant_dataset_cleaned
GROUP BY customer_name
ORDER BY order_count DESC
LIMIT 15;
```
<img width="293" height="270" alt="pizza_restaurant_sql_5" src="https://github.com/user-attachments/assets/322e8491-44b0-4096-a190-c068fe47ad0a" />

An in-depth [**SQL file**](https://github.com/SunehraFarhana/Pizza-Restaurant-Data-Analysis/blob/be4c76d8fe5b8dcb31fbdb1182698af518e6ae81/pizza_restaurant_queries.sql) detailing every step of the querying process is available in this repository.

---
## Visualizations in Tableau Public
The Tableau Public visualizations can be found [**here**](https://public.tableau.com/views/pizza_restaurant_visualizations/Dashboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link).

The data was organized into one interactive dashboard, which highlights the most relevant information about product trends and buyer behavior. Users can easily see the menu item factors that generated the most revenue, and the times where sales volume was the highest. They can also toggle between menu item categories and see, for example, around which time of year beverages were more popular with customers.

<img width="1399" height="599" alt="pizza_restaurant_visualizations_dashboard" src="https://github.com/user-attachments/assets/d4390a14-29f4-4243-a3cf-c361ab100833" />

---
## Project Insight and Recommendations
After cleaning the csv file, doing exploratory data analysis, and creating visualizations, the restaurant data reveals that:


---
## Conclusion
This project demonstrates how pizza restaurant order data can be transformed into meaningful business intelligence and strategic insight. By identifying seasonal demand patterns, top-performing products, and heavy delivery reliance, Little Caesars can make practical business decisions that enhance profitability, customer satisfaction, and operational efficiency. This analysis provides a strong foundation for future initiatives that help the restaurant better serve its customers while maximizing its revenue.
