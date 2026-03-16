---
name: experiments-mcp
description: Interact with the Shopify Experiments Dashboard — create/edit/search feature flags, experiments, bandits, metrics, segments, and manual assignments. Use when working with feature flags (f_*), experiments (e_*), checking flag/experiment status, creating flags for issues, or searching the experiments platform.
---

# Experiments MCP

CLI wrapper for the Shopify Experiments Dashboard MCP server. Provides access to all experiments platform operations.

## Usage

```bash
/path/to/experiments.sh <tool_name> [--param value ...]
```

Always use the full path: `~/.agents/skills/experiments-mcp/experiments.sh`

## Available Tools

### search
Search for experiments, flags, bandits, and metrics.
```bash
./experiments.sh search --query "my_flag" --include_flags true --include_experiments false --include_bandits false
```
Parameters:
- `--query` (string, optional): Search term to filter by name, title, handle, team, status, or description
- `--include_flags` (boolean, optional, default: true): Include flags in results
- `--include_experiments` (boolean, optional, default: true): Include experiments in results
- `--include_bandits` (boolean, optional, default: true): Include bandits in results
- `--include_metrics` (boolean, optional, default: false): Include metrics in results
- `--include_segments` (boolean, optional, default: false): Include segments in results

### flag_create
Create a new feature flag.
```bash
./experiments.sh flag_create --handle "f_my_flag" --title "My Flag" --description "Controls feature X" --subject_type shop
```
Parameters:
- `--handle` (string, required): Must start with `f_`. Snake_case, lowercase.
- `--title` (string, optional): Human-readable title. Auto-generated from handle if omitted.
- `--description` (string, optional): What the flag controls.
- `--subject_type` (string, optional): e.g., `shop`, `checkout`, `identity_user`, `storefront_user`, etc.
- `--owner_email` (string, optional): Flag owner's email.
- `--team_id` (integer, optional): Vault team ID.
- `--product_id` (string, optional): Vault product ID.
- `--project_id` (integer, optional): Vault project ID (GSD).
- `--tags` (JSON array, optional): e.g., `'["tag1","tag2"]'`
- `--slack_channels` (JSON array, optional): e.g., `'["my-channel"]'`

### flag_edit
Edit an existing feature flag.
```bash
./experiments.sh flag_edit --handle "f_my_flag" --title "Updated Title"
```
Same parameters as flag_create (handle is required, rest are optional updates).

### flag_status
Get flag status and configuration.
```bash
./experiments.sh flag_status --flag_handle "f_my_flag"
```
Parameters:
- `--flag_handle` (string, required): Flag handle or handle_hash.

### experiment_create
Create a new experiment.
```bash
./experiments.sh experiment_create --handle "e_my_experiment" --title "My Experiment" --subject_type shop
```
Parameters:
- `--handle` (string, required): Must start with `e_`. Snake_case, lowercase.
- `--title` (string, optional): Human-readable title.
- `--description` (string, optional): What the experiment tests.
- `--hypothesis` (string, optional): Hypothesis statement.
- `--subject_type` (string, optional): e.g., `shop`, `checkout`, etc.

### experiment_edit
Edit an existing experiment.
```bash
./experiments.sh experiment_edit --handle "e_my_experiment" --title "New Title"
```
Parameters: handle (required), plus optional: title, description, hypothesis, team_id, champion_id, tags, slack_channels.

### experiment_status
Quick experiment status summary.
```bash
./experiments.sh experiment_status --experiment_handle "e_my_experiment"
```

### experiment_details
Full experiment details including analysis results.
```bash
./experiments.sh experiment_details --experiment_handle "e_my_experiment"
```

### bandit_status
Get bandit status and configuration.
```bash
./experiments.sh bandit_status --bandit_handle "my_bandit"
```

### manual_assignments
Manage manual assignments for flags/experiments.
```bash
# List assignments
./experiments.sh manual_assignments --action list --handle "f_my_flag"
# Upsert assignments
./experiments.sh manual_assignments --action upsert --handle "f_my_flag" --assignments '[{"subject_id":"123","enabled":true}]'
# Delete assignments
./experiments.sh manual_assignments --action delete --handle "f_my_flag" --subject_ids '["123"]'
```

### metric_create / metric_status / metric_update
Create, view, or update metrics.

### segment_create / segment_status / segment_update
Create, view, or update segments.

### documentation
Search experiments platform documentation.
```bash
./experiments.sh documentation --prompt "How do I set up targeting rules?"
```

### enrich_metadata
Suggest improved metadata for experiments or metrics.
```bash
./experiments.sh enrich_metadata --experiment_handle "e_my_experiment" --fields '["description","hypothesis"]'
```

## Subject Types
Common values: `shop`, `checkout`, `identity_user`, `storefront_user`, `organization`, `api_client`, `buyer_session`, `email`, `merchant_email`.

## Notes
- Flag handles must start with `f_`
- Experiment handles must start with `e_`
- All handles are snake_case, lowercase, alphanumeric + underscores
- The script requires `uvx` and `shopify-mcp-bridge` to be installed
- Dashboard URL: `https://experiments.shopify.io/flags/{handle}` or `https://experiments.shopify.io/experiments/{handle}`
