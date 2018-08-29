# Mars Rover

Author: Mark Wong
Date: 03/21/16
Language: Ruby MRI 2.0.0p481
Developed on: OS X 10.10.5 (Yosemite)
Tested on:  OS X 10.10.5 and Ubuntu 14.04.3 LTS 64
Dependencies: Rspec Gem (for tests only)

## Instructions:
```
  To run application:
    - Copy files to a directory
    - make main.rb executable
      - 'chmod +x main.rb'
    - run main.rb
      - './main.rb'
  To run tests:
    - rspec -c -fd tests/mars_rover_spec.rb
```

## Overview:
This is a Mars Rover simulator. It simulates multiple rovers landing on one of the plateaus on Mars and moving about exploring the plateau terrain.  Mission data is read and executed for each rover.  The result is a mission log of the ending position and facing direction of each rover.

## Test Mission Data:
```
5 5         # the upper right corner coordinates of the plateau the rovers will land on
            # lower left coordinate are assumed to be 0, 0
            # so this plateau is a 6 x 6 grid that the rovers can maneuver on.  They must not cross the edge of the plateau as they would plummet to the ground
# Rover 1
1 2 N       # the initial coordinates of the rover on the plateau upon landing and the initial direction the rover faces 
LMLMLMLMM   # rotation and movement directions
              L = rotate 90 left
              R = rotate 90 right
              M = move forward one 

# Rover 2 
3 3 E
MMRMMRMRRM
```

## Final Output:
```
1 3 N  # Rover 1 ends up at plateau coordinates 1, 3 and facing North
5 1 E  # Rover 2 ends up at plateau coordinates 5, 1 and facing East
```


## Design:

I tried to design this application in a way that is loosely based on a simplified domain driven design philosophy.  My goal was to have as close as possible a one to one mapping of my objects to the real world of NASA rovers (or at least what I imagine it to be).  I believe that this makes code easier to understand because it is easier to make the connection between real world requirements and the code when names of objects and methods actually reflects the real world.  And in general, I usually try to avoid too many layers of abstraction, only what's necessary.  When trying to understand others' code, it's frustrating trying to trace through too many layers.  Of course, with large projects, sometimes this is not easily avoided, but it's I think it's good genral guideline to follow.

main.rb is the main driver program.

mission_control.rb gives the top level overview of the overall design of the software. Each method in that class reflects functionality that I imagine would really be part of a rover space program.

The mission data is read by the MissionDataReader object.  I made this class to accept either a file or string as input.  That way, testing is a lot easier as I can pass in various string inputs for the unit tests instead of reading different versions of the data from files. The file or string is parsed into an array representing each line of the mission data input.

PlateauData is a class that stores size information of the plateau. 

RoverInstructions stores the initial position data (where the rover will first land on the plateau) and the motion instructions.

Since the number of Rovers is determined by the mission data, the MissionControl#initialize_rovers method loops over the mission data (two lines at a time), grabs the rover instructions and instiantiates the Rovers.

Each Rover object takes the RoverInstructions and PlateauData and represents the Rover. It's main functionalities are rotating right and left and moving forward.  The PlateauData lets the rover know the size of the plateau.  The RoverInstructions tell the rover which direction to turn and how much to move forward. There are constraints built in so when a rover get to the edge of the plateau, it is prevented from moving forward another step. The rover keeps track of x and y location coordinates and current direction its pointing.

Direction is a collaborator object of Rover.  It stores the current direction of the rover and handles rotating left and right. I felt that the logic for this was complex enough to warrant its own class.

Once each rover has been loaded with it's instructions and plateau data, MissionControl@execute_rover_missions has each rover land on the plateau and execute its motions.  The method also keeps track of the final position and direction of each rover and stores it in the mission log which is displayed at the end.

I made no assumptions about the mission data input, specifically, whether it would be in the correct format.  So every object that holds and parses mission data has built in data validation methods. At first I thought to stores these validators in one Validation class, but then I opted to build the validators into each respective class.  I found that this way made for cleaner code.  The Validation class way requires the programmer to remember to call the validation methods for each piece of data at the right place.  By baking the validation into each class, the client programmer does not have to think about validation.  As each object is instantiated, validation kicks in and if invalid data is encountered, the appropriate exception/warning message is raised and depending on the severity of the error, the mission is aborted, or the data is skipped. Input validation is automatic and seamless. 

Most of the data validation and functionality above with various edge cases is covered in unit tests in tests/mars_rover_spec.rb 
