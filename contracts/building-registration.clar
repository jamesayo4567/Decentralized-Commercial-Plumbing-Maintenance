;; Building Registration Contract
;; Records details of commercial structures

(define-data-var last-building-id uint u0)

;; Building data structure
(define-map buildings
  { building-id: uint }
  {
    name: (string-utf8 100),
    address: (string-utf8 100),
    owner: principal,
    year-built: uint,
    total-floors: uint,
    registration-date: uint
  }
)

;; Register a new building
(define-public (register-building
    (name (string-utf8 100))
    (address (string-utf8 100))
    (year-built uint)
    (total-floors uint))
  (let
    (
      (new-id (+ (var-get last-building-id) u1))
      (owner tx-sender)
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    ;; Update last building ID
    (var-set last-building-id new-id)

    ;; Add building to buildings map
    (map-set buildings
      { building-id: new-id }
      {
        name: name,
        address: address,
        owner: owner,
        year-built: year-built,
        total-floors: total-floors,
        registration-date: current-time
      }
    )

    (ok new-id)
  )
)

;; Get building details
(define-read-only (get-building (building-id uint))
  (map-get? buildings { building-id: building-id })
)

;; Update building details
(define-public (update-building
    (building-id uint)
    (name (string-utf8 100))
    (address (string-utf8 100))
    (year-built uint)
    (total-floors uint))
  (let
    (
      (building (unwrap! (map-get? buildings { building-id: building-id }) (err u1)))
      (owner (get owner building))
    )
    ;; Check if sender is the owner
    (asserts! (is-eq tx-sender owner) (err u2))

    ;; Update building details
    (map-set buildings
      { building-id: building-id }
      {
        name: name,
        address: address,
        owner: owner,
        year-built: year-built,
        total-floors: total-floors,
        registration-date: (get registration-date building)
      }
    )

    (ok true)
  )
)

;; Transfer building ownership
(define-public (transfer-building (building-id uint) (new-owner principal))
  (let
    (
      (building (unwrap! (map-get? buildings { building-id: building-id }) (err u1)))
      (current-owner (get owner building))
    )
    ;; Check if sender is the owner
    (asserts! (is-eq tx-sender current-owner) (err u2))

    ;; Update building owner
    (map-set buildings
      { building-id: building-id }
      (merge building { owner: new-owner })
    )

    (ok true)
  )
)
