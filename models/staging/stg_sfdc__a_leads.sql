with source as (
    select * from {{ ref('seed_sfdc_a_lead') }}
),

renamed as (
    select
        id as lead_id,
        email,
        first_name,
        last_name,
        createddate::date as created_date,
        status,
        leadsource as lead_source,
        utm_source,
        utm_medium,
        utm_campaign,
        gclid,
        product_specialty,
        owner_id
    from source
)

select * from renamed
