# About Me

- **Name**: Chad Cole
- **Email**: chad.cole@shopify.com
- **Role**: Backend Engineer
- **Team**: Shop Platform Expansion (Vault team ID: 16743)
- **Group**: Shop Identity (5 years)
- **Vault profile**: https://vault.shopify.io/users/15066

## Current Projects

### Lead Capture (active - release phase)
- Project: Shop Sign In: Lead capture uplift (GSD project 48192)
- In release phase: focus is on flag toggling, rollout, and last-minute fixes
- Slack: #proj-id-lead-capture, #shop-identity-bots
- Main rollout flag: `f_eligible_for_shop_feature_canary_rollout` (currently at 50%, rolling_out)
  - Dashboard: https://experiments.shopify.io/flags/f_eligible_for_shop_feature_canary_rollout
  - Product: Shopify Forms (product_id: 91)
  - Vault team: Shop Identity (16742)
- Key code: `areas/core/shopify/components/shop_identity/app/models/graph_api/admin/shop_features.rb`

## Preferences

- Subject type for flags/experiments: `shop` (unless specified otherwise)
- Default team_id for flags/experiments: 16743
- When creating git commits, always append `Co-authored-by: AI` as a trailer in the commit message body (blank line after the main message, then the trailer)
