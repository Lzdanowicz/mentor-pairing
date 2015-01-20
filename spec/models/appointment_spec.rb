require 'spec_helper'

describe Appointment do
  it { should have_one(:mentor) }
  it { should belong_to(:mentee) }
  it { should have_many(:kudos) }

  describe "when first created" do
    before(:each) do
      @mentor = FactoryGirl.create(:mentor)
      @mentee = FactoryGirl.create(:mentee)
      @start_time = DateTime.new(2013, 1, 1)
      availability_attributes = FactoryGirl.attributes_for(:availability,
        start_time: @start_time,
        city: 'Chicago')
      @availability = @mentor.availabilities.create!(availability_attributes)
      @appointment = Appointment.create!(:mentor => @mentor, :mentee => @mentee, :availability => @availability)
    end

    context "with only a mentor" do
      it "should not be valid" do
        invalid_appointment = @mentor.mentoring_appointments.build
        expect(invalid_appointment.valid?).to eq(false)
      end
    end

    context "when created with a mentor and mentee" do
      context "passing in an availability object" do
        it "should have a start_time equal to that of the availability object passed to it" do
          expect(@appointment.start_time).to eq(@availability.start_time)
        end

        it "should have an end_time equal to that of the availability object passed to it" do
          expect(@appointment.end_time).to eq(@availability.end_time)
        end

        it "should create a kudo object" do
          expect(@appointment.mentor.received_kudos.count).to eq(1)
        end

        it "should have a city" do
          expect(@appointment.city).to eq(@availability.city)
        end

        it "should have a timezone" do
          expect(@appointment.timezone).to eq(@availability.timezone)
        end

        it "should have a location" do
          expect(@appointment.location).to eq(@availability.location)
        end
      end

    end

  end

  describe 'visibility' do
    it 'is visible when the appointment is entirely in the future' do
      availability = FactoryGirl.create(:availability, { :start_time => Time.now + 4.hours })
      appointment = FactoryGirl.create(:appointment, :availability => availability)
      Appointment.visible.should include(appointment)
    end

    it 'is visible when the appointment has begun, but not ended' do
      availability = FactoryGirl.create(:availability, {
        :start_time => Time.now - 30.minutes,
        :duration => 60
      })
      appointment = FactoryGirl.create(:appointment, :availability => availability)
      Appointment.visible.should include(appointment)
    end

    it 'is not visible when the appointment has ended' do
      availability = FactoryGirl.create(:availability, {
        :start_time => Time.now - 2.hours,
        :duration => 60
      })
      appointment = FactoryGirl.create(:appointment, :availability => availability)
      Appointment.visible.should_not include(appointment)
    end

  end

  context ".find_by_id_and_user" do
    it "returns an appointment when the ID matches and the user matches one of the users" do
      appointment = FactoryGirl.create(:appointment)

      expect(
        Appointment.find_by_id_and_user(appointment.id, appointment.mentor)
      ).to eq(appointment)
    end

    it "returns nil if the appointment does not match the provided user" do
      appointment = FactoryGirl.create(:appointment)
      some_other_user = FactoryGirl.create(:user)

      expect(
        Appointment.find_by_id_and_user(appointment.id, some_other_user)
      ).to eq(nil)
    end
  end

  context ".recently_ended" do
    it "finds appointments that should have ended in the last hour" do
      recently_ended_availability = FactoryGirl.create(:availability,
                                      :start_time => 90.minutes.ago,
                                      :duration => 60)
      recently_ended = FactoryGirl.create(:appointment, :availability => recently_ended_availability)
      in_the_future = FactoryGirl.create(:appointment)

      expect(Appointment.recently_ended).to include(recently_ended)
      expect(Appointment.recently_ended).to_not include(in_the_future)
    end
  end
end
