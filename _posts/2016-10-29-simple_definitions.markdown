---
layout: post
title:  "Producing Simple Definitions from Word Vectors"
date:   2016-10-29 22:25:30 -0500
categories: ml
---

![Simple network diagram]({{ site.url }}/assets/turnip_net.png)

I’ve trained a neural network to take a word vector and predict a two word definition for the word it encodes.  For instance, the network predicts “red vegetable” as the definition of “turnip.”

## introduction

Word embeddings are a great way to represent words for NLP tasks, but the vectors themselves are hard to directly interpret.  One way to see what kind of concept a word vector represents is to look for similar vectors in the embedding space.   For example, the word “ostrich” is most similar to chicken.  The next most similar word is “elephant,” followed by “pig”, “giraffe”, and finally “ratite,” which is a term for a group of species of flightless birds to which the ostrich belongs.  It’s not clear from this information how much the word embedding space “understands” about the ostrich.  It’s true that chickens are also birds, and it’s promising that “ratite” appears on the list, but “elephant” and “pig” are both above it.  It’s clearly recorded the fact that an Ostrich is an animal, but how detailed is the word embedding’s idea of what an ostrich is?

If you wanted to determine whether a person understood the meaning of a word, you might ask them to define it.  Let’s apply the same intuition here, and train a model to produce definitions of words in its vocabulary.  For this early experiment, I’ll limit the definitions to a simple form: a single adjective followed by a single noun.  For example, “flightless bird” might be a good definition for ostrich.

## gathering data

We need a large set of definitions examples of the form (adjective, noun).  Many dictionary definitions are of the form “adjective adjective hypernym ... “ where the hypernym is a category of which the word to define is an example.  For instance,

> ostrich (noun) a flightless swift-running African bird with a long neck, long legs, and two toes on each foot. It is the largest living bird, with males reaching an average height of 8 feet (2.5 m).

So we have that an ostrich is a type of bird that is flightless, swift-running, and African.  I’ll consider “flightless bird,” “swift-running bird,” and “African bird” to all be acceptable definitions for ostrich.

To extract these definitions automatically, I use hypernyms from wordnet.  I use part of speech tagging and take all the adjectives up to the first occurrence of a hypernym of the word being defined, and treat each (adjective, hypernym) pair as an example of a valid definition for that word.

This is a pretty simple approach, and it tends to pick up low quality definitions like “certain bird,” if the original defintion was “a certain tropical bird...” To mitigate this, I made a small list of disallowed adjectives, like “certain,” “such,” and “several.”

