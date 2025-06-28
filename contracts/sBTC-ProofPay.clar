
;; sBTC-ProofPay
;; Decentralized Escrow and Reputation Management

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-RECIPIENT (err u3))
(define-constant ERR-TRANSACTION-NOT-FOUND (err u4))
(define-constant ERR-INVALID-POINTS (err u5))
(define-constant ERR-INVALID-TRANSACTION-ID (err u6))

;; Validate recipient is not the sender
(define-private (is-valid-recipient (recipient principal))
  (and 
    (not (is-eq recipient tx-sender))
    (not (is-eq recipient CONTRACT-OWNER))
  )
)

;; Validate transaction ID
(define-private (is-valid-transaction-id (id uint))
  (and 
    (> id u0)
    (< id (var-get next-transaction-id))
  )
)

;; Transaction Map
(define-map transactions 
  { id: uint }
  {
    sender: principal,
    recipient: principal,
    amount: uint,
    status: (string-ascii 20),
    created-at: uint,
    reputation-points: uint
  }
)

;; User Reputation Map
(define-map user-reputation 
  { user: principal }
  { total-points: uint, total-transactions: uint }
)

;; Generate unique transaction ID
(define-data-var next-transaction-id uint u1)

;; Create new transaction
(define-public (create-transaction 
  (recipient principal) 
  (amount uint)
)
  (begin
    ;; Validate recipient
    (asserts! (is-valid-recipient recipient) ERR-INVALID-RECIPIENT)

    ;; Validate amount
    (asserts! (> amount u0) ERR-INSUFFICIENT-FUNDS)

    (let 
      (
        (transaction-id (var-get next-transaction-id))
      )
      ;; Increment transaction ID
      (var-set next-transaction-id (+ transaction-id u1))

      ;; Store transaction
      (map-set transactions 
        { id: transaction-id }
        {
          sender: tx-sender,
          recipient: recipient,
          amount: amount,
          status: "PENDING",
          created-at: stacks-block-height,
          reputation-points: u0
        }
      )

      (ok transaction-id)
    )
  )
)
