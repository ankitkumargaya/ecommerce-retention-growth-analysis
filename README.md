# 🚀 E-Commerce Customer Retention & Growth Analysis

## 📌 Project Overview

This project is an end-to-end product analytics case study focused on identifying **why business growth is slowing despite steady customer acquisition**.

The analysis uncovers key lifecycle bottlenecks affecting **customer retention, repeat purchase behavior, and long-term revenue growth**.

---

## 🎯 Business Problem

The business is acquiring customers efficiently with a strong **LTV/CAC ratio (~3.67)**, yet revenue growth remains stagnant.

### Key Question:
> Why is growth not scaling despite consistent acquisition?

---

## 🧠 Objective

- Identify where customers drop in the lifecycle
- Analyze repeat purchase behavior and retention trends
- Evaluate acquisition channel quality
- Diagnose bottlenecks impacting LTV and revenue
- Recommend strategies to shift from acquisition-led to retention-led growth

---

## 📊 Dataset & Data Model

The project uses a multi-table e-commerce dataset (~50K+ records), simulating real-world business scenarios.

### Tables:
- `customers` – user demographics & acquisition source
- `user_sessions` – website/app engagement
- `orders` – transactions & revenue
- `order_items` – product-level details
- `returns` – return behavior
- `marketing_events` – campaign tracking

---

## 🛠 Tools & Technologies

- **Python (Pandas, NumPy)** → Data cleaning & preprocessing  
- **Databricks (Spark SQL)** → Data transformation, Gold layer tables, analysis  
- **Power BI** → Dashboarding & business storytelling  

---

## 📈 Key Analysis Performed

- Customer acquisition performance by channel  
- Customer lifecycle & time to second purchase  
- Cohort retention analysis  
- Customer activation funnel (Session → Browsing → Cart → Checkout → Repeat)  
- Marketing efficiency using CAC, LTV, and LTV/CAC  

---

## 🔍 Key Insights

### 1. Growth Driven by Acquisition, Not Retention
- 30-day repeat rate is only **~13%**
- Majority of users do not return after first purchase

👉 Indicates unsustainable, acquisition-heavy growth

---

### 2. Early Lifecycle is the Main Bottleneck
- Avg time to second purchase: **~102 days**
- Significant drop in early engagement

👉 Customers are not getting activated quickly

---

### 3. Major Funnel Drop: Browsing → Add to Cart
- Largest drop-off occurs before purchase intent

👉 Indicates friction in decision-making stage

---

### 4. Retention Stabilizes After Initial Drop
- Cohort retention stabilizes at **12–15%**

👉 Problem is early churn, not long-term retention

---

### 5. Channel Quality Varies Significantly
- **Referral & Influencer channels** → highest LTV/CAC
- Paid channels bring volume but lower efficiency

---

## 💣 Root Cause

> The primary growth constraint is **poor early customer activation**, leading to low repeat purchase rates and delayed lifecycle progression.

---

## 💡 Recommendations

### 🚀 Improve Early Activation
- Post-purchase engagement campaigns
- Time-bound repeat purchase incentives

**Impact:** Faster repeat behavior, higher LTV

---

### 🚀 Optimize Browse → Cart Conversion
- Improve product trust (reviews, ratings)
- Add urgency (limited stock, offers)

**Impact:** Increased conversion rate

---

### 🚀 Scale High-ROI Channels
- Invest more in Referral & Influencer marketing

**Impact:** Better customer quality and retention

---

### 🚀 Retarget First-Time Buyers
- Target users inactive after 30–60 days

**Impact:** Recover lost revenue at low cost

---

### 🚀 Introduce Personalization
- Product recommendations
- Behavioral targeting

**Impact:** Higher engagement and repeat purchases

---

## 📊 Business Impact (Expected)

- 30-day repeat rate: **13% → 20–25%**
- Time to second order: **102 → 30–45 days**
- LTV increase: **+20–40%**
- Reduced dependency on paid acquisition

---

## 📊 Dashboard Features

- Multi-page Power BI dashboard:
  - Executive Overview  
  - Acquisition & Channel Performance  
  - Customer Lifecycle  
  - Retention Analysis  
  - Activation Funnel  

- KPI cards for:
  - Revenue, Orders, Customers  
  - LTV, CAC, Retention Rate  

- Interactive filters:
  - Year-Month  
  - Acquisition Channel  

- Custom navigation & insight buttons  

---

## 📸 Dashboard Preview

> (Add screenshots here)

---

## 🎯 Key Takeaway

> Business growth is not limited by acquisition, but by **failure to activate customers early in the lifecycle**, making retention the most critical lever for scaling revenue.

---

## 📌 Future Improvements

- A/B testing for activation strategies  
- Predictive churn modeling  
- Customer segmentation (RFM / behavioral)  
- Recommendation system integration  

---

## 👤 Author

**Ankit (Akki)**  
Aspiring Data Analyst | SQL | Power BI | Product Analytics  
