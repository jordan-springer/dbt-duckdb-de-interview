with campaigns as (
    select * from {{ ref('stg_sfdc__campaigns') }}
),

final as (
    select
        campaign_id,
        campaign_name,
        campaign_type,
        campaign_status,
        start_date,
        end_date,
        is_active,
        datediff('day', start_date, end_date) as campaign_duration_days
    from campaigns
)

select * from final
