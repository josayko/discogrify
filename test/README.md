# Testing Documentation

This document describes the comprehensive testing strategy and organization for the Discogrify application, covering both data models and API endpoints.

## Documentation Structure

- **README.md** (this file): Complete testing overview covering data models, contexts, and test organization
- **[API_TESTING.md](API_TESTING.md)**: Detailed documentation for API controller testing with coverage results

## Test Structure

### Test Files Organization

```
test/
├── discogrify/
│   ├── schemas/
│   │   ├── artist_test.exs          # Artist schema tests
│   │   └── album_test.exs           # Album schema tests
│   └── music_test.exs               # Music context tests
├── discogrify_web/
│   └── controllers/
│       ├── auth_controller_test.exs # Authentication API tests
│       └── album_controller_test.exs # Album search API tests
├── support/
│   ├── data_case.ex                 # Test case for database tests
│   ├── conn_case.ex                 # Test case for controller tests
│   ├── factory.ex                   # Test data factory
│   └── factory_test.exs             # Factory tests
├── README.md                        # Data model testing documentation
└── API_TESTING.md                   # API controller testing documentation
```

## Test Categories

### 1. Schema Tests (`test/discogrify/schemas/`)

These tests focus on testing the Ecto schemas and their changesets:

- **Changeset validation**: Testing required fields, field types, and validation rules
- **Database constraints**: Testing unique constraints, foreign key constraints
- **Associations**: Testing that relationships between models work correctly
- **Field types**: Ensuring correct data types and primary key configuration

#### Artist Schema Tests
- Tests `spotify_id` and `name` validation
- Tests unique constraint on `spotify_id`
- Tests association with albums

#### Album Schema Tests
- Tests all required fields (`spotify_id`, `name`, `release_date`, `artist_id`)
- Tests foreign key constraint with artist
- Tests unique constraint on `spotify_id`
- Tests belongs_to association with artist

### 2. Context Tests (`test/discogrify/music_test.exs`)

These tests focus on the business logic in the Music context:

- **Query functions**: Testing database queries and their results
- **Creation functions**: Testing data creation with proper validation
- **Integration scenarios**: Testing complete workflows
- **Edge cases**: Testing error conditions and boundary cases

#### Key Functions Tested
- `get_artist_by_spotify_id_with_albums/1`
- `get_artist_by_name_with_albums/1`
- `create_artist_changeset/1`
- `create_album/1`

### 3. API Controller Tests (`test/discogrify_web/controllers/`)

These tests focus on HTTP endpoints, authentication, and API functionality:

- **Authentication endpoints**: Login validation, token generation, error handling
- **Album search endpoints**: Database queries, Spotify API integration, response formatting
- **OpenAPI compliance**: Request/response schema validation
- **Error handling**: Authentication failures, API errors, validation errors
- **Edge cases**: Malformed requests, network failures, performance scenarios

For detailed API testing documentation, see **[API_TESTING.md](API_TESTING.md)**.

#### Coverage Results
- **AuthController**: 92.86% coverage (14 tests)
- **AlbumController**: 92.86% coverage (22 tests)
- **Total API Tests**: 36 comprehensive tests

## Test Data Factory

The `Discogrify.Factory` module provides helper functions to create test data easily and consistently.

### Usage Examples

```elixir
# Create a single artist
artist = Factory.insert_artist()

# Create an artist with custom attributes
artist = Factory.insert_artist(%{name: "Daft Punk", spotify_id: "daft_punk_id"})

# Create an album for an artist
album = Factory.insert_album(artist.id)

# Create an artist with albums
{artist, albums} = Factory.insert_artist_with_albums()

# Create an artist with specific number of albums
{artist, albums} = Factory.insert_artist_with_albums(%{name: "Artist"}, 3)

# Create multiple artists with albums
artists_data = Factory.insert_multiple_artists_with_albums(5)
```

### Factory Benefits

1. **Consistency**: All test data follows the same patterns
2. **Uniqueness**: Automatically generates unique IDs to avoid conflicts
3. **Flexibility**: Allows custom attributes while providing sensible defaults
4. **Maintainability**: Centralized test data creation logic

## Running Tests

### Run All Tests
```bash
# Run all tests (data models + API controllers)
mix test

# Run with coverage
mix test --cover
```

### Run Test Categories

#### Data Model Tests
```bash
# All data model tests
mix test test/discogrify/

# Schema tests only
mix test test/discogrify/schemas/

# Context tests only
mix test test/discogrify/music_test.exs
```

#### API Controller Tests
```bash
# All controller tests
mix test test/discogrify_web/controllers/

# Authentication controller tests
mix test test/discogrify_web/controllers/auth_controller_test.exs

# Album controller tests
mix test test/discogrify_web/controllers/album_controller_test.exs
```

