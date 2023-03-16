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

-- Adapted from https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_Scripting/examples/MotorMatrix_setup.lua

-- duplicate the standard + Quad mix
MotorsMatrix:add_motor_raw(0,-1, 0, 1, 2)
MotorsMatrix:add_motor_raw(1, 1, 0, 1, 4)
MotorsMatrix:add_motor_raw(2, 0, 1,-1, 1)
MotorsMatrix:add_motor_raw(3, 0,-1,-1, 3)

assert(MotorsMatrix:init(4), "Failed to init MotorsMatrix")

motors:set_frame_string("Quadruped Copter")

-- servo angles when robot is disarmed and resting body on the ground
local disarmed_leg_angles = {
   45, -90, 40, -- front right leg (coxa, femur, tibia)
  -45, -90, 40, -- front left leg (coxa, femur, tibia)
  -45, -90, 40, -- back left leg (coxa, femur, tibia)
   45, -90, 40  -- back right leg (coxa, femur, tibia)
}

local armed_leg_angles = {
  0, -25, -60, -- front right leg (coxa, femur, tibia)
  0, -25, -60, -- front left leg (coxa, femur, tibia)
  0, -25, -60, -- back left leg (coxa, femur, tibia)
  0, -25, -60  -- back right leg (coxa, femur, tibia)
}

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
  end

  for i = 1, 12 do
    -- normalised angle is in [-1, 1]
    local norm_angle = leg_angles[i] * leg_servo_direction[i] / 90
    -- ensure pwm is in [1000, 2000]
    local pwm = math.floor(norm_angle * 500 + 1500)

    -- Q: is index for assigned channel or absolute?
    -- A: it is absolute (so offset for the 4 motors)
    SRV_Channels:set_output_pwm_chan_timeout(i + 3, pwm, 1000)
  end

  return update,10
end

-- turn off rudder based arming/disarming
param:set_and_save('ARMING_RUDDER', 0)
gcs:send_text(0, "Quadruped Copter")
return update()
