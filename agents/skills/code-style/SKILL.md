---
name: code-style
description: Write Ruby code in Chad's style. Use when writing or reviewing any Ruby code, implementing features, fixing bugs, or refactoring. Applies Chad's conventions for structure, naming, typing, error handling, and test writing.
---

# Chad's Code Style

When writing Ruby code for Chad, follow these conventions derived from his actual codebase. The goal is code that is **easy to read, easy to use, and does the reasonable thing** — even if it takes more effort upfront.

## Core Principles

1. **Brevity without sacrificing clarity.** Don't use two lines when one will do. Prefer single-expression methods, inline returns, and guard clauses over nested conditionals.
2. **Do the reasonable thing.** Handle edge cases gracefully. Return sensible defaults. Fall back rather than crash. The caller shouldn't need to think about your internals.
3. **Flat over nested.** Use early returns and guard clauses to keep the happy path at the top indentation level. Avoid deep nesting.
4. **Types everywhere.** Every method gets a type signature — prefer RBS comments (`#:`) over Sorbet `sig` blocks. Use them consistently on both public and private methods.
5. **Small, focused classes.** Each class does one thing. If a class needs to coordinate, compose it from focused pieces.

## Method Style

### One-liner methods with endless syntax
When the body is a single expression, use endless method syntax:

```ruby
#: -> Integer
def shop_id = shop.id

#: (Customers::CustomerEntity) -> String?
def unsafe_customer_email(customer) = customer.default_email_address&.email_address&.value
```

### Guard clauses with inline returns
Chain guard clauses at the top. Return early on nil/blank rather than wrapping in conditionals:

```ruby
#: (Customers::CustomerEntity?) -> ApiCustomerAccessToken?
def customer_access_token(unsafe_customer)
  return if (customer = unsafe_customer).blank?
  return if (customer_email = unsafe_customer_email(customer)).blank?
  return if (api_permission = unsafe_api_permission).blank?

  CustomerTokenManager
    .new(api_permission)
    .create_or_renew_token(customer_email)
end
```

Note the pattern: **assign and test in the guard clause** (`return if (x = expr).blank?`) to avoid separate assignment lines.

### Method chains on separate lines
When chaining, put each step on its own line with leading dot, aligned:

```ruby
result = AdtAccumulator
  .new(set_personal_information(customer:, first_name:, last_name:, avatar_url:, request_context:, overwrite:))
  .then_accumulate { |customer| set_phone_number(customer:, phone_number:, request_context:, overwrite:) }
  .then_accumulate { |customer| set_tags(customer:, tags:, request_context:, overwrite:) }
  .result { |errors| errors.reduce { |combined, e| combined.merge(e) } }
```

## Type Signatures

