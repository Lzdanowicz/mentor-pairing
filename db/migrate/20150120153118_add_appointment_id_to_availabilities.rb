class AddAppointmentIdToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :appointment_id, :integer
    add_index :availabilities, :appointment_id
  end
end
