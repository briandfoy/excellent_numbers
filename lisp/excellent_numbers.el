(defun is-excellent (number)
	"Determine is ab = b^2 - a^2"
	(let ((ab-string (write-to-string number)))
		(let ((ab-length (length ab-string)))
			(let ((a (parse-integer (subseq ab-string 0 (/ ab-length 2))))
			      (b (parse-integer (subseq ab-string (/ ab-length 2)))))
			      	(if (= (- (* b b) (* a a )) number) t nil)
	))))

(loop for n from 0 to 5
	do (loop for ab from (expt 10 (+ (* n 2) 1 ) ) to (- (expt 10 (+ (+ (* n 2) 1 ) 1)) 1 )
		do (if (is-excellent ab) (format t "~a~%" ab))
		)
	)
