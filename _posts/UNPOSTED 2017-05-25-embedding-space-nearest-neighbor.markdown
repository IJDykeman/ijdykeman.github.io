---
layout: post
title:  "Efficient Nearest Neighbor Search Among Word Vectors"
date:   2017-05-22
categories: ml
---

# Given a vector in an embedding space, how do I quickly find the nearest vector in that space by cosine distance?

Say you have a language generation model which gives its output words in the form of word vectors rather than as discrete distributions over a vocabulary.  With a discrete distribution, the model predicts a probability of each word in the vocabulary appearing at each time step.  One can simply take the most likely word at each time step directly from this representation.  If instead the model predicts vectors in the embedding space as its output, each of those vectors must be converted into an English word by looking up the nearest known word in the embedding space to that predicted vector.  This means taking the nearest neighbor in the space to your predicted vector by cosine distance.  I couldn’t find mention of this particular problem online, so I’ll describe my own solution here, and hopefully anyone else with the same problem can save some time.

This is a classic high dimensional nearest neighbor search problem, but with a twist: we’re using cosine distance rather than Euclidean distance.  Lots of algorithms exist which efficiently search for nearest neighbors by Euclidean distance.  In order to take advantage of these, we can project all the word vectors in the embedding space space onto the unit sphere.   This way, the nearest neighbor to our query vector by cosine distance will also be the nearest neighbor by Euclidean distance.  A simple KD tree based approach now yields a X-times speedup.

The second improvement is to use ball trees rather than KD-trees.  Ball trees perform better than KD trees in high (> 20) dimensions.  This yields our final X-times speedup.

In short, the algorithm is:
* Normalize all the vectors in your embedding space to be of equal length.
* Create a ball tree containing those vectors.
* Use the ball tree to find the nearest neighbor(s) to your query vector.

# Evaluation Details

The X-times speedup I reference above is with an embedding space containing N K-dimensional elements.  I use the Scipy implementation of KD and ball trees (LINK).  A Jupyter notebook containing my implementation and timings can be found HERE.
