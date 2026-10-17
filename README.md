# E-commerce Marketplace Analysis (SQL)

An SQL analysis of about 98,000 orders from a Brazilian online marketplace (the Olist public dataset). I answered six business questions about growth, customers, products, delivery and sellers, working as if reporting to the operations and growth teams. Everything was done in PostgreSQL.

## Headline findings

- **Growth stalled.** Monthly revenue grew about 8x through 2017, then flattened at roughly R$0.85M to R$1.0M a month through 2018. Growth came from more orders, not bigger ones: average order value fell about 13%.
- **Late deliveries are the clearest fixable problem.** Late orders are 6.8% of volume but roughly a third of all low reviews. Even 1 to 3 days late drops the average score from 4.28 to 3.28.
- **Very few customers come back.** About 97% bought once. Revenue is also concentrated: three states (SP, RJ, MG) bring in 63%, and the top 10% of sellers bring in 67%.

All money figures are in Brazilian reais (R$). Revenue means item price only, with freight excluded.

## The six questions

| # | Question | Answer in one line |
|---|----------|--------------------|
| 1 | How has revenue grown, and where did it slow? | About 8x to November 2017, then a plateau. Year-over-year growth fell from +687% (Jan 2018) to +49% (Aug 2018), partly because the 2017 base was so small. |
| 2 | Who are the top customers, by state and by value? | São Paulo is 38% of revenue; seven states make up 82%. The top 10% of customers (R$280+ lifetime spend) are 41% of revenue. |
| 3 | Do customers come back? | 3.03% placed 2+ orders. 30% of those second orders were same-day (likely split baskets), so true returns are about 2.1% to 3.0%. |
| 4 | Which categories drive revenue and which disappoint? | Revenue is spread out (top 10 categories = 63%). bed_bath_table (7.7% of revenue, 17.2% low scores) and office_furniture (22.6% low scores) are the weak spots. |
| 5 | Do late deliveries hurt reviews? | Yes, strongly. Scores fall from 4.28 (on time) to about 1.7 after a week late. |
| 6 | Are we too dependent on a few sellers? | No single seller exceeds 1.7%, but the top 10% of sellers bring in 67% of revenue. They perform about as well as the rest. |

## Findings in more detail

**Q1: Revenue.** Revenue rose from R$120K (Jan 2017) to R$1.0M (Nov 2017). November's 52% jump and December's 26% drop look like a Black Friday effect, though the data can't prove that. Orders went from 787 to about 6,400 a month while average order value drifted from R$153 to R$132.

**Q2: Customers.** São Paulo has the lowest spend per customer (R$130). Mid-sized northeastern states spend more: Bahia R$156, Pernambuco R$163, Ceará R$174. The smallest states have too few customers to judge. The top 20% of customers bring in 57% of revenue; the bottom half brings in under 17%.

**Q3: Retention.** Repeat customers make up 5.6% of revenue and spend R$260 each versus R$138 for one-time buyers. Rough estimate: lifting the repeat rate by one percentage point is worth about R$115K over the 20 months, under 1% of revenue, and probably an upper bound.

**Q4: Categories.** Several of the weaker categories are bulky goods (furniture, bed and bath, decor), which fits a delivery explanation, but I did not test that. luggage_accessories, stationery and pet_shop combine decent volume with high ratings.

**Q5: Delivery.** Delivery was measured against the date promised to the customer.

| Delivery | Orders | Avg score | Low scores (1-2 stars) |
|---|---|---|---|
| On time or early | 89,672 | 4.28 | 9.5% |
| 1-3 days late | 1,869 | 3.28 | 32.4% |
| 4-7 days late | 1,802 | 2.09 | 68.1% |
| 8-14 days late | 1,478 | 1.67 | 80.4% |
| 15+ days late | 1,382 | 1.72 | 78.5% |

