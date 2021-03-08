;;;; © 2016-2021 Marco Heisig         - license: GNU AGPLv3 -*- coding: utf-8 -*-

(in-package #:petalisp.core)

(defun lazy-ref (input shape transformation)
  (let* ((relevant-shape (transform-shape shape transformation))
         (input-shape (lazy-array-shape input)))
    (unless (and (= (shape-rank relevant-shape)
                    (shape-rank input-shape))
                 (subshapep relevant-shape input-shape))
      (error "~@<Invalid reference to ~S with shape ~S and transformation ~S.~:@>"
             input shape transformation))
    (lazy-ref-aux input shape transformation relevant-shape)))

(defgeneric lazy-ref-aux (input shape transformation relevant-shape )
  (:argument-precedence-order transformation shape input relevant-shape))

;;; Optimization: Compose consecutive references.
(defmethod lazy-ref-aux
    ((lazy-reshape lazy-reshape)
     (shape non-empty-shape)
     (transformation transformation)
     (relevant-shape non-empty-shape))
  (lazy-ref-aux
   (lazy-array-input lazy-reshape)
   shape
   (compose-transformations
    (transformation lazy-reshape)
    transformation)
   (transform-shape relevant-shape (transformation lazy-reshape))))

;;; Optimization: Drop references with no effect.
(defmethod lazy-ref-aux
    ((lazy-array lazy-array)
     (shape non-empty-shape)
     (identity-transformation identity-transformation)
     (relevant-shape non-empty-shape))
  (if (and (shape-equal (lazy-array-shape lazy-array) shape)
           ;; Don't drop references to range immediates.  The reason for
           ;; this is that we never want these immediates to appear as
           ;; roots of a data flow graph.
           (not (typep lazy-array 'range-immediate)))
      lazy-array
      (call-next-method)))

;;; Optimization: Skip references to lazy fuse operations in case they fall
;;; entirely within a single input of that fusion.
(defmethod lazy-ref-aux
    ((lazy-fuse lazy-fuse)
     (shape non-empty-shape)
     (transformation transformation)
     (relevant-shape non-empty-shape))
  (loop for input in (lazy-array-inputs lazy-fuse)
        when (subshapep relevant-shape (lazy-array-shape input)) do
          (return-from lazy-ref-aux
            (lazy-ref-aux input shape transformation relevant-shape)))
  (call-next-method))

;;; Handle empty shapes.
(defmethod lazy-ref-aux
    ((lazy-array lazy-array)
     (empty-shape empty-shape)
     (transformation transformation)
     (relevant-shape non-empty-shape))
  (empty-array))

;;; Default: Construct a new reference.
(defmethod lazy-ref-aux
    ((lazy-array lazy-array)
     (shape non-empty-shape)
     (transformation transformation)
     (relevant-shape non-empty-shape))
  (make-instance 'lazy-reshape
    :ntype (element-ntype lazy-array)
    :inputs (list lazy-array)
    :shape shape
    :transformation (add-transformation-constraints shape transformation)))

;;; We can turn each axis of the resulting shape that consists of a single
;;; element into an additional input constraint for the transformation.
;;; This augmentation is important, because the additional constraints can
;;; turn a previously non-invertible transformation invertible.
(defun add-transformation-constraints (shape transformation)
  (if (loop for range in (shape-ranges shape)
            for mask-entry across (transformation-input-mask transformation)
            never (and (size-one-range-p range)
                       (not mask-entry)))
      transformation
      (let ((input-mask (copy-seq (transformation-input-mask transformation))))
        (loop for range in (shape-ranges shape)
              for index from 0
              when (size-one-range-p range)
                do (setf (aref input-mask index)
                         (range-start range)))
        (compose-transformations
         transformation
         (make-transformation :input-mask input-mask)))))

(defun transform-lazy-array (lazy-array transformation)
  (declare (lazy-array lazy-array)
           (transformation transformation))
  (lazy-ref
   lazy-array
   (transform-shape (lazy-array-shape lazy-array) transformation)
   (invert-transformation transformation)))
