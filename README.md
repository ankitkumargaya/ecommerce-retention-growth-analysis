# 🚀 E-Commerce Customer Retention & Growth Analysis  
### Product Analytics Case Study | Databricks + Spark SQL + Python + Power BI

<p align="center">
  <img src="images/overview.png" width="1000">
</p>

---

# 📌 Project Overview

This project is a complete end-to-end **Product Analytics & Retention Analysis** case study focused on identifying:

> Why business growth is slowing despite steady customer acquisition.

The analysis evaluates the full customer lifecycle — from acquisition to repeat purchase — to uncover:

- Retention gaps
- Funnel inefficiencies
- Activation bottlenecks
- Customer lifecycle delays
- Revenue growth constraints

The project simulates a real-world analytics environment used by modern product and e-commerce companies such as:

- Amazon
- Flipkart
- Meesho
- Zepto
- Blinkit
- Swiggy Instamart

---

# 🎯 Business Problem

The business demonstrates:

- Strong customer acquisition
- Healthy marketing efficiency
- Positive LTV/CAC ratio

However:

- Revenue growth is plateauing
- Repeat purchase behavior is weak
- Customer retention is low during the early lifecycle

---

# 🎯 Business Objective

The primary goal of this analysis was to identify:

- Why customers fail to repeat purchases early
- Which channels acquire high-value customers
- Where major funnel drop-offs occur
- How retention impacts long-term growth
- Which lifecycle stages require optimization

---

# 🛠 Tech Stack

| Tool / Technology | Purpose |
|---|---|
| Databricks (Spark SQL) | Large-Scale Data Processing & Analytical Querying |
| SQL | KPI Validation & Business Analysis |
| Python (Pandas, NumPy) | Data Cleaning & Feature Engineering |
| Power BI | Dashboard Development & Visualization |
| DAX | KPI Calculations & Time Intelligence |
| Power Query | Data Transformation |
| Star Schema Modeling | Scalable Analytics Architecture |

---

# ⚙️ Data Processing & Analytics Workflow

This project follows a modern analytics workflow similar to real-world product and e-commerce companies.

## Workflow Architecture

Raw Data → Python Cleaning → Databricks Processing (Spark SQL) → Analytical Tables → Power BI Dashboard

---

# 🔥 Databricks & Spark SQL Usage

Databricks and Spark SQL were used to simulate large-scale analytical processing and business KPI validation.

## Spark SQL Analysis Included

- Funnel analysis
- Retention calculations
- Cohort analysis
- Customer lifecycle analysis
- Channel performance analysis
- Repeat purchase analysis
- LTV & CAC analysis
- Revenue trend analysis

## Why Spark SQL?

Spark SQL enables scalable analytics processing for large datasets and is widely used in modern cloud-based data platforms.

### Benefits

- Faster large-scale querying
- Distributed processing
- Better performance for analytical workloads
- Real-world big data analytics simulation

---

# 🧱 Data Architecture (Bronze → Silver → Gold)

The project follows a layered modern analytics architecture.

---

# 🥉 Bronze Layer

Raw source datasets collected from transactional systems.

---

# 🥈 Silver Layer

Cleaned and transformed analytical tables.

## Core Tables

| Table Name | Description |
|---|---|
| customers | Customer details & acquisition channel |
| sessions | User engagement & activity |
| orders | Order-level transactions |
| order_items | Product-level order breakdown |
| returns | Return & refund behavior |
| marketing_events | Campaign interaction tracking |
| marketing_spend | Channel-level acquisition cost |

---

# 🥇 Gold Layer (Business-Ready Tables)

Optimized analytical tables for reporting and KPI tracking.

---

## 🔹 activation_funnel

Tracks customer movement through funnel stages:

- Session
- Product Browsing
- Add to Cart
- Checkout
- Repeat Purchase

### Includes

- Funnel conversion rates
- Stage-wise drop-offs
- Activation bottlenecks

