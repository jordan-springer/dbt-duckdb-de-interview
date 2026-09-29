-- One row per funnel milestone event, keyed on lead_id.
-- Seed uses file_started; brief language uses application — map here.
with milestones as (
    select * from {{ ref('stg_loan_milestones') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'lead_id',
            'milestone_type',
            'milestone_timestamp'
        ]) }} as conversion_transaction_id,
        lead_id,
        case
            when milestone_type = 'file_started' then 'application'
            else milestone_type
        end as milestone_type,
        milestone_timestamp,
        loan_id
    from milestones
)

select * from final
