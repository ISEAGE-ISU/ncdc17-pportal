(use-modules (dbi dbi))

(define db-open
    (lambda ()
      (dbi-open "postgresql" "jake::jake:tcp:localhost:5432")))

(define db-query
  (lambda (query)
    (let ((conn (db-open)))
      (dbi-query conn query)
      (let get-row ((rows '()) (row (dbi-get_row conn)))
        (cond
          (row
            (get-row (append rows (cons row '())) (dbi-get_row conn)))
          (else
            (dbi-close conn)
            rows))))))

