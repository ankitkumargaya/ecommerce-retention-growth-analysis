# 🚀 E-Commerce Customer Retention & Growth Analysis
### End-to-End Product Analytics Case Study | Databricks + Spark SQL + Python + Power BI

<p align="center">
  <img src="images/overview.png" width="1000">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Databricks-Spark%20SQL-FF3621?style=flat-square&logo=databricks&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat-square&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Python-Pandas%20%7C%20NumPy-3776AB?style=flat-square&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/SQL-Advanced-4479A1?style=flat-square&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Framework-What%2FWhy%2FAction%2FRisk-1F3864?style=flat-square">
</p>

---

## 📑 Table of Contents
[Overview](#-project-overview) · [Objective](#-business-objective) · [Insights at a Glance](#-key-insights-at-a-glance) · [Tech Stack](#-tech-stack) · [Data Architecture](#-data-architecture-bronze--silver--gold) · [Findings (What/Why/Action/Risk)](#-findings--recommendations-whatwhyactionrisk) · [Expected Impact](#-expected-business-impact) · [Dashboard Preview](#-dashboard-preview) · [Author](#-author)

---

## 📌 Project Overview

A complete, end-to-end **product analytics and customer retention case study** built on a Bronze → Silver → Gold data architecture, covering the full customer journey from **acquisition → activation → checkout → repeat purchase → returns**.

This version extends the original analysis with **full product-level and returns-level data**, which surfaced a sharper and more accurate diagnosis of the business's growth problem than the earlier draft.

Simulates a real-world analytics environment used by modern product and e-commerce companies such as Amazon, Flipkart, Meesho, Zepto, Blinkit, and Swiggy Instamart.

---

## 🎯 Business Objective

> To diagnose why revenue fell sharply in the final two months of the year despite continued marketing spend and heavy discounting — by tracing the full customer journey from acquisition to repeat purchase to pinpoint exactly where value was leaking, and recommend the levers to convert first-time buyers into a sustainably repeating, profitable customer base.

**Key reframe from the original analysis:** the business does not have an acquisition problem — it has a **repeat-purchase and revenue-leakage problem**, and that leakage accelerated sharply at the end of the year.

---

## 🔍 Key Insights at a Glance

| # | Insight | Signal |
|---|---|---|
| 1 | Revenue fell sharply in the final two months of the year | Down ~40% in January and a further ~8.8% in February — the steepest two-month decline in the dataset |
| 2 | The customer engine underneath is shrinking too | Acquisition down 30% (1,975 → 1,377/month); Total Orders down 31% (2,565 → 1,767/month) |
| 3 | Repeat-purchase behavior has collapsed | Second-order conversion fell from **96% → 16%** in under a year |
| 4 | Retention falls off a cliff after Month 1 | 41% at Month 1 → 23% by Month 3 → ~15% by Month 6 |
| 5 | The funnel bleeds hardest at the finish line | Cart rate 21.8% but checkout completion only 11.9% — a **~46% last-mile drop-off** |
| 6 | Acquisition budget doesn't follow efficiency | Referral has the best LTV:CAC (8.5) but isn't the top-funded channel |
| 7 | Growth is being bought, not earned | **63% of sales are discounted**; new products are only 32% of sales |

---

## 🛠 Tech Stack

| Tool / Technology | Purpose |
|---|---|
| Databricks (Spark SQL) | Large-scale data processing & analytical querying |
| SQL | KPI validation & business analysis |
| Python (Pandas, NumPy) | Data cleaning & feature engineering |
| Power BI | Dashboard development & visualization |
| DAX | KPI calculations & time intelligence |
| Power Query | Data transformation |
| Star Schema Modeling | Scalable analytics architecture |

---

## ⚙️ Data Processing & Analytics Workflow
Raw Data → Python Cleaning → Databricks Processing (Spark SQL) → Analytical Tables → Power BI Dashboard

---

## 🧱 Data Architecture (Bronze → Silver → Gold)

<details>
<summary><b>🥈 Silver Layer — Core Tables</b> (click to expand)</summary>

| Table Name | Description |
|---|---|
| customers | Customer details & acquisition channel |
| sessions | User engagement & activity |
| orders | Order-level transactions |
| order_items | Product-level order breakdown |
| returns | Return & refund behavior |
| marketing_events | Campaign interaction tracking |
| marketing_spend | Channel-level acquisition cost |

</details>

<details>
<summary><b>🥇 Gold Layer — Business-Ready Tables</b> (click to expand)</summary>

| Table | Tracks |
|---|---|
| `activation_funnel` | Session → Browsing → Cart → Checkout → Repeat, with stage-wise drop-offs |
| `customer_lifecycle` | First/second order date, days to second purchase, repeat flags |
| `retention_cohort` | Monthly cohort size, retained users, retention % |
| `channel_ltv` | Customers acquired, revenue, LTV, CAC, LTV:CAC ratio |
| `product_performance` | Product/category sales, quantity, discount impact, old vs. new SKUs |
| `returns_refunds` | Order status distribution, return rate, refund value |

</details>

---

## 🔎 Findings & Recommendations (What/Why/Action/Risk)

> Each finding below follows the **What → Why → Action → Risk** structure used for stakeholder-ready analysis. Click any finding to expand it.

<details open>
<summary><b>1️⃣ Revenue and Order Volume Collapsed Together at Year-End</b></summary>

| | |
|---|---|
| 📌 **WHAT** | Revenue fell ~40% in January and a further ~8.8% in February — the steepest two-month decline in the dataset. Total Orders fell 31% over the year (2,565 → 1,767/month), acquisition fell 30%, and delivered orders fell 33%. |
| 🎯 **WHY** | Four metrics dropped together in the same window — one shared cause, not four unrelated problems. |
| 🛠️ **ACTION** | Run a single root-cause investigation (marketing timing, stock availability, platform changes) before adding spend. |
| ⚠️ **RISK** | Left uninvestigated, the same drop can recur in the next low-volume window. |

</details>

<details>
<summary><b>2️⃣ Second-Order Conversion Has Collapsed</b></summary>

| | |
|---|---|
| 📌 **WHAT** | Second-order conversion fell from **96% → 16%** in under a year. The 83.29% all-time average conceals this. |
| 🎯 **WHY** | Too sharp for gradual demand softening — likely an operational break (CRM/notification, app, fulfillment) starting ~Nov 2025. |
| 🛠️ **ACTION** | Root-cause the Nov'25–Feb'26 cohorts specifically before assuming it's a demand issue. |
| ⚠️ **RISK** | Every acquisition rupee increasingly buys a one-time customer instead of a repeat one. |

</details>

<details>
<summary><b>3️⃣ Retention Falls Off a Cliff After Month 1</b></summary>

| | |
|---|---|
| 📌 **WHAT** | 40.65% retained at Month 1 → 23.38% by Month 3 → ~14.68% by Month 6. |
| 🎯 **WHY** | Most repeat purchases happen within an 8–30 day window (avg. 48 days) — the highest-leverage moment in the lifecycle. |
| 🛠️ **ACTION** | Launch a Day 8 / 20 / 30 lifecycle campaign targeting that exact window. |
| ⚠️ **RISK** | Without intervention, retention keeps compressing toward the ~15% Month 6 floor. |

</details>

<details>
<summary><b>4️⃣ Checkout Is the Single Largest Funnel Leak</b></summary>

| | |
|---|---|
| 📌 **WHAT** | 21.83% add to cart, but only **11.85%** complete checkout — a ~46% last-mile abandonment. |
| 🎯 **WHY** | The steepest single-step drop in the entire funnel — points to a checkout-specific UX or trust issue. |
| 🛠️ **ACTION** | Audit payment failures, hidden fees, forced signup, and load time — prioritize before upper-funnel work. |
| ⚠️ **RISK** | Fixing earlier stages first improves top-of-funnel metrics without moving revenue. |

</details>

<details>
<summary><b>5️⃣ Acquisition Budget Doesn't Match Channel Efficiency</b></summary>

| | |
|---|---|
| 📌 **WHAT** | Referral has the best LTV:CAC (**8.5**) but isn't top-funded — Organic is. Email + Influencer (weakest, 4.3–4.4) absorb 36% of spend. |
| 🎯 **WHY** | Budget follows historical habit, not current return. |
| 🛠️ **ACTION** | Shift 15–20% of Email/Influencer spend into Referral — incrementally, not all at once. |
| ⚠️ **RISK** | Referral CAC may rise as the channel scales — test before committing the full shift. |

</details>

<details>
<summary><b>6️⃣ Growth Is Increasingly Bought Through Discounting, Not Earned</b></summary>

| | |
|---|---|
| 📌 **WHAT** | 62.65% of sales are discounted across every category. New products are only 32% of sales vs. 68% from the old catalogue. |
| 🎯 **WHY** | Blanket discounts compress margin on customers who'd convert anyway; new SKUs lack visibility. |
| 🛠️ **ACTION** | Move to segment-targeted discounting + improve new-product placement and promotion. |
| ⚠️ **RISK** | Pulling discounts too fast could suppress conversion further while volume is already declining. |

</details>

---

## 📈 Expected Business Impact

| KPI | Current | Target |
|---|---|---|
| Revenue MoM Movement | -40% (Jan), -8.8% (Feb) | Stabilize / positive |
| Second-Order Conversion (recent) | ~16% | 50%+ |
| Checkout Completion Rate | 11.85% | 15%+ |
| Month 1 Retention | 40.65% | 45–48% |
| Discounted Sales Share | 62.65% | 45–50% |
| New Product Sales Share | 32% | 40%+ |

---

## 📊 Dashboard Pages

- Executive Overview
- Acquisition & Channel Performance
- Customer Lifecycle
- Retention Analysis
- Activation Funnel
- **Product & Category Performance** *(new)*
- **Returns & Refund Analysis** *(new)*

## ⚡ Advanced Power BI Features
Dynamic KPI selection · Field parameters · Drill-down & drill-through · Interactive filters/slicers · Custom page navigation · Insight buttons · Dynamic titles · YoY/MoM analysis · Conditional formatting · Tooltip enhancements

---

## 🔑 Key Skills Demonstrated

Product Analytics · Customer Retention & Cohort Analysis · Funnel Analytics · Customer Lifecycle Analytics · Spark SQL · Databricks · Advanced SQL · Power BI Dashboarding · DAX · Data Modeling · Business Intelligence · Data Storytelling

---

## 📸 Dashboard Preview

<details>
<summary><b>🔹 Executive Overview</b></summary>
<p align="center"><img src="images/overview.png" width="1000"></p>
</details>

<details>
<summary><b>🔹 Acquisition & Channel Performance</b></summary>
<p align="center"><img src="images/acquisition.png" width="1000"></p>
</details>

<details>
<summary><b>🔹 Customer Lifecycle</b></summary>
<p align="center"><img src="images/lifecycle.png" width="1000"></p>
</details>

<details>
<summary><b>🔹 Retention Analysis</b></summary>
<p align="center"><img src="images/retention.png" width="1000"></p>
</details>

<details>
<summary><b>🔹 Activation Funnel</b></summary>
<p align="center"><img src="images/funnel.png" width="1000"></p>
</details>

<details>
<summary><b>🔹 Product & Category Performance</b></summary>
<p align="center"><img src="images/product.png" width="1000"></p>
</details>

<details>
<summary><b>🔹 Returns & Refund Analysis</b></summary>
<p align="center"><img src="images/returns.png" width="1000"></p>
</details>

---

## 💼 Business Impact

This analysis helps stakeholders:
- Understand why revenue and order volume collapsed in the same window
- Fix the checkout step driving the largest single conversion loss
- Diagnose and reverse the second-order conversion collapse
- Reduce reliance on acquisition spend and blanket discounting
- Shift toward a retention-led, margin-healthy growth strategy

---

## 👨‍💻 Author

**Ankit Kumar**
Data Analyst | Product Analytics | SQL | Power BI | Python | Databricks

- GitHub: https://github.com/ankitkumargaya
- LinkedIn: https://www.linkedin.com/in/ankit5517

---

## 📌 Final Conclusion

> The primary issue is not customer acquisition — it's a coordinated year-end collapse in revenue and order volume, compounded by checkout friction, a broken second-order journey, and growth that's increasingly bought through discounting rather than earned through retention.

### Acquisition-Led, Discount-Dependent Growth → Retention-Led, Sustainable Growth
