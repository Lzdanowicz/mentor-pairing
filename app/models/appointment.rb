class Appointment < ActiveRecord::Base
  include LocaltimeAdjustment

  has_one :availability
  has_one :mentor, through: :availability

  belongs_to :mentee, :class_name => "User"
  validates :mentee, :presence => true

  has_many :kudos

  scope :visible, Proc.new {
    where("end_time > ?", Time.now)
  }

  scope :past, Proc.new {
    where("end_time < ?", Time.now)
  }

  scope :recently_ended, -> { where(:end_time => (1.hour.ago..Time.now)) }
  after_create :create_kudo
  scope :feedback_not_sent, -> { where(:feedback_sent => false) }
  scope :ready_for_feedback, -> { recently_ended.feedback_not_sent }

  def self.find_by_id_and_user(appointment_id, user)
    appointment_arel = Appointment.arel_table
    Appointment.where(:id => appointment_id).
                where(
                  appointment_arel[:mentor_id].eq(user.id).
                  or(appointment_arel[:mentee_id].eq(user.id))
                ).first


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
