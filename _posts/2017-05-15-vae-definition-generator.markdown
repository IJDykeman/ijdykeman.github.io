---
layout: post
title:  "Dictionary Definitions from Word Embeddings using Variational Autoencoders"
date:   2017-05-12 22:25:30 -0500
categories: ml
---


In this blog post, I’ll describe a model I built in collaboration with Angel Chang for generating dictionary definitions of word vectors.  Dense word embedding are known to capture the meaning of words in a way that is effective for many downstream NLP tasks.  However, it is difficult to observe directly what information they contain.  Word vectors can be arithmetically to solve analogy and word similarity problems, but these provide an indirect look at what meaning the embedding captures.  In particular, these tasks not reveal what use a complex model could make of these vectors.  We use the task of dictionary definition generation to measure the quality of word vectors in a way that is both closely related to the meaning captured by individual word vectors capture and can benefit from a model architecture with some understanding of language in general.  Our system is able to create plausible definitions for words that it has not seen a definition of before.

Using word embeddings as input for a complex downstream task can only tell us how well that embedding does as a representation for that task.  Our model creates a direct view of word vector contents by creating an English representation of their contents.  This is analogous to asking a person to produce a definition of a word if you want to evaluate their understanding of that word.


<!-- # Related work -->
<!-- Unnat's paper and the other definitions paper -->

# Data

We use a data set of 596,739 (*word*, *definition*) pairs compiled from various lexical resources.  Each word is paired with all definitions found in WordNet, The American Heritage Dictionary, The Collaborative International Dictionary of English, Wiktionary and Webster's Dictionary.
We perform a 85/10/5 split on the training data to obtain our final training,  validation, and test sets (see the table below for dataset statistics). We split by word so that all the definitions for a given word appear in only one of the data sets.  We only use definitions of length less than 20 to avoid a long tail of definitions which contain detailed historical or biographical information.  

|data set | words      |      definitions       |      definitions per word|
| --- | --- | --- | ---: |
|train      | 55888   | 507438 | 9.1                    |
|validation | 6575    | 58388  | 8.9                    |
|test       | 3288    | 30913  | 9.4                    |

*Data set statistics with total number of words and definitions, and average number of definitions per word.*




