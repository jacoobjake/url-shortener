# Requirements

The following tools are required to run the application locally.

| Tool       | Version                     |
| ---------- | --------------------------- |
| Ruby       | 3.4.x (see `.ruby-version`) |
| PostgreSQL | 13+                         |
| Node.js    | 18+ (for asset builds)      |
| Bundler    | 2.x                         |

## GeoLite2 Database

A copy of `GeoLite2-City.mmdb` is included in this repository at `db/GeoLite2-City.mmdb` **for demo purposes only**.

This product includes GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com). The database is licensed under the [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/) and is subject to the [MaxMind End User License Agreement](https://www.maxmind.com/en/geolite2/eula).

For production use, obtain your own copy from [MaxMind](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data) (free account required) and replace `db/GeoLite2-City.mmdb`.

> Geolocation gracefully degrades to `null` if this file is missing.
