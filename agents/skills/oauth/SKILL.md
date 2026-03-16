---
name: oauth
description: OAuth 2.0/2.1, OpenID Connect, and PKCE reference for writing and reviewing OAuth code. Covers RFCs 6749, 6750, 7636, 7519, 9126, 9207, 9449, OpenID Connect Core 1.0, and OAuth 2.1 draft. Use when implementing or reviewing authorization flows, token endpoints, PKCE, scopes, consent, redirect URI validation, or error handling in the Accounts OAuth namespace.
---

# OAuth & OpenID Connect Reference

Comprehensive reference for writing and reviewing OAuth/OIDC code, sourced from the actual RFCs and mapped to Shopify's `Accounts::OAuth` implementation.

## Applicable Specifications

| Spec | What it covers | Key sections |
|------|---------------|-------------|
| **RFC 6749** | OAuth 2.0 core framework | §4.1 Auth Code Grant, §5 Token Response, §10 Security |
| **RFC 6750** | Bearer token usage | §2 Authenticated Requests, §3 Error Codes |
| **RFC 7636** | PKCE (Proof Key for Code Exchange) | §4 Protocol, §7 Security |
| **RFC 7519** | JSON Web Token (JWT) | §4 Claims, §7 Creating/Validating |
| **RFC 9126** | Pushed Authorization Requests (PAR) | §2 PAR Endpoint, §3 Security |
| **RFC 9207** | Authorization Server Issuer Identification | §2 `iss` response parameter |
| **RFC 9449** | DPoP (Demonstrating Proof of Possession) | §4 DPoP Proof JWTs, §7 Security |
| **OAuth 2.1 draft-12** | Consolidates 2.0 + security BCP | §4.1 Auth Code, §10 Changes from 2.0 |
| **OIDC Core 1.0** | Identity layer on OAuth 2.0 | §2 ID Token, §3.1 Auth Code Flow, §5 Claims |
| **RFC 6819** | OAuth 2.0 Threat Model & Security | §4 Security Threats, §5 Countermeasures |

## Key Changes in OAuth 2.1 (draft-ietf-oauth-v2-1-12)

OAuth 2.1 is the consolidation of OAuth 2.0 + all security best practice RFCs. From §10 of the draft:

1. **PKCE is required** for all authorization code grants (incorporated from RFC 7636)
2. **Exact string matching** required for redirect URIs (per §4.1.3 of security BCP)
3. **Implicit grant removed** (`response_type=token` no longer defined)
4. **Resource Owner Password Credentials grant removed**
5. **Bearer tokens in query strings removed** (no `?access_token=` in URLs)
6. **Refresh tokens** for public clients must be sender-constrained or one-time use
7. **`redirect_uri` removed from token request** — PKCE now prevents code injection, making it unnecessary

---

## Authorization Code Flow

The only grant type that matters. OAuth 2.1 §4.1.

### Step 1: Authorization Request (`GET /authorize`)

RFC 6749 §4.1.1, OAuth 2.1 §4.1.1:

| Parameter | Required | Spec reference |
|-----------|----------|---------------|
| `response_type=code` | REQUIRED | RFC 6749 §3.1.1 — MUST be "code" |
| `client_id` | REQUIRED | RFC 6749 §2.2 — unique string, not a secret |
| `redirect_uri` | REQUIRED if multiple registered | RFC 6749 §3.1.2.3 — exact match per OAuth 2.1 |
| `scope` | OPTIONAL | RFC 6749 §3.3 — space-delimited, case-sensitive |
| `state` | RECOMMENDED | RFC 6749 §10.12 — CSRF protection, echoed back unchanged |
| `code_challenge` | REQUIRED (OAuth 2.1) | RFC 7636 §4.3 — `BASE64URL(SHA256(code_verifier))` |
| `code_challenge_method` | OPTIONAL | RFC 7636 §4.3 — defaults to "plain", MUST use "S256" |

OIDC adds:
| `nonce` | OPTIONAL | OIDC Core §3.1.2.1 — binds ID token to session, prevents replay |
| `prompt` | OPTIONAL | OIDC Core §3.1.2.1 — `none`, `login`, `consent`, `select_account` |
| `response_mode` | OPTIONAL | OAuth Multiple Response Types — `query`, `fragment`, `form_post`, `web_message` |

