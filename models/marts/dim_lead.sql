-- Customer-grain dimension from Salesforce LEAD (a-lead).
-- Anchor for lead reporting (Architecture Interview warehouse model).
with a_leads as (
    select * from {{ ref('stg_sfdc__a_leads') }}
)

select
    lead_id,
    email,
    first_name,
    last_name,
    created_date,
    status,
    lead_source,
    utm_source,
    utm_medium,
    utm_campaign,
    gclid,
    product_specialty,
    owner_id
from a_leads
