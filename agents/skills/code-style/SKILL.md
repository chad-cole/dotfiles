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

## Improvements (things to be mindful of when writing code together)

Don't sweat the small stuff — these are structural patterns to watch for, not a nitpick checklist. Follow Chad's style first, then apply these when they meaningfully improve the code.

### 1. Methods with too many keyword arguments
`backfill_missing_info` takes 12 keyword arguments. When a method accumulates that many params, it's usually doing too many things. Group related params into value objects:

```ruby
# When kwargs exceed ~5, consider extracting
PersonalInfo = Data.define(:first_name, :last_name, :avatar_url)
ContactInfo = Data.define(:phone_number, :addresses, :default_address)

def backfill(customer:, personal_info:, contact_info:, request_context:, overwrite: false)
```

### 2. Destructure result objects once
When accessing `result.ok_value.thing` more than 2-3 times, assign it once:

```ruby
# Instead of result.ok_value.x, result.ok_value.y, result.ok_value.z...
value = result.ok_value
customer = find_customer(value.email, value.first_name, value.last_name)
@redirect_uri = build_uri(value.encrypted_transport_token, value.consented_scopes)
```

### 3. Extract large controller orchestration to service objects
When a controller action exceeds ~20 lines of orchestration (creating objects, calling services, mapping errors, building responses), pull it into a service:

```ruby
def callback
  result = ShopCallbackService.new(shop:, request:, state:).perform
  result.ok? ? redirect_to(result.redirect_uri) : render_error(result.error)
end
```

### 4. Commit messages
Intermediate commits that get squashed are fine as shorthand, but standalone commits should explain *why*, not just *what*. When we write commits together, they will always be descriptive.

### Summary: When we write code together, we will:
1. **Keep keyword argument lists manageable** — extract value objects when they grow
2. **Destructure results once** instead of repeated deep access
3. **Extract orchestration to service objects** when controller actions get long
4. **Write meaningful commit messages**
5. **`.not_nil!`** never `T.must`
6. **`#:` RBS comments** for new files, match existing style when editing
