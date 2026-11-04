# Snowflake Native dbt Pipeline with Automated CI/CD

**End-to-End Data Engineering | Snowflake | dbt | GitHub Actions | AWS S3 | Snowpark Python**

An end-to-end data engineering project demonstrating how to build, test, deploy, and automate a modern analytics pipeline using **Snowflake-native dbt Projects**, GitHub Actions, and secure OpenID Connect (OIDC) authentication.

The project uses Snowflake's **Tasty Bytes** dataset to implement a layered data transformation architecture, automated data quality testing, separate development and production environments, and a CI/CD pipeline.

## 1. Project Overview

This project demonstrates a production-oriented data engineering workflow covering:

- Ingestion of source data from AWS S3 into Snowflake.
- Data transformation using SQL and Python dbt models.
- Layered staging and analytical mart architecture.
- Automated data quality validation with dbt tests.
- Separate DEV and PROD deployment environments.
- Native dbt execution inside Snowflake.
- Automated CI/CD using GitHub Actions.
- Passwordless authentication through GitHub OIDC.
- Scheduled model execution using Snowflake Tasks.

The implementation builds upon Snowflake's official *Getting Started with dbt Projects on Snowflake* tutorial and extends it with automated CI/CD deployment.

## 2. Architecture

### Data Pipeline Architecture

```text
                    AWS S3
                       |
                       v
              Snowflake External Stage
                       |
                       v
                 COPY INTO
                       |
                       v
             TASTY_BYTES_DBT_DB
                       |
                       v
                  RAW Schema
                 8 Source Tables
                       |
                       v
                dbt Staging Layer
                   8 Views
                       |
                       v
                dbt Mart Layer
                   3 Tables
                       |
             +---------+---------+
             |                   |
             v                   v
        SQL Models       Python / Snowpark
             |                   |
             +---------+---------+
                       |
                       v
                DEV / PROD
                       |
                       v
           Snowflake dbt Projects
                       |
                       v
              Analytics-Ready Data
```

### CI/CD Architecture

```text
                 GitHub Repository
                        |
              +---------+---------+
              |                   |
              v                   v
        Pull Request        Push to main
              |                   |
              v                   v
          DEV CI              DEV CI
              |                   |
              +---------+---------+
                        |
                        v
               GitHub Actions
                        |
                        v
             Snowflake OIDC Login
                        |
                        v
               Deploy DEV Project
                        |
                        v
                Run 50 dbt Tests
                        |
                        v
                 CI Successful?
                    /       \
                  No         Yes
                  |           |
                  v           v
                 Stop      PROD CD
                              |
                              v
                     Snowflake OIDC Login
                              |
                              v
                      Deploy PROD Project
                              |
                              v
                       Run 11 dbt Models
                              |
                              v
                        Run 50 dbt Tests
                              |
                              v
                       Deployment Result
```

The automatic production deployment is triggered by successful CI runs associated with pushes to the `main` branch. Pull-request CI runs do not automatically deploy to production.

Manual production deployment is also available through GitHub Actions.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data platform and analytical processing |
| dbt Projects on Snowflake | Native transformation, testing, and deployment |
| Snowflake Workspaces | Development environment |
| Snowflake Git Integration | Source-controlled project integration |
| Snowflake CLI | Command-line deployment and execution |
| GitHub Actions | CI/CD automation |
| GitHub OIDC | Passwordless workload authentication |
| SQL | Data modeling and transformations |
| Python | Python-based analytical transformations |
| Snowpark | Python execution inside Snowflake |
| AWS S3 | Source data storage |
| Snowflake Tasks | Scheduled model execution |
| GitHub | Version control and project documentation |

## 4. Data Ingestion

Source data is loaded from AWS S3 into the Snowflake `RAW` schema.

The ingestion process consists of:

1. Configuring the Snowflake database and schemas.
2. Creating a Snowflake external stage referencing AWS S3.
3. Defining raw source tables.
4. Loading data using Snowflake's `COPY INTO` command.
5. Validating source data availability.
6. Making raw tables available to downstream dbt models.

The resulting architecture separates source ingestion from transformation and analytical modeling.

## 5. dbt Data Transformation

The project contains **11 dbt models**, organized into staging and mart layers.

### 5.1 Staging Layer

The staging layer consists of eight models materialized as Snowflake views.

These models provide a transformation boundary between raw source data and downstream analytical models.

Using views for staging supports reusable transformation logic without requiring a separately stored table for every staging model.

