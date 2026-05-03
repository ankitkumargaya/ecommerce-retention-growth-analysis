# 🚀 E-Commerce Customer Retention & Growth Analysis

## 📌 Project Overview

This project is an end-to-end product analytics case study focused on identifying **why business growth is slowing despite steady customer acquisition**.

The analysis evaluates the complete customer lifecycle — from acquisition to repeat purchase — to uncover **retention gaps, funnel inefficiencies, and growth constraints**.

---

## 🎯 Business Objective

The business shows strong acquisition and healthy marketing efficiency (LTV/CAC > 3), but **revenue growth is not scaling proportionally**.

### Key Goal:
- Identify where customers drop in the lifecycle  
- Improve early-stage engagement and repeat purchase behavior  
- Increase long-term customer value (LTV)  
- Shift from **acquisition-led growth → retention-led growth**

---

## 🧠 Analytical Approach

The analysis is structured across key growth layers:

- Acquisition → Channel performance & customer quality  
- Activation → First to second purchase behavior  
- Conversion → Funnel drop-off analysis  
- Retention → Cohort retention trends  
- Monetization → LTV, CAC, and revenue impact  

---

## 🧱 Data Architecture (Bronze → Silver → Gold)

### 🔹 Analytics Tables (Cleaned Data)

- `customers` → Customer details & acquisition channel  
- `sessions` → User activity and engagement  
- `orders` → Order-level transactions  
- `order_items` → Order-level breakdown  
- `returns` → Return behavior  
- `marketing_events` → Campaign interactions  
- `marketing_spend` → Channel-level acquisition cost  

---

### 🥇 Gold Layer (Business-Ready Tables)

#### `activation_funnel`
Tracks user journey across stages:
- Session → Browsing → Cart → Checkout → Repeat  

Includes:
- Conversion rates at each stage  
- Drop-off identification  

---

#### `channel_ltv`
Channel-level performance:
- Total customers & orders  
- Revenue (gross & net)  
- Avg Customer LTV  
- Orders per customer  

---

#### `customer_lifecycle`
Customer-level behavior:
- First & second order tracking  
- Days to second purchase  
- Repeat flags (30-day)  
- Lifecycle segmentation  

---

#### `retention_cohort`
Cohort-based retention:
- Monthly retention tracking  
- Active users vs cohort size  
- Retention rate trends  

---

## 📊 Key Analysis Performed

- Customer acquisition performance by channel  
- Customer lifecycle & time to second purchase  
- Cohort retention analysis  
- Activation funnel analysis (Session → Repeat)  
- Marketing efficiency using CAC, LTV, LTV/CAC  

---

## 🔍 Key Insights

### 1. Growth is Acquisition-Driven, Not Retention-Driven
- LTV/CAC ≈ **3.67** (strong efficiency)  
- But 30-day repeat rate only **~13%**  

👉 Business relies heavily on new users → **unsustainable growth model**

---

### 2. Early Customer Activation is the Biggest Bottleneck
- Avg time to second purchase: **~102 days**  
- Large segment of users delay or never repeat  

👉 Weak habit formation → delayed revenue realization  

---

### 3. Major Funnel Drop at Browsing → Add to Cart
- Highest drop-off occurs before purchase intent  

👉 Indicates **decision friction**, not technical issue  

Possible causes:
- Weak product trust  
- Pricing perception  
- Lack of urgency  

---

### 4. Retention Stabilizes After Initial Drop
- Cohort retention stabilizes at **~12–15%**  

👉 Long-term retention is stable  
👉 Problem lies in **early-stage churn**

---

### 5. Channel Quality Matters More Than Volume
- Referral & Influencer → Highest LTV/CAC  
- Paid Ads → Lower efficiency  

👉 Not all customers are equal → **quality over quantity**

---

### 6. Revenue Trend Indicates Growth Plateau
- Revenue remains relatively stable despite acquisition  

👉 Confirms:
> Growth bottleneck is **retention, not acquisition**

---

## 💣 Root Cause

> The primary growth constraint is **poor early customer activation**, leading to low repeat purchase rates and delayed lifecycle progression.

---

## 💡 Recommendations

### 🚀 Improve Early Activation (Highest Impact)
- Post-purchase engagement (Day 1, Day 3, Day 7)
- Time-bound repeat purchase incentives  

**Why:**  
Reduces time to second purchase → increases LTV  

---

### 🚀 Optimize Browsing → Cart Conversion
- Add trust signals (reviews, ratings)  
- Introduce urgency (offers, stock alerts)  

**Why:**  
Biggest funnel drop → highest ROI improvement  

---

### 🚀 Scale High-ROI Channels
- Increase investment in Referral & Influencer  

**Why:**  
Higher retention + better LTV  

---

### 🚀 Retarget First-Time Buyers
- Target inactive users after 30–60 days  

**Why:**  
Recover already acquired users at low cost  

---

### 🚀 Introduce Personalization
- Behavioral targeting  
- Product recommendations  

**Why:**  
Improves engagement and repeat probability  

---

## 📊 Expected Business Impact

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

---

### 🔥 Advanced Features Implemented

- Custom page navigation (app-like experience)  
- Insight buttons for guided storytelling  
- Field parameters for dynamic metric switching  
- Interactive filters (Year-Month, Channel)  

---

## 📸 Dashboard Preview

## 📸 Dashboard Preview

### 🔹 Executive Overview
<p align="center">
  <img src="images/overview.png" width="900">
</p>

---

### 🔹 Acquisition & Channel Performance
<p align="center">
  <img src="images/acquisition.png" width="900">
</p>

---

### 🔹 Customer Lifecycle
<p align="center">
  <img src="images/lifecycle.png" width="900">
</p>

---

### 🔹 Retention Analysis
<p align="center">
  <img src="images/retention.png" width="900">
</p>

---

### 🔹 Activation Funnel
<p align="center">
  <img src="images/funnel.png" width="900">
</p>


