---
layout: post
title:  "Capturing Word Meaning and Cultural Association with a Character Level Model"
date:   2017-01-02 22:25:30 -0500
categories: ml
---

# Motivation and Introduction

In fiction, names are often designed to convey some suggestion of what a character might be like.  A clear example might be the name Voldemort, which to me sounds evil, and contains the “mort” subword, which is also in death-related words like mortal and mortuary.  Other names from fiction like Mordor, Sauron, Severus Snape, or Gothmog are meant to heighten the sense of the character’s evil.  Names like Dumbledore or Bilbo Baggins might instead suggest friendliness.  These types of associations are intentional on the part of the author, and can be reliably picked up by the reader.  Word embeddings are a powerful technique for representing word meaning, but these cues are lost on them since they generally represent all rare words with a single token, and since strange or creative names tend to be rare words, perhaps only appearing in a single document, they are ignored by these models.

I’d like to use a recurrent neural network operating on characters to place these types of words into an embedding space.  Then, using comparisons between words in that space, I’m hoping to see what kinds of aesthetic or emotional cues a word carries.  The model ends up being able to pick up some of this type of information, as well as other information, such as whether a word is a chemical, disease, or drug name, or whether it is a name of a person, and if so, where and when they might have lived.

In this post, I’ll describe a model that takes the letters that make up a word and predicts the associated word vector.


# Code

