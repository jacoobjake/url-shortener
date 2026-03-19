require "test_helper"

class GeoliteService::GetIpGeolocationTest < ActiveSupport::TestCase
  MMDB_PATH = Rails.root.join("db/GeoLite2-City.mmdb")

  test "returns geo data for a known public IPv4 address" do
    skip "GeoLite2-City.mmdb not present" unless File.exist?(MMDB_PATH)

    result = GeoliteService::GetIpGeolocation.call("8.8.8.8")
    assert result.present?
    assert result.key?("country")
  end

  test "returns false when the mmdb file is missing" do
    # Temporarily rename the file if it exists, then restore after the test
    tmp_path = "#{MMDB_PATH}.bak"

    if File.exist?(MMDB_PATH)
      File.rename(MMDB_PATH, tmp_path)
      begin
        result = GeoliteService::GetIpGeolocation.call("8.8.8.8")
        assert_equal false, result
      ensure
        File.rename(tmp_path, MMDB_PATH)
      end
    else
      result = GeoliteService::GetIpGeolocation.call("8.8.8.8")
      assert_equal false, result
    end
  end

  test "returns nil for a private/localhost IP address" do
    skip "GeoLite2-City.mmdb not present" unless File.exist?(MMDB_PATH)

    result = GeoliteService::GetIpGeolocation.call("127.0.0.1")
    assert_nil result
  end
end
