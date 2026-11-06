(define (problem mars-rover-base)
  (:domain mars-rover)

  (:objects
    Base SiteA SiteB SiteC SiteD SiteE SiteF - location
    Curiosity - rover
    Bay1 Bay2 - bay
    Drill1 - drill
    Rock1 Rock2 Rock3 Rock4 Rock5 - rock
  )

  (:init
    ;; Rover, drill, rocks: starting locations
    (rover-at Curiosity Base)
    (drill-at Drill1 SiteE)
    (rock-at Rock1 SiteA)
    (rock-at Rock2 SiteB)
    (rock-at Rock3 SiteC)
    (rock-at Rock4 SiteD)
    (rock-at Rock5 SiteF)

    ;; Both bays start empty
    (empty-bay Bay1)
    (empty-bay Bay2)

    ;; Rock hardness
    (soft Rock1)
    (soft Rock2)
    (hard Rock3)
    (soft Rock4)
    (hard Rock5)

    ;; ---- Two-way routes (one (connected ..) fact per direction) ----
    (connected Base SiteA)   (connected SiteA Base)
    (connected Base SiteB)   (connected SiteB Base)
    (connected SiteA SiteC)  (connected SiteC SiteA)
    (connected SiteB SiteD)  (connected SiteD SiteB)
    (connected SiteC SiteE)  (connected SiteE SiteC)
    (connected SiteD SiteE)  (connected SiteE SiteD)
    (connected SiteE SiteF)  (connected SiteF SiteE)

    ;; ---- One-way route: steep downhill slope, SiteC -> SiteD only ----
    (connected SiteC SiteD)
  )

  (:goal (and
    (rock-at Rock1 Base)
    (rock-at Rock2 Base)
    (rock-at Rock3 Base)
    (rock-at Rock4 Base)
    (rock-at Rock5 Base)
    (empty-bay Bay1)
    (empty-bay Bay2)
    (rover-at Curiosity Base)
  ))
)
