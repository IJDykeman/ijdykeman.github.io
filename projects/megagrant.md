---
title:  "MegaGrant Proposal for Low Cost Motion Capture"
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/3TgZoMTGJVs" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" style="display: block; margin: auto;" allowfullscreen></iframe>

We are creating a motion capture pipeline that requires only cheap commodity hardware (webcams you already have lying around) and clever software.  The special hardware in today’s products is expensive because it gives very accurate, direct measurements of body positions.  Our cheaper solution relies instead on algorithms from robotics which can make sense of noisy sensor data.  


![Prototpye interface]({{ site.url }}/assets/megagrant/image_w_pose.png)
*An image with 2D pose overlaid, and the 3D pose estimated using both camera images*

## Today’s mocap systems are using more hardware than necessary 

![Mocap hardware]({{ site.url }}/assets/megagrant/goofy_mocap_hardware.png)
*Hardware often used in today’s mocap systems*

Legacy mocap systems go to great lengths to ensure that every body part to be tracked is visible at all times and can be located precisely in every captured frame.  For instance, these systems use many cameras to surround the actors to prevent any part of the actor from being invisible at any time.  But why should our system fail if it can’t see every joint?  People have rigid skeletons and so by looking at some parts of the body, one can infer the positions of other parts.  Today’s deep learning-based computer vision systems can do this type of inference, so having perfect surround cameras isn’t necessary.  The top image on this page shows the system inferring the occluded elbow's location.

## Our approach

Our system takes video of the actors with two or more webcams.  In each camera's view, we identify the 2d positions of actors’ body keypoints in the image.  Since we know where the cameras are relative to each other, we can then estimate each keypoint’s position in 3D space.  With two cameras, you can think of this as “triangulating” the position of the keypoint, but our system can more cameras for better accuracy or to create a larger performance space.

![Mocap hardware]({{ site.url }}/assets/megagrant/triangulation.png)
*Two views of an elbow in who camera images let us triangulate the elbow in 3D*


### User’s workflow
To give a sense of what’s involved with using the system:
1. Our system asks the user to set up two or more cameras pointed at the actor or actors.
2. The user displays an image we provide on a phone or tablet and shows it to the cameras.  This lets the system infer the relative positions of the cameras.
3. The user hits record in our software, and the actors play out some motion.
4. The user hits stop and is able to export the motion data or start capture again.

The software will export animations in the FBX format, which will let users import the animations directly to Unreal Engine.

To identify body keypoints in 2D, we use PoseNet, which is an open source deep learning system developed by Google.  This greatly simplifies our work, since developing such learning systems from scratch is difficult, and it’s tough to know at the outset what the final performance of the learner might be.  With PoseNet already available for our use under an Apache license, we are left with only the more predictable challenge of geometrically fusing the data from different cameras.




## Going beyond the capabilities of today’s mocap

Today’s mocap system all share an obvious drawback: they are fixed in space.  A mobile motion capture system that allows a person carrying a small camera rig to follow an actor would expand the motion capture stage to an unlimited size.  For robotics applications, we have already developed localization and mapping technology that can let the camera rig estimate its own position is space as well as some simple scene geometry.  Coupling this with our human pose estimation system would allow mocap across large areas, including in outdoor spaces where one can’t set up special equipment.  

## Why are we the right team?

We come from a robotics background.  Estimating locations and other physical quantities from noisy data is what we love to do.  We recently founded [Main Street Autonomy](https://mainstreetautonomy.com/) to disseminate the best techniques in robotics across the industry.  This project is a first step toward applying those skills outside of robotics.  We think game development will benefit greatly from techniques from robotics, and we want to be the pioneers who make that happen!

**Isaac**
<br/>
[[linkedin](https://www.linkedin.com/in/ijdykeman), [blog](https://ijdykeman.github.io/)]
<br/>
Before striking out to apply his skills to a wider variety of problems, Isaac worked at  Uber ATG on their autonomous vehicle.  He did deep learning-based computer vision engineering, not unlike what’s being proposed here. 

**Jake**
<br/>
[[linkedin](https://www.linkedin.com/in/jacob-panikulam-a0a91b58)]
<br/>
Jake previously worked as the technical lead of motion planning for Aurora’s autonomous vehicle development.  He has extensive experience in calibration, which is important for estimating the cameras’ relative positions,  and in sensor fusion, which is the family of techniques that includes the multi-camera approach we use.  



## Why is this work important in light of other mocap products?

The only existing product that does 3D mocap with comodity hardware is Radical.  Radical is a software-as-a-service offering that converts single camera video into 3D human pose data.  They charge a monthly subscription fee.  We also want to make a free product that does not depend on external compute services.  We also believe our approach is the right one technically, and that it will produce higher quality motion capture.  

### Technical differences

#### Role of machine learning
Radical’s approach is to use machine learning to convert images to poses in a single step.  This approach prevents you from injecting known facts about human movement and skeletons into the system, because you cannot directly program the inner working of a learned algorithm.  For example, we know that elbows and knees cannot bend backward.  But looking at some output on Radical’s website, we see just that:


![Mocap hardware]({{ site.url }}/assets/megagrant/backward_elbow.jpg)
*A fully learned approach to pose estimation doesn’t directly incorporate prior knowledge, like which way elbows bend.*

We fuse input from multiple cameras using handwritten algorithms that take into account prior knowledge of human bodies.  This let’s us apply constraints like “elbows only bend in one direction.”

#### Single vs multiple cameras

An approach that uses a single camera to estimate 3D positions will never be as effective as one that uses multiple cameras.  Radical uses machine learning to estimate depth, but this is prone to unpredictable errors since there is no geometric backing for their estimates.  Our system relies on triangulation, which gives better accuracy guarantees.

#### Benefits to the community

We will make our motion capture system free to use rather than make it a paid subscription.  We won’t maintain a central cloud service.  Instead, we want to empower users by letting them run our system on their own hardware.

## Thanks for your consideration

We're really excited about this problem, and with your support, we hope to be able to devote ourselves to making it a tool anyone can use.