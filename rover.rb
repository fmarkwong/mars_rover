require_relative 'direction'

class Rover
  def initialize(rover_instructions, plateau_data)
    @rover_instructions = rover_instructions
    @plateau_data = plateau_data
  end

  def land
    @current_position_x = @rover_instructions.initial_position_data.x 
    @current_position_y = @rover_instructions.initial_position_data.y 
    @direction = Direction.new(@rover_instructions.initial_position_data.direction)
  end

  def execute_motions
    @rover_instructions.motion_instructions.each do |instruction|
      @direction.rotate_left if instruction == 'L'
      @direction.rotate_right if instruction == 'R'
      move_forward if instruction == 'M'
    end
  end

  def move_forward
    case @direction.current
    when 'N'
      raise PlateauLimitError if @current_position_y == @plateau_data.max_y 
      @current_position_y += 1
    when 'E'
      raise PlateauLimitError if @current_position_x == @plateau_data.max_x 
      @current_position_x += 1
    when 'S'
      raise PlateauLimitError if @current_position_y == @plateau_data.min_y 
      @current_position_y -= 1
    when 'W'
      raise PlateauLimitError if @current_position_x == @plateau_data.min_x 
      @current_position_x -= 1
    else
      warn "'#{@direction.current}' is not a valid direction.  Movement skipped." 
    end
     
  rescue PlateauLimitError 
    warn "Movement Skipped! PlateauLimitError: Currently at position #{@current_position_x}, #{@current_position_y}. Further moving #{@direction.current_long_name} will cause rover to fall off plateau."
  end

  def current_position_direction
    "#{@current_position_x} #{@current_position_y} #{@direction.current}"
  end
end

