with campaign_members as (
    select * from {{ ref('fct_campaign_members') }}
),

ab_metrics as (
    select
        experiment_key,
        variant,
        count(distinct lead_id) as total_leads,
        count(distinct case when has_responded then lead_id end) as responded_leads,
        count(distinct case when is_converted then lead_id end) as converted_leads,
        round(
            count(distinct case when has_responded then lead_id end)::numeric 
            / nullif(count(distinct lead_id), 0) * 100,
            2
        ) as response_rate_pct,
        round(
            count(distinct case when is_converted then lead_id end)::numeric 
            / nullif(count(distinct lead_id), 0) * 100,
            2
        ) as conversion_rate_pct
    from campaign_members
    where experiment_key is not null
    group by experiment_key, variant
)

select * from ab_metrics
order by experiment_key, variant