Per RFC 6749 §3.1: "Parameters sent without a value MUST be treated as if they were omitted from the request. The authorization server MUST ignore unrecognized request parameters. Request and response parameters MUST NOT be included more than once."

### Step 2: Authorization Response

RFC 6749 §4.1.2:

On **success**, redirect to `redirect_uri` with:
- `code` — authorization code (short-lived, single-use)
- `state` — REQUIRED if present in request, echoed back unchanged

On **error** (RFC 6749 §4.1.2.1):
- `error` — one of the defined error codes (see Error Codes section)
- `error_description` — OPTIONAL, human-readable ASCII for the developer
- `error_uri` — OPTIONAL, URI to human-readable error page
- `state` — REQUIRED if present in request

**Critical rule** (RFC 6749 §3.1.2.4): "If an authorization request fails validation due to a missing, invalid, or mismatching redirection URI, the authorization server SHOULD inform the resource owner of the error and MUST NOT automatically redirect the user-agent to the invalid redirection URI."

### Step 3: Token Request (`POST /token`)

RFC 6749 §4.1.3, OAuth 2.1 §4.1.3:

| Parameter | Required | Notes |
|-----------|----------|-------|
| `grant_type=authorization_code` | REQUIRED | |
| `code` | REQUIRED | The authorization code |
| `redirect_uri` | REQUIRED in 2.0 if sent in auth request; removed in 2.1 | |
| `client_id` | REQUIRED if not authenticating otherwise | |
| `code_verifier` | REQUIRED (OAuth 2.1) | RFC 7636 §4.5 — the PKCE verifier |

Per RFC 6749 §4.1.3, the authorization server MUST:
1. Require client authentication for confidential clients
2. Authenticate the client if authentication is included
3. Ensure the code was issued to the authenticated client
4. Verify the authorization code is valid
5. Ensure `redirect_uri` matches the one from the authorization request (2.0)

Per RFC 7636 §4.6, additionally:
6. Compute `BASE64URL(SHA256(code_verifier))` and compare to stored `code_challenge`
7. If they don't match, return `invalid_grant`

### Step 4: Token Response

RFC 6749 §5.1:

```json
{
  "access_token": "2YotnFZFEjr1zCsicMWpAA",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA",
  "scope": "openid email"
}
```

Headers MUST include `Cache-Control: no-store` (RFC 6749 §5.1).

When `scope` includes `openid`, the response MUST include `id_token` (OIDC Core §3.1.3.3).

---

## PKCE (RFC 7636)

Protects against authorization code interception attacks. **Required in OAuth 2.1.**

### Protocol (RFC 7636 §4)

1. **Client creates code_verifier** (§4.1): cryptographically random string, 43-128 chars, unreserved URI chars (`[A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~"`). RECOMMENDED: base64url-encode 32 random octets to get 43-char string.

2. **Client creates code_challenge** (§4.2):
   - `S256`: `code_challenge = BASE64URL(SHA256(ASCII(code_verifier)))` — **MUST use this if capable**
   - `plain`: `code_challenge = code_verifier` — only if S256 technically impossible

3. **Client sends code_challenge + code_challenge_method** in authorization request (§4.3)

4. **Server stores code_challenge** with the authorization code (§4.4). May store in encrypted form within the code itself (this is what Shopify does via JWT).

5. **Client sends code_verifier** in token request (§4.5)

6. **Server verifies** (§4.6): computes `BASE64URL(SHA256(code_verifier))`, compares to stored challenge. Mismatch → `invalid_grant`.

### Implementation (from `PKCEVerifierRule`)

```ruby
calculated_challenge = Base64.urlsafe_encode64(
  Digest::SHA256.digest(code_verifier),
  padding: false
)
error unless calculated_challenge == stored_code_challenge
```

### Security (RFC 7636 §7)

- Code verifier MUST have >= 256 bits of entropy (§7.1)
- S256 prevents eavesdroppers who can observe the authorization request from computing the verifier (§7.2)
- Each code_challenge is unique per authorization request — not salted, not reused (§7.3)

---

## OpenID Connect ID Token (OIDC Core §2)

