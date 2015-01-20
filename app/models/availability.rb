class Availability < ActiveRecord::Base
  include LocaltimeAdjustment

  CITY_ROUTE_CONSTRAINT = lambda do |req|
    loc = Location.find_by_slug(req[:city])
    loc && loc.physical?
  end

  attr_accessor :duration

  belongs_to :mentor, :class_name => "User"
  has_many :appointment_requests

  belongs_to :appointment

  validates :start_time, :presence => true
  validates :city, inclusion: {in: Location::LOCATION_NAMES }

  before_save :adjust_for_timezone
  before_save :set_end_time

  scope :visible, Proc.new {
    includes(:mentor).
    where("users.activated" => true).
    where("start_time > ?", Time.now).
    where(appointment_id: nil)
  }

  scope :abandoned, -> {
    includes(:mentor).
    where("users.activated" => true).
    where("start_time < ?", Time.now).
    where(appointment_id: nil)
  }

  scope :starting_between, ->(start_time, end_time) {
    where(start_time: (start_time..end_time))
  }

  def self.today(tz)
    now = Time.now
    where('start_time between ? and ?',
      now.utc.to_s,
      utc_eod_for_tz(now,tz).to_s)
  end


  def self.in_city(city_name)
    where(city: city_name)
  end

  def self.without_appointment_requests
     joins('LEFT OUTER JOIN appointment_requests ON appointment_requests.availability_id = availabilities.id')
     .where('appointment_requests.availability_id IS NULL')
  end

  private

  def self.utc_eod_for_tz(t, tz)
    t.in_time_zone(tz).end_of_day.utc
  end

  def adjust_for_timezone
    self.start_time = ActiveSupport::TimeZone.find_tzinfo(timezone).local_to_utc(start_time)
  end

  def set_end_time
    self.end_time = self.start_time + self.duration.to_i*60
  end

end
