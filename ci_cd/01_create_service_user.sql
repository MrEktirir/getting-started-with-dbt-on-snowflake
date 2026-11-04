USE ROLE ACCOUNTADMIN;

CREATE USER IF NOT EXISTS github_actions_service_user
  TYPE = SERVICE
  WORKLOAD_IDENTITY = (
    TYPE = OIDC
    ISSUER = 'https://token.actions.githubusercontent.com'
    SUBJECT = 'repo:MrEktirir/getting-started-with-dbt-on-snowflake:environment:prod'
  )
  COMMENT = 'Service user for GitHub Actions CI/CD';