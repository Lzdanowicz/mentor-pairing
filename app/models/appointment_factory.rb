class AppointmentFactory
  def self.create!(availability, mentee, mentor)

    # We grab these now, because the availability is destroyed when we create
    # the appointment.
    rejections = availability.appointment_requests.reject do |request|
      request.mentee_id == mentee.id
    end

    appointment = Appointment.create!(:mentee => mentee, :availability => availability)

    # Send all the emails
    mentee.send_appointment_confirmation(appointment)
    rejections.each do |rejection|
      rejection.mentee.send_appointment_rejection(availability)
    end
  end
end
