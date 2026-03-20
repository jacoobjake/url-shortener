# Short URL Path Strategy

## Algorithm

Short codes are generated using `SecureRandom.alphanumeric(8)`, producing an 8-character random string drawn from 62 alphanumeric characters (`a–z`, `A–Z`, `0–9`).

```
62^8 ≈ 218,340,105,584,896 unique combinations
```

This gives an astronomically large keyspace while keeping the URL short and human-readable. 8 characters was chosen to comfortably exceed any realistic usage scale while staying well within the 15-character maximum path requirement.

## Uniqueness Guarantee

Uniqueness is enforced at two layers:

1. **Application layer** — the generator pre-checks `ShortUrl.exists?(short_code: code)` before attempting to save, avoiding unnecessary round-trips in the common case.
2. **Database layer** — a `UNIQUE` index on `short_urls.short_code` acts as the authoritative constraint. If two concurrent requests race to claim the same code, only one will succeed; the other rescues `ActiveRecord::RecordNotUnique` and retries.

**Collision retry loop**: up to 5 attempts are made before raising. At current keyspace size (218 trillion), the probability of a single collision is negligible; the retry guard exists purely as a safety net.

## Trade-offs vs. Alternatives

| Approach                                      | Pro                                         | Con                                                       |
| --------------------------------------------- | ------------------------------------------- | --------------------------------------------------------- |
| **Random alphanumeric (chosen)**              | Simple, unguessable, no coordination needed | Tiny collision risk at extreme scale                      |
| Hash-based (MD5/SHA truncated)                | Deterministic for same input                | Same URL always maps to same code; partial collision risk |
| Auto-increment + base62                       | Zero collisions; sequential                 | Exposes total count; predictable enumeration              |
| Distributed counter (Twitter Snowflake-style) | Globally unique without DB round-trip       | Requires coordination service                             |
