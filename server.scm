(use-modules (artanis artanis))
(init-server)

(get "/sessions" #:conn #t
     (lambda (rc)
       (let ((mtable (map-table-from-DB (:conn rc))))
	 (object->string
	   (mtable 'get 'sessions #:columns '(pid sid))))))

(run #:use-db? #t #:port 8080)
