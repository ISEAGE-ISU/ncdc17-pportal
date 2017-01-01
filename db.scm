(use-modules (dbi dbi))

(define db-query
  (lambda (query)
    (let ((conn (dbi-open "postgresql" "pportal::pportal:tcp:localhost:5432")))
      (dbi-query conn query)
      (let get-row ((rows '()) (row (dbi-get_row conn)))
        (cond
          (row
            (get-row (append rows (cons row '())) (dbi-get_row conn)))
          (else
	    ;(dbi-close conn)
            rows))))))
