with source as (
    select * from {{ ref('seed_sfdc_b_lead') }}
),

renamed as (
    select
        id as b_lead_id,
        lead_id,
        createddate::date as created_date,
        campaign,
        cost::double as cost,
        utm_source,
        utm_medium,
        utm_campaign,
        gclid
    from source
)

select * from renamed
