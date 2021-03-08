;;;; Note: This file is not intended to be LOADed from Lisp, but to be
;;;; executed expression by expression.

(asdf:test-system :petalisp)

(defpackage #:petalisp.examples.getting-started
  (:use #:common-lisp #:petalisp))

(in-package #:petalisp.examples.getting-started)

(defun present (&rest arrays)
  (format t "~{~& => ~A~}" (compute-list-of-arrays arrays)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Petalisp Basics

(present
 (reshape 0 (~))) ; the empty space

(defun zeros (shape)
  (reshape 0 shape))

(present
 (zeros (~ 10))) ; ten zeros

(present
 (array-indices (zeros (~ 10)))) ; the numbers from 0 to 9 (inclusive)

(present
 (reshape #2a((1 2 3 4) (5 6 7 8)) (~ 0 2 ~ 1 3))) ; selecting values

(present
 (reshape #2a((1 2 3 4) (5 6 7 8))
          (transform i j to j i))) ; transforming

;; arrays can be merged with fuse

(present (fuse (reshape 5 (~ 0 3))
               (reshape 1 (~ 3 6))))

;; arrays can be overwritten with fuse*

(present
 (fuse* (zeros (~ 10 ~ 10))
        (reshape 1 (~ 2 8 ~ 2 8))))

;; lazy arrays permit beautiful functional abstractions

(defun chessboard (h w)
  (fuse (reshape 0 (~ 0 h 2 ~ 0 w 2))
        (reshape 0 (~ 1 h 2 ~ 1 w 2))
        (reshape 1 (~ 0 h 2 ~ 1 w 2))
        (reshape 1 (~ 1 h 2 ~ 0 w 2))))

(present
 (chessboard 8 8))

;; lazy applies a Lisp function element-wise

(present
 (lazy #'+ #(1 2 3) #(1 1 1)))

(present
 (lazy #'* 2 3)) ; scalar are treated as rank zero arrays

(present
 (lazy #'* 2 #(1 2 3))) ; lazy broadcasts automatically

;; lazy-reduce reduces array elements

(present
 (lazy-reduce #'+ #(1 2 3 4 5 6 7 8 9 10)))

(present
 (lazy-reduce #'+
    ;; only the axis zero is reduced
    #2A((1 2 3) (4 5 6))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Matrix multiplication

(defun matmul (A B)
  (lazy-reduce #'+
     (lazy #'*
        (reshape A (transform m n to n m 0))
        (reshape B (transform n k to n 0 k)))))

(defparameter MI #2a((1.0 0.0)
                     (0.0 1.0)))

(defparameter MA #2a((2.0 3.0)
                     (4.0 5.0)))

(present (matmul MI MI))

(present (matmul MI MA))

(present (matmul MA MA))

(present
 (matmul (reshape 3.0 (~ 4 ~ 8))
         (reshape 2.0 (~ 8 ~ 4))))

(defparameter M (reshape #(1 2 3 4 5 6) (~ 6 ~ 6)))

(present M)

(present
 (matmul M (reshape M (transform m n to n m))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Jacobi's Method

(defun jacobi-2d (grid)
  (let ((interior (array-interior grid)))
    (fuse*
     grid
     (lazy #'* 1/4
        (lazy #'+
           (reshape grid (transform i j to (1+ i) j) interior)
           (reshape grid (transform i j to (1- i) j) interior)
           (reshape grid (transform i j to i (1+ j)) interior)
           (reshape grid (transform i j to i (1- j)) interior))))))

(defparameter domain
  (fuse* (reshape 1.0 (~ 10 ~ 10))
         (reshape 0.0 (~ 1 9 ~ 1 9))))

(present domain)

(present
 (jacobi-2d domain))

(present
 (jacobi-2d
  (jacobi-2d domain)))

;;; Finally, let's have a glimpse at the Petalisp data flow representation
;;; of Jacobi's algorithm and the corresponding IR.

(petalisp.graphviz:view
 (list
  (jacobi-2d
   (jacobi-2d domain))))

(petalisp.graphviz:view
 (petalisp.ir:ir-from-lazy-arrays
  (list
   (jacobi-2d
    (jacobi-2d domain)))))
