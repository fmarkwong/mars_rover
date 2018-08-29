class InvalidPlateauDataError < StandardError
  def initialize(data)
    super "Mission Aborted! Invalid Mission Data: Plateau data '#{data}' must be 2 integers."
  end
end

class MissionDataReaderError < StandardError
  def initialize
    super "Mission Aborted! Mission Data Reader Error: Wrong IO type.  Must be :file or :string"
  end
end

class InvalidRoverInitialPositionDataError < StandardError
  def initialize(initial_position_data_raw)
    super "Mission Aborted! Invalid Mission Data: Rover Initial Position Data #{initial_position_data_raw} must be 2 integers and a direction character."
  end
end

class InvalidRoverMotionInstructionsError < StandardError
  def initialize(motion_instructions)
    super "Mission Aborted! Invalid Mission Data: Rover Motion Instructions #{motion_instructions} must be string consisting of 'L', 'R', or 'M' characters."
  end
end

class InvalidDirectionError < StandardError
  def initialize(current_direction)
    super "Mission Aborted! Invalid Direction: '#{current_direction}' is an invalid direction"
  end
end

class PlateauLimitError < StandardError ; end
