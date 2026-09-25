with source as (
    select * from {{ ref('seed_sfdc_lead') }}
),

renamed as (
    select
        id as lead_id,
        email,
        first_name,
        last_name,
        company,
        title,
        status,
        lead_source,
        created_date::date as created_date,
        is_converted::boolean as is_converted,
        converted_date::date as converted_date,
        owner_id
    from source
)

select * from renamed
