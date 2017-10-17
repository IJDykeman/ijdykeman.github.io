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