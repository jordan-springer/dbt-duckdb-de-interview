with history as (
    select * from {{ ref('seed_sfdc_lead_history') }}
    {# union all select * from {{ ref('seed_sfdc_lead_history_march') }} #}
),

renamed as (
    select
        lead_id,
        valid_from::date as valid_from,
        status,
        is_converted::boolean as is_converted,
        converted_date::date as converted_date,
        owner_id
    from history
)

select * from renamed