### Required Claims

| Claim | Description | Spec |
|-------|-------------|------|
| `iss` | Issuer identifier (HTTPS URL) | OIDC Core §2 — case-sensitive URL, no query/fragment |
| `sub` | Subject identifier (locally unique, never reassigned) | OIDC Core §2 — max 255 ASCII chars |
| `aud` | Audience — MUST contain the client_id | OIDC Core §2 — string or array of strings |
| `exp` | Expiration time (Unix timestamp) | OIDC Core §2 — MUST be in the future |
| `iat` | Issued at time (Unix timestamp) | OIDC Core §2 |

### Optional Claims

| Claim | Description |
|-------|-------------|
| `auth_time` | When authentication occurred (REQUIRED if `max_age` requested) |
| `nonce` | Echoed from authentication request — MUST verify matches |
| `acr` | Authentication Context Class Reference |
| `amr` | Authentication Methods References (array of strings) |
| `azp` | Authorized party (client_id) — only when extensions used |

### Standard Scopes → Claims (OIDC Core §5.4)

| Scope | Claims granted |
|-------|---------------|
| `openid` | `sub` (required to trigger OIDC) |
| `profile` | `name`, `family_name`, `given_name`, `middle_name`, `nickname`, `preferred_username`, `profile`, `picture`, `website`, `gender`, `birthdate`, `zoneinfo`, `locale`, `updated_at` |
| `email` | `email`, `email_verified` |
| `phone` | `phone_number`, `phone_number_verified` |
| `address` | `address` (JSON object) |

**Important from OIDC Core §5.4:** Scopes define which claim sets the client is requesting. The authorization server determines which claims to actually return based on the scopes, the user's consent, and the server's policy.

### Shopify Implementation Notes (from `OpenIDToken`)

- Only grant claims that `conferrable_scope` allows AND `requested_scope` asks for
- `profile` scope only shares `given_name`, `family_name`, and `picture` — other profile claims withheld per legal approval
- `phone` claims only included if user has a phone number on file
- `email_verified` is true if phone ownership verified OR authentication method was Email
- Session tokens gated behind `pay:session_token` scope
- Authorization codes encoded as encrypted JWTs (via `Pay::JwtSigningService`), NOT database records

### ID Token Signing (OIDC Core §2, §16.14)

- ID Tokens MUST be signed using JWS
- MAY be signed then encrypted (Nested JWT)
- MUST NOT use `"alg": "none"` unless no ID token returned from authorization endpoint
- SHOULD NOT use `x5u`, `x5c`, `jku`, or `jwk` header parameters

---

## Error Codes

### Authorization Endpoint (RFC 6749 §4.1.2.1)

| Code | RFC 6749 description | HTTP status |
|------|---------------------|-------------|
| `invalid_request` | Missing/invalid/duplicate parameter, or malformed | 400 |
| `unauthorized_client` | Client not authorized for this grant type | 403 |
| `access_denied` | Resource owner or server denied the request | 403 |
| `unsupported_response_type` | Server doesn't support the requested response_type | 400 |
| `invalid_scope` | Scope invalid, unknown, or malformed | 400 |
| `server_error` | Unexpected condition (use instead of HTTP 500 via redirect) | 500 |
| `temporarily_unavailable` | Server overloaded/maintenance (use instead of HTTP 503 via redirect) | 503 |

Per RFC 6749 §4.1.2.1: "Values for the 'error' parameter MUST NOT include characters outside the set %x20-21 / %x23-5B / %x5D-7E."

### Token Endpoint (RFC 6749 §5.2)

| Code | Description |
|------|-------------|
| `invalid_request` | Missing/invalid parameter |
| `invalid_client` | Client authentication failed |
| `invalid_grant` | Code expired, already used, verifier mismatch, or redirect_uri mismatch |
| `unauthorized_client` | Client not authorized for this grant type |
| `unsupported_grant_type` | Server doesn't support the grant type |
| `invalid_scope` | Scope exceeds what was originally granted |

### OIDC-Specific (OIDC Core §3.1.2.6)

