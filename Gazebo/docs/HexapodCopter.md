# Hexapod Copter

A Gazebo model for a hexapod copter (a hexapod rover with motors on each arm).

## Usage

Gazebo and the plugins should be installed as per the [ArduPilot Gazebo Plugin](https://github.com/ArduPilot/ardupilot_gazebo) instructions.

Update the `GZ_SIM_RESOURCE_PATH` to include these models:

```bash
export GZ_SIM_RESOURCE_PATH=$GZ_SIM_RESOURCE_PATH:\
$HOME/SITL_Models/Gazebo/models:\
$HOME/SITL_Models/Gazebo/worlds
```

#### Run Gazebo

```bash
$ gz sim -v4 -r hexapod_copter_runway.sdf
```

#### Run ArduPilot SITL

The initial version of this model is configured as a hexacopter.

```bash
$ sim_vehicle.py -v ArduCopter -f JSON --add-param-file=$HOME/SITL_Models/Gazebo/config/hexapod_copter.param --console --map
```

## Dimensions

- height: 53.23 mm
- coxa_axis_width: 101.42 mm
- coxa_axis_length: 177.03 mm
- coxa_axis_to_femur_axis: 30.0 mm
- femur_axis_to_tibia_axis: 76.17 mm
- tibia_axis_to_foot: 122.0 mm

## Credits

### Hexapod CAD model

- Author: [Tim Mills](https://grabcad.com/tim.mills-1)
- Model: [Hexapod Robot](https://grabcad.com/library/hexapod-robot-1)
