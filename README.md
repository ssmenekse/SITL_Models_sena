This branch introduces a fixed-wing model integrated with a camera sensor, designed for simulation purposes without requiring any ROS integration. Below, its described how the camera sensor is defined, configured, and used in the simulation.
![Screenshot from 2024-04-26 17-38-00](https://github.com/user-attachments/assets/37ba59be-3bff-467f-814d-3722b5fb90c1)
![Screenshot from 2024-04-27 18-39-56](https://github.com/user-attachments/assets/da12db80-0eff-4c4e-b8c2-96e27bd209b4)

1. Adding the Camera to the Model
In the model's SDF file, we define a link tag to represent the camera as a physical entity in the simulation. This determines how the camera interacts with the world. Within this link, we use a sensor tag to specialize the link as a camera.

Note:(where i lost great amount of my time)

    The sensor tag is nested within* the link tag. This ensures the camera is treated as part of the physical entity.
    
        
For advanced simulations, you can configure the camera’s lens and add noise to mimic real-world imperfections.       
`` <lens>
    <type>perspective</type>
    <cutoff_angle>3.14</cutoff_angle>
    <intrinsics>
        <fx>800</fx> 
        <fy>800</fy> 
        <cx>329.09962026</cx> 
        <cy>284.74455683</cy> 
        <s>0</s>
    </intrinsics>
</lens>       
<noise>
  <type>gaussian</type>
  <mean>0.0</mean>
  <stddev>0.20</stddev>
</noise> ``

Type: Gaussian noise for realistic distortion.
Mean & Stddev: Configure the noise's statistical properties.

2. Attaching the Camera to the Model
To attach the camera to the fixed-wing model, use a joint that connects the camera's link <child>link</child> to the model's body <parent>base_link</parent>.

3. Viewing Camera Output

The ImageDisplay plugin displays the camera feed directly in the Gazebo interface, at the specified topic, as defined in the <topic> tag

<topic>camera/image</topic>
<update_rate>30</update_rate>

If the displayed image appears pixelated or low quality when in fullscreen, increase the resolution in the image tag:

<image>
  <width>1920</width>
  <height>1080</height>
  <format>R8G8B8</format>
</image>

If you need to share or process the published images on another system, Gazebo provides the GStreamer Plugin. This plugin allows you to stream the camera feed in the topic we specifed over a UDP connection, making it accessible outside the simulation environment.

<plugin name="GstCameraPlugin"
    filename="GstCameraPlugin">
  <udp_host>127.0.0.1</udp_host>
  <udp_port>5600</udp_port>
  <use_basic_pipeline>true</use_basic_pipeline>
  <use_cuda>false</use_cuda>
</plugin>

check for more detail : https://github.com/ArduPilot/ardupilot_gazebo