| Code | When |
|------|------|
| `login_required` | `prompt=none` but user not authenticated |
| `interaction_required` | `prompt=none` but user interaction needed |
| `consent_required` | `prompt=none` but consent needed |
| `account_selection_required` | `prompt=none` but user must select account |
| `invalid_request_uri` | `request_uri` invalid |
| `invalid_request_object` | `request` parameter contains invalid Request Object |
| `request_not_supported` | Server doesn't support `request` parameter |
| `request_uri_not_supported` | Server doesn't support `request_uri` parameter |
| `registration_not_supported` | Server doesn't support `registration` parameter |

---

## Response Modes

| Mode | Spec | Delivery mechanism |
|------|------|--------------------|
| `query` | RFC 6749 §4.1.2 | Redirect, params in query string (`?code=...&state=...`) |
| `fragment` | RFC 6749 §4.2.2 | Redirect, params in URL fragment (`#access_token=...`) |
| `form_post` | OIDC Form Post Response Mode | Server POSTs params as form body to redirect_uri |
| `web_message` | draft-sakimura-oauth-wmrm | `postMessage` to parent window (requires `target_origin`) |

From the `ResponseMode` enum: `web_message` REQUIRES `target_origin` — validated and CSP-sanitized via `Pay::UrlHelper.csp_safe_origin`.

---

## Redirect URI Validation

### Per RFC 6749 §3.1.2.3

"If the client registration included the full redirection URI, the authorization server MUST compare the two URIs using simple string comparison as defined in [RFC3986] Section 6.2.1."

### Per OAuth 2.1 §4.1.3

Redirect URIs MUST be compared using **exact string matching**. No partial matching, no wildcards per spec.

### Per RFC 6749 §3.1.2.4

"If an authorization request fails validation due to a missing, invalid, or mismatching redirection URI, the authorization server SHOULD inform the resource owner of the error and MUST NOT automatically redirect the user-agent to the invalid redirection URI."

### Shopify Exceptions (from `RedirectURIRule`)

The codebase allows wildcard redirect URI matching for specific clients:
- **By UUID**: shop.app website, Shop Web local dev — `INSECURE_WILDCARD_CLIENT_UUIDS`
- **By handle**: identity, shop-web-staging-to-prod — `CLIENT_HANDLES_WITH_WILDCARD_REDIRECT_URIS`
- **By client type**: admin partner apps — `CLIENT_TYPES_WITH_WILDCARD_REDIRECT_URIS` (with killswitch)
- **By prefix**: Shop Pay payment requests — `KNOWN_ALLOWED_REDIRECT_URI_PREFIXES`

**Review rule:** New wildcard exceptions are a security risk. Require strong justification and consider the redirect URI as an open redirector vector (RFC 6749 §10.15).

---

## Security Requirements (RFC 6749 §10, RFC 7636 §7, OAuth 2.1 §7)

### MUST

- **TLS on all endpoints** (RFC 6749 §1.6, §3.1, §3.2, §10.9) — authorization, token, and redirection endpoints
- **Authorization codes single-use** (RFC 6749 §10.5) — "If the authorization server observes multiple attempts to exchange an authorization code for an access token, the authorization server SHOULD attempt to revoke all access tokens already granted based on the compromised authorization code"
- **PKCE required** (OAuth 2.1) — S256 only
- **State parameter** for CSRF protection (RFC 6749 §10.12) — must be non-guessable and bound to user-agent authenticated state
- **Exact redirect URI matching** (OAuth 2.1)
- **Token responses** include `Cache-Control: no-store` (RFC 6749 §5.1)
- **Credential entropy** ≥ 2^(-128) probability of guessing (RFC 6749 §10.10)
- **Sanitize and validate** all received values, especially `state` and `redirect_uri` (RFC 6749 §10.14)

### MUST NOT

- **Redirect on invalid client_id or redirect_uri** (RFC 6749 §3.1.2.4) — show error directly
- **Accept `response_type=token`** (OAuth 2.1 §10.1) — implicit grant removed
- **Accept `code_challenge_method=plain`** when S256 is possible (RFC 7636 §4.2)
- **Include credentials in request URI** (RFC 6749 §2.3.1) — body only for client_secret
- **Use `"alg": "none"`** for ID tokens (OIDC Core §2) unless no ID token from authorization endpoint

