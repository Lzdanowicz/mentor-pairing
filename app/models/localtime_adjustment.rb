module LocaltimeAdjustment
  def local_start_time
    localtime(:start_time)
  end

  def local_end_time
    localtime(:end_time)
  end

  def localtime(attribute)
    self.public_send(attribute).in_time_zone(self.timezone)
  end
end