We use word vectors trained by [Hill et al.](http://www.aclweb.org/anthology/Q16-1002)  using word2vec to represent words as input to our models, and as target outputs when applicable.  We do not modify the embeddings during training.  This allows us to to exploit large training corpora used for those embeddings, and to increase our ability to generalize to words not present in the dictionary data.

# Approaches


We investigate models across a spectrum of size and complexity.
Our simplest model is a multilayer perceptron for generating two-word definitions, e.g. *frog: amphibious animal*.  This model produces definitions that are reliably reasonable but limited in expressiveness.  To generate more complex and diverse definitions of unspecified length, we use variational autoencoders (VAEs) with RNN encoders and decoders.  We created one sequence VAE with softmax output, and one which outputs embedding space vectors at each time step. We compare all of these models to a baseline RNN decoder architecture.



## Two word definitions

In a previous blog post, I described a model for creating two word definitions from word vectors.  I’ll review it quickly here, and compare its output to that of the more complex models later on.  


As a preliminary experiment, we generate two-word definitions of the form (*adjective*, *noun*), for example, *ostrich: flightless bird*.  As training data, we use two-word definitions extracted from our original data for this task.  To extract a two-word definition, we search the original definition for a hypernym of the word being defined, then find adjectives that appear before that hypernym.  Each one of those (*adjective*, *hypernym*) pairs forms a valid two-word definition.  For example, given the dictionary definition *ostrich: a flightless African bird with a long neck, long legs, and two toes on each foot.* we get *ostrich: flightless bird* and *ostrich: African bird* as two word definitions.  To detect hypernyms, we use WordNet, and we use NLTK to part-of-speech tag the definitions to find adjectives.



Using this data, we train a multilayer perceptron to predict an adjective and a hypernym vector for a given word.
We use as the loss function the sum of the squared cosine distances between the two predicted vectors and the vectors for the two-word definition. We take the words in our embedding space with the lowest cosine distances to the vectors the model predicts to be its output.  We use an ensemble model that sums the outputs of 10 trained models to improve the quality of definitions generated.  

In the equation below, $$J$$ is the loss function.  $$\hat x_{adj}$$ is the vector the model predicts for the adjective, $$x_{adj}$$ is the vector for the target adjective.  $$\hat x_{noun}$$ is the predicted vector for the noun, $$x_{noun}$$ is the target.  

$$
\begin{equation}
\begin{split}
J(x, \hat x) =
 &\quad \left(\frac{x_{adj}
 \cdot \hat x_{adj}}{||x_{adj}||\times||\hat x_{adj}||}\right)^2 \\
 +  &\quad \left(\frac{x_{noun}
 \cdot \hat x_{noun}}{||x_{noun}||
    \times||\hat x_{noun}||}\right)^2
\end{split}
\end{equation}
$$

In general, this model produces results that are simple but reasonable.  For instance, the model generates the definitions *storm: violent wind* and *theist: religious person* (results section for more examples).  

For instance, it comes up with the definition *technocrat: sophisticated person.*  While this may accurately reflect part of the meaning of the word, this definition certainly doesn't capture everything that the word "technocrat" expresses, namely its association with technology.  To generate more complete definitions, we use variational autoencoders that can output definitions of varying length and structure.

## Background on Variational Autoencoders
<!-- %$Q$ is encouraged to be close to some prior distribution in the latent space. --><!-- %, and the prior is $$\mathcal{N}(\vec 0, \vec 1)$$. -->
A variational autoencoder (VAE) is a form of regularized autoencoder where the encoder produces a probability distribution $$Q$$ for each sample $$x$$, and the decoder receives as input samples from that probability distribution, which it uses to reconstruct $$x$$.  The encoder and decoder are neural networks. In our case, $$Q$$ is an isotropic Guassian. Given a data sample $$x$$, the encoder produces the parameters $$\vec \mu(x)$$ and $$\vec \sigma(x)$$ of $$Q$$, so $$Q=\mathcal{N}(\vec \mu(x), \vec \sigma(x))$$.
The decoder takes a sample $$z$$ from $$Q$$ and attempts to reconstruct $$x$$, producing $$\hat x$$.  We will denote the decoder function $$decode$$, so
$$ \hat x = decode(z) ~~\text{where} ~ z \sim \mathcal{N}(\vec \mu(x), \vec \sigma(x))$$  We will train the autoencoder to minimize the reconstruction error between $$x$$ and $$\hat x$$, which we will denote $$re(x, \hat x)$$.

In order to force $$Q$$ to be close to some known distribution, we also add the Kullback-Leibler divergence between $$Q$$ and a prior distribution to the loss.  In our case, the prior is $$\mathcal{N}(\vec 0, \vec 1)$$, so $$KL(\mathcal{N}(\vec \mu(x), \vec \sigma(x)) \|\mathcal{N}(\vec 0, \vec 1))$$ is added to the loss of the autoencoder.  Having a prior on $$Q$$ will be useful for generating novel samples, as we will describe later.

We denote the loss for an example $$x$$ with $$J(x)$$.  The loss expression is

$$
\begin{equation}
\begin{split}
J(x) & = re(x, \hat x) + KL(\mathcal{N}(\vec \mu(x), \vec \sigma(x)) ~ || ~ \mathcal{N}(\vec 0, \vec 1))\\
& =re(x, decode(z)) \\
& \quad + KL(\mathcal{N}(\vec \mu(x), \vec \sigma(x)) ~ || ~ \mathcal{N}(\vec 0, \vec 1))\\
& \quad \text{where} ~ z \sim \mathcal{N}(\vec \mu(x), \vec \sigma(x)))
\end{split}
\end{equation}
$$

