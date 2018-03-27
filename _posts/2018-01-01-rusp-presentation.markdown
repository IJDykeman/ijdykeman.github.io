---
layout: post
title:  "rusp presentation"
date:   2018-01-01 22:25:30 -0500
categories: ml
published: true
---



![lidar image]({{ site.url }}/assets/phrase_similarity_figures/word2vec.svg)
![Simple network diagram]({{ site.url }}/assets/turnip_net.svg)


* romanticism: philosophical movement
* breakthrough: spectacular performance
* intrigue: illegal subtlety
* stockade: large building
* cantaloupe: common fruit


![RNN decoder diagram](/assets/vae-definition-generation/rnn_decoder_diagram.svg)


<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#ccc;margin:0px auto;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#ccc;color:#333;background-color:#fff;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#ccc;color:#333;background-color:#f0f0f0;}
.tg .tg-k4q0{font-family:Georgia, serif !important;;vertical-align:top}
@media screen and (max-width: 767px) {.tg {width: auto !important;}.tg col {width: auto !important;}.tg-wrap {overflow-x: auto;-webkit-overflow-scrolling: touch;margin: auto 0px;}}</style>
<div class="tg-wrap"><table class="tg">
  <tr>
    <th class="tg-k4q0">word</th>
    <th class="tg-k4q0">vector CVAE</th>
    <th class="tg-k4q0">discrete CVAE</th>
    <th class="tg-k4q0">RNN decoder</th>
    <th class="tg-k4q0">two-word</th>
  </tr>
  <tr>
    <td class="tg-k4q0">sizzling</td>
    <td class="tg-k4q0">showing the fiery sound (in cooking)</td>
    <td class="tg-k4q0">made by heat</td>
    <td class="tg-k4q0">a very; a person</td>
    <td class="tg-k4q0">fiery sound</td>
  </tr>
  <tr>
    <td class="tg-k4q0">smuggling</td>
    <td class="tg-k4q0">transferring in illicit items (especially food goods)</td>
    <td class="tg-k4q0">making or other</td>
    <td class="tg-k4q0">the act of making or taking</td>
    <td class="tg-k4q0">illegal theft</td>
  </tr>
  <tr>
    <td class="tg-k4q0">undated</td>
    <td class="tg-k4q0">lacking a date in manuscript)</td>
    <td class="tg-k4q0">existing or written</td>
    <td class="tg-k4q0">not yet</td>
    <td class="tg-k4q0">original document</td>
  </tr>
  <tr>
    <td class="tg-k4q0">Arabia</td>
    <td class="tg-k4q0">the mediterranean country (in the africa)</td>
    <td class="tg-k4q0">country and north region</td>
    <td class="tg-k4q0">the region of southern asia</td>
    <td class="tg-k4q0">large area</td>
  </tr>
  <tr>
    <td class="tg-k4q0">connoisseur</td>
    <td class="tg-k4q0">any discerning performer (in taste)</td>
    <td class="tg-k4q0">someone who is skilled</td>
    <td class="tg-k4q0">one who is a person</td>
    <td class="tg-k4q0">energetic person</td>
  </tr>
  <tr>
    <td class="tg-k4q0">bishop</td>
    <td class="tg-k4q0">the biggest catholic priest in church</td>
    <td class="tg-k4q0">someone who makes or.</td>
    <td class="tg-k4q0">a male given name</td>
    <td class="tg-k4q0">catholic priest</td>
  </tr>
  <tr>
    <td class="tg-k4q0">tandoori</td>
    <td class="tg-k4q0">the indian uncooked dish (usually in curries)</td>
    <td class="tg-k4q0">made with meat.</td>
    <td class="tg-k4q0">a small, a small, a small.</td>
    <td class="tg-k4q0">small dish</td>
  </tr>
</table></div>




<!-- |model            |  random | similar |
| ----            |  ------ | ------- |
|two-word         | 63%     | 27%     |
|RNN              | 50%     | 23%     |
|discrete CVAE    | 55%     | 21%     |
|vector CVAE      | __71%__ | __30%__ |
|real definitions | 76%     | 50%     | -->