I also need the word vectors themselves.  I’m using both the vectors and the dictionary corpus from [this paper by Hill et. al.](http://www.aclweb.org/anthology/Q16-1002), which was a big factor in inspiring me to do this work, in addition to a good source of data.  You can get their data [here](http://www.cl.cam.ac.uk/~fh295/dicteval.html).


## a multicolumn perceptron

Since I’m predicting a fixed length response from fixed length input, and there’s no expectation of repeated local structure in the input vectors, I’ll simply use a deep, fully connected architecture.  I experimented with different numbers and widths of layers, and found that two 500 unit hidden layers works well.

I noticed that as I varied the number of layers, totally different sets examples from the validation set would work.  I wondered if perhaps more depth was helpful for some examples but not others.  In that case, it might help to have a network with subnetworks of various depth.  I used three columns of layers, one with 2 200 node layers, one with 3 100 node layers, and one with 4 100 node layers.  This model provided the best performance I managed over the course of the project.  

Some work has been done with multicolumn deep convolutional neural networks, but my cursory search of the literature didn't turn anything up about multicolumn fully connected networks, so I can’t provide references to attest to the qualities of this architecture in general.

I’ll train it using the Adam optimizer with a decaying learning rate starting at .001.  The loss function I’m using is 

$$L = cos(a, a’)^2 + cos(n, n’)^2$$

Where a and a’ are the predicted and correct adjective vector respectively, and the same for n and n’.  Cos is the cosine distance between two vectors.

## ensemble method for filtering generated definitions

Even with the mutlicolumn architecture, there’s still some noise in the generated definitions.  Training the same model multiple times produces models that succeed or fail on different examples.  If I could create an ensemble and then aggregate their predictions in some way, I might end up with a more robust system.  The problem is choosing which prediction to use.  One method would be simply averaging the predictions of all the models, but what if there were some way of evaluating each individual prediction and picking the best?

When a model makes a prediction, it predicts a vector in word space.  To convert this to readable text, I find the nearest word vector to the prediction.  I noticed that the distance between the predicted vectors and the nearest work vectors is negatively correlated with the quality of the prediction.

So if it seems that in cases where the distance between the prediction and the nearest word is high, the quality of the prediction is low, I’ll just gather predictions from a number of different models and take the prediction with the lowest cosine distances to the nearest words in the vocabulary.  This had a large positive effect on the quality of definitions produced.


## results

I’m pleased with the enseble model’s performance on the validation set.  My favorite is the definition of tracery as "botanical building."  Tracery is the flower-inspired stone openwork sometimes found on Gothic windows.


![Tracery]({{ site.url }}/assets/tracery.jpg)


Here are some other nice examples:

* romanticism: philosophical movement
* breakthrough: spectacular performance
* intrigue: illegal subtlety
* stockade: large building
* cantaloupe: common fruit
* philosopher: intellectual person
* d: old symbol
* soleus: strong muscle
* salsa: colorful music
* flamenco: strong music
* revenant: military spirit
* buttock: small end
* sensualism: religious carnality
* graduation: successful completion
* phi: greek letter
* ship: large vessel
* canoe: small boat
* galleon: large vessel
* dumpling: small food
* analysis: literary writing
* computer: electronic device
* algebra: formal mathematics
* beat: regular motion
* beet: swollen vegetable
* turnip: red vegetable
* stream: small fluidity
* tarpan: european horse
* update: forceful installation 
* predator: carnivorous animal
* sentimentality: dull philosophy
* skewer: small blade


## future work

I think these results could be greatly improved by collecting more data.  The set of examples I have is only about 50,000 strong.  

Only a fraction of definitions in the corpus are of the form I mentioned above.  It may be that some words’ hypernyms never show up in their definitions.  It might make sense to use hypernyms from wordnet even without corresponding adjectives.  This could help optimize the part of the network that determines hypernyms by having a separate loss function that only measures error on the noun prediction.

The other obvious next step is to try to produce arbitrary dictionary definitions from a word.  By limiting the form of definitions I use to (adjective, noun), I greatly reduce the amount of useful information I can extract from a dictionary.  The definition corpus used for the paper by Hill et. al. has 800,000 examples.  Perhaps this could be used to train a recurrent model to predict a full definition from a word vector.

I have not addressed the question of polysemy in my data.  Many words have multiple meanings, and so at training time, the network is seeing conflicting definitions for a given word.  One could remove definitions for non-dominant word senses, but word vectors are known to contain information about multiple senses of the word they represent, so there may be a way of creating reasonable definitions that cover various senses.  I plan to explore this.



### random examples from the validation set
* rabbi: american clergyman
* manometer: vertical device
* barb: small scrape 
* ligature: archness procedure 
* sardine: american fish 
* gradient: strong way 
* croton: small tree 
* stick: strong device 
* picumnus: atypical subfamily 
* peritoneum: thin membrane 
* carton: small bag 
* military: military priest 
* legume: small fruit 
* homegirl: male woman 
* brownie: large bread 
* iroquois: american indian
* reception: common arrangement 
* mullet: thin creature 
* subsystem: traditional device 
* fence: vertical structure 
* vagrancy: casual woman 
* medina: thin fabric 
* titter: nasty utterance 
* limb: small structure 
* auricle: small procedure 
* bait: powerful device 
* cree: american indian
* townsman: female person 
* annelid: phylogenetic organism
* bantamweight: professional boxer 
* alkali: oily mineral 
* bandanna: small scar
* blitz: sudden anger 
* galleon: large vessel 
* ottoman: western chinese 
* spelling: strong policy 
* smash: powerful sound 
* surcharge: special device 
* soleus: large muscle 
* lycosa: usual subfamily 
* rheostat: electrical device 
* hunger: extreme hatred 
* pia: political herb
* crappie: american fish 
* period: indefinite time 
* border: large room 
* dialect: poetic english 
* tracery: foliated flower 
* crypt: small room 
* macrophage: small leukocyte 
* factoid: short decameron 
* hysteroscopy: medical instrument 
