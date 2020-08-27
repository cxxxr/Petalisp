(in-package :common-lisp-user)

(defpackage #:petalisp.examples.linear-algebra
  (:use
   #:common-lisp
   #:petalisp)
  (:export
   #:matrix
   #:square-matrix
   #:zeros
   #:eye
   #:transpose
   #:norm
   #:dot
   #:asum
   #:max*
   #:matmul
   #:lu))

(in-package #:petalisp.examples.linear-algebra)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Matrix Utilities

(defun coerce-to-matrix (x)
  (setf x (lazy-array x))
  (trivia:ematch (array-shape x)
    ((~)
     (reshape x (~ 1 ~ 1)))
    ((~l (list range))
     (reshape x (~ (range-size range) ~ 1)))
    ((~l (list range-1 range-2))
     (reshape x (~ (range-size range-1) ~ (range-size range-2))))))

(defun coerce-to-scalar (x)
  (setf x (lazy-array x))
  (trivia:ematch (array-shape x)
    ((~) x)
    ((~ i 1+i)
     (unless (= (1+ i) 1+i)
       (trivia.fail:fail))
     (reshape x (make-transformation :input-mask (vector i) :output-rank 0)))
    ((~ i 1+i ~ j 1+j)
     (unless (and (= (1+ i) 1+i)
                  (= (1+ j) 1+j))
       (trivia.fail:fail))
     (reshape x (make-transformation :input-mask (vector i j) :output-rank 0)))))

(trivia:defpattern matrix (m n)
  (alexandria:with-gensyms (it)
    `(trivia:guard1 ,it (lazy-array-p ,it)
                    (array-shape ,it) (~ ,m ~ ,n))))

(trivia:defpattern square-matrix (m)
  (alexandria:with-gensyms (g)
    `(matrix (and ,m ,g) (= ,g))))

(trivia:defun-match matrix-p (object)
  ((matrix _ _) t)
  (_ nil))

(trivia:defun-match square-matrix-p (object)
  ((square-matrix _) t)
  (_ nil))

(deftype matrix ()
  '(satisfies matrix-p))

(deftype square-matrix ()
  '(satisfies square-matrix-p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Linear Algebra Subroutines

(defun zeros (m &optional (n m))
  (reshape 0 (~ m ~ n)))

(declaim (inline δ))
(defun δ (i j)
  (declare (type integer i j))
  (if (= i j) 1 0))

(defun eye (m &optional (n m))
  (let ((shape (~ m ~ n)))
    (α #'δ
       (indices shape 0)
       (indices shape 1))))

(defun transpose (x)
  (reshape
   (coerce-to-matrix x)
   (τ (m n) (n m))))

(defun dot (x y)
  (coerce-to-scalar
   (matmul
    (transpose x)
    (coerce-to-matrix y))))

(defun norm (x)
  (α #'sqrt (dot x x)))

(defun sum (x &optional axis)
  (β* #'+ 0 x axis))

(defun product (x &optional axis)
  (β* #'* 1 x axis))

(defun asum (x)
  (coerce-to-scalar
   (β #'+ (α #'abs (coerce-to-matrix x)))))

(defun max* (x)
  (β (lambda (lv li rv ri)
       (if (> lv rv)
           (values lv li)
           (values rv ri)))
     x (indices x)))

(defun matmul (A B)
  (β #'+
     (α #'*
        (reshape (coerce-to-matrix A) (τ (m n) (n m 0)))
        (reshape (coerce-to-matrix B) (τ (n k) (n 0 k))))))

(defun pivot-and-value (A d)
  (setf A (coerce-to-matrix A))
  (trivia:ematch A
    ((square-matrix m)
     (multiple-value-bind (v p)
         (max* (α #'abs (reshape A (~ d m ~ d (1+ d)))))
       (let ((p (coerce-to-scalar p))
             (v (coerce-to-scalar v)))
         ;(schedule A p v)
         (compute p v))))))

(defun swap-rows (A i j)
  (setf A (coerce-to-matrix A))
  (trivia:ematch A
    ((square-matrix m)
     (assert (< -1 i m))
     (assert (< -1 j m))
     (if (= i j)
         A
         (let ((si (~ i (1+ i) ~ m))
               (sj (~ j (1+ j) ~ m)))
           (fuse* A
                  (reshape A sj si)
                  (reshape A si sj)))))))

(defun lu (A)
  (setf A (coerce-to-matrix A))
  (trivia:ematch A
    ((square-matrix m)
     (labels
         ((rec (d P L U)
            (if (= (1+ d) m)
                (values (transpose P) L U)
                (multiple-value-bind (pivot value)
                    (pivot-and-value U d)
                  (assert (not (zerop value)))
                  (let* ((P (swap-rows P d pivot))
                         (L (swap-rows L d pivot))
                         (U (swap-rows U d pivot))
                         (S (α #'/ (reshape U (~ (1+ d) m ~ d (1+ d)))
                               (coerce-to-matrix value))))
                    (rec (1+ d)
                         P
                         (fuse* L S (reshape 1 (~ d (1+ d) ~ d (1+ d))))
                         (fuse* U
                                (α #'-
                                   (reshape U (~ (1+ d) m ~ d m))
                                   (α #'* S (reshape U (~ d (1+ d) ~ d m)))))))))))
       (rec 0 (eye m) (zeros m) A)))))
