---
layout: post
title:  "Simple Depth Estimation from Multiple Images in Tensorflow"
date:   2019-04-07
categories: slam
---


This post describes an algorithm for creating a depth image from a handful of RGB images taken of a scene.  I give an explanation of the system and provide a straightforward implementation of the algorithm using Tensorflow.  This algorithm is closely based on the depth map estimation step of [LSD-SLAM](https://vision.in.tum.de/_media/spezial/bib/engel14eccv.pdf), however I introduce a simplified optimization strategy that retains the key benefits of that algorithm while being easier to understand, implement, and extend.  This implementation is not meant to be competitive with existing methods, instead, it is meant to reveal the intuition behind some state-of-the-art methods.

The goal is this post is only to clearly frame depth estimation as an optimization problem, and so I elide some details.  These details can be found in the LSD-SLAM paper, Ethan Eade’s document on Lie algebras, and in the  [source code](https://github.com/IJDykeman/simple_depth_from_motion) I provide.

The animation below shows the algorithm aligning 4 images of the scene as it finds the camera poses that took the images.  Toward the end of the animation, some scene elements shift as the algorithm adjusts their position in 3D space to match the geometry of the scene.
<div style="width:100%;height:0;padding-bottom:100%;position:relative;"><iframe src="https://giphy.com/embed/U89joc4KJrsys7T0Gs" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>


The next animation shows the depth map being refined over the course of optimization.
<!-- <div style="width:100%;height:0;padding-bottom:100%;position:relative;"><iframe src="https://giphy.com/embed/ZEfBoPTODKz4H7XzaZ" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div> -->


<div style="width:100%;height:0;padding-bottom:100%;position:relative;"><iframe src="https://giphy.com/embed/lPMPu497g42fLRNnOb" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>


## Background




This post assumes that you are familiar with basic linear algebra and gradient descent.  You don’t need to know about any simultaneous localization and mapping (SLAM) algorithms to understand this post.  The source code is written in Python using Tensorflow.

This algorithm uses SE(3) to represent camera poses.  In this post, I treat that as a black box, though if you want to understand it, I recommend [Ethan Eade’s document on Lie algebras](http://ethaneade.com/lie.pdf) for representing transformations.  That material is depleted uranium dense.


## Aside: Why we care about depth

Measuring or estimating the distance from the camera to each pixel in an image is a step in many SLAM (simultaneous localization and mapping)  pipelines.  A depth image is an image where each pixel contains the distance from the camera to that point in the scene.  A depth image gives you a 3D model of the world in the camera’s view and lets you easily determine the transformation between two depth images of the same scene.  The quickest way to get a depth image is to use an RGD-Depth camera like a Kinect or RealSense.  Such hardware is more expensive than standard RGB cameras, however, and not nearly so ubiquitous.  In low-cost robotics applications, for instance, we are interested ways of getting the same 3D information about the world with clever algorithms rather than with specialized hardware.


## Depth from RGB images

In the absence of hardware for instantly producing RGB-D images, you can produce depth images by imaging the same scene from several perspectives and then reconstructing its 3D geometry.  This method does not require knowledge of what exact position the different frames were taken from, which sets it apart from methods that assume you have a calibrated stereo pair of cameras.  As we will see, this method works with unknown camera poses on unknown scenes.

If we have a model of how the camera projects world points onto the camera place, and if we assume the scene is rigid, we can reason about what the scene’s 3D structure must be given that we saw a certain set of images.  For instance, in the images in the figure below, the green cylinder moves more in the image between frames than the blue cube does because it is closer to the camera.   

![depth from motion setup]({{ site.url }}/assets/simple_depth/depth_from_motion_setup.svg)


## The algorithm

This algorithm takes as input a set of images like those in the scene above and designates one arbitrary image to be the “reference image.”  The algorithm outputs the distance from the reference camera plane to each point in the scene, along with the camera poses from which each photo was taken relative to the reference camera pose.  

The key to this algorithm is a warping operation that renders the scene from a given pose using given scene geometry.  If we have estimated the correct scene geometry and camera poses, we can warp the other images into the view of the reference camera, and we should get images that look the same as the reference image.  To produce depths maps, we optimize the depth and pose estimates until we are able to reconstruct the reference image given the other images.


![depth from motion graph]({{ site.url }}/assets/simple_depth/depth_from_motion_graph.svg)


The image warp is a differentiable operation that takes in

+ The depth image from the reference camera’s view
+ Some image of the scene $$I$$
+ A transform that takes the reference camera’s pose and moves it to the pose of the camera that took the scene image $$I$$

and outputs a warped image where the pixels in $$I$$ have been moved to their locations in the view of the reference camera.  In a nutshell, we know how the camera projects world points into the image plane, we know how far each reference image pixel is from the reference camera, and we have estimated the transform between the reference camera and the camera that took $$I$$. Given all that, we can calculate a correspondence between pixels in $$I$$ and pixels in the reference image.  By resampling $$I$$ according to this correspondence, we get an image of the pixels in $$I$$ from the reference camera’s point of view.  

![depth from motion graph]({{ site.url }}/assets/simple_depth/image_warping.svg)


The figure above illustrates warping one pixel between camera views by inferring its location in 3D space.  This correspondence is found for all pixels in order to warp one view into another.   The warp operation is differentiable, allowing us to easily optimize the depth and pose variables it takes as input using gradient descent.

The formula for the warp given

* $$p$$, a pixel location in the reference image
* $$d(p)$$, a function mapping a pixel location $$p$$ in the reference image to the depth value at that location
* $$\textbf{T}$$, a homogenous transformation matrix representing the transform from some camera's frame to that of the reference image

$$\text{warp}(p, d, \textbf{T}) = \textbf{T} \begin{bmatrix}
           p_x \\
           p_y \\
           1/d(p) \\
           1
         \end{bmatrix}
         $$

gives us the location of pixel $$p$$ in the view of the reference camera.  The homogenous transform $$T$$ is computed from the SE(3) representation of the camera poses using the method in Ethan Eade's document, which I implement for Tensorflow in tf_lie.py.


Once $$I$$ is warped into the reference camera view, we need some way of measuring how well this warped image approximates the reference image, since this tells us how well our depth map and camera poses match the true values.  The photometric loss is a measure of the difference between two images.  There are many possible functions to use here.  I simply do a huber loss on the raw RGB values.  This is by no means optimal, but it was a couple nice properties.  First, it is dead simple.  Second, the huber loss is a robust loss, so if some pixels are way off due to occlusion or specular highlights in one image, our photometric loss will not be hugely affected.  A more enlightened algorithm would handle these cases explicitly.  If $$ref(p)$$ is the reference image's color at position $$p$$ and $$I(p)$$ is an image $$I$$'s color at position $$p$$, then our cost function is 

$$ \sum_p \text{huber}(ref(p), I(\text{warp}(p, d, T))) $$

For clarity, the function above elides iterating over the r, g, and b channels of the image as I do in my implementation.

As a note, the iteratively reweighted least squares optimization scheme proposed in the LSD-SLAM paper is really finding the minimum of the robust distance metric between images, although they don’t frame it this way.  Details on that can be found in Ethan Eade’s document on Gauss-Newton optimization.

Given the the ability to represent camera poses and warp images, solving for the depth map and camera poses is a simple optimization problem to set up.  Given a few images $$I$$ and a reference image, we take a sum over the photometric loss for each $$I$$ given the depth estimate and camera pose estimate for that image.  I can now jointly optimize the poses and depth using gradient descent to minimize the sum of photometric losses.

The video below shows the whole optimization process in action.  The points on the lower right are the estimated locations of the cameras, and each pixel in the scene is represented as a point that moved closer or farther away from the reference camera (the blue point) according to its depth value over the course of optimization.  Notice how the camera images are in a smooth arc.  That's because I took these images from a video, during which I made a smooth sweeping motion with the camera.

<div style="width:100%;height:0;padding-bottom:100%;position:relative;"><iframe src="https://giphy.com/embed/gjlenSUuxvjMqhHVoi" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>


<video width="100%" autoplay loop>
  <source src="{{ site.url }}/assets/simple_depth/pointcloud_viz.mp4" type="video/mp4">
    Error displaying video
</video>

# An implementation in tensorflow

[My implementation can be found here.](https://github.com/IJDykeman/simple_depth_from_motion)

That repo contains 
* An ipython notebook that generates a depth map using my approach
* A directory of images of the rock and plant scene
* tf_lie.py, a utility for handling SE(3) transformations in tensorflow which handles tensors where the last dimension represents SE(3) elements
* image_warping.py which implements the image warp described above


The heart of the implementation is this snippet, which what is in the notebook, and here is pared down for clarity, ommitting some casting and other cruft.

```python
depth =  tf.abs(tf.Variable(tf.ones([400,400])) + 1) +.1

cost = 0.0

for scene_image in scene_images:
    # pose representation for the cameras that took each scene image
    translation_representation = tf.Variable([[0.01, 0.01, 0.01]])
    rotation_representation = tf.Variable([[0.01, 0.01, 0.01]])

    warped_scene_image = warp_image(scene_image, depth,
                                    translation_representation,
                                    rotation_representation)

    cost += tf.losses.huber_loss(reference_image, warped_scene_image)
    
optimizer = tf.train.AdamOptimizer(learning_rate=.005).minimize(cost)

init = tf.global_variables_initializer()
sess = tf.Session()
sess.run(init)
for _ in range(2000):
    sess.run(optimizer)

```

I think it's very surprising that in about a dozen lines of python, you can capture the essense of the depth map estimation algorithm:

1. First, initialize the depth map to be all ones and constrain depth to be positive.
2. Define the cost to be the robust Huber metric between the reference image and the scene image warped into the reference view.
3. Minimize the loss by adjusting the camera poses and the depth map using gradient descent.

The rest of the code in the notebook is data setup and visualization.

In this project, I have allowed myself one hack: I include a total variation term in the cost function.  This term measures the amount of discontinuity in the depth map and so encourages the depth map to be smooth.  This term makes the results look better and something like it is often used in depth estimation, but is not very principled.  For instance, it penalizes flat surfaces that are tilted with respect to the camera, and a surface like grass that truly has lots of depth discontinuity will be penalized.  A slightly better approach would be to penalize the curvature of the depth map, but that is a slippery slope of heuristics and hand-tuning that I will not journey down.  

This approach yields the depth map below.  It looks reasonable, but has obvious blocky artifacts caused by the total variation term encouraging regions of zero gradient to form.

![depth]({{ site.url }}/assets/simple_depth/naive_depth_image.png)


# Refining the deth map using a "deep image prior"

In the approach above, I represent each pixel as a separate depth value, and introduce some regularity through a total variation term.  Inspired by the [deep image prior](https://arxiv.org/abs/1711.10925) paper, I experimented with instead representing the depth map as the output of a fully convolutional neural network.  The intuition in that paper is that a CNN has an easier time representing a "natural" image than one containing artifacts such as high-frequency noise or the blocky artifacts introdcued by image compression, or in my case by the total variation term.  In the deep image prior paper, a u-net style architecture is trained to take a corrupted image and simply reproduce it as the network's output.  This task is trivial since the network need only memorize a single data sample, but by using early stopping, the authors get images that are produced after the network has learned to predict the desired, "natural" structure in the image but before the network has memorized the undesireable noise or artifacts in the input image.  

This approach produces a much nicer looking depth map:

![depth]({{ site.url }}/assets/simple_depth/cnn_depth_image.png)



# Conclusion


For this scene of a plant and a rock on some leaf litter,

![scene]({{ site.url }}/assets/simple_depth/reference_image.png)

my approach which represents the depth map using a u-net that takes the original image as input produces this depth map:

![depth]({{ site.url }}/assets/simple_depth/cnn_depth_image.png)

While that depth map is not perfect, I think it's surprising that something so reasonable looking can be produced with such a simple optimization setup.  Once you have utilities for manipulating camera poses (tf_lie.py) and doing image warping (image_warping.py), the problem can be solved in about a dozen lines of tensorflow code.  
