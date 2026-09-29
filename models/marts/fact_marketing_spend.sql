-- Campaign × date marketing spend (purchased-lead cost + Google/Bing Ads).
with spend as (
    select * from {{ ref('stg_marketing_spend') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'spend_date',
            'campaign'
        ]) }} as marketing_spend_id,
        spend_date,
        campaign,
        channel,
        cost
    from spend
)

select * from final
