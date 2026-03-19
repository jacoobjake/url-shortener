require "test_helper"

class CaptureVisitJobTest < ActiveJob::TestCase
  setup do
    @short_url = short_urls(:github)
  end

  test "enqueues on the default queue" do
    assert_enqueued_with(job: CaptureVisitJob, queue: "default") do
      CaptureVisitJob.perform_later(@short_url.id, "1.2.3.4", "Mozilla/5.0", nil)
    end
  end

  test "creates a ShortUrlVisit record when performed" do
    # Patch the geo lookup so the job completes without reading the mmdb or
    # making network calls. Use define_singleton_method so it only affects
    # this test's execution context.
    GeoliteService::GetIpGeolocation.define_singleton_method(:call) { |*| nil }

    assert_difference "ShortUrlVisit.count", 1 do
      perform_enqueued_jobs do
        CaptureVisitJob.perform_later(@short_url.id, "1.2.3.4", "Mozilla/5.0", nil)
      end
    end
  ensure
    GeoliteService::GetIpGeolocation.singleton_class.remove_method(:call)
  end

  test "stores the correct short_url_id on the created visit" do
    GeoliteService::GetIpGeolocation.define_singleton_method(:call) { |*| nil }

    perform_enqueued_jobs do
      CaptureVisitJob.perform_later(@short_url.id, "10.0.0.1", "TestAgent", "https://ref.com")
    end

    visit = ShortUrlVisit.last
    assert_equal @short_url.id, visit.short_url_id
    assert_equal "TestAgent",       visit.user_agent
    assert_equal "https://ref.com", visit.referrer
  ensure
    GeoliteService::GetIpGeolocation.singleton_class.remove_method(:call)
  end
end
