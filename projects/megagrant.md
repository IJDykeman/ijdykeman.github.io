Script

Hello, we are three software engineers who used to work on self-driving cars.  We teamed up to apply our skills to problems in other industries, and with your help, we’re going to make motion capture for games cheap and easy.  

Existing motion capture systems are expensive and require custom capture hardware and outfits.  But computer vision and machine learning techniques have come a long way, and it’s time for this to change.

Our motion capture system needs no specialized hardware.  It’s just two webcams and some clever algorithms.

Here’s how it works:

We use deep learning to estimate 2d poses information in both camera images.  The deep learning based pose estimation is very smart — it can even estimate the positions of joints they can’t see by looking at other parts of the body.  However, it doesn’t tell us where a person’s joints are in 3D.  But with two cameras, we can triangulate each joint’s exact 3D position.

[PoseNet figuring out an occluded joint]

We’re confident that this approach works, but we need your help because making this technology into a robust, free product will be a significant engineering effort.  We detail the challenge on our proposal’s website, and give a breakdown of the components involved and a projected timeline.  

Thanks for your consideration.

Website

## We’re making motion capture cheap and easy.

Existing motion capture methods require expensive custom hardware:

We are creating a motion capture pipeline that instead uses cheap commodity hardware (webcams you already have lying around) and clever software.  The special hardware in today’s products is expensive because it gives very accurate, direct measurements of body positions.  Our cheaper solution relies instead on algorithms from robotics which can make sense of noisy sensor data.  


![Simple network diagram]({{ site.url }}/assets/megagrant/pose_ui.png)
*Our prototype interface with a human pose in blue and camera locations as magenta points*

## Today’s mocap systems are using more hardware than necessary 
*Hardware often used in today’s mocap systems*

Legacy mocap systems go to great lengths to ensure that every body part to be tracked is visible at all times and can be located precisely in every captured frame.  For instance, these systems use many cameras to surround the actors to prevent any part of the actor from being invisible at any time.  But why should our system fail if it can’t see every joint?  People have rigid skeletons and so by looking at some parts of the body, one can infer the positions of other parts.   

Today’s deep learning-based computer vision systems can do this type of inference:
[figure of a person with an occluded joint]
So having perfect surround cameras isn’t necessary.  What you need is smart tracking algorithms that can work with incomplete data.

## Our approach

Our system takes video of the actors with two or more webcams.  In each frame from each camera, we identify the 2d positions of actors’ body keypoints in the image.  Since we know where the cameras are relative to each other, we can then estimate each keypoint’s position in 3D space.  With two cameras, you can think of this as “triangulating” the position of the keypoint, but our system can more cameras for better accuracy or to create a larger performance space.

### User’s workflow
To give a sense of what’s involved with using the system:
Our system asks the user to set up two or more cameras pointed at the actor or actors.
The user displays an image we provide on a phone or tablet and shows it to the cameras.  This lets the system infer the relative positions of the cameras.
The user hits record in our software, and the actors play out some motion.
The user hits stop and is able to export the motion data or start capture again.

To identify body keypoints in 2D, we use PoseNet, which is an open source deep learning system developed by Google.  This greatly simplifies our work, since developing such learning systems from scratch is difficult, and it’s tough to know at the outset what the final performance of the learner might be.  With PoseNet already available for our use under an Apache license, we are left with only the more predictable challenges of geometrically fusing the data from different cameras.


Two views of an elbow in who camera images let us triangulate the elbow in 3D



## Going beyond the capabilities of today’s mocap

Today’s mocap system all share an obvious drawback: they are fixed in space.  A mobile motion capture system that allows a person carrying a small camera rig to follow an actor would expand the motion capture stage to an unlimited size.  We have already developed localization and mapping technology that can let the camera rig estimate its own position is space as well as some simple scene geometry.  Coupling this with our human pose estimation system will allow mocap across large areas, including in outdoor spaces where one can’t set up special equipment.  

## Why are we the right team?

We come from a robotics background.  Estimating locations and other physical quantities from noisy data is what we love to do.  Currently, we are running Main Street Autonomy [LINK], which offers consulting services and software to companies with robotics-related problems.  We’re excited about applying techniques from robotics to game development, and we think this project is the right place to start given our skill sets.

Isaac
[linkedin, blog, CV]
Before striking out to apply his skills to a wider variety of problems, Isaac worked at  Uber ATG on their autonomous vehicle.  He did deep learning-based computer vision engineering, not unlike what’s being proposed here. 

Jake
[linkedin]
Jake previously worked as the technical lead of motion planning for Aurora’s autonomous vehicle development.  He has extensive experience in calibration, which is important for estimating the cameras’ relative positions,  and in sensor fusion, which is the family of techniques that includes the multi-camera approach we use.  


## Why is this work important in light of other mocap products?

The only comparable effort we are aware of is Radical.  Radical is a software-as-a-service offering that converts single camera video into 3D human pose data.  They charge a monthly subscription fee.  We also want to make a free product that does not depend on external compute services.  We also believe our approach is the right one technically, and that it will produce higher quality motion capture.  

### Technical differences

#### role of machine learning
Radical’s approach is to use machine learning to convert images to poses in a single step.  This approach prevents you from injecting known facts about human movement and skeletons into the system, because you cannot directly program the inner working of a learned algorithm.  For example, we know that elbows and knees cannot bend backward.  But looking at some output on Radical’s website, we see just that:


*A fully learned approach to pose estimation doesn’t directly incorporate prior knowledge, like which way elbows bend.*

We fuse input from multiple cameras using handwritten algorithms that take into account prior knowledge of human bodies.  This let’s us apply constraints like “elbows only bend in one direction.”

#### single vs multiple cameras

An approach that uses a single camera to estimate 3D positions will never be as effective as one that uses multiple cameras.  Radical uses machine learning to estimate depth, but this is prone to unpredictable errors since there is no geometric backing for their estimates.  Our system relies on triangulation, which gives better accuracy guarantees.

#### Benefits to the community

We will make our motion capture system free to download rather than make it a paid subscription.  We won’t maintain a central cloud service.  Instead, we want to empower users by letting them run our system on their own hardware.


## What do we need to succeed?

It’s easy to make an interesting prototype, and much harder to make a usable product.  We will use the MegaGrant to pay living expenses while we take this final step.

We are asking for $37,500, which will cover expenses for us for 3 months, and allow us to hire some outside talent for demo performances.  Below is a Gantt chart detailing our estimated timeline.



