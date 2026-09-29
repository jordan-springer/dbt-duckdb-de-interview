with source as (
    select * from {{ ref('seed_marketing_spend') }}
),

renamed as (
    select
        date::date as spend_date,
        campaign,
        channel,
        cost::double as cost
    from source
)

select * from renamed
