---
layout: post
title:  "Producing Simple Definitions from Word Vectors"
date:   2016-10-29 22:25:30 -0000
categories: ml
---


I’ve trained a neural network to take a word vector a predict a two word definition for the word it encodes.  For instance, the network predicts “red vegetable” as the definitions of “turnip.”


## introduction


Word embeddings are a great way to represent words for NLP tasks, but the vectors themselves are hard to directly interpret.  One way to see what kind of concept a word vector represents is to look for similar vectors in the embedding space.  Let’s look at some examples


The word “ostrich” is most similar to chicken.  The next most similar word is “elephant,” followed by “pig”, “giraffe”, and finally “ratite,” which is a term for a group of species of flightless birds to which the ostrich belongs.  It’s not clear from this information how much the word embedding space “understands” about the Ostrich.  It’s true that chickens are also birds, and it’s promising that “ratite” appears on the list, but “elephant” and “pig” are both above it.  It’s clearly recorded the fact that an Ostrich is an animal, but how detailed is the word embedding’s “idea” of what an ostrich is?


If you wanted to determine whether a person understood the meaning of a word, you might ask them to define it.  Let’s apply the same intuition here, and train a model to produce definitions of words in its vocabulary.  For this early experiment, I’ll limit the definitions to a simple form: a single adjective followed by a single noun.  For example, “flightless bird” might be a good definition for ostrich.




## gathering data


We need a large set of definitions examples of the form (adjective, noun).  Many dictionary definitions are of the form “adjective adjective hypernym ... “ where the hypernym is a category of which the word to define is an example.  For instance,


> ostrich *noun* a flightless swift-running African bird with a long neck, long legs, and two toes on each foot. It is the largest living bird, with males reaching an average height of 8 feet (2.5 m).


So we have that an ostrich is a type of bird that is flightless, swift-running, and African.  I’ll consider “flightless bird,” “swift-running bird,” and “African bird” to all be acceptable definitions for ostrich.


To extract these definitions automatically, I use hypernyms from wordnet.  I use part of speech tagging and take all the adjectives up to the first occurrence of a hypernym of the word being defined, and treat each (adjective, hypernym) pair as an example of a valid definition for that word.


This is a pretty simple approach, so I’ve hand built a list of disallowed adjectives, like “certain,” “such,” and “several.”  This ought to reduce the chance that a definition for “grass” comes out as “such plant.”  Problems like that occured before I did this preprocessing.


## the model


Since I’m predicting a fixed length response from fixed length input, and there’s no expectation of repeated local structure in the input vectors, I’ll simply use a deep, fully connected architecture.  I experimented with the architecture some, but my original two 500 unit hidden layer, relu activated architecture gave the best results.  


I’ll train it using the Adam optimizer with a decaying learning rate starting at .001.  


## results


I’m quite pleased with the model’s performance on the validation set.  Here are some nice examples:

* roquefort: soft cheese
* skewer: small blade
* romanticism: philosophical movement
* breakthrough: spectacular performance
* intrigue: illegal subtlety
* stockade: large building
* fawn: white goat    (close enough)
* cantaloupe: common fruit
* philosopher: intellectual person
* d: old symbol
* soleus: strong muscle
* flamenco: strong music


Some examples are slightly strange


* inside: outer skin
* chartreuse: thick red
* amontillado: corruptive brandy
* indifference: good disposition
* frenchman: native inhabitant


I’m betting chartreuse maps to red because red and green are close to each other in the word embedding space, so it’s not necessarily very easy to tell from the vector for chartreuse which color it is.


## future work


I think these results could be greatly improved by collecting more data.  The set of examples I have is only about 50,000 strong.  


The other obvious next step is to try to produce arbitrary dictionary definitions from a word.  By limiting the form of definitions I use to (adjective, noun), I greatly reduce the amount of useful information I can extract from a dictionary.  The definition corpus used for BENGIO_PAPER has 800,000 examples.  Perhaps this could be used to train a recurrent model to predict a full definition from a word vector.