---

## 🔹 customer_lifecycle

Tracks long-term customer behavior.

### Includes

- First order date
- Second order date
- Days to second purchase
- Repeat purchase flags
- Lifecycle segmentation

---

## 🔹 retention_cohort

Monthly cohort retention tracking.

### Includes

- Cohort size
- Active retained users
- Retention percentage
- Long-term retention trends

---

## 🔹 channel_ltv

Channel-level profitability and customer quality analysis.

### Includes

- Total customers acquired
- Revenue contribution
- Average LTV
- CAC
- LTV/CAC ratio
- Orders per customer

---

# 🧠 Analytical Approach

The analysis was structured across key growth layers:

| Growth Layer | Business Focus |
|---|---|
| Acquisition | Channel quality & customer acquisition |
| Activation | First-to-second purchase behavior |
| Conversion | Funnel performance & drop-off analysis |
| Retention | Cohort retention analysis |
| Monetization | LTV, CAC & revenue efficiency |

---

# 📊 Key Analysis Performed

## Customer Acquisition Analysis
- Channel-wise customer acquisition
- CAC comparison
- Customer quality analysis

---

## Customer Lifecycle Analysis
- Time to second purchase
- Repeat purchase behavior
- Lifecycle segmentation

---

## Retention Analysis
- Monthly cohort retention
- Early-stage churn analysis
- Retention trend analysis

---

## Funnel Analysis
- Session → Cart → Checkout → Repeat conversion
- Funnel drop-off identification
- Activation bottleneck analysis

---

## Marketing Efficiency Analysis
- LTV by channel
- CAC analysis
- LTV/CAC efficiency tracking

---

# 🔍 Key Insights

# 1️⃣ Growth is Acquisition-Driven, Not Retention-Driven

- LTV/CAC ≈ **3.67**
- 30-day repeat rate only **~13%**

### Business Insight

The business heavily depends on new customer acquisition instead of repeat customer growth.

### Risk

This creates an unsustainable growth model with increasing acquisition dependency.

---

# 2️⃣ Early Customer Activation is the Biggest Bottleneck

- Average time to second purchase ≈ **102 days**
- Large percentage of users never repeat

### Business Insight

Customers are not forming purchasing habits early enough.

### Impact

Delayed repeat behavior slows revenue scaling and reduces long-term customer value.

---

# 3️⃣ Major Funnel Drop at Browsing → Add to Cart

Largest customer drop-off occurs before purchase intent formation.

### Possible Causes

- Weak product trust
- Poor urgency signals
- Pricing hesitation
- Lack of reviews/social proof

### Business Impact

The issue is behavioral friction, not technical friction.

---

# 4️⃣ Retention Stabilizes After Initial Churn

- Cohort retention stabilizes at **~12–15%**

### Business Insight

Long-term retention is relatively stable.

### Root Problem

The largest issue is early-stage churn immediately after acquisition.

---

# 5️⃣ Channel Quality Matters More Than Volume

### Best Performing Channels

- Referral
- Influencer

### Weak Performing Channels

- Paid Ads

### Business Insight

High acquisition volume does not guarantee high customer value.

---

# 6️⃣ Revenue Trend Indicates Growth Plateau

Revenue remains relatively stable despite steady acquisition growth.

### Conclusion

The primary growth bottleneck is:

> Poor retention, not poor acquisition.

---

# 💣 Root Cause Analysis

> The core business constraint is weak early customer activation, resulting in low repeat purchase behavior and delayed customer lifecycle progression.

---

# 🚀 Strategic Recommendations

# 1️⃣ Improve Early Customer Activation

## Recommended Actions

- Day 1 onboarding campaigns
- Day 3 & Day 7 remarketing
- Repeat purchase incentives
- Personalized product recommendations

## Expected Impact

- Faster repeat purchases
- Increased LTV
- Improved retention

---

# 2️⃣ Optimize Browsing → Cart Conversion

