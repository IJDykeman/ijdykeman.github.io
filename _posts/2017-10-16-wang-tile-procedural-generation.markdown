---
layout: post
title:  "Procedural Worlds from Simple Tiles"
date:   2017-10-12 22:25:30 -0500
categories: ml
---

In this post, I'll describe the two algorithms I implemented for creating complex procedural worlds from simple sets of colored tiles.  I will show that by carefully designing these tile sets, you can create interesting procedurally generated content, such as landscapes with cities, or dungeons with interesting internal structure.  The video below shows the system creating a procedural world based on the rules encoded in 43 colored tiles.

<iframe width="100%" height="500" src="https://www.youtube.com/embed/XVIYY0AQF-8?rel=0&amp;showinfo=0"
	frameborder="0" allowfullscreen
	style="display: block; margin: auto;"></iframe>


The image below shows the tile set that generated the world in the video above.  The world is annotated to assist in the exercise of imagination required to see it as an actual environment.

![map explanation]({{ site.url }}/assets/wang_tiles/map_explanation.svg)

We will define a tiling as a finite grid where one of those tiles lies in each grid square.  We will further define a valid world as one where the colors along the edges of adjacent tiles must be the same.

![valid pairs]({{ site.url }}/assets/wang_tiles/pair_examples.svg)

*This is the only concrete rule for a tiling: tile edge colors must match up.  All the higher level structure flows from this.*


A valid tiling looks like this:

![valid tiling]({{ site.url }}/assets/wang_tiles/example_valid_tiling.png)

*This is a tiling which is supposed to represent a map with water, beaches, grass, towns with buildings (blue rectangles), and snow capped mountains.  The black lines show borders between tiles.*

<!-- In this post, I'll explore algorithms for efficiently taking large, complex tile sets and producing valid or nearly valid tilings that look like convincing landscapes, dungeons, and other commonly procedurally generated content.  When these algorithms work well, they can produce some very nice looking results: -->

I think this is an interesting way to create worlds because very often, procedural generation algorithms take a top-down approach.  L-systems, for instance, rely on a recursive description of an object where the top level, large details are determined before lower level ones.  There is nothing wrong with this approach, but I think that it is interesting to create tile sets that are only able to encode simple low level relationships (e.g., ocean water and grass must be separated by a beach, buildings can only have convex, 90 degree corners) and see high level patterns emerge (e.g. square buildings).

## Why Creating a Tiling is Hard

Intuitively, the problem of correctly creating a nontrivial tiling is hard because the tile sets can encode arbitrary, long term dependencies.  Formally, this is an NP complete constraint satisfaction problem when we consider tile sets in general.  The hope is that we can create interesting worlds using tile sets that are solvable using approximate methods.  I have found two algorithms that seem to work well in practice, and I describe them below.

<!-- ## Examples of Interesting Tile Sets

To motivate this post, I'll show a few tile sets that I've come up with and some tilings that can be generated under the constraints they describe.  
 -->

## Greedy Placement with Crude Undoing

*Randomly place valid tiles.  If you get stuck, remove some and try again.*

```
Initialize the entire map to UNDECIDED

while UNDECIDED tiles remain on the map
    if any valid tile can be places on the map
      t <- collection of all possible valid tile placements
      l <- random selection from t weighted by tile probabilities
      place l on the map
    else
      select a random UNDECIDED tile and set all its neighbors to UNDECIDED
```

![randomized algorithm example]({{ site.url }}/assets/wang_tiles/randomized_algo_diagram.svg)


The first approach I took to creating a tiling from a tile set is to simply start with the entire grid in an undefined state, and to iteratively place a random tile in a location where it is valid, or, if no locations are valid, set a small region on near an undefined tile to be undefined and continue greedy placement.  The "greedy placement" is the strategy of placing a tile as long as all its edges line up with existing tiles, without regard for whether this placement will create a partial tiling that cannot be completed without removing existing tiles.  When such a situation arises, and we cannot place any more tiles, we must remove some previously placed tiles.  But we can't say which are ideal to remove, because if we could solve that problem, we could probably also have solved the problem of placing tiles in a smart way in the first place.  To give the algorithm another chance at finding a valid tiling for a given area, we set all the tiles around the location that undefined and continue with the greedy placement strategy.  Eventually, the hope is, a valid tiling will be found, but this is not guaranteed.  The algorithm will continue to run until a valid tiling is found, which may be forever.  It has no ability to detect when a tile set is unsolvable.

