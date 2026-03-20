# Running the Application

## Live Demo

A hosted demo is available at [https://url-shortener-fqp5.onrender.com](https://url-shortener-fqp5.onrender.com) — no setup required. _(Demo only — data may be reset at any time.)_

## Development

The app uses Puma (web server) and the TailwindCSS watcher. Run both with:

```bash
bin/dev
```

This starts:

- `bin/rails server` on [http://localhost:3000](http://localhost:3000)
- `bin/rails tailwindcss:watch` for CSS compilation
