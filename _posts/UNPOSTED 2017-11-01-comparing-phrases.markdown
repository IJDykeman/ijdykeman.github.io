---
layout: post
title:  "Measuring the Similarity between Short English Phrases using Recurrent Neural Networks"
date:   2017-11-01 22:25:30 -0500
categories: ml
---


In this post, I will describe an algorithm I created while interning at Tableau for measuring the similarity of short English phrases.  This algorithm is used in the natural language interface described in our paper [Applying Pragmatics Principles for Interaction with Visual Analytics](https://research.tableau.com/sites/default/files/VAST2017_105.pdf).

My group at Tableau was working on building a system called Evizeon, which is natural language interface that takes in English queries and produces vizualizations to answer the questions.  Say the user is examining a data set of pieces of real estate which contains information about location, neighborhood, square footage, price, and more.  The user might ask for the "most expensive houses in Queen Anne," where Queen Anne is a neighborhood.  The system must now figure out that "expensive" refers to price, and a high price in particular.  The system must also infer that Queen Anne refers to the neighborhood the house is in.  In the end, we would like the system to display the houses with the highest prices in the Queen Anne neighborhood.  Our system is able to correctly answer this query.


![expensive houses in Eviza](/assets/phrase_similarity_figures/most_expensive.png)

My contribution to this project was the algorithm that matches short phrases to data columns.  In the case above, my system matches "expensive" to the price attribute and determines that the user wants the highest prices.