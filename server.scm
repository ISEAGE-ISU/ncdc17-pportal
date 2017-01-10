(use-modules (artanis artanis))
(use-modules (artanis utils))

(load "db.scm")
(load "session.scm")
(init-server)

(define require-login
  (lambda (rc if-logged-in)
    (let ((pid (session-get rc "pid")))
      (format #t "Pid: ~a" pid)
      (cond
        ((or (not (string? pid)) (string=? pid ""))
         (let* (
                (cor #t)
                (page (tpl->html "login.tpl" (the-environment))))
           (tpl->response "layout.tpl" (the-environment))))
        (else (if-logged-in rc))))))

(get "/session" #:session #t
     (lambda (rc) 
       (format #f "Session: ~a" (session-sid rc))))

(get "/setpid/:pid" #:session #t
     (lambda (rc) 
       (session-set rc "pid" (params rc "pid"))
       (format #f "PID ~a" (params rc "pid"))))

(get "/getpid" #:session #t
     (lambda (rc)
       (require-login rc (lambda (rc) 
                           (format #f "PID: ~a" (session-get rc "pid"))))))

(get "/login" #:session #t
     (lambda (rc)
       (let* ((cor (not (params rc "incorrect")))
              (page (tpl->html "login.tpl" (the-environment))))
         (tpl->response "layout.tpl" (the-environment)))))

(get "/" #:session #t
     (lambda (rc)
       (let ((page (tpl->html "index.tpl" (the-environment))))
         (tpl->response "layout.tpl" (the-environment)))))

(get "/logout" #:session #t
     (lambda (rc)
       (session-set rc "pid" "")
       (let ((page (tpl->html "index.tpl" (the-environment))))
         (tpl->response "layout.tpl" (the-environment)))))

(get "/do_login" #:session #t
     (lambda (rc)
       (let* ((uname (params rc "uname"))
              (pid (let ((res (db-query
                                (format #f 
                                        "SELECT id FROM pdata WHERE uname='~a'"
                                        uname))))
                     (cond
                       ((null? res) "")
                       (else (cdr (car (car res)))))))
              (pin_cor (let ((res (db-query
                                    (format #f
                                            "SELECT pin FROM pdata WHERE id='~a'"
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
         (db-query "SELECT * FROM pdata")
         (format 
           #t 
           "uname: ~a pid: ~a pcor: ~a - pin: ~a - cor: ~a~%" 
           uname pid pin_cor (params rc "pin") cor)
         (cond
           (cor 
             (session-set rc "pid" pid)
             (let ((page (tpl->html "index.tpl" (the-environment))))
               (tpl->response "layout.tpl" (the-environment))))
           (else
             (let ((page (tpl->html "login.tpl" (the-environment))))
               (response-emit 
                (tpl->html "layout.tpl" (the-environment))
                #:status 401)))))))


(get "/showdata/:data" #:session #t
     (lambda (rc)
       (let ((data (rc params "data")))
         (cond 
           ((string=? data "appointments"
                      ))))))


                      (run #:port 8080) 
