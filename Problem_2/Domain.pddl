;; ============================================================
;; Domain: Mars Rover Sample Collection
;; Requirements: :strips, :typing only (no numeric fluents,
;; no negative preconditions)
;; ============================================================

(define (domain mars-rover)

  (:requirements :strips :typing)

  (:types
    location
    rover
    bay
    drill
    rock
  )

  (:predicates
    (rover-at      ?r  - rover    ?l - location)   ; rover's current location
    (rock-at       ?rk - rock     ?l - location)   ; rock lying at a location
    (drill-at      ?d  - drill    ?l - location)   ; drill lying at a location (before pickup)
    (connected     ?l1 - location ?l2 - location)  ; directed travel edge l1 -> l2
    (empty-bay     ?b  - bay)                       ; storage bay has no rock in it
    (in-bay        ?rk - rock     ?b - bay)         ; rock currently stored in a bay
    (carrying-drill ?r - rover    ?d - drill)       ; rover has picked up the drill
    (hard          ?rk - rock)                      ; rock requires drill to collect
    (soft          ?rk - rock)                      ; rock can be collected directly
  )

  ;; ----------------------------------------------------------
  ;; MOVE: travel along a connected (directed) edge.
  ;; Two-way routes are modelled as two (connected ..) facts
  ;; (one in each direction); the one-way slope has only one.
  ;; ----------------------------------------------------------
  (:action move
    :parameters (?r - rover ?from - location ?to - location)
    :precondition (and
      (rover-at ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (rover-at ?r ?from))
      (rover-at ?r ?to)
    )
  )

  ;; ----------------------------------------------------------
  ;; PICK-DRILL: pick up the drill at the rover's current
  ;; location. Once picked up it is kept for the whole mission
  ;; (no "put-down-drill" action exists).
  ;; ----------------------------------------------------------
  (:action pick-drill
    :parameters (?r - rover ?d - drill ?l - location)
    :precondition (and
      (rover-at ?r ?l)
      (drill-at ?d ?l)
    )
    :effect (and
      (not (drill-at ?d ?l))
      (carrying-drill ?r ?d)
    )
  )

  ;; ----------------------------------------------------------
  ;; COLLECT-SOFT: pick up a soft rock into an empty bay.
  ;; No drill required.
  ;; ----------------------------------------------------------
  (:action collect-soft
    :parameters (?r - rover ?rk - rock ?b - bay ?l - location)
    :precondition (and
      (rover-at ?r ?l)
      (rock-at ?rk ?l)
      (empty-bay ?b)
      (soft ?rk)
    )
    :effect (and
      (not (rock-at ?rk ?l))
      (not (empty-bay ?b))
      (in-bay ?rk ?b)
    )
  )

  ;; ----------------------------------------------------------
  ;; COLLECT-HARD: pick up a hard rock into an empty bay.
  ;; Requires the rover to already be carrying the drill.
  ;; ----------------------------------------------------------
  (:action collect-hard
    :parameters (?r - rover ?rk - rock ?b - bay ?l - location ?d - drill)
    :precondition (and
      (rover-at ?r ?l)
      (rock-at ?rk ?l)
      (empty-bay ?b)
      (hard ?rk)
      (carrying-drill ?r ?d)
    )
    :effect (and
      (not (rock-at ?rk ?l))
      (not (empty-bay ?b))
      (in-bay ?rk ?b)
    )
  )

  ;; ----------------------------------------------------------
  ;; DEPOSIT: drop a carried rock at the rover's current
  ;; location, freeing the bay it occupied.
  ;; ----------------------------------------------------------
  (:action deposit
    :parameters (?r - rover ?rk - rock ?b - bay ?l - location)
    :precondition (and
      (rover-at ?r ?l)
      (in-bay ?rk ?b)
    )
    :effect (and
      (not (in-bay ?rk ?b))
      (empty-bay ?b)
      (rock-at ?rk ?l)
    )
  )

)
