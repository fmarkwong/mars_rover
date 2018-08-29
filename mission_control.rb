require_relative 'mission_data_reader'
require_relative 'plateau_data'
require_relative 'rover_instructions'
require_relative 'rover'

class MissionControl
  attr_reader :mission_log

  def initialize
    @rovers = []
    @mission_log = ''
  end

  # if reading from file, io_type is :file and io_object is the file name.
  # if reading from string, io_type is :string and io_object is the string.
  def read_mission_data(io_type, io_object)
    @plateau_data_string, @rover_instructions_array = MissionDataReader.read(io_type, io_object)
  end

  def initialize_plateau_data
    @plateau_data = PlateauData.new(@plateau_data_string)
  end

  def initialize_rovers
    @rover_instructions_array.each_slice(2).with_index do |rover_instructions, index|
      @rovers[index] = Rover.new(RoverInstructions.new(rover_instructions), @plateau_data)
    end
  end

  def execute_rover_missions
    @rovers.each do |rover|
      rover.land
      rover.execute_motions
      @mission_log += rover.current_position_direction + $/
    end
  end

  def display_mission_log
    puts @mission_log
  end
end
