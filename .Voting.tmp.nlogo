globals[history poll result parties nr-parties count-max one-vote percent-to-win winner runner-up pwinner prunner-up gap same-two-counter] ;; polls is the result of previous election

patches-own
[
  like ;; my vote (0 - nr-parties)
  vote   ;; my vote (0 - nr-parties)
  previous-vote ;; (0 - nrparties)
  area ;; (list of what the neighbors voted)
  counter ;;
]

to setup
  clear-all

  set parties [0 1 2 3 4 5 6]
  set result  [0 0 0 0 0 0 0]
  set history [0 0 0 0 0 0 0]

  set poll result
  set nr-parties length parties
  set count-max 2 ;;after voting count-max on a party that is not its preference its preference changes

  set one-vote (1 / count patches)
  set percent-to-win 1 / nr-parties ;;all have equal chance to win according to polls


  ask patches
    [
      set vote random nr-parties

      set previous-vote like
      recolor-patch ]
  reset-ticks
end

to-report get-gap [input]
  let win_per max input

  let arr replace-item (position win_per input) input 0

  set gap win_per - max arr

  report gap
end

to-report get-second-biggest [input]

  let arr replace-item (position (max input) input) input 0

  report position max arr arr
end

to go
  ;;grabs our poll data from the latest voting
  set poll result

  set result [0 0 0 0 0 0 0]


  ask patches [
    go-vote
  ]


  set percent-to-win max result

  set pwinner winner
  set prunner-up runner-up

  ;;gets the position of the two biggest
  set winner position percent-to-win result
  set runner-up get-second-biggest result

  ifelse (winner = pwinner and runner-up = prunner-up) or (winner = prunner-up and runner-up = pwinner) [
    set same-two-counter same-two-counter + 1
  ][
    set same-two-counter 0
  ]

  set gap get-gap result

  let new-value 1 + item winner history
  set history replace-item winner history new-value


  ask patches [
    recolor-patch
  ]
  tick
end

to-report other-alive [start];;party

  let change one-of parties
  let counting 0

  if item change result = 0 or change = start and counting < 10 [
    set change one-of parties
    set counting counting + 1
  ]

  report change
end

to go-vote ;; patch procedure

  let l 0
  let r 0

  ;;defining l and r as left and right of the current vote
  ifelse vote - 1 >= 0         [set l vote - 1] [set l vote]
  ifelse vote + 1 < nr-parties [set r vote + 1] [set r vote]

  let my-vote vote

  ifelse my-vote = winner and gap > percent considered-close and random-float 1 < percent switch-if-very-likely-to-win [
      set my-vote other-alive vote
  ]
  [
    ;chance of voting if the vote is not close
    if abs(item my-vote poll - percent-to-win) > percent considered-close or random-float 1 < percent switch-even-though-close [
      ;;change vote to bigger party
      if item l poll > item r poll and l != winner[
        set my-vote l
      ]

      if item l poll < item r poll and r != winner[
        set my-vote r
      ]

      if item l poll = item r poll and l != winner and r != winner[
        ifelse random-float 1 <= 0.5 [
          set my-vote l
        ][
          set my-vote r
        ]
      ]
    ]
  ]


  if random-float 1 < percent chance-of-switching-randomly [
    set my-vote other-alive vote
  ]

  set vote my-vote

  let new-vote-total one-vote + item my-vote result
  ;; adds one vote to the party it voted for
  set result replace-item vote result new-vote-total
end

to recolor-patch  ;; patch procedure
  set pcolor 52 + vote
end

to-report percent [percent-to-dec]
  report percent-to-dec / 100
end

to-report is-two-party-system
  report same-two-counter > 10
end

; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
249
10
710
472
-1
-1
3.0
1
10
1
1
1
0
1
1
1
-75
75
-75
75
1
1
1
ticks
30.0

BUTTON
51
66
106
99
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
116
67
171
100
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
74
31
149
64
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
731
11
931
161
plot 1
NIL
NIL
0.0
7.0
0.0
22500.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [vote] of patches"

SLIDER
15
139
224
172
switch-even-though-close
switch-even-though-close
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
15
180
227
213
switch-if-very-likely-to-win
switch-if-very-likely-to-win
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
6
226
238
259
chance-of-switching-randomly
chance-of-switching-randomly
0
100
2.0
1
1
%
HORIZONTAL

SLIDER
47
301
219
334
considered-close
considered-close
0
100
30.0
1
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is a simple cellular automaton that simulates voting distribution by having each patch take a "vote" of its eight surrounding neighbors, then perhaps change its own vote according to the outcome.

## HOW TO USE IT

Click the SETUP button to create an approximately equal but random distribution of blue and green patches.  Click GO to run the simulation.

When both switches are off, the central patch changes its color to match the majority vote, but if there is a 4-4 tie, then it does not change.

If the CHANGE-VOTE-IF-TIED? switch is on, then in the case of a tie, the central patch will always change its vote.

If the AWARD-CLOSE-CALLS-TO-LOSER? switch is on, then if the result is 5-3, the central patch votes with the losing side instead of the winning side.

## THINGS TO NOTICE

Watch how any setup quickly settles to a static state when both switches are off.

Watch what happens when only the CHANGE-VOTE-IF-TIED? switch is on.  How is the result different?

Watch what happens when only the AWARD-CLOSE-CALLS-TO-LOSER? switch is on.  How is the result different?

What happens when both switches are on?

## EXTENDING THE MODEL

Try other voting rules.

Start with a nonrandom green-and-blue pattern. For example, one could make half of the world blue and half green.

Can you enhance the model to incorporate multiple colors and multiple votes?  One might interpret shades of color to represent the degree of a patch's opinion about an issue: strongly against, against, neutral, etc.  Each patch could have more than two choices and weighted votes: blue patches' vote could count twice, etc.

## RELATED MODELS

Ising (a physics model, but the rules are very similar)

## CREDITS AND REFERENCES

This model is described in Rudy Rucker's "Artificial Life Lab", published in 1993 by Waite Group Press.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Voting model.  http://ccl.northwestern.edu/netlogo/models/Voting.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Test1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <exitCondition>is-two-party-system</exitCondition>
    <metric>is-two-party-system</metric>
    <enumeratedValueSet variable="considered-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-if-very-likely-to-win">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-even-though-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-of-switching-randomly">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Test2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <exitCondition>is-two-party-system</exitCondition>
    <enumeratedValueSet variable="considered-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-if-very-likely-to-win">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-even-though-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-of-switching-randomly">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Test3" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>item 0 history</metric>
    <metric>item 1 history</metric>
    <metric>item 2 history</metric>
    <metric>item 3 history</metric>
    <metric>item 4 history</metric>
    <metric>item 5 history</metric>
    <metric>item 6 history</metric>
    <enumeratedValueSet variable="considered-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-if-very-likely-to-win">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-even-though-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-of-switching-randomly">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Test4" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>item 0 history</metric>
    <metric>item 1 history</metric>
    <metric>item 2 history</metric>
    <metric>item 3 history</metric>
    <metric>item 4 history</metric>
    <metric>item 5 history</metric>
    <metric>item 6 history</metric>
    <enumeratedValueSet variable="considered-close">
      <value value="0"/>
      <value value="510"/>
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-if-very-likely-to-win">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-even-though-close">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-of-switching-randomly">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Test5" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <exitCondition>is-two-party-system</exitCondition>
    <metric>is-two-party-system</metric>
    <enumeratedValueSet variable="considered-close">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-if-very-likely-to-win">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch-even-though-close">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-of-switching-randomly">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
