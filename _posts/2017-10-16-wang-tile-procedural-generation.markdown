---
layout: post
title:  "Procedural Generation from Tile Sets"
date:   2017-10-16 22:25:30 -0500
categories: ml
---

In this post, I'll describe the two algorithms I came up with for creating complex procedural worlds from simple sets of colored tiles.  I will show that by carefully designing these tile sets, you can create interesting procedurally generated content, such as landscapes with cities, or dungeons with interesting internal structure.

<iframe width="640" height="640" src="https://www.youtube.com/embed/XVIYY0AQF-8?rel=0&amp;controls=0&amp;showinfo=0"
	frameborder="0" allowfullscreen
	style="display: block; margin: auto;"></iframe>



![latent space diagram]({{ site.url }}/assets/wang_tiles/dungeon_tileset.png)
*This set of tiles is the only information needed to describe the generation of the world in the video above.*

A tile set is a collection of 3 by 3 grids of colors.  A collection of tiles might look like this:


We will define a tiling as a finite grid where one of those tiles lies in each grid square.  We will further define a valid world as one where the colors along the edges of adjacent tiles must be the same.  A valid tiling of the tile set above might look like this:

An invalid tiling would include unmatched edges between tiles, as in the image below.


In this post, I'll explore algorithms for efficiently taking large, complex tile sets and producing valid or nearly valid tilings that look like convincing landscapes, dungeons, and other commonly procedurally generated content.  When these algorithms work well, they can produce some very nice looking results:
<!-- Very often, procedural generation algorithms take a top-down approach.   -->

<!-- ## Why Creating a Tiling is Hard -->

<!-- Intuitively, the problem of correctly creating a nontrivial tiling  -->

## Examples of Interesting Tile Sets

To motivate this post, I'll show a few tile sets that I've come up with and some tilings that can be generated under the contraints they describe.  


## Greedy Placement with Crude Undoing

The first approach I took to creating a tiling from a tile set is to simply start with the entire grid in an undefined state, and to iteratively place a random tile in a location where it is valid, or, if no locations are valid, set a small region on near an undefined tile to be undefined and continue greedy placement.  The "greedy placement" is the strategy of placing a tile as long as all its edges line up with existing tiles, without regard for whether this placement will create a partial tiling that cannot be completed without removing existing tiles.  When such a situation arises, and we cannot place any more tiles, we must remove some previously placed tiles.  But we can't say which are ideal to remove, because if we could solve that problem, we could probably also have solved the problem of placing tiles in a smart way in the first place.  To give the algorithm another chance at finding a valid tiling for a given area, we set all the tiles around the location that undefined and continue with the greedy placement strategy.  Eventually, the hope is, a valid tiling will be found, but this is not guaranteed.

There is obviously no guarantee that this algorithm will halt.  A simple tile set with two tiles that share no colors would cause this algorithm to loop forever.  An even simpler case would be one tile with different colors on the top and bottom.  It might make sense to somehow check for tile sets that cannot produce valid tilings.  We might say that a tile set is certainly valid if it can tile an infinite plane.  In some cases it is clearly possible to prove or disprove whether a tile set can tile an infinite plane, but the problem turns out to be undecidable in general.  Therefore, it is up to the designer of the tile set to create one which can yield a valid tiling.  

## Wave Collapse Tiling

Next, I'll describe an algorithm which is guaranteed to halt and produces better looking results for all the tile sets I have tried.  It is also able to produce nearly-valid tilings for tile sets that are much more complicated than those which the previous algorithm can handle.  The tradeoff is that this algorithm does not guarantee that its output is always a valid tiling.

The difficulty of creating a valid tiling is largely determined by the number of transitions necesarry to get between two tile types.  A simple tile set might contain only sand, water, and grass.  If grass and water cannot touch, then a transition to sand will be necesarry between the two.  This is a simple case that the greedy algorithm can solve easily.  A more complex case might involve many nested levels of tile types.  For instance, you might have deep water, water, sand, grass, high plain, mountain, and snow cap.  Seven transitions would need to be present in the map for all of these types to appear, assuming that these types cannot touch except in the order I stated them.  Further complexity can be introduced by creating tiles that naturally create long-distance dependencies between tiles.



## Manipulating Tilings by Changing Tile Selection Probabilities.

I've claimed that the problem of creating valid tilings is hard and provided two algorithms neither of which can both finish in bounded time and produce a result that is guaranteed to be correct.  Yet obviously a valid tiling can be created for any tile set that has a single tile of uniform color.  Placing that tile everywhere will always yield a valid tiling.  Furthermore, one would expect that most tile sets used to create procedural content would contain tiles of uniform color to represent floors or water, as I have done above.  Intuitively, we might want to make sure that the whole tile set is represented in a tiling.

To be more concrete, we can decide on a probability that a given tile appears in a tiling, and then try to create algorithms which output tilings where each tile appears at about its predefined rate.  By adjusting the probabilities of various tiles appearing, one can adjust the sizes of various features on the tiling.

IMAGE OF A SPECTRUM OF 3 IMAGES AT DIFFERENT OCEAN PROBABILITIES
	could even make this a 3x3 showing different probabilities of two tiles.

## Make Your Own Tile Sets

### A Graphical Tile Set Specification

To 

