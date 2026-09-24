with leads as (
    select * from {{ ref('stg_sfdc__leads') }}
),

final as (
    select
        lead_id,
        email,
        first_name,
        last_name,
        company,
        title,
        status,
        lead_source,
        created_date,
        is_converted,
        converted_date,
        owner_id,
        case
            when is_converted then datediff('day', created_date, converted_date)
            else null
        end as days_to_convert
    from leads
)

select * from final
