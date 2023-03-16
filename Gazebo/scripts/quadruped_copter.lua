-- Lua "motor driver" for a four legged walking / flying robot
--
-- Adapted from https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_Scripting/examples/quadruped.lua

-- AutoPilot servo connections:
-- SERVO1: Motor1: front left ccw
-- SERVO2: Motor2: back left ccw
-- SERVO3: Motor3: front left cw
-- SERVO4: Motor4: back right cw
-- SERVO5: Script5: front right coxa (hip) servo
-- SERVO6: Script6: front right femur (thigh) servo
-- SERVO7: Script7: front right tibia (shin) servo
-- SERVO8: Script8: front left coxa (hip) servo
-- SERVO9: Script9: front left femur (thigh) servo
-- SERVO10: Script10: front left tibia (shin) servo
-- SERVO11: Script11: back left coxa (hip) servo
-- SERVO12: Script12: back left femur (thigh) servo
-- SERVO13: Script13: back left tibia (shin) servo
-- SERVO14: Script14: back right coxa (hip) servo
-- SERVO15: Script15: back right femur (thigh) servo
-- SERVO16: Script16: back right tibia (shin) servo
--
-- CAUTION: This script should only be used with ArduPilot firmware


local FRAME_LEN = 177 -- frame length in mm
local FRAME_WIDTH = 101 -- frame width in mm

local COXA_LEN = 28.5 -- distance (in mm) from coxa (aka hip) servo to femur servo
local FEMUR_LEN = 76.2 -- distance (in mm) from femur servo to tibia servo
local TIBIA_LEN = 102 -- distance (in mm) from tibia servo to foot

--body position and rotation parameters
local body_rot_max = 10 -- body rotation maximum for any individual axis
local body_rot_x = 0 -- body rotation about the X axis (i.e. roll rotation)
local body_rot_y = 0 -- body rotation about the Y axis (i.e. pitch rotation)
local body_rot_z = 0 -- body rotation about the Z axis (i.e. yaw rotation)
local body_pos_x = 0 -- body position in the X axis (i.e. forward, back).  should be -40mm to +40mm
local body_pos_y = 0 -- body position in the Y axis (i.e. right, left).  should be -40mm to +40mm
local body_pos_z = 0 -- body position in the Z axis (i.e. up, down).  should be -40mm to +40mm

-- servo angles when robot is disarmed and resting body on the ground
local disarmed_leg_angles = {
  45, -90, 40,  -- front right leg (coxa, femur, tibia)
  -45, -90, 40, -- front left leg (coxa, femur, tibia)
  -45, -90, 40, -- back left leg (coxa, femur, tibia)
  45, -90, 40   -- back right leg (coxa, femur, tibia)
}

local armed_leg_angles = {
  0, -30, -60,  -- front right leg (coxa, femur, tibia)
  0, -30, -60, -- front left leg (coxa, femur, tibia)
  0, -30, -60, -- back left leg (coxa, femur, tibia)
  0, -30, -60   -- back right leg (coxa, femur, tibia)
}

-- Adapted rom https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_Scripting/examples/MotorMatrix_setup.lua

-- duplicate the standard + Quad mix
MotorsMatrix:add_motor_raw(0,-1, 0, 1, 2)
MotorsMatrix:add_motor_raw(1, 1, 0, 1, 4)
MotorsMatrix:add_motor_raw(2, 0, 1,-1, 1)
MotorsMatrix:add_motor_raw(3, 0,-1,-1, 3)

assert(MotorsMatrix:init(4), "Failed to init MotorsMatrix")

motors:set_frame_string("Set Quadruped Copter MotorMatrix")

function update()

  local leg_servo_direction = {
    1, -1,  1,  -- front right leg (coxa, femur, tibia)
    1,  1, -1,  -- front left leg (coxa, femur, tibia)
    -1, -1,  1, -- back left leg (coxa, femur, tibia)
    -1,  1, -1  -- back right leg (coxa, femur, tibia)
  }

  local leg_angles
  if arming:is_armed() then
    leg_angles = armed_leg_angles
  else
    leg_angles = disarmed_leg_angles
    -- leg_angles = armed_leg_angles
  end

  -- legs 1 - 12 (first leg output is 4 as 0 - 3 are assigned to motors)
  for i = 1, 12 do
    -- norm_angle in [-1, 1]
    local norm_angle = leg_angles[i] * leg_servo_direction[i] / 90
    -- pwm in [1000, 2000]
    local pwm = math.floor(norm_angle * 500 + 1500)

    SRV_Channels:set_output_pwm_chan_timeout(i + 3, pwm, 1000)
  end

  return update,10
end

-- turn off rudder based arming/disarming
param:set_and_save('ARMING_RUDDER', 0)
gcs:send_text(0, "Quadruped Copter")
return update()
