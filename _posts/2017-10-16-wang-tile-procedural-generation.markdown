---
layout: post
title:  "Procedural Worlds from Simple Tiles"
date:   2017-10-16 22:25:30 -0500
categories: ml
---

In this post, I'll describe the two algorithms I came up with for creating complex procedural worlds from simple sets of colored tiles.  I will show that by carefully designing these tile sets, you can create interesting procedurally generated content, such as landscapes with cities, or dungeons with interesting internal structure.  The video below shows the system creating a procedural world based on the rules encoded in 43 colored tiles.

<iframe width="100%" height="500" src="https://www.youtube.com/embed/XVIYY0AQF-8?rel=0&amp;controls=0&amp;showinfo=0"
	frameborder="0" allowfullscreen
	style="display: block; margin: auto;"></iframe>

A tile set is a collection of 3 by 3 grids of colors.  A collection of tiles might look like this:

![dungeon tileset]({{ site.url }}/assets/wang_tiles/dungeon_tileset.png)

*This set of tiles is the only information needed to describe the generation of the world in the video above.*

To assist you in the exercise of imagination required to see this as a "world," see the helpful diagram below.

![map explanation]({{ site.url }}/assets/wang_tiles/map_explanation.svg)

We will define a tiling as a finite grid where one of those tiles lies in each grid square.  We will further define a valid world as one where the colors along the edges of adjacent tiles must be the same.

![valid pairs]({{ site.url }}/assets/wang_tiles/pair_examples.svg)

*This is the only concrete rule for a tiling: tile edge colors must match up.  All the higher level structure flows from this.*


A valid tiling of the tile set above might look like this:

![valid tiling]({{ site.url }}/assets/wang_tiles/example_valid_tiling.png)

*This is a tiling which is supposed to represent a map with water, beaches, grass, towns with buildings (blue rectangles), and snow capped mountains.  The black lines show borders between tiles.*

An invalid tiling would include unmatched edges between tiles, as in the image below.

<!-- In this post, I'll explore algorithms for efficiently taking large, complex tile sets and producing valid or nearly valid tilings that look like convincing landscapes, dungeons, and other commonly procedurally generated content.  When these algorithms work well, they can produce some very nice looking results: -->

I think this is an interesting way to create worlds because very often, procedural generation algorithms take a top-down approach.  L-systems, for instance, rely on a recursive description of an object where the top level, large details are determined before lower level ones.  There is nothing wrong with this approach, but I think that it is interesting to create tile sets that are only able to encode simple low level relationships (e.g., ocean water and grass must be separated by a beach, buildings can only have convex, 90 degree corners) and see high level patterns emerge (e.g. square buildings).

## Why Creating a Tiling is Hard

Intuitively, the problem of correctly creating a nontrivial tiling is hard because the tile sets can encode arbitrary, long term dependencies.  Formally, this is an NP complete constraint satisfaction problem whne we consider tile sets in general.  The hope is that we can create interesting worlds using tile sets that are solvable using approximate methods.  I have found two algorithms that seem to work well in practice, and I describe them below.

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

The first approach I took to creating a tiling from a tile set is to simply start with the entire grid in an undefined state, and to iteratively place a random tile in a location where it is valid, or, if no locations are valid, set a small region on near an undefined tile to be undefined and continue greedy placement.  The "greedy placement" is the strategy of placing a tile as long as all its edges line up with existing tiles, without regard for whether this placement will create a partial tiling that cannot be completed without removing existing tiles.  When such a situation arises, and we cannot place any more tiles, we must remove some previously placed tiles.  But we can't say which are ideal to remove, because if we could solve that problem, we could probably also have solved the problem of placing tiles in a smart way in the first place.  To give the algorithm another chance at finding a valid tiling for a given area, we set all the tiles around the location that undefined and continue with the greedy placement strategy.  Eventually, the hope is, a valid tiling will be found, but this is not guaranteed.  The algorithm will continue to run until a valid tiling is found, which may be forever.  It has no ability to detect when a tile set is unsolveable.

