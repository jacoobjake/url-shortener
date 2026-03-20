# Strengths

## Async Visit Tracking

Redirects complete immediately; geolocation lookup and visit recording are handled in a background job (SolidQueue), so latency is not added to the user's redirect. SolidQueue runs on the primary PostgreSQL database — no external broker (Redis, etc.) is required.

## Cached Resolution

Short code lookups are memoized in SolidCache with a 12-hour TTL, reducing database load on popular links. SolidCache also runs on the primary PostgreSQL database, keeping the infrastructure footprint minimal.

## Single-Database Architecture

SolidQueue, SolidCache, and SolidCable all share the primary PostgreSQL database. This eliminates the need to provision or maintain separate databases or external services for background jobs, caching, and ActionCable, while still providing full production-grade functionality.

## Privacy-Respecting Analytics

IP addresses are anonymized before storage (IPv4 last octet zeroed; IPv6 last five groups zeroed), keeping analytics useful while reducing PII exposure.

## Bot-Aware Redirects

14 common crawler user-agents are detected and served an Open Graph-enriched preview page (`<meta http-equiv="refresh">` still redirects them), preventing bots from inflating visit counts.

## Metadata Scraping

Page title, meta description, OG title, and OG image are extracted at creation time via Nokogiri and stored. Errors (network timeouts, HTTP errors) are caught and the URL is still shortened with empty metadata.

## Rate Limiting

Rails 8 native rate limiting:

- 5 creates/minute per IP
- 100 redirects/minute per (short code + IP)
- 300 general requests/minute per IP

## Security Tooling

CI runs `brakeman` (static vulnerability analysis) and `bundler-audit` (known CVE checks) on every push.

## Service Object Architecture

Creation, resolution, visit capture, and geolocation are isolated services, making each independently testable and replaceable.
