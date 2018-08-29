class MissionDataReader
  def self.read(io_type, io_object)
    mission_data = []

    self.io_class_type(io_type).open(io_object, 'r+') do |f|
      mission_data = f.readlines
    end

    [mission_data.shift, mission_data]
  end

  def self.io_class_type(io_type)
    return File if io_type == :file
    return StringIO if io_type == :string

    raise MissionDataReaderError 
  end
end
