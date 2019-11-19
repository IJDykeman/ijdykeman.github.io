---
layout: page
title: About
permalink: /about/
---

<style type="text/css">
    h4 {
        margin-bottom: 0;
        margin-top: .7em;
    }
    h3{
        margin-bottom: 0;
        margin-top: .7em;
    }
</style>

![portrait]({{ site.url }}/assets/isaac_jet.jpg)



I am a software engineer based in Pittsburgh.  I am interested in machine learning, robotics, computer graphics, and in some things that do not involve computers.

Contact me at ijdykeman@gmail.com .




### Selected Professional Experience

#### Perception Software Engineer at Uber ATG, 2017-2019
I worked on Uber's autonomous vehicle program, building and improving capabilities of the car's perception systems.
* Implemented improvements to the car’s core deep-learning-based, multi-sensor object
detector
* Implemented visualization tools and process automation for the learning pipeline
* As an intern in summer 2017, I implemented an experimental lidar-based object detection model


#### Tableau, Summer 2016
I worked with Tableau's research team in Palo Alto on Evizeon, Tableau's experimental natual langauge interface for data visualization.
* Implemented a model to predict the semantic similarity of short English phrases
* Co-authored [Applying Pragmatics Principles for Interaction with Visual Analytics](https://ieeexplore.ieee.org/document/8019833)
    * Published in IEEE Transactions on Visualization and Computer Graphics

### Selected Projects
* Deep learning
    * [Researched prediction of hurricane damage using deep learning](https://csweb.rice.edu/news/students-showcase-projects-annual-rice-undergraduate-research-symposium)
        * Used LIDAR terrain maps and convolutional neural networks to evaluate individual homes’ probability of being damaged under given hurricane wind conditions
        * Created a model which improves substantially (+.3 AUC) on the state of the art for single home level damage probability estimation
    * [Researched learning dictionary definitions from raw text](https://ijdykeman.github.io/ml/2017/05/12/vae-definition-generator.html)
        * Implemented a variational autoencoder with novel output modality of raw embedding vectors to write dictionary-style definitions of unseen words
        * The model produces definitions for words it has only seen in context, such as "smuggling: transferring in illicit items (especially food goods)"
* Computer vision
    * For PrepMatters, a test-prep company, I built a system for extracting data from user-provided document images.  This let them score multiple-choice tests remotely without relying on expensive Scantron machines or expensive Scantron-provided answer sheets.
    * For Augary, LLC, I trained a random forest-based detector for cars and road signs on a mobile phone platform.  I also built a lane detector for estimating how well-centered in the lane the driver is.
* Graphics
    * [Generate Worlds](http://generateworlds.com/)
        * An interactive world generator based on an [accelerated](https://ijdykeman.github.io/procedural_generation/2019/11/08/generate-worlds-algorithm.html) constraint-solving algorithm.
        * Includes a custom deferred shading pipeline with shadow-mapped point lights
    * [Brimming Sea](http://brimmingsea.com/)
        * Built with a custom engine.
    * For Augary, LLC, I adapted expensive geometric routines to the GPU for mobile applications.

### Education

#### Rice University, BS in Computer Science
* [Researched prediction of hurricane damage using deep learning](https://csweb.rice.edu/news/students-showcase-projects-annual-rice-undergraduate-research-symposium)
    * Used LIDAR terrain maps and convolutional neural networks to evaluate individual homes’ probability of being damaged under given hurricane wind conditions
    * Created a model which improves substantially (+.3 AUC) on the state of the art for single home level damage probability estimation
* [Researched learning dictionary definitions from raw text](https://ijdykeman.github.io/ml/2017/05/12/vae-definition-generator.html)
    * Implemented a variational autoencoder with novel output modality of raw embedding vectors to write dictionary-style definitions of unseen words

