class WeeklyMetricsPresenter
  attr_reader :for_week_of

  def initialize(for_week_of = nil)
    @for_week_of = for_week_of ? Time.parse(for_week_of) : Time.now
  end

  def starting
    for_week_of.beginning_of_week(:sunday)
  end

  def ending
    for_week_of.end_of_week(:sunday)
  end

  def total_appointments
    Availability.starting_between(starting, ending).count
    # Appointment.where(:start_time => (starting..ending)).count
  end

  def has_included_date?(date)
    (starting..ending).cover?(date)
  end

  def total_abandoned_availabilties
    Availability.starting_between(starting, ending).abandoned.count
  end
end
