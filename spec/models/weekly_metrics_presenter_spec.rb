require "spec_helper"

describe WeeklyMetricsPresenter do
  def appointment_for(start_time, duration = 60)
    availability = FactoryGirl.create(:availability,
                                      :start_time => start_time,
                                      :duration => duration)
    FactoryGirl.create(:appointment, :availability => availability)
  end

  context "#for_week_of" do
    it "is the current time if when not initialized with a value" do
      now = Time.now
      Time.stub(:now).and_return(now)

      wm_presenter = WeeklyMetricsPresenter.new
      expect(wm_presenter.for_week_of).to eq(now)
    end

    it "is the parsed time of the value presenter was initialized with" do
      wm_presenter = WeeklyMetricsPresenter.new("20130224")
      expect(wm_presenter.for_week_of).to eq(Time.parse("20130224"))
    end
  end

  context "#starting" do
    it "starts at the beginning of the week from the for week of value" do
      wm_presenter = WeeklyMetricsPresenter.new
      expect(wm_presenter.starting).to eq(Time.now.beginning_of_week(:sunday))
    end
  end

  context "#ending" do
    it "starts at the beginning of the week from the for week of value" do
      wm_presenter = WeeklyMetricsPresenter.new
      expect(wm_presenter.ending).to eq(Time.now.end_of_week(:sunday))
    end
  end

  context "#total_appointments" do
    it "returns the count of appointments from the database" do
      future_appointment = appointment_for(2.weeks.from_now)
      this_week = (Time.now.beginning_of_week(:sunday)...Time.now.end_of_week(:sunday))
      expected_count = rand(0..5)+1
      expected_count.times { appointment_for(rand(this_week)) }

      wm_presenter = WeeklyMetricsPresenter.new
      expect(wm_presenter.total_appointments).to eq(expected_count)
    end
  end

  context "#include_date" do
    it "returns true if the the date is greater than the start and less than the end" do
      wm_presenter = WeeklyMetricsPresenter.new
      this_week = (wm_presenter.starting..wm_presenter.ending)

      expect(wm_presenter).to have_included_date(rand(this_week))
    end
  end

  context "when calculating abandoned availabilities" do
    it "returns the count of abandoned availabilities from the db" do
      arbitrary_date = Time.new(2014, 3, 19)
      expected_count = rand(0..5)+1
      expected_count.times do
        FactoryGirl.create(:availability,
                           :start_time => 1.day.ago(arbitrary_date),
                           :duration => 60
        )
      end
    end
  end

  context "total abandoned availabilties" do
    let(:last_week) {
      (1.week.ago.beginning_of_week(:sunday)...1.week.ago.end_of_week(:sunday))
    }

    it "returns the toal amount of abandoned availabilities for a given period" do
      FactoryGirl.create(:availability, start_time: rand(last_week))
      wm_presenter = WeeklyMetricsPresenter.new(last_week.begin.strftime("%Y%m%d"))
      expect(wm_presenter.total_abandoned_availabilties).to eq(1)
    end
  end
end
