# Native dbt Data Pipeline on Snowflake

## Overview

This project demonstrates an end-to-end dbt data pipeline running natively inside Snowflake using the Tasty Bytes dataset.

The project was implemented using Snowflake Workspaces and dbt Projects on Snowflake, covering source data ingestion, dbt modeling, testing, development and production environments, native deployment, and scheduled execution.

The implementation is based on Snowflake's official **Getting Started with dbt Projects on Snowflake** tutorial and was adapted and validated in a Snowflake trial environment.

## Architecture

AWS S3
   ↓
Snowflake External Stage
   ↓
RAW Tables
   ↓
dbt Staging Models (Views)
   ↓
dbt Mart Models (Tables)
   ↓
DEV / PROD
   ↓
Deployed Snowflake dbt Project
   ↓
Snowflake Scheduled Task

## Technologies

- Snowflake
- dbt Projects on Snowflake
- Snowflake Workspaces
- Snowflake Git Integration
- Snowflake Tasks
- SQL
- Python / Snowpark
- AWS S3
- GitHub

## Data Pipeline

Source data is loaded from AWS S3 into the `RAW` schema using a Snowflake external stage and `COPY INTO`.

The dbt project contains:

### Staging Layer

Eight staging models are materialized as **views** and provide the transformation layer between the raw source tables and downstream marts.

### Mart Layer

Three models are materialized as **tables**:

- `orders`
- `customer_loyalty_metrics`
- `sales_metrics_by_location`

The `sales_metrics_by_location` model is implemented as a Python dbt model using Snowpark.

## Data Quality

The project includes dbt data tests covering:

- `not_null`
- `unique`
- `relationships`
- custom generic tests

The validated development build completed successfully with:

- 11 models
- 50 data tests
- 61 total build operations
- 0 errors

## Environments

Two Snowflake schemas are used as dbt targets:

- `DEV` — development and validation
- `PROD` — production execution

The project was first compiled, executed, tested, and built against the development environment before being deployed and executed against production.

## Native dbt Deployment

The dbt project is deployed as a native Snowflake `DBT PROJECT` object:

`TASTY_BYTES_DBT_DB.INTEGRATIONS.TASTY_BYTES_DBT_PROJECT`

The deployed project uses the `prod` target by default.

A production execution was successfully validated across all 11 models.

## Scheduling

A Snowflake Task named:

`CUSTOMER_LOYALTY_METRICS_TASK`

was created to execute:

`dbt run --select customer_loyalty_metrics`

on the `dev` target every 12 hours.

## Repository Structure

```text
tasty_bytes_dbt_demo/
├── models/
│   ├── staging/
│   └── marts/
├── macros/
├── tests/
├── setup/
├── dbt_project.yml
├── packages.yml
├── profiles.yml
└── schedules.sql