### Run Specific Test Files
```bash
# Artist schema tests
mix test test/discogrify/schemas/artist_test.exs

# Album schema tests
mix test test/discogrify/schemas/album_test.exs

# Music context tests
mix test test/discogrify/music_test.exs

# Factory tests
mix test test/support/factory_test.exs
```

### Run Tests with Coverage
```bash
# All tests with coverage
mix test --cover

# Specific tests with coverage
mix test --cover test/discogrify_web/controllers/
```

## Test Environment Setup

### Database Configuration

The test environment uses a separate PostgreSQL database (`discogrify_test`) with:
- SQL Sandbox for test isolation
- Parallel test execution support
- Automatic database cleanup between tests

### Environment Variables

Test-specific configuration is handled automatically:
- Spotify API credentials use dummy values for testing
- Database connection uses test-specific settings
- No external API calls are made during tests
- Authentication tokens use test-specific signing

### HTTP Testing Setup

The test environment includes:
- ConnCase for controller testing
- Authentication helpers for protected endpoints
- OpenAPI schema validation
- Error response testing utilities

## Coverage Summary

### Current Test Coverage
- **Data Models**: 100% coverage (54 tests)
  - Artist Schema: 16 tests
  - Album Schema: 18 tests
  - Music Context: 20 tests
- **API Controllers**: 92.86% coverage (36 tests)
  - AuthController: 14 tests
  - AlbumController: 22 tests
- **Supporting Modules**: 100% coverage
  - Factory: Comprehensive test data generation
  - AuthPlug: Authentication middleware

### Total: **90 tests** with excellent coverage across all critical components

## Best Practices

### 1. Test Isolation
Each test runs in a separate database transaction that's rolled back after completion, ensuring tests don't interfere with each other.

### 2. Descriptive Test Names
Test names clearly describe what they're testing:
```elixir
test "validates required fields"
test "enforces unique spotify_id constraint"
test "returns artist with albums when found"
```

### 3. Setup and Fixtures
Use `setup` blocks to prepare test data that's shared across multiple tests in the same describe block.

### 4. Comprehensive Coverage
Tests cover:
- Happy paths (valid data, successful operations)
- Error conditions (invalid data, constraint violations)
- Edge cases (empty results, boundary values)
- Integration scenarios (complete workflows)
- Authentication and authorization
- API contract compliance (OpenAPI)

### 5. Using Factories
Prefer using the Factory module for creating test data to ensure consistency and reduce test setup complexity.

### 6. API Testing Best Practices
- Use authentication helpers for protected endpoints
- Validate OpenAPI schema compliance
- Test both success and error responses
- Include edge cases and malformed requests
- Test authentication middleware separately

## Adding New Tests

When adding new schemas, contexts, or controllers:

1. **Create schema tests** in `test/discogrify/schemas/`
2. **Create context tests** in `test/discogrify/`
3. **Create controller tests** in `test/discogrify_web/controllers/`
4. **Update Factory** if new test data patterns are needed
5. **Follow existing patterns** for test organization and naming
6. **Add API documentation** to API_TESTING.md if adding controllers

## Common Patterns

### Testing Changesets
```elixir
test "changeset with valid attributes" do
  changeset = Schema.changeset(%Schema{}, valid_attrs)
  assert changeset.valid?
end

test "changeset with invalid attributes" do
  changeset = Schema.changeset(%Schema{}, invalid_attrs)
  refute changeset.valid?
  assert %{field: ["can't be blank"]} = errors_on(changeset)
end
```

### Testing Database Operations
```elixir
test "creates record with valid data" do
  assert {:ok, record} = Context.create_function(valid_attrs)
  assert record.field == expected_value
end

test "returns error with invalid data" do
  assert {:error, changeset} = Context.create_function(invalid_attrs)
  assert %{field: ["error message"]} = errors_on(changeset)
end
```

### Testing Queries
```elixir
test "returns record when found" do
  existing_record = Factory.insert_record()
  result = Context.get_function(existing_record.id)
  assert result.id == existing_record.id
end

test "returns nil when not found" do
  result = Context.get_function("non_existent_id")
  assert is_nil(result)
end
```

### Testing API Controllers
```elixir
test "returns success with valid authentication" do
  conn = build_conn()
    |> authenticate_conn()
    |> post("/api/endpoint", valid_params)
  
  assert %{"data" => data} = json_response(conn, 200)
  assert data["field"] == expected_value
end

test "returns unauthorized without authentication" do
  conn = build_conn()
    |> post("/api/endpoint", valid_params)
  
  assert json_response(conn, 401)
end

test "validates OpenAPI schema compliance" do
  conn = build_conn()
    |> authenticate_conn()
    |> post("/api/endpoint", valid_params)
  
  assert_schema(json_response(conn, 200), "ResponseSchema", DiscogrifyWeb.ApiSpec.spec())
end
```

For comprehensive API testing examples and patterns, see **[API_TESTING.md](API_TESTING.md)**.
```
