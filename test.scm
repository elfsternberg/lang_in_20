(define fact 
  (lambda (x) 
    (if (== x 1) 1
        (* x (fact (- x 1))))))

(fact 6)
  
