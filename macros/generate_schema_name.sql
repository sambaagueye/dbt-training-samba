{% macro generate_schema_name(custom_schema_name, node) -%}

    {# 1. Retrieve the Environment and Target variables #}
    {%- set dbt_env = env_var('DBT_ENVIRONMENT', 'DEV') | upper | trim -%}
    {%- set target_name = target.name | upper | trim -%}
    {%- set default_schema = target.schema -%}

    {# 2. Logic for Development Environment (IDE / Local) #}
    {# Force everything into the user s personal schema defined in credentials #}
    {%- if dbt_env == 'DEV' -%}

        {{ default_schema }}

    {# 3. Logic for CI Jobs (Pull Requests) #}
    {# Return only the default schema; dbt Cloud handles the PR prefixing automatically #}
    {%- elif target_name == 'CI' -%}

        {{ default_schema }}

    {# 4. Logic for deployement or merge Jobs #}
    {# If a custom schema is defined (e.g. 'marts'), use it directly without a prefix #}
    {%- elif target_name == 'DEPLOY' -%}

        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}

    {# 5. Default Fallback #}
    {%- else -%}

        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {%- endif -%}

    {%- endif -%}

{%- endmacro %}