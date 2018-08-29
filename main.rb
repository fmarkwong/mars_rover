#!/usr/bin/env ruby
require_relative 'mission_control'
require_relative 'errors'

mission_control = MissionControl.new
mission_control.read_mission_data(:file, 'mission_data.txt')
mission_control.initialize_plateau_data
mission_control.initialize_rovers
mission_control.execute_rover_missions
mission_control.display_mission_log
