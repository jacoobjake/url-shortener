require "test_helper"

class ShortUrlService::CaptureVisitTest < ActiveSupport::TestCase
  setup do
    @short_url = short_urls(:github)
  end

  # Replace the class-level .call for the duration of the block, then restore
  def with_geo(response)
    GeoliteService::GetIpGeolocation.define_singleton_method(:call) { |*| response }
    yield
  ensure
    GeoliteService::GetIpGeolocation.singleton_class.remove_method(:call)
  end

  test "creates a visit record with full geo data" do
    geo = {
      "country"      => { "iso_code" => "US", "names" => { "en" => "United States" } },
      "subdivisions" => [ { "iso_code" => "CA", "names" => { "en" => "California" } } ],
      "city"         => { "names" => { "en" => "San Francisco" } }
    }

    with_geo(geo) do
      assert_difference "ShortUrlVisit.count", 1 do
        ShortUrlService::CaptureVisit.call(@short_url.id, "1.2.3.4", "Mozilla/5.0", "https://ref.example.com")
      end
    end

    visit = ShortUrlVisit.last
    assert_equal "US",            visit.country_code
    assert_equal "United States", visit.country_name
    assert_equal "CA",            visit.region_code
    assert_equal "California",    visit.region_name
    assert_equal "San Francisco", visit.city
  end

  test "anonymizes IPv4 address by zeroing the last octet" do
    with_geo({}) do
      ShortUrlService::CaptureVisit.call(@short_url.id, "192.168.1.99", nil, nil)
    end
    assert_equal "192.168.1.0", ShortUrlVisit.last.ip_address.to_s
  end

  test "stores user_agent and referrer on the visit" do
    with_geo({}) do
      ShortUrlService::CaptureVisit.call(@short_url.id, "1.2.3.4", "TestAgent/1.0", "https://ref.example.com")
    end
    visit = ShortUrlVisit.last
    assert_equal "TestAgent/1.0",           visit.user_agent
    assert_equal "https://ref.example.com", visit.referrer
  end

  test "creates a visit with no geo data when geolocation returns nil" do
    with_geo(nil) do
      assert_difference "ShortUrlVisit.count", 1 do
        ShortUrlService::CaptureVisit.call(@short_url.id, "1.2.3.4", "curl/7.68.0", nil)
      end
    end
    visit = ShortUrlVisit.last
    assert_nil visit.country_code
    assert_nil visit.city
  end

  test "handles missing subdivision gracefully" do
    geo = {
      "country"      => { "iso_code" => "DE", "names" => { "en" => "Germany" } },
      "subdivisions" => [],
      "city"         => { "names" => { "en" => "Berlin" } }
    }
    with_geo(geo) do
      assert_difference "ShortUrlVisit.count", 1 do
        ShortUrlService::CaptureVisit.call(@short_url.id, "1.2.3.4", nil, nil)
      end
    end
    visit = ShortUrlVisit.last
    assert_equal "DE", visit.country_code
    assert_nil visit.region_code
  end

  test "stores nil ip_address when remote_ip is nil" do
    with_geo({}) do
      ShortUrlService::CaptureVisit.call(@short_url.id, nil, "Mozilla/5.0", nil)
    end
    assert_nil ShortUrlVisit.last.ip_address
  end
end
