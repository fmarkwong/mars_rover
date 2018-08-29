require 'rspec'
require_relative '../mission_control'
require_relative '../mission_data_reader'
require_relative '../plateau_data'
require_relative '../errors'

describe MissionDataReader do
  describe '#read' do
    let(:io_object) { "5 5\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM" }

    subject { MissionDataReader.read(io_type, io_object) }
    
    context 'valid io_type and io_object' do
      let(:io_type) { :string }

      it 'should return an array of correct initial position and motion instruction data' do
        expect(subject).to eq(["5 5\n", ["1 2 N\n", "LMLMLMLMM\n", "3 3 E\n", "MMRMMRMRRM"]])
      end
    end

    context 'invalid io_type' do
      let(:io_type) { :blah }

      it 'should raise MissionDataReaderError' do
        expect { subject }.to raise_error(MissionDataReaderError)
      end
    end
  end
end

describe PlateauData do
  describe '#new' do
    
    subject { PlateauData.new(data_string) }

    context 'valid plateau data' do
      let(:data_string) { "5 5\n"}

      it 'should take one parameter and return a correct PlateauData object without errors' do
        expect(subject).to be_an_instance_of PlateauData
        expect(subject.max_x).to eq(5)
        expect(subject.max_y).to eq(5)
        expect { subject }.to_not raise_error
      end
    end

    context 'invalid plateau data' do
      [
        { :context => 'invalid plateau data: 1 integer',               :data_string => "5\n" },
        { :context => 'invalid plateau data: 1 integer 1 non numeral', :data_string => "g 5\n" },
        { :context => 'invalid plateau data: 3 integers',              :data_string => "5 3 4\n"},
      ].each do |v|
        context "#{v[:context]}" do
          let(:data_string) { v[:data_string] }

          it 'should raise InvalidPlateauDataError' do
            expect { subject }.to raise_error(InvalidPlateauDataError)
          end
        end
      end
    end
  end
end

describe RoverInstructions do
  describe '#new' do
    let(:initial_position_data) { "1 2 E\n" }
    let(:motion_instructions) { "LMLMLMLMM\n" }
    
    subject { RoverInstructions.new([initial_position_data, motion_instructions]) }

    context 'with valid instructions' do
      it 'should take one parameter and return a RoverInstructions object without errors' do
        expect(subject).to be_an_instance_of RoverInstructions
        expect { subject }.to_not raise_error
      end
    end

    context 'invalid initial position data' do
      [
        { context: 'nil',                                initial_position_data: nil },
        { context: 'alphabetic, integer and direction',  initial_position_data: "A 2 E\n" },
        { context: '1 integer and direction',            initial_position_data: "2 E\n" },
        { context: '2 integers and non-direction',       initial_position_data: "1 2 T\n" },
        { context: '2 integers and lowercase direction', initial_position_data: "1 2 e\n" },
        { context: 'invalid motion instructions',        initial_position_data: "LMLMzLMLMM\n" },
      ].each do |v|
        context "#{v[:context]}" do
          let(:initial_position_data) { v[:initial_position_data] }

          it 'should raise InvalidRoverInitialPositionDataError' do
            expect { subject }.to raise_error(InvalidRoverInitialPositionDataError)
          end
        end
      end
    end

    context 'invalid motion instructions' do
      [
        { context: 'invalid motion instruction character', motion_instructions: "LMLMzLMLMM\n" },
        { context: 'nil',                                  motion_instructions: nil },
        { context: 'space',                                motion_instructions: "LMLMLM LMM\n"},
      ].each do |v|
        context "#{v[:context]}" do
          let(:motion_instructions) { v[:motion_instructions] }

          it 'should raise InvalidRoverMotionInstructionsError' do
            expect { subject }.to raise_error(InvalidRoverMotionInstructionsError)
          end
        end
      end
    end
  end
end

def test_rotate(direction, current_expected_array)
  describe "#rotate_#{direction}" do
    subject { Direction.new(current_direction) }

    before(:each) do
      subject.send("rotate_#{direction}".to_sym)
    end

    current_expected_array.each do |v|
      context "current direction: #{v[:current]}" do
        let(:current_direction) { v[:current] }

        it "should face #{v[:expected]}" do
          expect(subject.current).to eq(v[:expected])
        end
      end
    end
  end
end

describe Direction do
  describe '#new' do
    it 'should take one parameter and return a Direction object' do
      expect(Direction.new('N')).to be_an_instance_of Direction
    end

    context 'Invalid direction input' do
      it 'shoud raise an InvalidDirectionError' do
        expect { Direction.new('Z') }.to raise_error(InvalidDirectionError)
      end
    end
  end
  rotate_left_array = [
    { current: 'N', expected: 'W'},
    { current: 'E', expected: 'N'},
    { current: 'S', expected: 'E'},
    { current: 'W', expected: 'S'},
  ]
  test_rotate('left', rotate_left_array)

  rotate_right_array = [
    { current: 'N', expected: 'E'},
    { current: 'E', expected: 'S'},
    { current: 'S', expected: 'W'},
    { current: 'W', expected: 'N'},
  ]
  test_rotate('right', rotate_right_array)
end

describe Rover do
  let(:initial_position_data) { "1 2 N\n" }
  let(:motion_instructions) { "LMLMLMLMM\n" }
  let(:rover_instructions) { RoverInstructions.new([initial_position_data, motion_instructions]) }
  let(:data_string) { "5 5\n"}
  let(:plateau_data) { PlateauData.new(data_string) }

  subject { Rover.new(rover_instructions, plateau_data) }

  describe '#new' do
    it 'should take two parameters and return Rover object' do
      expect(subject).to be_an_instance_of Rover
    end
  end

  describe '#land' do
    it 'should land at the correction coordinates and point in the right direction' do
      subject.land

      expect(subject.current_position_direction).to eq('1 2 N')
    end
  end

  describe '#execute_motions' do
    context 'valid movement instructions' do
      it 'should end up in the correct position' do
        subject.land
        subject.execute_motions

        expect(subject.current_position_direction).to eq('1 3 N')
      end
    end

    context 'movement instructions to try it make rover fall off plateau' do
      let(:initial_position_data) { "5 5 N\n" }

      it 'should rescue from a PlateauLimitError and skip invalid movements' do
        subject.land

        expect{ subject.move_forward }.to output(/PlateauLimitError: Currently at position/).to_stderr 
      end
    end
  end
end

describe MissionControl do
  describe '#new' do
    it 'return MissionControl object' do
      expect(MissionControl.new).to be_an_instance_of MissionControl
    end
  end

  describe "#execute_rover_missions" do
    let(:mission_control) { MissionControl.new }

    before(:each) do
        mission_control.read_mission_data(:string, mission_data)
        mission_control.initialize_plateau_data
        mission_control.initialize_rovers
    end

    subject { mission_control }

    context 'valid mission' do
      let(:mission_data) { "5 5\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM" }
      let(:mission_result_data ) { "1 3 N\n5 1 E\n" }

      it 'should result in an accurate and successful mission' do
        mission_control.execute_rover_missions

        expect(subject.mission_log).to eq(mission_result_data)
      end
    end

    context 'attempt to run rover off cliff' do
      let(:mission_data) { "5 5\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRMMMMMMMMM" }
      let(:final_rovers_position_data ) { "1 3 N\n5 1 E\n" }

      it 'should rescue from a PlateauLimitError and skip invalid movements' do
        expect{ subject.execute_rover_missions }.to output(/PlateauLimitError/).to_stderr 
      end
    end
  end
end
