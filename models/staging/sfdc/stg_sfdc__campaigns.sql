with source as (
    select * from {{ ref('seed_sfdc_campaign') }}
),

renamed as (
    select
        id as campaign_id,
        name as campaign_name,
        type as campaign_type,
        status as campaign_status,
        start_date::date as start_date,
        end_date::date as end_date,
        is_active::boolean as is_active
    from source
)

select * from renamed
