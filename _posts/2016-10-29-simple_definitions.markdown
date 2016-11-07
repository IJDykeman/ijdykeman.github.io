---
layout: post
title:  "Producing Simple Definitions from Word Vectors"
date:   2016-10-29 22:25:30 -0500
categories: ml
---

![Simple network diagram]({{ site.url }}/assets/turnip_net.png)




Word embeddings are a great way to represent words for NLP tasks, but the vectors themselves are hard to directly interpret.  One way to see what kind of concept a word vector represents is to look for similar vectors in the embedding space.   For example, the word “ostrich” is most similar to chicken.  The next most similar word is “elephant,” followed by “pig”, “giraffe”, and finally “ratite,” which is a term for a group of species of flightless birds to which the ostrich belongs.  It’s not clear from this information how much the word embedding space “understands” about the ostrich.  It’s true that chickens are also birds, and it’s promising that “ratite” appears on the list, but “elephant” and “pig” are both above it.  It’s clearly recorded the fact that an Ostrich is an animal, but how detailed is the word embedding’s idea of what an ostrich is?

If you wanted to determine whether a person understood the meaning of a word, you might ask them to define it.  Let’s apply the same intuition here, and train a model to produce definitions of words in its vocabulary.  For this early experiment, I’ll limit the definitions to a simple form: a single adjective followed by a single noun.  For example, “flightless bird” might be a good definition for ostrich.

## gathering data

We need a large set of definitions examples of the form (adjective, noun).  Many dictionary definitions are of the form “adjective adjective hypernym ... “ where the hypernym is a category of which the word to define is an example.  For instance,

> ostrich (noun) a flightless swift-running African bird with a long neck, long legs, and two toes on each foot.

So we have that an ostrich is a type of bird that is flightless, swift-running, and African.  I’ll consider “flightless bird,” “swift-running bird,” and “African bird” to all be acceptable definitions for ostrich.

To extract these definitions automatically, I use hypernyms from wordnet and part of speech tagging and take all the adjectives up to the first occurrence of a hypernym of the word being defined, and treat each (adjective, hypernym) pair as an example of a valid definition for that word.

This is a pretty simple approach, and it tends to pick up low quality definitions like “certain bird,” if the original defintion was “a certain tropical bird...” To mitigate this, I made a small list of disallowed adjectives, like “certain,” “such,” and “several.”

