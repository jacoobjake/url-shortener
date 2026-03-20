# Installation & Setup

## 1. Install Ruby Gems

```bash
bundle install
```

## 2. Configure Environment Variables

The app reads `DATABASE_HOST`, `DATABASE_USERNAME`, and `DATABASE_PASSWORD` from the environment. For local development, create a `.env` file or export them directly:

```bash
export DATABASE_HOST=localhost
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=
```

## 3. Set Up the Database

This command creates, migrates, and seeds all databases:

```bash
bin/rails db:prepare
```
