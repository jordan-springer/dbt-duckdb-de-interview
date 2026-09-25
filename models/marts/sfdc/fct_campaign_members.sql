with campaign_members as (
    select * from {{ ref('stg_sfdc__campaign_members') }}
),

leads as (
    select * from {{ ref('stg_sfdc__leads') }}
),

campaigns as (
    select * from {{ ref('stg_sfdc__campaigns') }}
),

final as (
    select
        cm.campaign_member_id,
        cm.campaign_id,
        cm.lead_id,
        cm.member_status,
        cm.has_responded,
        cm.created_date,
        cm.variant,
        cm.experiment_key,
        c.campaign_name,
        c.campaign_type,
        l.status as lead_status,
        l.is_converted,
        l.converted_date
    from campaign_members cm
    left join campaigns c on cm.campaign_id = c.campaign_id
    left join leads l on cm.lead_id = l.lead_id
)

select * from final