We now might now like to optimize the encoder decoder networks with backpropagation, but we cannot as long as there is a non-differentiable sampling operation producing $$z$$.  To alleviate this, we invoke the reparametrization trick.  The reparametrization trick involves not sampling $$z$$ from $$\mathcal{N}(\vec \mu(x), \vec \sigma(x))$$, but instead sampling $$\epsilon$$ from $$\mathcal{N}(\vec 0, \vec 1))$$ and taking $$z = \hat \sigma(x) \odot \epsilon + \hat \mu(x)$$, where $$\odot$$ is elementwise multiplication.  Our loss expression is now:

$$
\begin{equation}
\begin{split}
J(x) & =re(x, decode(\hat \sigma(x) \odot \epsilon + \hat \mu(x))) \\
& \quad + KL(\mathcal{N}(\vec \mu(x), \vec \sigma(x)) ~ || ~ \mathcal{N}(\vec 0, \vec 1))\\
& \quad \text{where} ~ \epsilon \sim \mathcal{N}(\vec 0, \vec 1))
\end{split}
\end{equation}
$$


After performing the reparametrization trick, we can train the model end-to-end using backpropagation.  

Once the model is trained, we would like to use it to generate samples similar to those in our training data.  Since we added a term in the loss to encourage $$Q$$ to be close to $$\mathcal{N}(\vec 0, \vec 1)$$, the decoder function has been trained to accept samples $$z$$ from a distribution that is close to $$\mathcal{N}(\vec 0, \vec 1)$$.  Therefore, to generate new samples, we simply feed values $$z \sim \mathcal{N}(\vec 0, \vec 1)$$ into the decoder.

We would also like the ability to condition the samples we generate on some input.  For instance, we might want to generate an image of a particualr type of object, or a definition of a particular word.  For this, we use a conditional variational autoencoder (CVAE).
<!-- \cite{sohn2015learning} -->
A CVAE is the same as a VAE except that both the encoder and the decoder take in a label $$y$$ in addition to their usual input.  

# Conditional Variational Autoencoder with Discrete Output

<!-- % To generate definitions for specific words, we use a conditional VAE (CVAE).  At training time, we feed the encoder and decoder of our model the vector of the word to be defined, and feed the decoder a vector $z$ sampled a normal distribution parametrized by the output of the encoder.
% At inference time, we feed the decoder a latent vector $z$
% sampled from a standard normal distribution
% along with a word vector, and we expect to see a reasonable definition for that unseen word. -->

