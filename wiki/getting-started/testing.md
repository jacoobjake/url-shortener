# Running the Test Suite

```bash
# Unit, service, controller, and integration tests
bin/rails test

# System tests (browser-driven via Capybara)
bin/rails test:system

# All tests
bin/rails test:all
```

The test suite covers:

- Model validations
- Service logic (creation, resolution, visit capture)
- Geolocation
- Job enqueueing
- Controller happy paths and error paths
- System tests — full browser flows including the home page form, creating a short URL, validation errors, and the show/analytics pages
