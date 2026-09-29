with source as (
    select * from {{ ref('seed_loan_milestones') }}
),

renamed as (
    select
        lead_id,
        milestone_type,
        milestone_timestamp::timestamp as milestone_timestamp,
        nullif(trim(loan_id), '') as loan_id
    from source
)

select * from renamed
