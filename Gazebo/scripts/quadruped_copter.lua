-- Lua "motor driver" for a four legged walking / flying robot
--
-- Adapted from https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_Scripting/examples/quadruped.lua

-- AutoPilot servo connections:
-- Output1: motor 1 front left ccw
-- Output2: motor 2 back left ccw
-- Output3: motor 3 front left cw
-- Output4: motor 4 back right cw
-- Output5: front right coxa (hip) servo
-- Output6: front right femur (thigh) servo
-- Output7: front right tibia (shin) servo
-- Output8: front left coxa (hip) servo
-- Output9: front left femur (thigh) servo
-- Output10: front left tibia (shin) servo
-- Output11: back left coxa (hip) servo
-- Output12: back left femur (thigh) servo
-- Output13: back left tibia (shin) servo
-- Output14: back right coxa (hip) servo
-- Output15: back right femur (thigh) servo
-- Output16: back right tibia (shin) servo
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

local disarmed_motor_speeds = {
  1000, 1000, 1000, 1000
}

local armed_motor_speeds = {
  1100, 1100, 1100, 1100
}

function update()

  local motor_speeds
  if arming:is_armed() then
    motor_speeds = armed_motor_speeds
  else
    motor_speeds = disarmed_motor_speeds
    motor_speeds = armed_motor_speeds
  end

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
    leg_angles = armed_leg_angles
  end

  -- motors 1 - 4
  for i = 1, 4 do
    SRV_Channels:set_output_pwm_chan_timeout(
      i - 1,
      motor_speeds[i],
      1000)
  end

  -- legs 1 - 4
  for i = 1, 12 do
    SRV_Channels:set_output_pwm_chan_timeout(
      i + 3,
      math.floor(((leg_angles[i] * leg_servo_direction[i] * 1000) / 90) + 1500),
      1000)
  end
end

-- turn off rudder based arming/disarming
param:set_and_save('ARMING_RUDDER', 0)
gcs:send_text(0, "quadruped simulation")
return update()
