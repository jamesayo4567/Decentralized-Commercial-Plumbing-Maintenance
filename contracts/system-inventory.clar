;; System Inventory Contract
;; Tracks fixtures and water infrastructure

(define-data-var last-inventory-id uint u0)

;; Inventory item types
(define-constant FIXTURE_TYPE_SINK u1)
(define-constant FIXTURE_TYPE_TOILET u2)
(define-constant FIXTURE_TYPE_SHOWER u3)
(define-constant FIXTURE_TYPE_WATER_HEATER u4)
(define-constant FIXTURE_TYPE_PIPE u5)
(define-constant FIXTURE_TYPE_VALVE u6)
(define-constant FIXTURE_TYPE_PUMP u7)
(define-constant FIXTURE_TYPE_OTHER u8)

;; Inventory data structure
(define-map inventory-items
  { inventory-id: uint }
  {
    building-id: uint,
    item-type: uint,
    description: (string-utf8 100),
    location: (string-utf8 100),
    installation-date: uint,
    manufacturer: (string-utf8 100),
    model: (string-utf8 100),
    last-maintenance-date: (optional uint)
  }
)

;; Add inventory item
(define-public (add-inventory-item
    (building-id uint)
    (item-type uint)
    (description (string-utf8 100))
    (location (string-utf8 100))
    (installation-date uint)
    (manufacturer (string-utf8 100))
    (model (string-utf8 100)))
  (let
    (
      (new-id (+ (var-get last-inventory-id) u1))
    )
    ;; Update last inventory ID
    (var-set last-inventory-id new-id)

    ;; Add item to inventory map
    (map-set inventory-items
      { inventory-id: new-id }
      {
        building-id: building-id,
        item-type: item-type,
        description: description,
        location: location,
        installation-date: installation-date,
        manufacturer: manufacturer,
        model: model,
        last-maintenance-date: none
      }
    )

    (ok new-id)
  )
)

;; Get inventory item details
(define-read-only (get-inventory-item (inventory-id uint))
  (map-get? inventory-items { inventory-id: inventory-id })
)

;; Update inventory item
(define-public (update-inventory-item
    (inventory-id uint)
    (description (string-utf8 100))
    (location (string-utf8 100))
    (manufacturer (string-utf8 100))
    (model (string-utf8 100)))
  (let
    (
      (item (unwrap! (map-get? inventory-items { inventory-id: inventory-id }) (err u1)))
    )
    ;; Update inventory item details
    (map-set inventory-items
      { inventory-id: inventory-id }
      (merge item {
        description: description,
        location: location,
        manufacturer: manufacturer,
        model: model
      })
    )

    (ok true)
  )
)

;; Update maintenance date
(define-public (update-maintenance-date (inventory-id uint) (maintenance-date uint))
  (let
    (
      (item (unwrap! (map-get? inventory-items { inventory-id: inventory-id }) (err u1)))
    )
    ;; Update maintenance date
    (map-set inventory-items
      { inventory-id: inventory-id }
      (merge item { last-maintenance-date: (some maintenance-date) })
    )

    (ok true)
  )
)

;; Remove inventory item
(define-public (remove-inventory-item (inventory-id uint))
  (begin
    ;; Delete the item from inventory map
    (map-delete inventory-items { inventory-id: inventory-id })
    (ok true)
  )
)