I implemented this model in Tensorflow.  You can find the code in a Jupyter notebook [here](https://github.com/IJDykeman/CharacterMeaningModel).

# The model

![model diagram](/assets/chars-to-vec_figures/chars2vec.svg)

I’ll represent the letters as one-hot vectors.  The recurrent neural net receives these vectors as input and then feeds into two fully connected layers.  I found that adding dropout after the last LSTM output reduced overfitting.  Following the intuition presented in [this paper](https://papers.nips.cc/paper/5346-sequence-to-sequence-learning-with-neural-networks.pdf), I reverse the order of the letters as I feed them into the RNN, though that isn’t reflected in the diagram above.  By reversing the letters as they are fed in, the PAD tokens are not the last ones the LSTM sees before its final state is created.  Instead, it sees the actual input data last, so there are fewer long term dependencies to handle at training time.  I represent the words in the model’s vocabulary using word vectors trained by the authors of [Learning to Understand Phrases by Embedding the Dictionary](https://arxiv.org/pdf/1504.00548v4.pdf).


In the diagram, 〈Chilperic〉 is meant to represent the word vector associated with the word “Chilperic.”  The ≈ symbol indicates that the output of the final layer of the model has a low cosine distance to 〈Chilperic〉.  When the model makes a prediction, it outputs a vector, then looks up the word vectors closest to its output.  These nearest neighbors are the model’s opinion on what words are similar to its input.


## Where it Works and where it Doesn’t

As expected, this model performs well on morphologically rich words, that is, words whose meaning is closely related to the meanings of subwords.  A common source of these types of words is medical terminology.  For instance, “tendinitis” is a swelling of the tendons.  The suffix “itis” indicates that this word describes a [swelling disease](https://en.wiktionary.org/wiki/-itis#Suffix).  The prefix “tendin” obviously indicates that it is a disease that affects tendons.  The model consistently identifies disease names with other disease names already present in the word vector corpus.  

The model associates the made-up disease name “sternumitis” to other diseases: paraparesis, scleritis, and radiculopathy.  I found a fake [drug name generator](http://www.generatorland.com/glgenerator.aspx?id=55#) online, and the words it produces are consistently associated by the model to real drugs.  For instance, the fake name Glazioxx is mapped to Lescol, idarubicin, and Sandimmune.

Some words aren’t so morphologically rich.  The word “cat” can’t be broken down into parts that indicate the meaning of the whole word.  As expected, the model performs poorly in guessing words similar to these.


## Predicting Attributes from Fictional Names

I think “Zorgon” is a sinister sounding name.  Given “Zorgon,” which is not present in the word embedding I used, the system predicts that Arthas, Beastman, and Gorath are similar words.  These are names of fictional characters who all look like they could all plausibly be named “Zorgon.”

![zorgon characters](/assets/chars-to-vec_figures/zorgon_characters.svg)

Unfortunately, it’s a bit harder to find names of characters that sound particularly like names of good people.  In the Harry Potter books, which tend to take liberties with naming, morally upstanding characters tend to simply have common names: Harry, Ron, Molly, Albus, James, or Ginny.  I’ll take Dobby and Dumbledore as examples of good-sounding names of good characters.  The model associates these both to cute names like “Sweatpea,” or “Stompy,” which is the name of a cartoon baby elephant.  While these associations don’t quite capture the gravity Dumbledore is meant to have, they convey at least a positive connotation.

Galadriel, a sorceress in Lord of the Rings who rules an enchanted forest, is associated most strongly with with Balor, an Irish mythical king of supernatural beings, and Melisandre, the sorceress from A Song of Ice and Fire.


If you hear of a company called Iteron and one called Dromgoole’s, you would likely make different assumptions about the type of business each one is.  In particular, Iteron sounds more like a tech company, while Dromgoole’s sounds like it’s trying to be associated with a more traditional aesthetic.  The model agrees with this intuition.  “Iteron” is associated with Aricent, Vixs, Cloudera, and Idirect.  These are all real companies whose businesses have to do with software, satellite communications, and semiconductors.  The name Iteron is the name of a spaceship from the game Eve Online, so I think this association with technology is very reasonable.

The model associates “Dromgoole’s” most strongly with “Theobalds” which is the name of an estate in england that was a royal palace in the 16th and 17th centuries.  It also associates the name “Trelissick,” which is an english garden.  Other strongly associated terms are also names of English towns and gardens.  Dromgoole’s is the name of a high-end fountain pen shop, so it’s likely that this is just the type of aesthetic that name was designed to evoke.



# Separating Coincidental Association from Similarity

The word “beowulf” is in the word embedding space I used.  If I simply look up nearby words, I get names of characters from the poem Beowulf, like Grendel, Hrothgar, and Unferth.  It is also associated with other epic poems, The Iliad, The Nibelungenlied, and The Kalevala.  These are reasonable associations if you want to know about Beowulf the poem, but this doesn’t capture the idea of who Beowulf himself is.

The model associates the characters “Beowulf” with names of Northern European kings who lived in the 6th century, which is when the events of Beowulf are supposed to have taken place.  The top 9 matches are Chilperic, Theudebert, Fredegund, Audoin, Chlothar, Theodahad, Vratislaus, Gundobad, and Thurisind, all 6th century monarchs living around the area where Beowulf is set.

The model has managed to extract likely information about Beowulf the person from his name, which may be of practical interest when the vector for Beowulf is most strongly  associated with the eponymous poem.  The original association captures the fact that Grendel and Beowulf are often mentioned together, but one is a king, and the other is a man-eating monster.  The model makes an association that captures the type of person Beowulf is.  

The model behaves the same way when given the name “Gawain,” who is a character from a poem set in Arthurian England.  The vector for “Gawain” is close to those of other characters in the poem, while the model associates the name “Gawain” with Irish names like “Domhnall,” “Conchobar”, and “Conall.”

The model is also able to reliably associate the names of real monarchs to other monarchs in their region or from their culture, but that’s a less impressive feat, since the word vectors for those names are likely to already be associated with other monarchs related to them, since there usually aren’t confounding factors like poems named after those people.

In the examples of fictional character names above, the word vectors for the names themselves were always closest to names of other characters from the same stories, while the model picked out different types of associations, like matching Galadriel with other magical fantasy characters.

# Conclusion

This model is able to pick up subtle associations like name styles from a certain culture and time period.  It’s also able to associate evil sounding names with evil characters and make other, more subtle associations, like matching a magical sounding name to other magical characters, as in the Galadriel example.  The model uses no labeled data.  Its only data source is the raw text used to train the word embedding this model is trained on.  As far as I know, this is the first work toward building a model for associating fictional characters to each other based on their names.  


# Future work


The stated goal here was to extract “emotional or aesthetic cues” from a character sequence.  This has been achieved only partially, since the model isn’t able to say that it believes a name sounds evil.  It can only present other words that it thinks are similar to the input.  If we gave it an evil sounding name and it returns other evil sounding names, that’s a kind of success, but it’s not explicit extraction of the belief that the name sounds evil.  A dataset with fictional names labeled by moral alignment of the characters or other attributes of interest could serve as supervision for this task.  A model like the one described here could perhaps be used for that task.

I also don’t have a way of quantifying the quality of the model’s predictions about fictional names.  Associating things like company names with certain cultures, like the Dromgoole’s example, relies on a highly subjective judgement that “Dromgoole’s” sounds like the kind of place a British aristocrat might like.  A dataset labeled with associations people make after seeing a name might help here.


I think another interesting future project would be creating a generative model for creating names from word vectors.  It’s [known](https://arxiv.org/pdf/1601.03764v2.pdf) that word vectors can contain a weighted combination of different concepts.  Perhaps by choosing a mix of known names and attributes, you could generate candidate names that would fit a particular type of character, or even create plausible sounding words in general.