I also need the word vectors themselves.  I’m using both the vectors and the dictionary corpus from [this paper by Hill et. al.](http://www.aclweb.org/anthology/Q16-1002), which was a big factor in inspiring me to do this work, in addition to a good source of data.  You can get their data [here](http://www.cl.cam.ac.uk/~fh295/dicteval.html).


## a multicolumn perceptron

Since I’m predicting a fixed length response from fixed length input, and there’s no expectation of spatial structure in the input vectors, I’ll simply use a deep, fully connected architecture.  I experimented with different numbers and widths of layers, and found that two 500 unit hidden layers works well.

I noticed that as I varied the number of layers, different sets examples from the validation data would work.  I wondered if perhaps more depth was helpful for some examples but not others.  In that case, it might help to have a network with subnetworks of various depth.  I used three columns of layers, one with 2 200 node layers, one with 3 100 node layers, and one with 4 100 node layers.  This model provided the best performance I managed over the course of the project.  

Some work has been done with multicolumn deep convolutional neural networks, but a cursory search of the literature didn't turn anything up about multicolumn fully connected networks, so I can’t provide references to attest to the qualities of this architecture in general.

I’ll train it using the Adam optimizer with a decaying learning rate starting at .0005.  The loss function I’m using is 

$$L = (1-cos(a, a’))^2 + (1-cos(n, n’))^2 + L2$$

Where a and a’ are the predicted and correct adjective vector respectively, and the same for n and n’.  Cos is the cosine similarity between two vectors.  L2 is the L2 regularization  term.

## ensemble method for filtering generated definitions

Even with the mutlicolumn architecture, there’s still some noise in the generated definitions.  Training the same model multiple times produces models that succeed or fail on different examples.  If I could create an ensemble and then aggregate their predictions in some way, I might end up with a more robust system.  The problem is choosing which model's prediction to use.

To convert a model's predicted vector to readable text, I find the nearest word vector to the prediction.  I noticed that the cosine distance between the predicted vectors and the nearest word vectors is negatively correlated with the quality of the prediction.  So if the distance between the prediction and the nearest word is high, the quality of the prediction is low, I’ll just gather predictions from a number of different models and take the prediction with the lowest cosine distances to the nearest words in the vocabulary.  This made the system's results much more reliable.


## results

I'm happy with the model's performance on the validation set.  Here are some hand-picked examples:

* romanticism: philosophical movement
* breakthrough: spectacular performance
* intrigue: illegal subtlety
* stockade: large building
* cantaloupe: common fruit
* philosopher: intellectual person
* d: old symbol
* salsa: colorful music
* flamenco: strong music
* buttock: small end
* sensualism: religious carnality
* graduation: successful completion
* phi: greek letter
* ship: large vessel
* canoe: small boat
* dumpling: small food
* analysis: literary writing
* computer: electronic device
* algebra: formal mathematics
* beat: regular motion
* beet: swollen vegetable
* turnip: red vegetable
* skewer: small blade


The result I liked the most while I was working on this model was the definitions of tracery.  Tracery is the flower-inspired stone openwork sometimes found on Gothic windows.  The model described it as "botanical building."  Though the final ensemble model predicts the more correct "decorative structure," this clearly shows that information about the symbolic, sensory quality of tracery is present in its word vector.

![Tracery]({{ site.url }}/assets/tracery.jpg)
*The tracery in the east window of Christ Church Cathedral in Fredericton New Brunswick*


## future work

I think these results could be greatly improved by collecting more data.  The set of examples I have is only about 50,000 strong.  

Only a fraction of definitions in the corpus are of the form I mentioned above.  It may be that some words’ hypernyms never show up in their definitions.  It might make sense to use hypernyms from wordnet even without corresponding adjectives.  This could help optimize the part of the network that determines hypernyms by having a separate loss function that only measures error on the noun prediction.

The other obvious next step is to try to produce arbitrary dictionary definitions from a word.  By limiting the form of definitions I use to (adjective, noun), I greatly reduce the amount of useful information I can extract from a dictionary.  The definition corpus used for the paper by Hill et. al. has 800,000 examples.  Perhaps this could be used to train a recurrent model to predict a full definition from a word vector.

I have not addressed the question of polysemy in my data.  Many words have multiple meanings, and so at training time, the network is seeing conflicting definitions for a given word.  One could remove definitions for non-dominant word senses, but word vectors are known to contain information about multiple senses of the word they represent, so there may be a way of creating reasonable definitions that cover various senses.  I plan to explore this.



### random examples from the validation set
* rabbi: religious person
* manometer: mechanical instrument
* barb: thick piece
* ligature: plural letter
* sardine: small fish
* gradient: vertical motion
* croton: unusual jawfish
* stick: heavy strap
* picumnus: atypical subfamily
* peritoneum: thin structure
* carton: small container
* military: military state
* legume: large plant
* homegirl: female woman
* brownie: small milk
* iroquois: western indian
* reception: official creation
* mullet: short hair
* subsystem: ventral device
* fence: narrow barrier
* vagrancy: political state
* medina: small tree
* titter: high sound
* limb: high strength
* auricle: small part
* bait: large device
* cree: american indian
* townsman: native inhabitant
* annelid: small organism
* bantamweight: professional boxer
* alkali: similar compound
* bandanna: small coat
* blitz: violent event
* galleon: narrow vessel
* ottoman: french inhabitant
* spelling: formal act
* smash: strong buzz
* surcharge: military fee
* soleus: large muscle
* lycosa: large subfamily
* rheostat: electrical instrument
* hunger: extreme fear
* pia: hard piece
* crappie: small fish
* period: definite time
* border: perceptible passage
* dialect: particular word
* tracery: decorative structure
* crypt: deep building
* macrophage: low tree
* factoid: revelatory essay
* hysteroscopy: medical instrument
* lungi: south fabric
* technocrat: sophisticated person
* hypocrisy: false dishonesty
* halfback: american position
* bird: old bird
* deflagration: violent explosion
* cleft: small rock
* node: large unit
* electrocution: mental destruction
* ripsaw: small car
* ladin: western german
* gravity: physical movement
* corticosteroid: synthetic antibiotic
* sentimentality: repetitive sentimentality
* amplitude: large quantity
* magneto: small bird
* medic: medical person
* real: ultimate structure
* tub: large vessel
* temperament: intrinsic person
* straight: curved part
* usurer: obnoxious person
* lindane: synthetic analgesic
* tarpan: native cattle
* dorsum: second direction
* anarchy: political state
* colony: legal district
* gulch: large hole
* profundity: splendid quality
* ovenbird: small bird
* sauerkraut: french pasta
* neritidae: morphological family
* micrococcus: red subfamily
* benelux: musical movement
* hymenoptera: phylogenetic order
* storminess: high weather
* predator: carnivorous animal
* cardboard: thin fabric
* clam: small crustacean
* street: large area
* coast: coarse boundary
* kris: bright leaf
* update: informal procedure
* lift: minimal motion
* treason: strong punishment
* impromptu: traditional music
* nu: official letter
* territorial: real person
* sidestep: astonishing return
* instability: strong state
* sapsucker: small bird
* vaccinia: large infection
* neurologist: medical doctor
* lollipop: small case
* prednisolone: quinoline antibiotic
* footnote: small part
* nystatin: generic antibiotic
* newsletter: short book
* postage: french coin
* servitude: brutal loyalty
* odynophagia: extraordinary symptom
* associationism: political doctrine
* montrachet: white wine
* stanchion: small device
* public: informal person
* stream: strong region
* peat: low rock
* lathi: english knife