I have not addressed the question of polysemy in my data.  Many words have multiple meanings, and so at training time, the network may be conflicting definitions for a given word.  One could remove definitions for non-dominant word senses, but word vectors are known to contain information about multiple senses of the word they represent, so there may be a way of creating reasonable definitions that cover various senses.  I plan to explore this.














### Cute examples


* penguin: large tree
* row: continuous strip
* birthday: s anniversary
* graduation: successful completion
* phi: greek letter
* penguin: large tree
* ostrich: large bird
* sparrow: small bird
* ship: large vessel
* canoe: small boat
* dumpling: small food
* analysis: literary writing
* computer: electronic device
* algebra: formal mathematics
* beat: regular motion
* beet: swollen vegetable
* turnip: red vegetable
* hillary: general game






### random examples from the validation set


* fawn: white goat
* excuse: strong paycheck
* roquefort: soft cheese
* dulse: proteinaceous germy
* cupid: dead person
* parcheesi: thin kisser
* forepaw: large advantage
* inside: outer skin
* skewer: small blade
* romanticism: philosophical movement
* breakthrough: spectacular performance
* standdown: proper treatment
* cantaloupe: common fruit
* booster: modest person
* frenchman: native inhabitant
* argillite: prismatic rock
* amontillado: corruptive brandy
* pickerel: various fish
* cyme: small subfamily
* indifference: good disposition
* philosopher: intellectual person
* d: old symbol
* soleus: strong muscle
* crook: simple person
* flamenco: strong music
* huguenot: southern person
* courtesy: other use
* aureole: harsh art
* afghan: short indian
* germination: vigorous procedure
* australopithecine: herbivorous cynodont
* cholla: soft shrub
* cercopithecidae: botanical subfamily
* stegosaur: large archosaur
* headstock: small side
* hypochondria: high anxiety
* cirrus: small cloud
* dacha: large district
* tempest: intense disturbance
* bridesmaid: female mother
* ghrelin: partial protein
* reassignment: usual discharge
* golliwog: english person
* scum: disrespectful disorder
* supernumerary: medical supporter
* tibialis: common subfamily
* unicycle: similar machine
* heartbeat: mechanical person
* stockade: large building
* approver: verbal person
* dammar: red bark
* blain: same dessert
* hinge: small lines
* morel: soft berry
* contentment: joyful property
* crossing: massive difficulty
* malathion: particular pesticide
* antler: stupid tree
* iritis: severe inflammation
* refuge: external mechanism
* lambkin: french tree
* intrigue: illegal subtlety
* chartreuse: thick red
* diazonium: metallic compound
* keratinization: undesirable abnormality
* basil: black bayberry
* vanity: such feeling
* berm: low vehicle
* genitive: plural word
* orator: public art
* lunch: short meal
* tractor: convenient vehicle
* businesswoman: female woman
* mill: elegant tube
* shogi: several peasant
* syrian: native inhabitant
* recency: continuous sensitivity
* buttress: main barrier
* subsystem: generic sound
* trip: s journey
* cubeb: indian shrub
* aggregate: other number
* counterfeit: similar criminal
* fisher: vicious person
* cert: engraving symbol
* platypus: several knife
* vanillin: synthetic glycoside
* handmaid: male woman
* anomaly: slight aspect
* balmoral: ornamental tree
* garter: large order
* mackinaw: single salmon
* pouch: tight part
* herald: spiritual weapon
* ectrodactyly: single abnormality
* beads: similar fusion
* botfly: frequent subfamily
* detraction: troublesome structure
* fury: strong anger
* oriolus: type subfamily
* stroke: physical manifestation
* liveliness: pragmatic importance
* fracture: special change
* perpetuity: judicious generosity
* sucker: shallow bivalve
* improvisation: poetic movement
* phlegm: incredible liquid
* cataract: dramatic outflow
* botany: agricultural medicine
* dink: small rifle
* font: narrow image
* bolster: old implement
* poltergeist: american location
* misgovernment: improper ruthlessness
* mainstream: such philosophy
* infection: messy infection
* pellet: single structure
* slider: vertical lines
* catena: unmusical instrument
* radiation: bodily substance
* urbanity: obvious respect
* marquetry: decorative decoration