There is obviously no guarantee that this algorithm will halt.  A simple tile set with two tiles that share no colors would cause this algorithm to loop forever.  An even simpler case would be one tile with different colors on the top and bottom.  It might make sense to somehow check for tile sets that cannot produce valid tilings.  We might say that a tile set is certainly valid if it can tile an infinite plane.  In some cases it is clearly possible to prove or disprove whether a tile set can tile an infinite plane, but the problem turns out to be undecidable in general.  Therefore, it is up to the designer of the tile set to create one which can yield a valid tiling.  

## Wave Collapse Tiling

*Maintain a probability distribution over tiles at each location, making nonlocal updates to these distributions when a placement decision is made.  Never backtrack.*

![wave collape example]({{ site.url }}/assets/wang_tiles/wave_collapse_example.svg)

Next, I'll describe an algorithm which is guaranteed to halt and produces better looking results for all the tile sets I have tried.  It is also able to produce nearly-valid tilings for tile sets that are much more complicated than those which the previous algorithm can handle.  The tradeoff is that this algorithm does not guarantee that its output is always a valid tiling.

The difficulty of creating a valid tiling is largely determined by the number of transitions necessary to get between two tile types.  A simple tile set might contain only sand, water, and grass.  If grass and water cannot touch, then a transition to sand will be necessary between the two.  This is a simple case that the greedy algorithm can solve easily.  A more complex case might involve many nested levels of tile types.  For instance, you might have deep water, water, sand, grass, high plain, mountain, and snow cap.  Seven transitions would need to be present in the map for all of these types to appear, assuming that these types cannot touch except in the order I stated them.  Further complexity can be introduced by creating tiles that naturally create long-distance dependencies between tiles.

An algorithm should, therefore, have some ability to "look ahead" and consider at least a few transitions out what the consequences of its placement choices might be.  In order to do this, the tile map is considered to be a probability distribution over tiles at each location.  When the algorithm places a tile, it updates the probability distributions around that tile to reflect the number of possible ways that each other tile could be transitioned to given that that that tile was placed.


## Manipulating Tilings by Changing Tile Selection Probabilities.

I've claimed that the problem of creating valid tilings is hard and provided two algorithms neither of which can both finish in bounded time and produce a result that is guaranteed to be correct.  Yet obviously a valid tiling can be created for any tile set that has a single tile of uniform color.  Placing that tile everywhere will always yield a valid tiling.  Furthermore, one would expect that most tile sets used to create procedural content would contain tiles of uniform color to represent floors or water, as I have done above.  Intuitively, we might want to make sure that the whole tile set is represented in a tiling.

To be more concrete, we can decide on a probability that a given tile appears in a tiling, and then try to create algorithms which output tilings where each tile appears at about its predefined rate.  By adjusting the probabilities of various tiles appearing, one can adjust the sizes of various features on the tiling.

![water probability comparison]({{ site.url }}/assets/wang_tiles/water_probability.svg)


## Make Your Own Tile Sets

Using the code (at your own risk; I wrote most of it in high school) I've put on github, you can create your own tilesets using an image editor, and see how the tiling solver creates worlds with them.  Simply clone the repo and edit the image named dungeon.png, then use Processing to run wangTiles.pde to see an animation of the map being generated. I'll now describe the "language" that the tiling solver expects.

### The Tile Set Specification

![tile spec]({{ site.url }}/assets/wang_tiles/tile_spec.svg)

The tiles are laid out on a grid of 4x4 cells.  Each cell contains a colored tile in the upper left 3x3 region, and the remaining 7 pixel contain metadata about the tile.  The pixel below the center of the tile can be set to pure red to comment that tile out of the set.  The solvers will never include it in a map.  The upper pixel to the right of the tile can be set to pure black to add all 4 rotations of the tile to the tile set as well.  This is a nice shorthand when you want to add something like a corner, which can reasonably exist in 4 orientations.  Finally, the most important piece of markup is the pixel below and to the left of the tile.  This controls the base probability of that tile appearing in the map.  The darker the pixel is, the more likely that tile is to appear.  


