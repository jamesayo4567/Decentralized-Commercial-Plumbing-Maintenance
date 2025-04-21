;; Maintenance Scheduling Contract
;; Manages regular inspections and repairs

(define-data-var last-maintenance-id uint u0)

;; Maintenance status constants
(define-constant STATUS_SCHEDULED u1)
(define-constant STATUS_IN_PROGRESS u2)
(define-constant STATUS_COMPLETED u3)
(define-constant STATUS_CANCELLED u4)

;; Maintenance type constants
(define-constant TYPE_INSPECTION u1)
(define-constant TYPE_REPAIR u2)
(define-constant TYPE_REPLACEMENT u3)
(define-constant TYPE_EMERGENCY u4)

;; Maintenance data structure
(define-map maintenance-records
  { maintenance-id: uint }
  {
    building-id: uint,
    inventory-id: (optional uint),
    maintenance-type: uint,
    description: (string-utf8 100),
    scheduled-date: uint,
    status: uint,
    assigned-to: (optional principal),
    completion-date: (optional uint),
    notes: (optional (string-utf8 100))
  }
)

;; Schedule maintenance
(define-public (schedule-maintenance
    (building-id uint)
    (inventory-id (optional uint))
    (maintenance-type uint)
    (description (string-utf8 100))
    (scheduled-date uint)
    (assigned-to (optional principal)))
  (let
    (
      (new-id (+ (var-get last-maintenance-id) u1))
    )
    ;; Update last maintenance ID
    (var-set last-maintenance-id new-id)

    ;; Add record to maintenance map
    (map-set maintenance-records
      { maintenance-id: new-id }
      {
        building-id: building-id,
        inventory-id: inventory-id,
        maintenance-type: maintenance-type,
        description: description,
        scheduled-date: scheduled-date,
        status: STATUS_SCHEDULED,
        assigned-to: assigned-to,
        completion-date: none,
        notes: none
      }
    )

    (ok new-id)
  )
)

;; Get maintenance record
(define-read-only (get-maintenance-record (maintenance-id uint))
  (map-get? maintenance-records { maintenance-id: maintenance-id })
)

;; Update maintenance status
(define-public (update-maintenance-status (maintenance-id uint) (new-status uint))
  (let
    (
      (record (unwrap! (map-get? maintenance-records { maintenance-id: maintenance-id }) (err u1)))
    )
    ;; Update status
    (map-set maintenance-records
      { maintenance-id: maintenance-id }
      (merge record { status: new-status })
    )

    (ok true)
  )
)

;; Complete maintenance
(define-public (complete-maintenance (maintenance-id uint) (notes (optional (string-utf8 100))))
  (let
    (
      (record (unwrap! (map-get? maintenance-records { maintenance-id: maintenance-id }) (err u1)))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    ;; Update record
    (map-set maintenance-records
      { maintenance-id: maintenance-id }
      (merge record {
        status: STATUS_COMPLETED,
        completion-date: (some current-time),
        notes: notes
      })
    )

    (ok true)
  )
)

;; Cancel maintenance
(define-public (cancel-maintenance (maintenance-id uint) (notes (optional (string-utf8 100))))
  (let
    (
      (record (unwrap! (map-get? maintenance-records { maintenance-id: maintenance-id }) (err u1)))
    )
    ;; Update record
    (map-set maintenance-records
      { maintenance-id: maintenance-id }
      (merge record {
        status: STATUS_CANCELLED,
        notes: notes
      })
    )

    (ok true)
  )
)
