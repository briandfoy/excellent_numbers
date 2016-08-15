(defun is-excellent (number)
	"Determine is ab = b^2 - a^2"
	(let ((ab-string (write-to-string number)))
		(let ((ab-length (length ab-string)))
			(format t "String: ~a~%Length: ~a~%" ab-string ab-length)
			(let ((a (parse-integer (subseq ab-string 0 (/ ab-length 2))))
			      (b (parse-integer (subseq ab-string (/ ab-length 2)))))
			      	(format t "a: ~a~%b: ~a~%" a b)
			      	(if (= (- (* b b) (* a a )) number) t nil)
	))))

(princ (is-excellent 3468))