There is obviously no guarantee that this algorithm will halt.  A simple tile set with two tiles that share no colors would cause this algorithm to loop forever.  An even simpler case would be one tile with different colors on the top and bottom.  It might make sense to somehow check for tile sets that cannot produce valid tilings.  We might say that a tile set is certainly valid if it can tile an infinite plane.  In some cases it is clearly possible to prove or disprove whether a tile set can tile an infinite plane, but the problem turns out to be undecidable in general.  Therefore, it is up to the designer of the tile set to create one which can yield a valid tiling.

This algorithm is unable to find good solutions for the dungeon tile set in the video at the top of this post.  It performs better on the towns and mountains tile set.

## Wave Collapse Tiling

*Maintain a probability distribution over tiles at each location, making nonlocal updates to these distributions when a placement decision is made.  Never backtrack.*

![wave collapse example]({{ site.url }}/assets/wang_tiles/wave_collapse_example.svg)

Next, I'll describe an algorithm which is guaranteed to halt and produces better looking results for all the tile sets I have tried.  It is also able to produce nearly-valid tilings for tile sets that are much more complicated than those which the previous algorithm can handle.  The tradeoff is that this algorithm does not guarantee that its output is always a valid tiling.  I'll discuss optimizations that help this technique run fast even over large tile sets and maps.

The difficulty of creating a valid tiling is largely determined by the number of transitions necessary to get between two tile types.  A simple tile set might contain only sand, water, and grass.  If grass and water cannot touch, then a transition to sand will be necessary between the two.  This is a simple case that the previous algorithm can solve easily.  A more complex case might involve many nested levels of tile types.  For instance, you might have deep water, water, sand, grass, high plain, mountain, and snow cap.  Seven transitions would need to be present in the map for all of these types to appear, assuming that these types cannot touch except in the order I stated them.  Further complexity can be introduced by creating tiles that naturally create long-distance dependencies between tiles, like roads that must start and end at certain types of tiles.

An algorithm should, therefore, have some ability to "look ahead" and consider at least a few transitions out what the consequences of its placement choices might be.  In order to do this, the tile map is considered to be a probability distribution over tiles at each location.  When the algorithm places a tile, it updates the probability distributions around that tile to reflect the number of possible ways that each other tile could be transitioned to given that that that tile was placed.

For example, if a water tile is placed on the map, the tiles next to it must contain water.  The tiles next to those tiles might also contain water, but there are other possibilities, such as grass if a beach was placed next to the original water.  The farther we get from the placed tile, the more other tiles become possible to place.  We can go further and count the number of ways that we can arrive at each tile placement near the original tile.  In some cases, only a single sequence of transitions can cause one tile to transition to another over a given distance.  In other cases, there could be many possible transition sequences.  Once we have placed a tile, we can determine the probability distributions of tiles at nearby locations by counting the number of ways we can transition from the tile we have placed to nearby tiles.  The "look ahead" that the algorithm performs is tracking these transition counts and treating them as probability distributions from which to select future tiles to place.

![tile transition counts]({{ site.url }}/assets/wang_tiles/tile_transition_counts.svg)

At each time step, the algorithm examines all non-decided tile locations, each of which is a probability distribution over tiles, and selects one location to "collapse" into a tile.  It selects the distribution from the map with the lowest entropy.  Low entropy multinomial distributions tend to have their probability concentrated in a few modes, so collapsing these first yields the effect of placing tiles we already have some constraints for.  This is why the algorithm fills in tiles near tiles that are already decided first.

<!-- This algorithm can create tilings where the edge color matching constraint is not satisfied.  In the video at the top of this post, you can see some dead-end tunnels, which should not be possible given the tile set.  Locations on the map with unmatched edges end up getting populated with tiles that were the most likely before some tile was placed that made any correct placement impossible at that location. -->

  <!-- It may be possible to improve this algorithm by -->


