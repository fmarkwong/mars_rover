class Direction
  DIRECTIONS = %w(N E S W)
  DIRECTIONS_LONG_NAME = {'N'=>'North', 'E'=>'East', 'S'=>'South', 'W'=>'West' }

  DIRECTIONS_LENGTH = DIRECTIONS.length

  def initialize(current_direction)
    @current_index = DIRECTIONS.index(current_direction)
    raise InvalidDirectionError.new(current_direction) if @current_index.nil?
  end

  def rotate_left
    @current_index = (@current_index -= 1) % DIRECTIONS_LENGTH
  end

  def rotate_right
    @current_index = (@current_index += 1) % DIRECTIONS_LENGTH
  end

  def current
    DIRECTIONS[@current_index]
  end

  def current_long_name
    DIRECTIONS_LONG_NAME[current]
  end
end