Late rates are highest in the northeast (Alagoas 21.5%, Maranhão 17.5%, Ceará 13.8%, Bahia 12.2%) and in Rio de Janeiro (12.1%, versus 4.5% in São Paulo). Rio is the second-largest state by revenue, so it is the biggest single lever.

**Q6: Sellers.** There are 3,029 sellers. The top 10 make up 13% of revenue, the top 1% make up 26%, the top 10% make up 67% and the top 20% make up 82%. The top 10% of sellers have a 6.9% late rate and a 4.10 average rating, against 6.4% and 4.16 for the rest.

## Recommendations

1. **Fix delivery first, starting with Rio de Janeiro and the northeast.** Set more realistic delivery estimates where late rates are high, and warn customers early when an order is at risk.
2. **Hold marketing pushes into Bahia and Ceará** until delivery there improves. Those states spend more per customer but have some of the worst late rates.
3. **Treat retention as a test, not a promise.** Run a small post-purchase re-engagement experiment and measure the lift.
4. **Review quality in bed_bath_table and office_furniture** (product and delivery) before investing in growth there.
5. **Monitor the top ~300 sellers** as a managed group. Their performance is healthy today, but they carry most of the volume.
6. **Plan capacity ahead of November peaks.**

## Data quality

Before any analysis I checked the data and logged every issue and decision in [`docs/data_quality_log.md`](docs/data_quality_log.md). The main ones:

| Issue | Decision |
|---|---|
| 775 orders had no items (603 unavailable, 164 canceled, 8 other) | Excluded from analysis |
| Orders in 2016 are very sparse and Sep to Oct 2018 are partial | Analysis window set to Jan 2017 to Aug 2018 (97,905 orders, 98.5% of all) |
| `customer_id` is created per order: 99,441 IDs but 96,096 real people | Used `customer_unique_id` for any customer-level analysis |
| 555 orders have more than one review | Kept the latest review per order |
| 610 products have no category; 2 categories had no translation | Labelled "unknown"; added the 2 translations manually |
| 303 orders where items and payments don't match (0.3%) | Revenue taken from items only. Of the 264 overpaid orders, 249 used installments, which fits added interest. The 39 underpaid orders are unexplained |
| 8 delivered orders had no delivery date | Excluded from delivery-time analysis |

## Repository structure

```
.
├── README.md
├── schema.sql              # table definitions with keys
├── queries/
│   ├── 01_data_quality_checks.sql
│   ├── q1_monthly_revenue.sql
│   ├── q2_customers_by_state_and_value.sql
│   ├── q3_repeat_purchases.sql
│   ├── q4_categories.sql
│   ├── q5_delivery_and_reviews.sql
│   └── q6_seller_concentration.sql
├── docs/
│   ├── er_diagram.png
│   └── data_quality_log.md
└── results/                # CSV exports of key query outputs
```

To reproduce: create a PostgreSQL database, run `schema.sql`, load the nine CSVs from the [Olist dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) in dependency order (translation, customers, sellers, products, orders, order_items, order_payments, order_reviews), then create the `valid_orders`, `products_clean` and `order_reviews_clean` views from the data quality script and run the queries in order.

## SQL techniques used

Multi-table joins, CTEs, window functions (`LAG`, `ROW_NUMBER`, `NTILE`, running totals), conditional aggregation with `FILTER`, `CASE` bucketing, percentiles, views for reusable cleaning rules, and aggregating before joining to avoid double counting.

## Limitations

- One dataset covering 20 months; findings describe this marketplace in this period.
- There is no cost or margin data, so these are revenue findings, not profit findings.
- The data has no returns, so review scores stand in for quality. The late-delivery link is a correlation: late orders may also be damaged or wrong.
- The repeat rate is understated for recent customers, who had less time to come back, and about 30% of "repeat" orders were same-day.
- Seller IDs are anonymised, so sellers can't be named or profiled by what they sell.
- I did not run significance tests; differences like the top-seller gap (6.9% vs 6.4% late) are small and should be read as directional.
