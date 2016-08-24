(defparameter *PHI* 0.619)

(defun split-into-a-b-string (number)
	"Split a number into two parts with equal digits"
	(let ((ab-string (write-to-string number)))
		(let ((ab-length (length ab-string)))
			(if (evenp ab-length)
				(let ((a (parse-integer (subseq ab-string 0 (/ ab-length 2))))
					  (b (parse-integer (subseq ab-string (/ ab-length 2)))))
						(cons a b))
				nil))))

(defun split-into-a-b-log (number)
	"Split a number into two parts with equal digits"
	(let ((power (floor (log number 10d0))))
		(if (evenp power)
			nil
			(let ((half-power (expt 10 (/ (+ power 1) 2))))
				;(format t "power is ~a half is ~a~%" power half-power)
				(let (
					(a (floor (/ number half-power)))
					(b (mod number half-power)))
					;(format t "ab ~a -> a ~a b ~a~%" number a b)
					(cons a b))))))

(defun diff-of-squares ( a-b )
	"Take a difference of squares
	 a-b is a cons of a and b
	 "
	(-
		(expt (cdr a-b) 2)
		(expt (car a-b) 2)))

(defun is-excellent (number)
	"Determine is ab = b^2 - a^2
	"
	(let ((a-b (split-into-a-b-log number)))
		(if a-b
			(if (= (diff-of-squares a-b) number)
				t
				nil)
			nil)))

(defun log-ceil (n)
	"Find the next higher power for the number
	I use this to shift a over to put it together with b
	to get ab.

	This fails when the input is exactly a power to ten,
	in which case it returns one less. For my purposes,
	this doesn't matter because it will never be a value
	of b
	"
	(ceiling (log n 10d0))
	)

(defun make-number-from-a-b (a b)
	"Put the halves back together to make ab
	"
	(+
		(* a (expt 10 (log-ceil b)))
		b))

(defun is-power-of-ten (n)
	(=
		(floor (log n 10))
		(log n 10)))

(defun low-by-power (n)
	(expt 10 (+ (* n 2) 1 )))

(defun high-by-power (n)
	(*
		*PHI*
		(-
		(expt 10 (+ (* n 2) 2 ) )
		1)))

(defun high-by-magnitude (n)
	"Return the highest number of a to check
	that's the same power of 10 as n
	"
	(ceiling
		(*
			*PHI*
			(expt
				10
				(log-ceil n)
				))))

(defun show-number (ab)
	(format t "[~a] ~a~%" (get-internal-real-time) ab))

