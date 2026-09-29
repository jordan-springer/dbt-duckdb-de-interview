with leads as (
    select * from {{ ref('stg_sfdc__leads') }}
),

lead_history as (
    select * from {{ ref('stg_sfdc__lead_history') }}
),

history_lead_ids as (
    select distinct lead_id from lead_history
),

bootstrap_versions as (
    select
        l.lead_id,
        l.created_date as valid_from,
        l.status,
        l.is_converted,
        l.converted_date,
        l.owner_id
    from leads as l
    left join history_lead_ids as h on l.lead_id = h.lead_id
    where h.lead_id is null
),

all_versions as (
    select * from bootstrap_versions
    union all
    select * from lead_history
),

scd2 as (
    select
        lead_id,
        valid_from,
        status,
        is_converted,
        converted_date,
        owner_id,
        lead(valid_from) over (
            partition by lead_id
            order by valid_from
        ) as valid_to
    from all_versions
),

final as (
    select
        v.lead_id,
        l.email,
        l.first_name,
        l.last_name,
        l.company,
        l.title,
        v.status,
        l.lead_source,
        l.created_date,
        v.is_converted,
        v.converted_date,
        v.owner_id,
        v.valid_from,
        v.valid_to,
        v.valid_to is null as is_current,
        case
            when v.is_converted then datediff('day', l.created_date, v.converted_date)
            else null
        end as days_to_convert
    from scd2 as v
    inner join leads as l on v.lead_id = l.lead_id
)

select * from final
