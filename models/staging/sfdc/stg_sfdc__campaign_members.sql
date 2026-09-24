with source as (
    select * from {{ ref('seed_sfdc_campaign_member') }}
),

renamed as (
    select
        id as campaign_member_id,
        campaign_id,
        lead_id,
        status as member_status,
        has_responded::boolean as has_responded,
        created_date::date as created_date,
        variant,
        experiment_key
    from source
)

select * from renamed
