class RoverInstructions
  attr_reader :initial_position_data, :motion_instructions

  InitialPositionData = Struct.new(:x, :y, :direction)

  def initialize(instructions)
    raise initial_position_data_error if instructions[0].nil? 
    raise InvalidRoverMotionInstructionsError.new('') if instructions[1].nil? 
    @initial_position_data_raw = instructions[0].chomp.split
    @motion_instructions       = instructions[1].chomp.split('')

    validate_instructions

    @initial_position_data = InitialPositionData.new(@initial_position_data_raw[0].to_i, @initial_position_data_raw[1].to_i, @initial_position_data_raw[2])
  end

  def validate_instructions
    validate_initial_position_data
    validate_motion_data
  end

  def validate_motion_data
    raise InvalidRoverMotionInstructionsError.new(@motion_instructions) if !@motion_instructions.all? { |c| %W(L R M).include? c }
  end

  def validate_initial_position_data
    raise initial_position_data_error if @initial_position_data_raw.count != 3 
    raise initial_position_data_error if not_int? @initial_position_data_raw[0..1]
    raise initial_position_data_error if not_direction? @initial_position_data_raw[2]
  end

  def initial_position_data_error
    InvalidRoverInitialPositionDataError.new(@initial_position_data_raw)
  end

  # checks if any elements are not character integers
  def not_int?(array)
    !array.all? { |c| c =~ /\A\d+\z/ }
  end

  def not_direction?(character)
    !%w(N E S W).include? character
  end
end
