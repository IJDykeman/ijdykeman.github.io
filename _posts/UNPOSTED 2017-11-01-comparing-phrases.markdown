---
layout: post
title:  "Measuring the Similarity between Short English Phrases using Recurrent Neural Networks"
date:   2017-11-01 22:25:30 -0500
categories: ml
---


In this post, I will give a high level description an algorithm I created while interning at Tableau for measuring the similarity of short English phrases.  This algorithm is used in the natural language interface described in our paper [Applying Pragmatics Principles for Interaction with Visual Analytics](https://research.tableau.com/sites/default/files/VAST2017_105.pdf).

In the summer of 2016, my group at Tableau was working on building a system called Evizeon, which is natural language interface that takes in English queries and produces visualizations to answer the questions.  Say the user is examining a data set of pieces of real estate which contains information about location, neighborhood, square footage, price, and more.  The user might ask for the "most expensive houses in Queen Anne," where Queen Anne is a neighborhood.  The system must now figure out that "expensive" refers to price, and a high price in particular.  The system must also infer that Queen Anne refers to the neighborhood the house is in.  In the end, we would like the system to display the houses with the highest prices in the Queen Anne neighborhood.  Our system is able to correctly answer this query.


![expensive houses in Evizeon](/assets/phrase_similarity_figures/most_expensive.png)

My contribution to this project was the algorithm that matches short phrases to data columns.  In the case above, my system matches "expensive" to the price attribute and determines that the user wants items with the highest price.  My system is not responsible for identifying which phrases in the input need to be matched with data columns; that is handled separately.

<!-- ## Word Embedding Spaces

The next section deals with  -->

## Mapping Phrases into a Word Embedding Space

In order to take a query phrase and select the most similar data description phrase, we need some way to measure similarity between short English phrases.  Methods exist for comparing entire English documents using features like shared words.  One such method is creating a vector for each document where each position in the vector holds the number of times a certain words appears in that document.  If two documents share many words, these vectors will have a high cosine similarity.  There are many algorithms that improve upon this strategy, but this is the basic idea.  
These algorithms work well on large documents with many words, but two short phrases meaning exactly the same thing like "high price" and "expensive" will very likely have no words in common, so word counting based approaches are unlikely to work.

One possible approach to solving this problem might be to train a model to take in two phrases and immediately predict their similarity.  The difficulty of this is that it would require a large data set of groups of similar short phrases.  I know of no such data set.  Rather than training on the phrase similarity task directly, I used a domain adaptation approach where I adapted a model that embeds phrases into a word embedding space in which distance measurements are easy.  Given a vector in a word embedding space for each phrase, I will use the cosine similarity between these phrase vectors to measure the similarity between phrases.  Now I needed a way to place phrases into a word embedding space so that similar phrases end up near each other.

One model which maps word sequences to word vectors was proposed by Hill et al.  It is an RNN that takes in a dictionary definition and predicts the vector for the word that the definition corresponds to.  Using this model, two dictionary definitions with the same meaning, like "costing a lot of money" and "having a high price" should map near the same vector for "expensive."  This seems a lot like the behavior we are looking for, as long as the domain adaptation from the domain of dictionary definitions to the domain of short English phrases works well.

I implemented the Hill et al. model in Tensorflow and trained it on the data set they provide.  As a word of caution to those considering using this data themselves, there is an issue with the train/test split in the data they provide.  SAY MORE 

I found that the Hill et al. model does in fact produce reasonable embedding space vectors for short phrases as well as actual dictionary definitions.

## Ranking Phrases by Similarity to a Query

The task we are studying is not just measuring the similarity between phrases, but ranking a number of data columns in order or relevance to a query.  This means incorporating the phrase similarity measurement into some sort of ranking scheme, and hopefully also taking advantage of other information in the data column, such as words that appear in the data itself, not just in the column descriptors.  