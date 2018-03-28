---
layout: post
title:  "Visualizing a Very Simple Embedding Space"
date:   2017-03-01
categories: ml
---

# What Do Word Embedding Spaces Look Like?


Visualizing word embedding spaces is difficult, since they are so high dimensional.  Techniques for dimensionality reduction like TSNE give us a chance to see which words are close together in the embedding space and which are far apart.  However, these visualizations erase much of the information present in the full embedding.  They also make it unclear why the cosine distance between two word vectors is a useful metric for measuring similarity between words in the space.

If the embedding space were low dimensional to begin with, we could visualize it directly without going through a dimensionality reduction step.  A 2D embedding space would make this easy.  Embedding something as complex as an english vocabulary into a low dimensional space wouldn’t be natural, but embedding something simpler, like individual letters, in a low dimensional space might yield an embedding which contains substantial information about its elements and which is easy to visualize.

The word2vec algorithm creates a word embedding by examining the context in which each word appears.  It makes sense that we can learn things about characters by the characters that appear around them.  We might, for instance, expect to see differentiation between consonants and vowels.

To create an embedding space for characters, I’ll just use a standard word embedding algorithm, but feed it sequences of individual characters rather than sequences of words.  I'll ignore letter case by making all letters in the training set lowercase.  I'll also remove non-letter characters from the training data.  I’ll have the system create a 2-dimensional embedding space.  Here is that space:

IMAGE OF CHAR2VEC

The first thing you’ll notice is that the characters are arranged in a ring around the origin.  This is a nice example of why cosine similarity between word vectors makes sense as a distance metric.  Note that one part of the ring is devoted to consonants, and another to vowels.  Y, sometimes a vowel, comes in between.  

<!-- If we embed this using TSNE, we see a visualization of the style we saw for word vectors above.  Problem is, we can't embed in 2 dimensions because that would just give us the same points we put in.   We can, however, embed to one dimension.  

1D EMBEDDING IMAGE

Vowels are still clustered, but there isn't the same circular structure.  So we've preserved some information about letter similarity, but destroyed the structure that lets us use cosine distance to measure that similarity.  This same thing happens when you visualize a 500 dimensional embedding space in 2 dimensions. -->

I think this directly visualizable example of an embedding space is enlightening.  It can provide at least some intuition about the way word embedding spaces are structured in higher dimensions.  In particular, you may notice that the embedding does not take advantage of all the space on the ring.  It leaves large regions blank.  If you have a model that is predicting a sequence of character vectors, and it predicts a vector in that empty region, you may be suspicious that that prediction is less likely to be correct than one that falls in a dense region of the embedding space.  This intuition seems to be borne out by at least one example of behavior like this in a real word embedding space.  When I built a model for {predicting simple definitions from word vectors}[http://ijdykeman.github.io/ml/2016/10/30/simple_definitions.html] I noticed that the higher the cosine distance from a predicted word vector to the nearest vector in the word vector corpus, the more likely that nearest word was to be nonsensical.  With this simple character embedding in mind, this makes sense.  Predicting a word in a low density region of the embedding space is an issue because the vectors at the borders of that region aren’t necessarily closely related.


# Code

This experiment was easy to do by modifying the input pipeline of an off-the-shelf word2vec implementation to split on each character rather than on complete words.  The code is  [here](PUT A LINK TO THE CODE).
