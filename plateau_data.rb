class PlateauData
  attr_reader :min_x, :min_y, :max_x, :max_y

  def initialize(data_string)
    @data = data_string.chomp.split
    validate_data

    @min_x, @min_y = 0, 0
    @max_x, @max_y = @data.map(&:to_i)
  end

  def validate_data
    @data.each do |c|
      raise InvalidPlateauDataError.new(@data) if c !~ /\A\d+\z/ #if non-numeral data
    end

    raise InvalidPlateauDataError.new(@data) if @data.count != 2
  end
end
