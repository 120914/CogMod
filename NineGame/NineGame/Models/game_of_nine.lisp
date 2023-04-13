​(clear-all)
​
(define-model game-of-nine
    
;(sgp :v nil :esc t :lf .6 :bll 0.5 :ans 0.4 :rt 1.1 :ncnar nil)
​
(chunk-type strategy type)
​(chunk-type move claim strategy my-move
(chunk-type move type strategy op-mns mns op-bid-diff bid-diff op-move my-move)
(chunk-type game-state state type-move my-mns op-mns my-bid-diff op-bid-diff op-move my-move op-final strategy-op)
(chunk-type goal state strategy my-mns)
​
(add-dm
 (strategy1 isa strategy type coop)
 (strategy2 isa strategy type agg)
 (claim1 ISA claim strategy coop my-move 0)
 (bid1 ISA move type bid strategy coop bid-diff 3 op-move -2 my-move -2)
 (bid2 ISA move type bid strategy coop bid-diff 2 op-move -2 my-move -2)
 (bid3 ISA move type bid strategy coop bid-diff 2 op-move -1 my-move -1)
 (bid4 ISA move type bid strategy coop bid-diff 1 op-move -1 my-move -1)
 (bid5 ISA move type bid strategy coop bid-diff 3 op-move 0 my-move -1)
 (bid6 ISA move type bid strategy coop bid-diff 1 op-move 0 my-move 0)
 (decision1 ISA move type decision strategy coop bid-diff 1 op-move -1 my-move reject)
 (decision2 ISA move type decision strategy coop bid-diff 2 op-move -1 my-move accept)
; so coop never accepts??
 (opening1 ISA move type opening strategy coop mns 1 op-move 6 my-move 5)
 (opening2 ISA move type opening strategy coop mns 4 op-move 6 my-move 6)
 (opening3 ISA move type opening strategy coop mns 1 op-move 5 my-move 5)
 (opening4 ISA move type opening strategy coop mns 4 op-move 8 my-move 7)
 (claim2 ISA claim strategy agg my-move 1)
 (bid7 ISA move type bid strategy agg bid-diff 3 op-move 1 my-move 0)
 (bid8 ISA move type bid strategy agg bid-diff 2 op-move 1 my-move 0)
 (decision3 ISA move type decision strategy agg bid-diff 1 op-move -1 my-move reject)
 (decision4 ISA move type decision strategy agg bid-diff 2 op-move -1 my-move accept)
 (final-offer1 ISA move type bid strategy agg bid-diff 2 op-move 0 my-move 0)
 (final-offer2 ISA move type bid strategy agg bid-diff 3 op-move 0 my-move -1)
 (opening5 ISA move type opening strategy agg mns 1 op-move 8 my-move 9)
 (opening6 ISA move type opening strategy agg mns 4 op-move 6 my-move 7)
 (opening7 ISA move type opening strategy agg mns 1 op-move 7 my-move 8)
 (opening8 ISA move type opening strategy agg mns 4 op-move 7 my-move 8)
 (quit1 ISA move type bid strategy agg bid-diff 2 op-move 1 my-move quit)
 (bid9 ISA move type bid strategy neutral bid-diff 2 op-move -2 my-move -1)
 (bid10 ISA move type bid strategy neutral bid-diff 3 op-move -1 my-move -1)
 (bid11 ISA move type bid strategy neutral bid-diff 1 op-move -1 my-move 0)
 (bid12 ISA move type bid strategy neutral bid-diff 3 op-move 0 my-move 0)
 (bid13 ISA move type bid strategy neutral bid-diff 2 op-move 0 my-move 0)
 (final-offer3 ISA move type bid strategy neutral bid-diff 1 op-move 0 my-move 0)
 (final-offer4 ISA move type bid strategy neutral bid-diff 2 op-move 0 my-move -1)
 (decision5 ISA move type decision strategy neutral bid-diff 1 op-move -1 my-move accept)
 (decision6 ISA move type decision strategy neutral bid-diff 0 op-move -1 my-move reject)
 (opening9 ISA move type opening strategy neutral mns 3 op-move 7 my-move 7)
 (quit2 ISA move type bid strategy neutral mns 1 bid-diff 0 op-move 0 my-move quit)
 (goal isa goal state start strategy neutral)
 (reject) (accept) (quit) (coop) (agg) (neutral) (bid) (decision) (opening) (claim)
 (final-offer) (quit))
​
; TODO: is the MNS of the player visible to the model before making the claim?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; report mns value to model and start claim round
(P start-game
   =goal>
      ISA         goal
      state       start
    strategy    =s
   =action>
    ISA        game-state
    state        game
    my-mns    =m-mns
==>
   =goal>
      state       claim
    my-mns    =m-mns
   +partial>
    ISA        move
    type        claim
    strategy    =s
   -action>
)

; note: partial matching allowed for claims (no claim for neutral but that can change)
; declare mns
(P make-claim
   =goal>
    ISA        goal
    state        claim
   =partial>
    ISA        move
    type        claim
    my-move    =move
==>
   =goal>
    state        find-strategy
   +action>
    ISA        game-state
    type-move    claim
    my-move    =move
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; depending on game stage, retrieve an action (opening, bid, final-offer, quit, decision)

(P start-opening
   =goal>
    ISA        goal
    state        bid
    strategy    =s
    my-mns    =m-mns
   =action>
    ISA        game-state
    state        game
    my-bid-diff    nil
    op-move    =o-move
==>
   +partial>
    ISA        move
    type        opening
    strategy    =s
    mns        =m-mns
    op-move    =o-move
   -action>
)

(P start-bid
   =goal>
    ISA        goal
    state        bid
    strategy    =s
   =action>
    ISA        game-state
    state        game
    my-bid-diff    =m-diff
    op-move    =o-move
    op-final    no
==>
   +partial>
    ISA        move
    type        bid
    strategy    =s
    bid-diff    =m-diff
    op-move    =o-move
   -action>
)

(P start-decision
      =goal>
    ISA        goal
    state        bid
    strategy    =s
   =action>
    ISA        game-state
    state        game
    my-bid-diff    =m-diff
    op-move    =o-move
    op-final    yes
==>
   +partial>
    ISA        move
    type        decision
    strategy    =s
    bid-diff    =m-diff
    op-move    =o-move
   -action>
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; report move to ModelView
(P make-move
   =goal>
    ISA        goal
    state        bid
   =partial>
    ISA        move
    type        =t
    my-move    =m-move
==>
   +action>
    ISA        game-state
    type        =t
    my-move    =m-move
   =goal>
    state        find-strategy
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; identify strategy of oponent by pretending that model is oponent
(P get-op-strategy
   =goal>
    ISA        goal
    state        find-strategy
   =action>
    ISA        game-state
    state        game
    op-mns    =o-mns
    op-bid-diff    =o-bid-diff
    op-move    =o-move
    my-move    =m-move
   ?retrieval>
    state        empty
==>
   +partial>
    ISA        move
    mns        =o-mns
    bid-diff    =o-bid-diff
    op-move    =m-move
    my-move    =o-move
   =action>
)

; update strategy of model based on proposed strategy of player (simplified version for now)
(P retrieve-op-strategy
   =goal>
    ISA        goal
    state        find-strategy
   =partial>
    ISA        move
    strategy    =s
   ?imaginal>
    state        free
==>
   +imaginal>
    ISA        strategy
    type        =s
   =goal>
    ISA        goal
    state        update-strategy
)

(P retrieve-my-strategy
   =goal>
    ISA        goal
    state        update-strategy
   ?imaginal>
    state        free
==>
   +retrieval?
    ISA        strategy
)

(P update-my-strategy
   =goal>
    ISA        goal
    state        update-strategy
   ?retrieval>
    ISA        strategy
    type        =s
==>
   =goal>
    strategy     =s
    state        bid
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ModelView reports good moves back to model at the end of the negotiation
; take info from action buffer and create chunk in imaginal buffer of desired format
(P process-good-game
   =action>
    ISA        game-state
    state        feedback
    type-move    =t
    my-mns    =m-mns
    op-mns    =o-mns
    my-bid-diff    =m-bid-diff
    op-bid-diff    =o-bid-diff
    op-move    =o-move
    my-move    =m-move
    strategy-op    =s
   ?imaginal>
    state free
==>
   +imaginal>
    ISA        move
    type        =t
    mns        =m-mns
    op-mns    =o-mns
    bid-diff    =m-bid-diff
    op-bid-diff    =o-bid-diff
    op-move    =o-move
    my-move    =m-move
)

; every time there is a chunk in the imaginal buffer (namely after feedback was provided)
; clear the chunk such that it enters declarative memory
(P clear-new-imaginal-chunk
   ?imaginal>
    state        free
    buffer    full
==>
   -imaginal>)


(set-all-base-levels 100000 -1000)
(goal-focus goal)
​
)
