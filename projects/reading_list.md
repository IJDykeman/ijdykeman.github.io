---
layout: page
title: Reading List
permalink: /reading_list/
---



These are the resources that have most helped me understand new topics.  This list
* aims to be short
* includes only what helped me personally
* is biased toward things I reference often while working

Why this might be an interesting resource for others
* at least one person actually transitioned from ignorance to understanding using each resource.
* these documents are not being judged as "useful to a novice" by an expert.  An expert is the last person who should make that judgement!
* these resources are likely to play well together in terms of notation, because a particular individual prefers them all.

## physics

If this seems like largely a list of Feynman lectures I have read, that's because it is.  They are the most helpful things I have found.  I imagine physics in college would have been more pleasant if I had thrown away my textbook and read one of these a week instead.

### light

[Lights and Shadows by Bartosz Ciechanowski](https://ciechanow.ski/lights-and-shadows/)\
A magnificent introduction to some concepts in geometric optics like (projected) solid angle, concepts in radiometry, and more.  It is presented with clear prose and beautiful interactive illustrations.  You literally cannot walk away from this without learning something new, unless you already knew all this article had to offer.  I wish I had had this article while tackling Radiosity.  Everything should be presented this way.

[Feynman: Optics: The Principle of Least Time](https://www.feynmanlectures.caltech.edu/I_26.html)\
This is very spicy and rewarding stuff.  It is approachable in a way that other least-something principles are not.  The idea that wave interference implements a least-time optimization is very cool.

[PBR book's treatment of participating media](https://www.pbr-book.org/3ed-2018/Volume_Scattering/Volume_Scattering_Processes)\
Handy for graphics applications, and good for building intuition.  This belongs in the physics section because it is really about the behavior of light as opposed to how to simulate it.


### fluids

[Feynman: The Flow of Dry Water](https://www.feynmanlectures.caltech.edu/II_40.html)\
[Feynman: The Flow of Wet Water](https://www.feynmanlectures.caltech.edu/II_41.html)\
These together are a good exposition of Navier-Stokes.  

## geometry

[Keenan Crane's Discrete Differential Geometry book](https://www.cs.cmu.edu/~kmcrane/Projects/DDG/paper.pdf)\
Packed with good insights, well-illustrated, and compact.  Includes surprisingly lucid little treatments of all sorts of things it doesn't claim to be a book on.  For instance, it contains a nice treatment on some basics of vector calculus, before applying these to the discrete setting.

## graphics

[Radiosity Method]({{ site.baseurl }}{% link assets/reading/radiosity.pdf %}) (original link [here](http://www.fsz.bme.hu/~szirmay/radiosit.pdf))\
I am guessing better treatments exist.  This one is not very user-friendly, but if you wade through it line by line, you will know enough to implement radiosity from memory without referencing anything.  In particular, my group was caught up by not understanding the "projected solid angle" soon enough.  Please first look at [Lights and Shadows](https://ciechanow.ski/lights-and-shadows/).  For the math, I recommend referencing:

[Wikipedia article on Radiosity in computer graphics](https://en.wikipedia.org/wiki/Radiosity_(computer_graphics)) (accessed July 6 2021)\
A nice reference on the Radiosity method.


## optimization

### unconstrained optimization

[Ethan Eade's document on Gauss-Newton optimization](http://ethaneade.com/optimization.pdf)\
Includes a nice terse derivation of Gauss-Newton, and some practical information for how to ensure convergence.  A handy reference.

## constraint satisfaction

[Artificial Intelligence: A Modern Approach](http://aima.cs.berkeley.edu/)\
Ubiquitous for a reason.  This book covers many topics, but it served me most as a treatment of constraint satisfaction algorithms.

## deep learning

[The Deep Learning  Book](https://www.deeplearningbook.org/)\
A great, low-madness, practical introduction to a bunch of deep learning concepts.  When possible, it is best to learn from this book rather than from a paper, since it tends to be clean and expository, with few "prior work" history lessons or text espousing the importance of the author's tweaks.

---

## cooking

[Masala Lab](https://www.amazon.com/dp/B0756WQVKR/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1)\
If there were a Feynman lecture on cooking rice, it would look like this.  This short book explains a bunch of physical and chemical ideas about cooking in the context of Indian food.  Why is the amount of water you use when cooking rice an affine, not linear, function of the amount of rice?



<!---
candidates
Dijkstra on mathematical notation
https://www.cs.utexas.edu/users/EWD/transcriptions/EWD13xx/EWD1300.html?fbclid=IwAR2eqZgLzAfnaKkaHMdY92s0T3nuIgo-aktO1dDWHMekm2_HvDU9f3XIUN8
-->