### 5.2 Mart Layer

The mart layer consists of three materialized tables.

| Model | Purpose | Technology |
|---|---|---|
| `orders` | Order-level analytical data | SQL |
| `customer_loyalty_metrics` | Customer loyalty analytics | SQL |
| `sales_metrics_by_location` | Location-based sales analytics | Python / Snowpark |

The `sales_metrics_by_location` model demonstrates how Python-based transformations can be integrated into a native Snowflake dbt project.

### 5.3 Model Summary

| Layer | Models | Materialization |
|---|---:|---|
| Staging | 8 | Views |
| Marts | 3 | Tables |
| **Total** | **11** | **8 views + 3 tables** |

## 6. Data Quality and Testing

Data quality is validated using dbt's built-in and custom generic tests.

The project includes:

- `not_null` tests for required values.
- `unique` tests for uniqueness constraints.
- `relationships` tests for referential integrity.
- Custom generic tests for additional business rules.

### Validated Results

| Metric | Result |
|---|---:|
| dbt models | 11 |
| dbt data tests | 50 |
| Development build operations | 61 |
| Development build errors | 0 |
| CI test failures | 0 |

The development build completed successfully, and the automated CI workflow passed all 50 dbt tests.

Production model execution and testing were also successfully validated through GitHub Actions.

## 7. Environment Strategy

The project uses separate Snowflake schemas for development and production.

| Environment | Database | Schema | Purpose |
|---|---|---|---|
| DEV | `TASTY_BYTES_DBT_DB` | `DEV` | Development and automated validation |
| PROD | `TASTY_BYTES_DBT_DB` | `PROD` | Production model execution |

The same dbt project is deployed to both environments using environment-specific targets.

### Development

The DEV environment supports model validation, automated testing, and CI execution.

### Production

The PROD environment supports automated deployment, model execution, and production data quality testing.

This separation provides distinct development and production deployment targets.

## 8. Snowflake-Native dbt Deployment

The project uses Snowflake-native `DBT PROJECT` objects to execute dbt directly within Snowflake.

### DEV Project

```text
TASTY_BYTES_DBT_DB.DEV.TASTY_BYTES_DBT_CI
```

### PROD Project

```text
TASTY_BYTES_DBT_DB.PROD.TASTY_BYTES_DBT_PROD
```

An additional native deployment was implemented during the original tutorial:

```text
TASTY_BYTES_DBT_DB.INTEGRATIONS.TASTY_BYTES_DBT_PROJECT
```

This original deployment demonstrates native Snowflake dbt functionality, while the DEV and PROD projects support the automated GitHub Actions workflows.

### Native Execution Examples

Execute production models:

```sql
EXECUTE DBT PROJECT
    TASTY_BYTES_DBT_DB.PROD.TASTY_BYTES_DBT_PROD
    ARGS = 'run --target prod';
```

Execute production tests:

```sql
EXECUTE DBT PROJECT
    TASTY_BYTES_DBT_DB.PROD.TASTY_BYTES_DBT_PROD
    ARGS = 'test --target prod';
```

These commands execute the deployed dbt project within Snowflake.

## 9. Continuous Integration (CI)

**Workflow:** `.github/workflows/dbt_ci.yml`

Continuous Integration is implemented using GitHub Actions.

### Triggers

The CI workflow runs on:

- Pull requests targeting `main`.
- Pushes to `main`.
- Manual workflow dispatch.

### CI Execution Steps

1. Check out the GitHub repository.
2. Install and configure Snowflake CLI.
3. Authenticate to Snowflake using GitHub OIDC.
4. Verify the Snowflake connection.
5. Deploy the dbt project to the DEV environment.
6. Execute 50 dbt data tests.
7. Report the workflow result.

### DEV Deployment

The pipeline deploys the project using Snowflake CLI:

```bash
snow dbt deploy TASTY_BYTES_DBT_CI -x \
  --source tasty_bytes_dbt_demo \
  --profiles-dir tasty_bytes_dbt_demo \
  --database TASTY_BYTES_DBT_DB \
  --schema DEV \
  --warehouse COMPUTE_WH \
  --default-target dev
```

### DEV Testing

```sql
EXECUTE DBT PROJECT
    TASTY_BYTES_DBT_DB.DEV.TASTY_BYTES_DBT_CI
    ARGS = 'test --target dev';
```

The CI workflow validates the deployed DEV models through dbt tests.

**Note:** The current CI workflow deploys and tests the DEV project. It does not independently execute a full dbt model build.

