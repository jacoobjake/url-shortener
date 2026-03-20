# URL Shortener

A URL shortener microservice built with Ruby on Rails 8. Given a target URL, it generates a short code, scrapes the page title/metadata, tracks every visit with geolocation, and presents a per-link analytics view.

🔗 **Live demo:** [https://url-shortener-fqp5.onrender.com](https://url-shortener-fqp5.onrender.com) _(demo only — data may be reset at any time)_

📖 **Documentation:** [https://jake-yin.gitbook.io/simple-url-shortener](https://jake-yin.gitbook.io/simple-url-shortener)

For full local documentation, see the [wiki](wiki/README.md).

---

## Requirements

| Tool       | Version                     |
| ---------- | --------------------------- |
| Ruby       | 3.4.x (see `.ruby-version`) |
| PostgreSQL | 13+                         |
| Node.js    | 18+ (for asset builds)      |
| Bundler    | 2.x                         |

> **GeoLite2 database** — a copy of `GeoLite2-City.mmdb` is included at `db/GeoLite2-City.mmdb` **for demo purposes only**. See the [requirements page](wiki/getting-started/requirements.md) for details.

---

## Installation & Setup

```bash
# 1. Install Ruby gems
bundle install

# 2. Configure environment variables
export DATABASE_HOST=localhost
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=

# 3. Set up the database
bin/rails db:prepare
```

Then start the app:

```bash
bin/dev
```

This starts `bin/rails server` on <http://localhost:3000> and the TailwindCSS watcher.