### SHOULD

- **Rotate refresh tokens** on use (RFC 6749 §10.4)
- **Short-lived access tokens** — prefer < 1 hour
- **Validate nonce** in ID tokens to prevent replay (OIDC Core §2)
- **Use external browsers** not embedded webviews for authorization (RFC 6749 §10.13 — clickjacking prevention)
- **Frame-busting or X-Frame-Options** on authorization endpoint (RFC 6749 §10.13)

---

## Shopify's Accounts::OAuth Implementation Map

```
Accounts::OAuth::
├── AuthorizeRequest         # §4.1.1 — structures /authorize params, stores as JWT
├── AuthorizationCode        # §4.1.2 — codes as encrypted JWTs (not DB records)
│   └── Result               # Wraps decoded code + analytics trace
├── ErrorCode (T::Enum)      # §4.1.2.1 + §5.2 — all RFC error codes
├── ErrorResponse            # Error builder with factory methods + descriptions
├── ResponseBuilder          # Builds per response_mode (web_message, form_post, redirect)
├── ResponseType (T::Enum)   # code, id_token
├── ResponseMode (T::Enum)   # web_message, form_post, fragment, query
├── ConsentPolicy            # OIDC §3.1.2.4 — when explicit consent needed
├── OpenIDToken (T::Struct)  # OIDC §2 — ID token with all standard claims
│   ├── EmailDetails         # OIDC §5.4 — email scope claims
│   └── PhoneDetails         # OIDC §5.4 — phone scope claims
└── Prompt (T::Enum)         # OIDC §3.1.2.1 — login, consent, none, etc.

Accounts::OAuthValidator::
├── OAuthRequest (T::Struct)  # Input for validation
├── OAuthError (T::Struct)    # Error output with factory methods
├── OAuthRule                 # Base linked-list rule
├── ClientRule                # §2.3 — client valid + required scope
├── RedirectURIRule           # §3.1.2.3 — exact or wildcard matching
├── ResponseTypeRule          # §3.1.1 — supported response type
├── ResponseModeRule          # Multiple Response Types — supported mode
├── PKCERule                  # RFC 7636 §4.3 — S256 only
├── PKCEVerifierRule          # RFC 7636 §4.6 — verifier matches challenge
├── UserRule                  # User present and valid
└── RequestedScopeRule        # §3.3 — scope ⊆ conferrable_scope
```

### Validation Order

1. **Client** → is the client valid and has required scope?
2. **Redirect URI** → is it on the allowlist?
3. **Response Type** → is `code` or `id_token`?
4. **Response Mode** → is it supported? (`web_message` needs `target_origin`)
5. **PKCE** → is `code_challenge_method` S256?
6. **User** → is the user present?
7. **Scope** → is requested_scope ⊆ conferrable_scope AND ⊇ required_scope?

---

## Code Review Checklist

When reviewing OAuth code, verify against the actual RFCs:

- [ ] **Auth codes are single-use** and short-lived (RFC 6749 §10.5 — 5 min in Shopify)
- [ ] **PKCE enforced** — S256 only, no plain (RFC 7636 §4.2, OAuth 2.1)
- [ ] **Redirect URIs validated before any redirect** (RFC 6749 §3.1.2.4)
- [ ] **No redirect on invalid client_id/redirect_uri** — show error directly (RFC 6749 §3.1.2.4)
- [ ] **Scopes checked** against `conferrable_scope` (RFC 6749 §3.3)
- [ ] **ID token claims match scope grants** — no extra claims leaking (OIDC Core §5.4)
- [ ] **`state` echoed back unchanged** (RFC 6749 §4.1.2)
- [ ] **`nonce` included in ID token** if present in request (OIDC Core §2)
- [ ] **Token responses have `Cache-Control: no-store`** (RFC 6749 §5.1)
- [ ] **No raw tokens/codes in logs** (RFC 6749 §10.8)
- [ ] **New wildcard redirect URIs** have security justification (RFC 6749 §10.15)
- [ ] **Error codes use exact RFC values** — `invalid_request`, not custom strings (RFC 6749 §4.1.2.1)
- [ ] **Error descriptions are for developers**, not end users (RFC 6749 §4.1.2.1)
