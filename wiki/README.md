# URL Shortener

A URL shortener microservice built with Ruby on Rails 8. Given a target URL, it generates a short code, scrapes the page title/metadata, tracks every visit with geolocation, and presents a per-link analytics view.

🔗 **Live demo:** [https://url-shortener-fqp5.onrender.com](https://url-shortener-fqp5.onrender.com) _(demo only — data may be reset at any time)_

## Overview

| Feature             | Details                                                                        |
| ------------------- | ------------------------------------------------------------------------------ |
| **Framework**       | Ruby on Rails 8                                                                |
| **Database**        | PostgreSQL (single database — primary DB hosts app data, cache, queue & cable) |
| **Background Jobs** | SolidQueue (runs on primary DB, no external broker required)                   |
| **Caching**         | SolidCache (runs on primary DB, 12-hour TTL on short code lookups)             |
| **Realtime**        | SolidCable (runs on primary DB)                                                |
| **Geolocation**     | MaxMind GeoLite2                                                               |
| **Asset Pipeline**  | Importmap + TailwindCSS                                                        |

## Quick Links

- [Requirements](getting-started/requirements.md)
- [Installation & Setup](getting-started/installation.md)
- [Running the Application](getting-started/running.md)
- [Short URL Path Strategy](architecture/short-url-strategy.md)
- [Strengths](strengths.md)
- [Limitations](limitations.md)