To generate definitions for specific words, we use a conditional variational autoencoder with recurrent neural networks as its encoder and decoder.  This model is a conditional version of the VAE presented in [Bowman et al. 2016](https://arxiv.org/pdf/1511.06349.pdf) that outputs a discrete distribution over its vocabulary at each time step.  A single layer LSTM is used for both the encoder and decoder.  The encoder's final hidden state is passed through a linear projection to create the $$\vec \sigma$$ and $$\vec \mu$$ parameters for the Gaussian $$Q$$ in the latent space.  At each time step, the decoder's output is passed through a softmax layer.

# Conditional Variational Autoencoder with Word Vector Output

![VAE diagram](/assets/vae-definition-generation/full_pathway_drawing.svg)

*A diagram of the vector output model at training time.  The RNN on the left is the encoder, and the one on the right is the decoder.  For the vector model, we add a special STOP vector to the embedding space to indicate the end of output.  The discrete output model is the same except that instead of a nearest neighbor search on each output step, we take the argmax over the output.*


In order to exploit the representational power of word vectors as output as well as input, we created a language decoder which outputs vectors in the embedding space at each time step instead of outputting a probability distribution over the entire vocabulary.  This is a logical extension of the two-word model, which also outputs word vectors and is able to consistently capture the meanings of words in its output.  To our knowledge, this is the first language generator to use word vectors as its output representation.  As we show in the results section, this model produces definitions that are substantially better than those from the discrete output models (the CVAE with discrete output and the RNN decoder baseline model).

Like the CVAE with discrete output, this model's encoder takes in the word to be defined, and it's decoder takes in the word to be defined and a sample from the Gaussian parametrized by the encoder (see figure below).  This model model uses for its loss the sum of the cosine distances between each word in the predicted sequence $$\hat x$$ and the word at the same location in the target sequence $$x$$. In the equation below, $$J$$ is once again the loss function and $$Q=\mathcal{N}(\vec \mu(x), \vec \sigma(x)$$.


$$J(x, \hat x, Q)
= \sum_{i=1}^{|x|}
\frac{\hat x_i \cdot x_i}{||\hat x_i||~||x_i||}
+ KL(Q,~ \mathcal{N}(\vec 0, \vec 1))$$


At inference time, we feed in a latent vector $$z$$ and a word vector to be defined, and then find the nearest neighbor in the embedding space to each vector the model predicts.  That sequence of nearest neighbor words is the model's output.


# Baseline RNN Decoder Model

![RNN decoder diagram](/assets/vae-definition-generation/rnn_decoder_diagram.svg)

*A diagram of the baseline RNN decoder model.*

As a baseline, we created a simple RNN decoder architecture.  This architecture takes a word vector as input, and uses the same LSTM architecture as the discrete CVAE model decoder to predict a sequence of words for its definition.

This model sometimes produces reasonable definitions, such as *tibet: a region of the central region of the country of china* or *sterling: a surname*.  More often, it produces definitions that do not clearly express any aspect of the meaning of a word, or are extremely vague, such as *suburbs: the area of a region*.

Unlike the variational autoencoder models, this model will always produce the same definitions for a given word.  The variational autoencoders will produce different definitions depending on the value of $$z$$ which they recieve at inference time.


# Results
We present example definitions of words from the test set generated by our implementations of each of our four models, and evaluate the definition quality using BLEU against dictionary definitions and a user study.  For all our experiments, we used Tensorflow and TF.learn.  For our CVAEs, we use a latent space dimensionality of 13, the same as [Bowman et al. 2016](https://arxiv.org/pdf/1511.06349.pdf), and an LSTM size of 3000.   All models are trained using backpropagation with the Adam optimize, with the validation set used to monitor  convergence.  

## Model Output

When sampling from the vector output models, we take each vector produced and look up the nearest word by cosine distance in the embedding space.  If that word is the word we are trying to define, we instead take the next nearest neighbor.  To speed up nearest neighbor lookup during inference, we restrict the output vocabulary to the 10,000 most common words in English.  This usually does not produce different definitions from those that are decoded using the full 800,000 word embedding since words in the long tail (e.g. Twitter hashtags) are uncommon in definitions.  For discrete output models, we also ignore the word we are defining, taking the next highest scoring word instead.  We ignore words that are repeated, i.e. "the dog dog the" becomes "the dog the."  Note that we allow all models (except the two-word model) to output punctuation, including parentheses.

The table below shows examples of definitions produced by each of our models. The vector output models (vector CVAE and two-word) are most consistent about generating a definition that clearly expresses at least part of the meaning of the target word.  The vector CVAE performs especially well on words with only a single meaning, for instance, *glaucoma: the abnormal hemorrhagic disease.  Often the interocular illness.*  This is an accurate definition, since glaucoma is in fact an interocular disease that can cause hemorrhaging.

The discrete models (discrete CVAE and RNN decoder) often miss the meaning of the word completely, while still producing grammatically reasonable output, e.g. *bishop: a male given name*.
<!-- %As expected, the two-word model generates simple, reasonable definitions.  The discrete output model is more able to create correct English, whereas the vector output model expresses more detail about the word being defined. e.g. for ``neurosis,'' ``feeling excessive desire of something'' is a more grammatically correct, but less accurate definition than ``an obsessional rather aimlessness or irrational anxiety.'' -->

| word       |  vector CVAE   |  discrete CVAE   |
|---         | ---            | ---  |
|sizzling    | showing the fiery sound (in cooking)                  | made by heat                 |
|smuggling   | transferring in illicit items (especially food goods) | making or other              |
|undated     | lacking a date in manuscript)                         | existing or written          |
|Arabia      | the mediterranean country (in the africa)             | country and north region     |
|connoisseur | any discerning performer (in taste)                   | someone who is skilled       |
|bishop      | the biggest catholic priest in church                 | someone who makes or.        |
|tandoori    | the indian uncooked dish (usually in curries)         | made with meat.              |

| word        |  RNN decoder                      |  two-word  |
|---         | ---                                | --- |
|sizzling    | a very; a person                   | fiery sound|
|smuggling   | the act of  making or  taking      | illegal theft|
|undated     | not yet                            | original document|
|Arabia      | the region of southern asia        | large area|
|connoisseur | one who is a person                | energetic person|
|bishop      | a male given name                  | catholic priest|
|tandoori    | a small, a small, a small.         | small dish|


## User Study

To see if our definitions can be understood by people we selected 200 words from the test set, and 4 distractor words for each (chosen randomly, or from the 10 closest words in the embedding space).  Then, we recruited 211 Amazon Mechanical Turk workers. We showed them the target word and distractor words, along with a definition generated from one of our models, or a real definition, and asked them to select the target word among the distractors.  As the table below shows, the vector CVAE outperforms all other models.  This can be a challenging task even with real definitions and random distractors due to uncommon word senses: e.g., the definition *pebble: in australia, a hard, obstinate person; a tough; also said of animals* had distractors "brilliant", "advisor", "nuclear", and "slander", leading a worker to wrongly select "advisor".  A challenging case with similar distractors is *fearful: indicating anxiety, fear, or terror; a fearful, nervous glance* with distractors "worried", "alarmed", "apprehensive", "afraid" where the person mistakenly chose "afraid".



|model            |  random | similar |
| ----            |  ------ | ------- |
|two-word         | 63%     | 27%     |
|RNN              | 50%     | 23%     |
|discrete CVAE    | 55%     | 21%     |
|vector CVAE      | __71%__ | __30%__ |
|real definitions | 76%     | 50%     |

*Percent correct selected by users with random selection being 20% correct.*

## Quantitative Comparison with BLEU Scores

To compare our models, we use the BLEU score to measure similarity between the generated definitions and those in the dictionary (see table below).  We present the BLEU scores for the holdout set, where each definition produced by the model is compared with multiple reference definitions.
The vector CVAE model performs better than the discrete models, confirming our intuition that leveraging the vector representation as output helps with definition synthesis.


|model             | test set BLEU |
| ----             | ------------- |
|RNN decoder       | 0.5458        |
|discrete CVAE     | 0.5023        |
|vector CVAE       | __0.6319__    |


## Defining Unseen Words
We can produce definitions for words with no definition in the dictionary data we drew from.  The vector VAE definition of "Anthropologie," a "boho-chic" clothing chain is *anthropologie: an modern merchandiser to a boutique emporium.* For Voldemort, the evil wizard from Harry Potter: *voldemort: the evil one in the demon of magic in the war*.

## Limitations

The vector CVAE model produces definitions that mostly refer to a correct sense of the word.  However, it has issues with grammar, combining multiple senses in one definition, and vagueness. For example, *cannon: the gun weapon*, misses the key feature that it is large, and *rocking: having the sound and (as a swing)* confuses rocking in the sense of music (sound) and rocking in the sense of movement (swing).  A promising avenue for future work is to generate definitions in context, and to use sense embeddings to disentangle the different possible senses.
