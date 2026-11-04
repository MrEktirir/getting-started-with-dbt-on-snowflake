USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
COPY INTO tasty_bytes_dbt_db.raw.country
FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/country/;
COPY INTO tasty_bytes_dbt_db.raw.franchise
FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/franchise/;
COPY INTO tasty_bytes_dbt_db.raw.location
FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/location/;
COPY INTO tasty_bytes_dbt_db.raw.menu
FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/menu/;
COPY INTO tasty_bytes_dbt_db.raw.truck
FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/truck/;
COPY INTO tasty_bytes_dbt_db.raw.customer_loyalty
FROM @tasty_bytes_dbt_db.public.s3load/raw_customer/customer_loyalty/;
COPY INTO tasty_bytes_dbt_db.raw.order_header
FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/order_header/;
COPY INTO tasty_bytes_dbt_db.raw.order_detail
