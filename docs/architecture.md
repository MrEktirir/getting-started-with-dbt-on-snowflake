## Architecture

```text
                         GitHub Repository
                                │
                                ▼
                       Snowflake Workspace
                                │
                                ▼
                      dbt Projects on Snowflake
                                │
                                │
AWS S3 ──► External Stage ──► RAW Tables
                                │
                                ▼
                       dbt Staging Models
                            (Views)
                                │
                                ▼
                         dbt Mart Models
                            (Tables)
                                │
                         ┌──────┴──────┐
                         ▼             ▼
                        DEV           PROD
                                       │
                                       ▼
                              Deployed DBT PROJECT

Snowflake Task ──► Scheduled dbt Run
