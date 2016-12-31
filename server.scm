(use-modules (artanis artanis))
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

(run #:port 8080) 