## 10. Continuous Deployment (CD)

**Workflow:** `.github/workflows/dbt_cd.yml`

Continuous Deployment automates production deployment after successful CI validation.

### Automatic Trigger

The CD workflow uses GitHub Actions `workflow_run` to respond to completed CI workflows.

The production deployment job runs automatically when:

- The upstream CI workflow completes successfully.
- The upstream CI run was triggered by a push.
- The upstream CI branch is `main`.
- The upstream repository matches the project repository.

This prevents a failed upstream CI run from automatically proceeding to production deployment.

Manual deployment remains available through `workflow_dispatch`.

### CD Execution Steps

1. Check out the GitHub repository.
2. Install and configure Snowflake CLI.
3. Authenticate using the production OIDC identity.
4. Verify the Snowflake connection.
5. Deploy the dbt project to PROD.
6. Execute 11 dbt models.
7. Run 50 dbt data tests.
8. Report the production execution result.

### PROD Deployment

```bash
snow dbt deploy TASTY_BYTES_DBT_PROD -x \
  --source tasty_bytes_dbt_demo \
  --profiles-dir tasty_bytes_dbt_demo \
  --database TASTY_BYTES_DBT_DB \
  --schema PROD \
  --warehouse COMPUTE_WH \
  --default-target prod
```

### PROD Model Execution

```sql
EXECUTE DBT PROJECT
    TASTY_BYTES_DBT_DB.PROD.TASTY_BYTES_DBT_PROD
    ARGS = 'run --target prod';
```

### PROD Data Quality Validation

```sql
EXECUTE DBT PROJECT
    TASTY_BYTES_DBT_DB.PROD.TASTY_BYTES_DBT_PROD
    ARGS = 'test --target prod';
```

The automated CI/CD sequence was successfully executed and validated using GitHub Actions.

## 11. Authentication and Security

The CI/CD pipeline uses GitHub OpenID Connect (OIDC) for Snowflake authentication.

This approach avoids storing long-lived Snowflake user passwords or private keys in GitHub Actions.

### DEV Identity

```text
User: GITHUB_ACTIONS_CI_USER
Role: GITHUB_ACTIONS_CI_ROLE
```

### PROD Identity

```text
User: GITHUB_ACTIONS_SERVICE_USER
Role: GITHUB_ACTIONS_CICD_ROLE
```

Separate Snowflake identities and roles are configured for the development and production workflows.

GitHub Environments are also configured:

- `dev`
- `prod`

The Snowflake account identifier is supplied through the `SNOWFLAKE_ACCOUNT` GitHub secret.

OIDC authentication is configured using:

```yaml
permissions:
  contents: read
  id-token: write
```

The workflows use the official Snowflake GitHub Action to configure authentication and Snowflake CLI.

**Security consideration:** Manual production deployment remains enabled. The current implementation also does not enforce a separate production approval step.

## 12. Scheduling and Orchestration

In addition to GitHub Actions, the original tutorial implementation includes native Snowflake Task scheduling.

### Scheduled Task

```text
CUSTOMER_LOYALTY_METRICS_TASK
```

The task was configured to execute:

```text
dbt run --select customer_loyalty_metrics
```

using the `dev` target every 12 hours.

This demonstrates how Snowflake Tasks can orchestrate scheduled dbt execution independently of repository-based CI/CD deployment.

GitHub Actions handles source-driven deployments, while Snowflake Tasks demonstrate scheduled data transformation execution.

## 13. Repository Structure

The repository contains the dbt project, supporting setup files, and GitHub Actions workflow definitions.

```text
getting-started-with-dbt-on-snowflake/
|
|-- .github/
|   `-- workflows/
|       |-- dbt_ci.yml
|       `-- dbt_cd.yml
|
|-- tasty_bytes_dbt_demo/
|   |-- models/
|   |   |-- staging/
|   |   `-- marts/
|   |
|   |-- macros/
|   |-- tests/
|   |-- setup/
|   |-- dbt_project.yml
|   |-- packages.yml
|   |-- profiles.yml
|   `-- dbt_projects_profiles.yml
|
|-- README.md
`-- ... additional supporting files
```

The `.github/workflows/` directory defines the automated CI/CD pipelines, while `tasty_bytes_dbt_demo/` contains the Snowflake-native dbt project.

## 14. Reproducing the Project

The following is a high-level setup guide. A new Snowflake environment requires its own account, permissions, source data, and OIDC configuration.

### Prerequisites

- A Snowflake account supporting dbt Projects on Snowflake.
- A Snowflake warehouse with appropriate execution privileges.
- GitHub repository access.
- Snowflake CLI for command-line deployment.
- Access to the required Tasty Bytes source data.
- Permissions to create Snowflake database objects, roles, and integrations.

### Step 1 — Prepare Snowflake

Create the required database and schemas:

```sql
CREATE DATABASE IF NOT EXISTS TASTY_BYTES_DBT_DB;