This solver is similar to the Wave Function Collapse project by [@ExUtumno](https://twitter.com/ExUtumno).  That algorithm maintains a map of "partially observed" assignments and samples from them to create a final image, which is similar to the distributions over tiles maintained here.  The approaches differ in a few ways.  First, that algorithm is example based, and extracts patches from an example image rather than having a template based approach like this one, where allowable pieces of the final map are defined by hand.  It handles its output at the pixel level, rather than at the level of groups of pixels, over which hard matching constraints can be defined.  My motivation for framing things in terms of tiles is to introduce the idea of a "valid" tiling as one where explicit, hand designed constraints are satisfied.  This allows interesting structures like rectangles (buildings can only be rectangular because only 90 degree corners and straight edges are defined) or nested tile types (buildings can only transition into a "town" background color) to be put into the final tiling reliably, assuming you have a valid tiling.

<!-- The main different between my approach and this one is an method for approximating the probabilities that will propigate out from a tile placement.  One approach would be to count the possible transitions outward from a placed tile each tile a tile is placed.  This would be very slow, since many transition pairs would need ot be considered for each map location to which the new probabilities are propagated.  One obvious optimizaiton is not to propigate accross the entire map.   -->

This is the most effective algorithm I have managed to implement for this problem, and it has the added advantage of lending itself to nice visualizations as it runs.  It may be possible to improve this algorithm by adding some form of backtracking.  If an invalid location exists in the final tiling, undoing nearby tile placements and then resampling from the resulting distributions at their locations may allow a fix to be found for the final tiling.  Of course, if you were determined to always keep searching until a valid tiling is found, you would lose the bounded run time guarantee we have now.


## Manipulating Tilings by Changing Tile Selection Probabilities.

So far, I've talked about only about how to create valid tilings, but beyond being valid, there might be other properties we might like a tiling to have.  For instance, we might like it to have a certain ratio of one tile type to another, or we might like to ensure that it is not all one uniform type of tile, even if such a tiling is valid.  To accomplish this, both the algorithms I describe take as input a base probability associated with each tile.  The higher this probability, the more likely that tile should be in the final tiling.  Both algorithms make random choices over collections of tiles, and I simply weight these random choices by the base tile probabilities.

Below, you can see how this is used.  By adjusting the probability of the solid water tile appearing, I can adjust the size and frequency of water features on the map.  

![water probability comparison]({{ site.url }}/assets/wang_tiles/water_probability.svg)


## Make Your Own Tile Sets

In short,
* clone my [repo on github](https://github.com/IJDykeman/wangTiles)
* install Processing
* in the data/ folder of the repo, modify tiles.png
* use processing to open wangTiles.pde and click the play button

Using the code (You can modify it, but do so at your own risk; I wrote most of it in high school) I've put on github, you can create your own tilesets using an image editor, and see how the tiling solver creates worlds with them.  Simply clone the repo and edit the image named dungeon.png, then use Processing to run wangTiles.pde to see an animation of the map being generated. I'll now describe the "language" that the tiling solver expects.

 

### The Tile Set Specification

![tile spec]({{ site.url }}/assets/wang_tiles/tile_spec.svg)

The tiles are laid out on a grid of 4x4 cells.  Each cell contains a colored tile in the upper left 3x3 region, and the remaining 7 pixel contain metadata about the tile.  The pixel below the center of the tile can be set to pure red to comment that tile out of the set.  The solvers will never include it in a map.  The upper pixel to the right of the tile can be set to pure black to add all 4 rotations of the tile to the tile set as well.  This is a nice shorthand when you want to add something like a corner, which can reasonably exist in 4 orientations.  Finally, the most important piece of markup is the pixel below and to the left of the tile.  This controls the base probability of that tile appearing in the map.  The darker the pixel is, the more likely that tile is to appear.  


## Conclusion and Acknowledgments

Enforcing local rules to create high level structure, such as having a rule that roads have no dead ends enforcing the fact that roads must lead from some non-road location to another, is an interesting perspective on the problem of procedural generation.  A surprising range of interesting rules can be encoded this way.  The quality of the resulting tilings is highly dependent on the solver, however, so a fruitful direction for future work would be improving the algorithms that do the tiling.  I have not explored using genetic algorithms, simulated annealing, or general purpose constraint satisfaction algorithms for this task yet.  Any of these might yield a tile set solver that is able to handle a wide range of tile sets with minimal parameter tuning.

I would like to thank [Cannon Lewis](http://cannontwo.com/) and Ronnie McLaren for helpful discussions during this project.  Ronnie came up with many interesting ideas about how to encode interesting behavior in the tiles.  The wave collapse algorithm resulted from a conversation with Cannon, and his advice was instrumental in creating the efficient approximate algorithm that I described in here.