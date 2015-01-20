class Appointment < ActiveRecord::Base
  include LocaltimeAdjustment

  has_one :availability
  has_one :mentor, through: :availability

  belongs_to :mentee, :class_name => "User"
  validates :mentee, :presence => true

  has_many :kudos

  scope :visible, -> {
    end_time_field = Availability.arel_table[:end_time]
    joins(:availability).where(end_time_field.gt(Time.now))
  }

  scope :past, -> {
    end_time_field = Availability.arel_table[:end_time]
    joins(:availability).where(end_time_field.lt(Time.now))
  }

  after_create :create_kudo

  scope :recently_ended, -> {
    end_time_field = Availability.arel_table[:end_time]
    joins(:availability).where(end_time_field.in(1.hour.ago..Time.now))
  }
  scope :feedback_not_sent, -> { where(:feedback_sent => false) }
  scope :ready_for_feedback, -> { recently_ended.feedback_not_sent }



  def start_time
    availability.start_time
  end

  def end_time
    availability.end_time
  end

  def city
    availability.city
  end

  def timezone
    availability.timezone
  end

  def location
    availability.location
  end

  def self.find_by_id_and_user(appointment_id, user)
    mentee_id_field = Appointment.arel_table[:mentee_id]
    mentor_id_field = Availability.arel_table[:mentor_id]
    self.joins(:availability)
        .where(mentor_id_field.eq(user.id).or(mentee_id_field.eq(user.id)))
        .find_by(id: appointment_id)

  end

  private

  def create_kudo
    self.kudos.create(mentor_id: self.mentor.id, mentee_id: self.mentee_id)
  end
end