### Prefer RBS comment syntax
Use `#:` for signatures. Use `sig` blocks only when existing code uses them (don't mix styles in a file):

```ruby
#: (String?) -> Role?
def self.load(string)
  try_deserialize(string)
end

#: -> bool
def has_admin?
  role == Role::Admin
end

#: (event: String, ?success: bool, ?payload: Hash, ?error_message: String?) -> void
def report(event:, success: true, payload: {}, error_message: nil)
```

### Inline type assertions
Prefer RBS inline assertions over `T.let`/`T.cast`:

```ruby
@errors = [] #: Array[V]
@fatal = false #: bool
@value = adt.ok_value #: U
```

## Class Structure

### Consistent ordering
1. `typed` and `frozen_string_literal` pragmas
2. Module/class declaration
3. `include`s and `extend`s
4. `self.table_name`, `self.primary_key`, configuration blocks
5. Constants
6. Validations
7. Serializers (defined as inner classes if custom)
8. Associations (`belongs_to`, `has_many`)
9. Callbacks
10. Public methods
11. `private` keyword
12. Private methods

### Inner classes for domain concepts
Define serializers, enums, and value types as inner classes when they're tightly coupled:

```ruby
class AccessPolicy < GlobalDbRecord
  class Role < T::Enum
    include Comparable

    enums do
      Read = new("READ")
      ReadWrite = new("READ_WRITE")
    end

    #: -> Hash[Role, Integer]
    def self.precedence
      { Read => 1, Write => 2, ReadWrite => 2, Admin => 3 }
    end
  end

  serialize :role, coder: Role
end
```

### Type aliases for union types
When a parameter could be multiple types, define a named type alias in its own file:

```ruby
# permissible.rb
module CustomData
  Permissible = T.type_alias { T.any(MetafieldNamespace, MetafieldDefinition) }
end
```

## Error Handling

### Structured errors with factory methods
Define error structs with descriptive factory methods rather than bare strings:

```ruby
class OAuthError < T::Struct
  const :error, Error
  const :can_redirect, T::Boolean
  const :violation, T.nilable(String)

  class << self
    sig { params(can_redirect: T::Boolean).returns(OAuthError) }
    def invalid_client_error
      OAuthError.new(
        error: Error.new(code: :invalid_client, message: "Unknown client"),
        can_redirect: false,
      )
    end
  end
end
```

### Chain of responsibility for validation
Use composable rule chains. Each rule is a small class with a single `check` method:

```ruby
class OAuthRule
  def rule(rule, &side_effect)
    rule.previous_rule = self
    rule.side_effect = side_effect
    rule
  end

  def validate(request)
    if (error = check_previous(request)).nil?
      if (error = check(request))
        @side_effect&.call
      end
    end
    error
  end
end
```

### Accumulate errors, don't fail fast (when appropriate)
When multiple independent operations can fail, collect all errors instead of stopping at the first:

```ruby
result = AdtAccumulator
  .new(first_operation)
  .then_accumulate { |val| second_operation(val) }
  .then_accumulate { |val| third_operation(val) }
  .result { |errors| errors.reduce { |combined, e| combined.merge(e) } }
```

## Fallback Patterns

### GlobalDB with Vitess fallback
When reading from GlobalDB, always provide a Vitess fallback:

```ruby
#: -> (Permissible | Global::MetafieldDefinition)?
def load_definition_from_globaldb
  GlobalDbRetryHandler.with_rescue(fallback: ->(_e) { MetafieldDefinition.find_by(uuid: resource_uuid) }) do
    Global::MetafieldDefinition.readonly.find_by(uuid: resource_uuid)
  end
end
```

### Feature flag checks before new behavior
Gate new behavior behind flags with clean fallbacks:

```ruby
#: -> (CustomData::MetafieldDefinition | CustomData::Global::MetafieldDefinition)?
def resolved_definition
  return definition if GlobalDbRecord.disabled_for_pay_and_identity?

  GlobalDbRetryHandler.with_rescue(fallback: ->(_e) { definition }) do
    global_definition
  end
end
```

## Controller Style

### Compact action methods
Controllers should read like a narrative. Extract shared logic into concerns and private helpers:

```ruby
#: -> void
def fetch_customer_access_token
  return head(:not_found) unless (customer_id = request.session[:customer_identifier])

  customer = find_customer(customer_id)
  access_token = customer_access_token(customer)

  if access_token.present?
    payload = { message: "Access token exchange successful", access_token: access_token.access_token, access_token_expires_at: access_token.expires_at }
    report(event: "fetch_customer_access_token", payload:)
    render json: payload
  else
    report(event: "fetch_customer_access_token", success: false)
    render status: :unprocessable_entity, json: { message: "Access token exchange unsuccessful" }
  end
end
```

### Centralized reporting helpers
Wrap StatsD + Rails.event.notify in a single `report` method:

```ruby
#: (event: String, ?success: bool, ?payload: Hash, ?error_message: String?) -> void
def report(event:, success: true, payload: {}, error_message: nil)
  metric_name = "LoginWithShop.Storefront.LeadCapture.#{event}"
  StatsD.increment(metric_name, tags: { success: })
  Rails.event.notify(metric_name, message: success ? "Succeeded" : "Failed", **payload)
end
```

## Test Style

### Descriptive test names that state the behavior
```ruby
test "#fetch_customer_access_token returns not_found when no customer_identifier in session" do
test "#fetch_customer_access_token returns access token when customer exists and api permission is present" do
test ".merge_scopes combines two scope strings and deduplicates" do
test "#result returns error when initial result is an error" do
```

### Test structure: setup → act → assert
Keep tests focused. One behavior per test. Use fixtures and helpers, not complex mocking:

```ruby
test "#then_accumulate skips all steps when initial result is an error" do
  initial = Shopify::Adt::Result.error("fatal")
  step_called = false #: bool

  accumulator = AdtAccumulator.new(initial)
    .then_accumulate do |_value|
      step_called = true
      Shopify::Adt::Result.ok("updated")
    end

  refute(step_called)

  result = accumulator.result { |errors| errors.first }
  assert_predicate(result, :error?)
end
```

### Use `assert_predicate` for boolean checks
```ruby
assert_predicate(result, :ok?)
assert_predicate(result, :error?)
```

## Formatting

- **Trailing commas** on multi-line hashes and argument lists
- **Shorthand hash syntax** when key matches variable name: `{ customer:, shop_id: }` and in keyword args: `can_redirect:`
- **Parentheses on method calls** unless it's a DSL (validates, belongs_to, etc.)
- **No blank lines** between consecutive one-liner methods or guard clauses
- **One blank line** between logical sections within a method

---

## Critiques & Corrections (things to do BETTER when writing code together)

These are patterns observed in Chad's code that we should actively improve on. When writing new code, follow these corrections. When touching existing code with these issues, fix them opportunistically.

### 1. Typos in method names ship to production
`becomess_vitess_access_policy` — double "s" — exists in TWO files and is part of a public interface. Spell-check method names. When we write code together, **re-read every method name before committing.**

### 2. God methods with too many keyword arguments
`backfill_missing_info` takes 12 keyword arguments. This is a code smell — it's doing too many things and the call sites are unwieldy:

```ruby
# BAD — 12 kwargs, impossible to read at the call site
def backfill_missing_info(customer:, api_client:, ip:, user_agent:, referer:, first_name: nil, last_name: nil, avatar_url: nil, tags: nil, addresses: nil, default_address: nil, phone_number: nil, overwrite: false)
```

**Fix:** Extract a parameter object or split into focused methods. Group related params (request context is already extracted — do the same for personal info, contact info, etc.):

```ruby
# BETTER — compose from focused operations
PersonalInfo = Data.define(:first_name, :last_name, :avatar_url)
ContactInfo = Data.define(:phone_number, :addresses, :default_address)

def backfill(customer:, personal_info:, contact_info:, request_context:, overwrite: false)
```

### 3. Reaching deep into result objects repeatedly
`result.ok_value.encrypted_transport_token`, `result.ok_value.consented_scopes`, `result.ok_value.first_name`, etc. — the same `result.ok_value` is dereferenced 6+ times in a single method. This is fragile and noisy.

**Fix:** Destructure once at the top:

```ruby
# BAD
customer = find_customer(result.ok_value.email, result.ok_value.first_name, result.ok_value.last_name)
@redirect_uri = build_uri(result.ok_value.encrypted_transport_token, result.ok_value.consented_scopes)

# BETTER
value = result.ok_value
customer = find_customer(value.email, value.first_name, value.last_name)
@redirect_uri = build_uri(value.encrypted_transport_token, value.consented_scopes)
```

### 4. Ternary abuse for nil-checking
```ruby
phone: id_token.phone && id_token.phone_verified ? id_token.phone : nil
```
This is hard to read and the precedence is ambiguous without knowing Ruby's rules. Prefer a guard or `then`:

```ruby
# BETTER
phone: (id_token.phone if id_token.phone_verified)
```

### 5. Inconsistent error mapping patterns
`map_backfill_errors_to_shop_scope_errors` uses string interpolation to build a case key (`"#{k}:#{code}"`), then matches it. This is brittle — if the error structure changes, the string matching silently breaks. Also, `errors.to_set.join(" ")` on an array that may contain `nil` from the `next unless` is risky.

**Fix:** Use structured matching, compact nils:

```ruby
# BETTER
def map_backfill_errors_to_shop_scope_errors(backfill_errors)
  return unless backfill_errors

  backfill_errors.to_hash.filter_map { |field, violations|
    code = violations&.first&.dig(:code)&.serialize
    next unless code

    map_error_code(field, code)
  }.uniq.join(" ").presence
end

def map_error_code(field, code)
  case [field, code]
  in [:phone_number, "taken"] then "phone:taken"
  else "unknown_error"
  end
end
```

### 6. Tests that setup too much and assert too little
Some tests build elaborate fixtures, mock multiple collaborators, and then only assert one thing (or assert things that aren't related to what was set up). The phone verification test creates a full IdToken, mocks ExchangeCode and IdToken.decode, then only checks `assert_nil actual.phone` — and has a dangling unused `decrypted` variable.

**Fix:** If you only care about one field, minimize setup. Remove dead code from tests. Every line should serve the assertion:

```ruby
# BAD — unused variable, excessive setup
actual = @sut.perform(host:, client:, code:, state:).ok_value
decrypted = T.must(TransportToken.decrypt(actual.encrypted_transport_token))  # never used
assert_nil actual.phone

# BETTER — remove the dead line
result = @sut.perform(host:, client:, code:, state:)
assert_nil result.ok_value.phone
```

### 7. Mixed typing styles in the same file
Some files mix `sig { ... }` blocks with `#:` RBS comments. Pick one per file and stick with it. When writing NEW files, always use `#:`. When editing existing files, match the dominant style unless doing a deliberate migration.

### 8. `T.must` when `.not_nil!` is preferred
Per Shopify conventions, never use `T.must` — use `.not_nil!` instead. Some existing code still uses `T.must` (e.g., in `value_matches_definition_type`). In new code, always use `.not_nil!`.

### 9. Controller actions that do too much inline
The `shop_callback_controller#callback` method has a ~60 line action that creates customers, backfills info, stores mappings, builds redirect URIs, maps errors, and subscribes to email marketing — all inline. Even though individual pieces are extracted to helpers, the orchestration itself is hard to follow.

**Fix:** Extract the callback into a service object that returns a result, then the controller just renders based on the result:

```ruby
# BETTER — controller is just routing
def callback
  result = ShopCallbackService.new(shop:, request:, state:).perform
  result.ok? ? redirect_to(result.redirect_uri) : render_error(result.error)
end
```

### 10. Magic strings for error codes
`"phone:taken"`, `"unknown_error"` — these are stringly-typed. If the consumer on the other side checks for `"phone:taken"`, a typo is a silent bug.

**Fix:** Define constants or an enum:

```ruby
module ShopScopeErrors
  PHONE_TAKEN = "phone:taken"
  UNKNOWN = "unknown_error"
end
```

### 11. Commit message discipline
Commit messages like `"more stuff"`, `"wip"`, `"Fixes task and test"` provide zero context for future archaeology. Even for intermediate commits that get squashed, write messages that explain *why*. The PR merge commits are better — keep that quality for all commits.

### Summary: When we write code together, we will:
1. **Spell-check all names** before committing
2. **Cap keyword arguments at ~5** — extract objects beyond that
3. **Destructure results once** instead of repeated deep access
4. **Prefer `if`/`unless` modifiers** over ternaries for nil-checks
5. **Use structured matching** (arrays/pattern matching) over string interpolation for dispatch
6. **Remove dead code from tests** — every line serves an assertion
7. **One typing style per file** — `#:` for new files
8. **`.not_nil!`** never `T.must`
9. **Extract orchestration to service objects** when controller actions exceed ~20 lines
10. **Define constants for stringly-typed identifiers**
11. **Write meaningful commit messages** even for intermediate commits
