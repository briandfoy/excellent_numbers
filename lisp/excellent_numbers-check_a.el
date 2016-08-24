(load "excellent_numbers.el")

(show-number *PHI*);

(loop for n from 1 to 10
	do (loop for a from n to (high-by-magnitude n)
		do (format t "~a ~a ~%" a (high-by-magnitude n))))



		;do (if (is-excellent ab) (show-number ab))))
