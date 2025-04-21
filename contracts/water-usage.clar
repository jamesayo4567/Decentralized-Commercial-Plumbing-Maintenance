;; Water Usage Contract
;; Monitors consumption and identifies leaks

(define-data-var last-reading-id uint u0)
(define-data-var last-alert-id uint u0)

;; Reading data structure
(define-map water-readings
  { reading-id: uint }
  {
    building-id: uint,
    timestamp: uint,
    meter-reading: uint,  ;; in gallons or liters
    reader: principal
  }
)

;; Leak alerts data structure
(define-map leak-alerts
  { alert-id: uint }
  {
    building-id: uint,
    detected-at: uint,
    consumption-rate: uint,  ;; consumption per hour
    threshold: uint,
    status: uint  ;; 1: active, 2: resolved
  }
)

;; Add water meter reading
(define-public (add-water-reading
    (building-id uint)
    (meter-reading uint))
  (let
    (
      (new-id (+ (var-get last-reading-id) u1))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    ;; Update last reading ID
    (var-set last-reading-id new-id)

    ;; Add reading to map
    (map-set water-readings
      { reading-id: new-id }
      {
        building-id: building-id,
        timestamp: current-time,
        meter-reading: meter-reading,
        reader: tx-sender
      }
    )

    (ok new-id)
  )
)

;; Get water reading
(define-read-only (get-water-reading (reading-id uint))
  (map-get? water-readings { reading-id: reading-id })
)

;; Create leak alert
(define-public (create-leak-alert
    (building-id uint)
    (consumption-rate uint)
    (threshold uint))
  (let
    (
      (new-id (+ (var-get last-alert-id) u1))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    ;; Update last alert ID
    (var-set last-alert-id new-id)

    ;; Add alert to map
    (map-set leak-alerts
      { alert-id: new-id }
      {
        building-id: building-id,
        detected-at: current-time,
        consumption-rate: consumption-rate,
        threshold: threshold,
        status: u1  ;; active
      }
    )

    (ok new-id)
  )
)

;; Get leak alert
(define-read-only (get-leak-alert (alert-id uint))
  (map-get? leak-alerts { alert-id: alert-id })
)

;; Resolve leak alert
(define-public (resolve-leak-alert (alert-id uint))
  (let
    (
      (alert (unwrap! (map-get? leak-alerts { alert-id: alert-id }) (err u1)))
    )
    ;; Update alert status
    (map-set leak-alerts
      { alert-id: alert-id }
      (merge alert { status: u2 })  ;; resolved
    )

    (ok true)
  )
)
