/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL



--- ====================================================================
  /* data quality checks for gold layers */
  ------------------------ dim products -----------------------------
  select * from gold.dim_products;

select prd_key, count(*) from (
SELECT pn.prd_id
      ,pn.cat_id
      ,pn.prd_key
      ,pn.prd_nm
      ,pn.prd_cost
      ,pn.prd_line
      ,pn.prd_start_dt
      ,pc.cat
      ,pc.subcat
      ,pc.maintenance
  FROM DataWarehouse_1.silver.crm_prd_info pn
  LEFT JOIN DataWarehouse_1.silver.erp_px_cat_g1v2 pc
  ON pn.cat_id = pc.id
  where prd_end_dt is null)t
  group by prd_key having count(*) > 1;  ---- Filter out historical data


  select prd_id, count(*) from DataWarehouse_1.silver.crm_prd_info pn group by prd_id;


  ----------------------------- dim_customers-------------------------

    select t.cst_id , count(*) from (
SELECT ci.cst_id 
      ,ci.cst_key
      ,ci.cst_firstname
      ,ci.cst_lastname
      ,ci.cst_marital_status
      ,case when ci.cst_gndr != 'n/a' THEN ci.cst_gndr
       else COALESCE(ca.gen,'n/a')
       end as new_gen
      ,ci.cst_create_date
      ,ca.bdate
      ,la.cntry
  FROM DataWarehouse_1.silver.crm_cust_info ci 
  LEFT JOIN DataWarehouse_1.silver.erp_cust_az12 ca
  ON ci.cst_key = ca.cid
  LEFT JOIN DataWarehouse_1.silver.erp_loc_a101 la
  ON ci.cst_key = la.cid ) t
  group by t.cst_id
  having count(*) > 1;


  SELECT DISTINCT
       ci.cst_gndr,
       ca.gen,
       case when ci.cst_gndr != 'n/a' THEN ci.cst_gndr
       else COALESCE(ca.gen,'n/a')
       end as new_gen
  FROM DataWarehouse_1.silver.crm_cust_info ci 
  LEFT JOIN DataWarehouse_1.silver.erp_cust_az12 ca
  ON ci.cst_key = ca.cid
  LEFT JOIN DataWarehouse_1.silver.erp_loc_a101 la
  ON ci.cst_key = la.cid 
  ORDER BY 1,2;


  SELECT distinct gender FROM gold.dim_customers;


  ------------------------- fact sales --------------------------------

  SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
where c.customer_key IS NULL OR p.product_key is NULL;

SELECT 
      sls_ord_num AS order_number,
      pr.product_key,
      cu.customer_key,
      sls_order_dt AS order_date,
      sls_ship_dt AS shipping_date,
      sls_due_dt AS due_date,
      sls_sales AS sales_amount,
      sls_quantity AS quantity,
      sls_price
  FROM DataWarehouse_1.silver.crm_sales_details sd
  LEFT JOIN gold.dim_products pr
  ON sd.sls_prd_key = pr.product_number
  LEFT JOIN gold.dim_customers cu
  ON sd.sls_cust_id = cu.customer_id
 -- where sd.sls_ord_num = 'SO55367'
 ;
