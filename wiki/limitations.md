# Limitations

## HTTPS-Only Target URLs

The validator rejects `http://`, `ftp://`, and bare domains. This prevents open-redirect abuse and passive eavesdropping, but means HTTP-only sites cannot be shortened.

## No Custom Short Codes

Short codes are always randomly generated. Users cannot request a memorable alias (e.g. `/my-promo`). This could be added by accepting an optional `alias` parameter at creation time, validating it against a reserved-words list, and storing it alongside the random code.

## No Link Expiry

Short URLs live forever. Adding an `expires_at` timestamp column would be straightforward; a scheduled job (e.g. a recurring SolidQueue task) could periodically purge or deactivate expired records, and the resolution service would treat an expired code as not found.

## No Access Control on Analytics

The visits page and JSON API are publicly accessible to anyone who knows the short code. A simple owner token (generated at creation and returned once) would gate access without requiring full authentication.

## GeoLite2 License for Production

The bundled `db/GeoLite2-City.mmdb` is included for demo purposes only. Any production deployment must comply with the [MaxMind EULA](https://www.maxmind.com/en/geolite2/eula) and should use a separately obtained copy. When the file is missing, all visits are stored without geolocation data.

## Private/LAN IPs Return No Geolocation

MaxMind does not resolve private address ranges (`192.168.x.x`, `10.x.x.x`, `::1`, etc.), so local development visits show no country/city.

## Metadata Scraping Adds Creation Latency

Scraping is performed synchronously on create. While SolidQueue is fully available (running on the primary database), scraping happens inline so the title and OG data are immediately available on the newly created short URL page. Moving scraping to a background job would return the short code faster but the page would initially show empty metadata until the job completes.

## Collision Retry Limit

The code retries up to 5 times on `RecordNotUnique`. At 218 trillion keyspace this is practically irrelevant, but at extreme saturation (billions of existing codes) this could raise an unhandled error. Switching to an auto-increment + base62 scheme or a distributed counter would eliminate collisions entirely at the cost of sequential/predictable codes. See [Short URL Path Strategy](architecture/short-url-strategy.md) for a full comparison.
