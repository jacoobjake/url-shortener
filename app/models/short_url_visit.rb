class ShortUrlVisit < ApplicationRecord
  belongs_to :short_url

  validates :country_code, length: { is: 2 }, allow_nil: true
  validates :region_code, length: { maximum: 10 }, allow_nil: true
  validates_length_of :country_name, :region_name, :city, maximum: 100, allow_nil: true
end