## Recommended Actions

- Add product reviews & ratings
- Introduce urgency messaging
- Improve pricing communication
- Highlight trust indicators

## Expected Impact

Improves highest-drop funnel stage.

---

# 3️⃣ Scale High-ROI Acquisition Channels

## Recommended Actions

- Increase Referral investment
- Expand Influencer partnerships
- Reduce inefficient ad spend

## Expected Impact

Higher-quality customers with stronger retention.

---

# 4️⃣ Retarget First-Time Buyers

## Recommended Actions

- Re-engage inactive users after 30–60 days
- Trigger lifecycle-based campaigns

## Expected Impact

Low-cost revenue recovery from already acquired customers.

---

# 5️⃣ Introduce Personalization

## Recommended Actions

- Behavioral targeting
- Dynamic product recommendations
- Personalized offers

## Expected Impact

Improves engagement and repeat probability.

---

# 📈 Expected Business Impact

| KPI | Current | Expected |
|---|---|---|
| 30-Day Repeat Rate | ~13% | 20–25% |
| Avg Time to Second Order | ~102 Days | 30–45 Days |
| Customer LTV | Baseline | +20–40% |
| Acquisition Dependency | High | Reduced |

---

# 📊 Dashboard Features

The project includes a multi-page interactive Power BI dashboard.

## Dashboard Pages

- Executive Overview
- Acquisition & Channel Performance
- Customer Lifecycle
- Retention Analysis
- Activation Funnel

---

# ⚡ Advanced Power BI Features

## Implemented Features

- Dynamic KPI Selection
- Field Parameters
- Drill-down Functionality
- Drill-through Navigation
- Interactive Filters & Slicers
- Custom Page Navigation
- Insight Buttons for Storytelling
- Dynamic Titles
- YoY & MoM Growth Analysis
- Conditional Formatting
- Tooltip Enhancements

---

# 🔑 Key Skills Demonstrated

- Product Analytics
- Customer Retention Analysis
- Funnel Analytics
- Cohort Analysis
- Customer Lifecycle Analytics
- Spark SQL
- Databricks
- SQL Analytics
- Power BI Dashboarding
- DAX Calculations
- Data Modeling
- Business Intelligence
- Data Storytelling

---

# 📸 Dashboard Preview

## 🔹 Executive Overview

<p align="center">
  <img src="images/overview.png" width="1000">
</p>

---

## 🔹 Acquisition & Channel Performance

<p align="center">
  <img src="images/acquisition.png" width="1000">
</p>

---

## 🔹 Customer Lifecycle

<p align="center">
  <img src="images/lifecycle.png" width="1000">
</p>

---

## 🔹 Retention Analysis

<p align="center">
  <img src="images/retention.png" width="1000">
</p>

---

## 🔹 Activation Funnel

<p align="center">
  <img src="images/funnel.png" width="1000">
</p>

---

# 💼 Business Impact

This analysis helps stakeholders:

- Identify retention bottlenecks
- Improve customer activation
- Reduce acquisition dependency
- Increase customer lifetime value
- Improve repeat purchase behavior
- Optimize marketing investment efficiency
- Support retention-led growth strategy

---

# 👨‍💻 Author

## Ankit Kumar  
Aspiring Data Analyst | Product Analytics | SQL | Power BI | Python | Databricks

- GitHub: https://github.com/ankitkumargaya
- LinkedIn: Add Your LinkedIn Profile Here

---

# 📌 Final Conclusion

This project demonstrates how product analytics and customer lifecycle analysis can uncover the real drivers behind business growth constraints.

The analysis reveals that:

> The primary issue is not customer acquisition, but poor early customer activation and low repeat purchase behavior.

By improving retention and reducing lifecycle friction, the business can transition from:

### Acquisition-Led Growth → Retention-Led Sustainable Growth

This project reflects real-world analytical thinking used in modern product, fintech, and e-commerce companies.
