module GeoliteService
  class GetIpGeolocation < ApplicationService
    def initialize(ip_address)
      @ip_address = ip_address
    end

    def call
      unless File.exist?(Rails.root.join("db/GeoLite2-City.mmdb"))
        Rails.logger.warn("GeoLite2-City.mmdb not found, geolocation data will not be available")
        return false
      end
      @georeader = MaxMind::DB.new(Rails.root.join("db/GeoLite2-City.mmdb"), mode: MaxMind::DB::MODE_MEMORY)
      @georeader.get(@ip_address)
    end
  end
end
