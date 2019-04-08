---
layout: post
title:  "Simple Depth Estimation from Multiple Images in Tensorflow"
date:   2019-04-07
categories: slam
---

<div style="width:100%;height:0;padding-bottom:100%;position:relative;"><iframe src="https://giphy.com/embed/U89joc4KJrsys7T0Gs" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/U89joc4KJrsys7T0Gs">via GIPHY</a></p>


This post describes an algorithm for creating a depth image from a handful of RGB images taken of a scene.  I give an explanation of the system and provide a straightforward implementation of the algorithm using Tensorflow.  This algorithm is closely based on the depth map estimation step of LSD-SLAM (https://vision.in.tum.de/_media/spezial/bib/engel14eccv.pdf), however I introduce a simplified optimization strategy that retains the key benefits of that algorithm while being easier to understand, implement, and extend.  This implementation is not meant to be competitive with existing methods, instead, it is meant to reveal the intuition behind some state-of-the-art methods.

The goal is this post is only to clearly frame depth estimation as an optimization problem, and so I elide details on how exactly I represent poses and how image warping is implemented.  These details can be found in the LSD-SLAM paper, Ethan Eade’s document on Lie algebras, and in the tf_lie.py and image_warping.py source files I provide.


## Assumed background




This post assumes that you are familiar with basic linear algebra and gradient descent.  You don’t need to know about any simultaneous localization and mapping (SLAM) algorithms to understand this post.

This algorithm uses a Lie algebra to represent camera poses.  In this post, I treat that as a black box, though if you want to understand it, I recommend [Ethan Eade’s document on Lie algebras](http://ethaneade.com/lie.pdf) for representing transformations.  That material is depleted uranium dense.


## Aside: Why we care about depth

Measuring or estimating the distance from the camera to each pixel in an image is a step in many SLAM (simultaneous localization and mapping)  pipelines.  A depth image gives you a 3D model of the world in the camera’s view and lets you easily determine the transformation between two depth images of the same scene.  The quickest way to get a depth image is to use an RGD-Depth camera like a Kinect or RealSense.  Such hardware is more expensive than standard RGB cameras, however, and not nearly so ubiquitous.  In low-cost robotics applications, for instance, we are interested ways of getting the same 3D information about the world with clever algorithms rather than with specialized hardware.


## Depth from RGB images

In the absence of hardware for instantly producing RGB-D images, you can produce depth images by imaging the same scene from several perspectives and reconstructing its 3D geometry.  This method here does not require knowledge of what exact position the different frames were taken from, which sets it apart from methods that assume you have a calibrated stereo pair of cameras.  As we will see, this method works with unknown camera poses on unknown scenes.

If we have a model of how the camera projects world points onto the camera place, and if we assume the scene is rigid, we can reason about what the scene’s 3D structure must be given that we saw a certain set of images.  For instance, in the images in the figure below, the green cylinder moves more in the image between frames than the blue cube does because it is closer to the camera.   

![depth from motion setup]({{ site.url }}/assets/simple_depth/depth_from_motion_setup.svg)


## The algorithm

This algorithm takes as input a set of images like those in the scene above and designates one arbitrary image to be the “reference image.”  The algorithm outputs the distance from the reference camera plane to each point in the scene, along with the camera poses from which each photo was taken relative to the reference camera pose.  

The key to this algorithm is a warping operation that renders the scene from a given pose using given scene geometry.  If we have the correct scene geometry and camera poses, we can warp the other images into the view of the reference camera, and we should get images that look the same as the reference image.  We optimize the depth and pose estimates until we are able to reconstruct the reference image given the other images.

![depth from motion graph]({{ site.url }}/assets/simple_depth/depth_from_motion_graph.svg)


The image warp is a differentiable operation that takes in

+ The depth image from the reference camera’s view
+ Some image of the scene *I*
+ A transform that takes the reference camera’s pose and moves it to the pose of the camera that took the scene image I

and outputs a warped image where the pixels in I have been moved to their locations in the view of the reference camera.  In a nutshell, we know how the camera projects world points into the image plane, we know how far each reference image pixel is from the reference camera, and we have estimated the transform between the reference camera and the camera that took I. Given all that, we can calculate a correspondence between pixels in I and pixels in the reference image.  By resampling I according to this correspondence, we get n image of the pixels in I from the reference camera’s point of view.  

![depth from motion graph]({{ site.url }}/assets/simple_depth/image_warping.svg)


The figure above illustrates warping one pixel between camera views by inferring its location in 3D space.  This correspondence is found for all pixels in order to warp one view into another.   The warp operation is differentiable, allowing us to easily optimize the depth and pose variables it takes as input using gradient descent.

Once I is warped into the reference camera view, we need some way of measuring how well this warped image approximates the reference image, since this tells us how well our depth map and camera poses match the true values.  The photometric loss is a measure of the difference between two images.  There are many possible functions to use here.  I simply do a huber loss on the raw RGB values.  This is by no means optimal, but it was a couple nice properties.  First, it is dead simple.  Second, the huber loss is a robust loss, so if some pixels are way off due to occlusion or specular highlights in one image, our photometric loss will not be hugely affected.  A more enlightened algorithm would handle these cases explicitly.  As a note, the iteratively reweighted least squares optimization scheme proposed in the LSD-SLAM paper is really finding the minimum of the robust distance metric between images, although they don’t frame it this way.  Details on that can be found in Ethan Eade’s document on Gauss-Newton optimization.

Given the the ability to represent camera poses and warp images, solving for the depth map and camera poses is a simple optimization problem to set up.  Given a few images I and a reference image, we take a sum over the photometric loss for each I given the depth estimate and camera pose estimate for that image.  Finding the poses and depth can now be done by using gradient descent to minimize the sum of photometric losses.

# An implementation in tensorflow

My implementation can be found here.

That repo contains 
An ipython notebook for setting up and running the optimization of a depth map.
A directory of images of the rock and plant scene.
tf_lie.py which is a small utility for handling transformations in SO(3) in tensorflow.  SE(3) is a Lie group that can be used to represent rotation and translation transforms in 3D space.  This file is based on the equations in Ethan Eade’s document on Lie algebras and is meant to transparently handle any tensors where the last dimension is Lie group elements.  This is useful if you have, for instance, a batch of images with a transform for each pixel.
image_warping.py which implements the image warp from the LSD-SLAM paper.

In this project, I have allowed myself one hack: I include a total variation term in the cost function.  This term measures the amount of discontinuity in the depth map and so encourages the depth map to be smooth.  This term makes the results look better and something like it is often used in depth estimation, but is not very principled.  For instance, it penalizes flat surfaces that are tilted with respect to the camera, and a surface like grass that truly has lots of depth discontinuity will be penalized.  A slightly better approach would be to penalize the curvature of the depth map, but that is a slippery slope of heuristics and hand-tuning that I will not journey down at this time.  

There are more principled ways of imposing a prior on the depth map.  The LSD-SLAM paper estimates an uncertainty at each pixel and treats high uncertainty locations differently downstream.  While developing this code, I experimented with using a “deep image prior” on the depth map where instead of representing the depth map with one optimization variable for each pixel, I represent it using the output of a convolutional neural network which I optimize to produce the depth map for one scene.  


