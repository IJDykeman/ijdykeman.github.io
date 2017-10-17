---
layout: post
title:  "Predicting Wind Damge to Homes using Convolutional Neural Networks"
date:   2017-10-17 22:25:30 -0500
categories: ml
published: false
---


In this post, I'll describe a new state of the art model for predicting the probability that a given home will be damaged under given hurricane wind conditions. It works by using a convolutional neural network which uses high resolution LIDAR scans of residential areas to learn the relationship between the various physical environments in which a home exists and its probability of being damaged in a given storm.
This model improves significantly upon the state of the art HAZUS-MH model used by FEMA to estimate wind damages in advance of a hurricane.  
Many factors besides wind interact to affect the probability that a given home will be damaged in a storm.  Chief among these is the physical structure of and environment around a home.  Previous models have relied on highly simplified representations of the complex and heterogeneous physical environments that surround houses.
We demonstrate a significant improvement of from an AUC of 0.43 to 0.75  over the HAZUS-MH baseline on a data set of about 800,000 homes in Harris County, Texas.

## Introduction
When hurricane Ike struck Harris County, where Houston, Texas is located, about 170,000 homes of the over 800,000 homes in the area were damaged.  These homes were exposed to varying wind speeds and directions, but the observed damage patterns do not closely align with wind intensity.  Previous attempts to better model storm risk have focused on incorporating information such as a home's age and value to better predict its damage risk. In this paper, we present a novel method for incorporating high resolution terrain maps into a model of storm risk, and show substantial improvement over state of the art storm risk predictions.

The physical environment around a home has a significant effect on the probability that it will be damaged in given wind conditions.  Houses in Harris county exist in very diverse physical conditions.  Some are situated in dense developments, others stand alone in large empty areas.  Some are surrounded by dense trees, some are near freeways or waterways, some are close to much larger buildings, while others are in neighborhoods of highly uniform structures. A system which is able to learn the relationship between these conditions and damage probability may be able to much more reliably explain variance in damage probability %in given weather conditions 
between homes which other models fail to capture.

The physical environment around a house is represented by a height map with 1 meter spatial resolution.  We use the output of a pretrained convolutional neural network with the VGG-16 architecture as one of the inputs to a multilayer perceptron which we also feed the age, value, and a time series of wind speeds and wind directions over the duration of a storm.

## Data


We use four data sources to model hurricane damage risk: LIDAR scans of terrain; information about wind during hurricane Ike; and tax related information about each home, such as its age and value.  We also have data on whether each home was damaged or not in hurricane Ike.

####Hurricane Ike Wind Data

We have the approximate speed and direction of wind at an altitude of X meters above each home in Harris County for each of 12 points in time during hurricane Ike. 

####Harris County Appraisal District Data


Harris County collects information about each home in it for purposes of tax assessment.  This information includes the value of the home, its age, its last year of renovation, and a rough estimate of its physical condition.  See figure \ref{market_price} for a map of prices of homes in Harris County.


![market value](market_value.png)
*A map of average market price of homes in Harris County.  Log scale.*


It is worth noting that while this data has 35 dimensions, the data is truly less rich.  In fact, the data can be reduced to one dimension and reconstructed with little loss of information.  We tested this by ... 


####LIDAR data for Harris County

In 2008, the Houston-Galveston Area Council commissioned a  high resolution LIDAR scan of Harris county and areas surrounding it.  These scans cover 3,700 square miles at a horizontal resolution of 1m and a vertical resolution of 7cm.  This data has been used in its full form for predicting flooding CITE, but only simplified versions of the data have been used for storm prediction CITE.


![lidar image](large_lidar_image_2.png)
*LIDAR elevation data for a large area in Houston.*


![diverse terrain](diverse_terrain.png)
*Examples of various conditions that exist around homes in Houston.*


When predicting the damage probability for a given home, we consider a $224 \time 224$ pixel region of the LIDAR scan centered on that home.  The data is a 2D heightmap.  The image below is an example of one of these LIDAR images. 

![lidar example](lidar_example.png)
*An example of a LIDAR image as it is presented to our CNN architecture.  The brighter regions are higher in elevation.  The boxy objects are buildings.*


![3d image](3d_image.png)
*A 3D visualization of the LIDAR height map around a house.  The protruding objects are homes and trees.  Streets and a waterway are visible.*


## A Convolutional Neural Network model that Incorporates LIDAR Data

We built a convolutional neural network (CNN) which takes in LIDAR images and wind data and classifies that case as damaged or undamaged.  This model also takes as input wind and tax related data.  We pretrain all but the final convolutional layer on the ImageNet task.  The output of the convolutional layers along with the wind and tax data is fed into a multilayer perceptron, which predicts the probability of damage for the given home.  See figure \ref{cnn_diagram} for a diagram of this architecture.

![CNN diagram](cnn_diagram.png)

### Pretraining the CNN

In the domain of image classification, it is common to pretrain a model on a large dataset of images which are not necessarily similar to those you are working with, and then use layers from that model as part of your final model.  This method has been used for other difficult vision tasks, such as detecting skin cancer \cite{SkinCancer}.  We use a VGG-16 \cite{Vgg16} model trained on the ImageNet ~\cite{ImageNet} classification task. 

### CNN Architecture Details

We use a the VGG-16 architecture's convolutional layers.  These layers are pretrained and their parameters are fixed during training.  We add a convolutional layer on top of these with $64~ 3\times 3$ filters.  
This convolutional layer is trainable.  
We do this to reduce the size of the $7\times 7\times 512$ activation volume to $7 \times 7 \times 64$. The output from that convolutional layer is concatenated with the wind and tax data and fed into a fully connected layer with 32 nodes.  The next fully connected layer also has 32 nodes.  The fully connected layer and the convolutional layer we add are ReLU activated  The output layer has a single node with sigmoid activation.  We use crossentropy loss to train this model.

