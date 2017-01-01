(use-modules (artanis artanis))
(use-modules (artanis utils))

(load "db.scm")
(load "session.scm")
(init-server)

(get "/session" #:session #t
     (lambda (rc) 
       (format #f "Session: ~a" (session-sid rc))))

(get "/setpid/:pid" #:session #t
     (lambda (rc) 
       (session-set rc "pid" (params rc "pid"))
       (format #f "PID ~a" (params rc "pid"))))

(get "/getpid" #:session #t
     (lambda (rc)
       (format #f "PID: ~a" (session-get rc "pid"))))

(get "/login" #:session #t
     (lambda (rc)
       (let* ((cor (not (params rc "incorrect")))
	     (page (tpl->html "login.tpl" (the-environment))))
	 (tpl->response "layout.tpl" (the-environment)))))

(get "/" #:session #t
     (lambda (rc)
       (let ((page (tpl->html "index.tpl" (the-environment))))
	 (tpl->response "layout.tpl" (the-environment)))))

(get "/do_login" #:session #t
      (lambda (rc)
	(let* ((pid (params rc "pid"))
	       (pin_cor (let ((res (db-query
			        (format #f
				  "SELECT pin FROM patients WHERE pid='~a'"
				  pid))))
                          (cond 
			    ((null? res) "")
			    (else (cdr (car (car res)))))))
	       (cor (string=?
		      (params rc "pin")
		      pin_cor))
	       (page (tpl->html 
		       (cond (cor "index.tpl") (else "login.tpl"))
		       (the-environment))))
	  (format #t "pcor: ~a - pin: ~a - cor: ~a~%" pin_cor (params rc "pin") cor)
	  (cond
	    (cor 
	      (session-set rc "pid" pid)
	      (redirect-to rc "/"))
	    (else
	      (redirect-to rc "/login?incorrect=true"))))))


(run #:port 8080) 
