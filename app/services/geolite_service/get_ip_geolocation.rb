module GeoliteService
  class GetIpGeolocation < ApplicationService
    def initialize(ip_address)
      @ip_address = ip_address
      @georeader = MaxMind::DB.new(Rails.root.join("db/GeoLite2-City.mmdb"), mode: MaxMind::DB::MODE_MEMORY)
    end

    def call
      @georeader.get(@ip_address)
    end
  end
end
