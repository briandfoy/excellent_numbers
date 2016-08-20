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
	(let ((power (floor (log number 10))))
		(if (evenp power)
			nil
			(let ((half-power (expt 10 (/ (+ power 1) 2))))
				;(format t "power is ~a half is ~a~%" power half-power)
				(let (
					(a (floor (/ number half-power)))
					(b (mod number half-power)))
					;(format t "ab ~a -> a ~a b ~a~%" number a b)
					(cons a b))))))

(defun is-excellent (number)
	"Determine is ab = b^2 - a^2"
	(let ((a-b (split-into-a-b-log number)))
		(if a-b
			(if (=
					(-
						(expt (cdr a-b) 2)
						(expt (car a-b) 2))
					number)
			t nil)
			nil)
	))


(loop for n from 0 to 4
	do (loop for ab from (expt 10 (+ (* n 2) 1 ) ) to (- (expt 10 (+ (+ (* n 2) 1 ) 1)) 1 )
		do (if (is-excellent ab) (format t "[~a] ~a~%" (get-internal-real-time) ab))
		)
	)