CREATE SCHEMA IF NOT EXISTS TASTY_BYTES_DBT_DB.RAW;
CREATE SCHEMA IF NOT EXISTS TASTY_BYTES_DBT_DB.DEV;
CREATE SCHEMA IF NOT EXISTS TASTY_BYTES_DBT_DB.PROD;
```

Prepare a warehouse such as `COMPUTE_WH` and configure the necessary role privileges.

### Step 2 — Load Source Data

Configure the source stage and load the required Tasty Bytes data into the `RAW` schema.

The repository's setup files provide the project-specific ingestion and configuration logic.

### Step 3 — Configure dbt

Review:

```text
tasty_bytes_dbt_demo/dbt_project.yml
tasty_bytes_dbt_demo/dbt_projects_profiles.yml
```

Configure the DEV and PROD targets for the Snowflake environment.

### Step 4 — Configure GitHub OIDC

Create the Snowflake identities, roles, and workload identity integrations required by the workflows.

Configure the `dev` and `prod` GitHub Environments and the Snowflake account secret.

### Step 5 — Deploy to DEV

Deploy the dbt project to the DEV schema using Snowflake CLI.

Run the dbt tests and confirm that the required source tables and models are available.

### Step 6 — Deploy to PROD

Deploy the validated project to the PROD schema.

Execute the models and tests.

### Step 7 — Enable CI/CD

Configure the GitHub Actions workflows and verify that:

1. Pull requests trigger DEV CI.
2. Pushes to `main` trigger DEV CI.
3. Successful push-triggered CI runs trigger PROD CD.
4. Failed CI runs do not automatically deploy to PROD.

## 15. Implementation Results

The following outcomes were achieved during implementation:

| Component | Result |
|---|---|
| AWS S3 source ingestion | Completed |
| Snowflake RAW layer | 8 source tables |
| dbt staging layer | 8 views |
| dbt mart layer | 3 tables |
| Python / Snowpark model | Implemented |
| dbt data tests | 50 |
| Development dbt build | Successful |
| Native Snowflake dbt deployment | Successful |
| Snowflake Task configuration | Completed |
| DEV CI deployment and tests | Successful |
| PROD CD deployment, run, and tests | Successful |
| GitHub OIDC authentication | Working |
| Automatic CI → CD execution | Verified |

## 16. Key Learnings

This project provided practical experience in:

- Building a layered analytical data pipeline.
- Integrating AWS S3 source data with Snowflake.
- Developing SQL and Python models with dbt.
- Running Python transformations through Snowpark.
- Implementing automated data quality tests.
- Managing separate development and production environments.
- Deploying dbt projects natively inside Snowflake.
- Automating deployment with GitHub Actions.
- Configuring passwordless OIDC authentication.
- Using Snowflake Tasks for scheduled execution.
- Troubleshooting GitHub Actions, Snowflake CLI, role privileges, and deployment issues.

## 17. Future Improvements

Potential extensions include:

- Running `dbt build` against an isolated CI schema before production deployment.
- Enforcing branch protection and required status checks.
- Adding production environment approval rules.
- Restricting production deployments to approved source revisions.
- Adding incremental models and snapshot-based change tracking.
- Implementing monitoring and alerting for pipeline failures.
- Introducing more advanced data quality and observability checks.
- Adding infrastructure-as-code for Snowflake and GitHub configuration.

## 18. References

- [Snowflake Documentation](https://docs.snowflake.com/)
- [dbt Projects on Snowflake](https://docs.snowflake.com/en/user-guide/data-engineering/dbt-projects-on-snowflake)
- [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index)
- [dbt Documentation](https://docs.getdbt.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/concepts/security/openid-connect)

---

**Project Repository:** [getting-started-with-dbt-on-snowflake](https://github.com/MrEktirir/getting-started-with-dbt-on-snowflake)

**Project Focus:** Data Engineering · Analytics Engineering · Snowflake · dbt · CI/CD · Cloud Data Platforms