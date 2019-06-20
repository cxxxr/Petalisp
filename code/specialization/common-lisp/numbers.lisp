;;;; © 2016-2019 Marco Heisig         - license: GNU AGPLv3 -*- coding: utf-8 -*-

(in-package #:petalisp.specialization)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Auxiliary Functions

(defun slow-numeric-contagion (&rest type-codes)
  (labels ((initial-state ()
             (type-code-subtypecase (pop type-codes)
               ((not number) (type-code-from-type-specifier 'nil))
               (short-float (short-float-state))
               (single-float (single-float-state))
               (double-float (double-float-state))
               (long-float (long-float-state))
               (float (float-state))
               (integer (integer-state))
               (rational (rational-state))
               (real (real-state))
               ((complex short-float) (complex-short-float-state))
               ((complex single-float) (complex-single-float-state))
               ((complex double-float) (complex-double-float-state))
               ((complex long-float) (complex-long-float-state))
               (complex (complex-state))
               (t (number-state))))
           (short-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'short-float)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (short-float-state))
                   (single-float (single-float-state))
                   (double-float (double-float-state))
                   (long-float (long-float-state))
                   (float (float-state))
                   (integer (short-float-state))
                   (rational (short-float-state))
                   (real (real-state))
                   ((complex short-float) (complex-short-float-state))
                   ((complex single-float) (complex-single-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (single-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'single-float)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (single-float-state))
                   (single-float (single-float-state))
                   (double-float (double-float-state))
                   (long-float (long-float-state))
                   (float (float-state))
                   (integer (single-float-state))
                   (rational (single-float-state))
                   (real (real-state))
                   ((complex short-float) (complex-single-float-state))
                   ((complex single-float) (complex-single-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (double-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'double-float)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (double-float-state))
                   (single-float (double-float-state))
                   (double-float (double-float-state))
                   (long-float (long-float-state))
                   (float (float-state))
                   (integer (double-float-state))
                   (rational (double-float-state))
                   (real (real-state))
                   ((complex short-float) (complex-double-float-state))
                   ((complex single-float) (complex-double-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (long-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'long-float)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (long-float-state))
                   (single-float (long-float-state))
                   (double-float (long-float-state))
                   (long-float (long-float-state))
                   (float (float-state))
                   (integer (long-float-state))
                   (rational (long-float-state))
                   (real (real-state))
                   ((complex short-float) (complex-long-float-state))
                   ((complex single-float) (complex-long-float-state))
                   ((complex double-float) (complex-long-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'float)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (float-state))
                   (single-float (float-state))
                   (double-float (float-state))
                   (long-float (float-state))
                   (float (float-state))
                   (integer (float-state))
                   (rational (float-state))
                   (real (real-state))
                   ((complex short-float) (complex-state))
                   ((complex single-float) (complex-state))
                   ((complex double-float) (complex-state))
                   ((complex long-float) (complex-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (integer-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'integer)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (short-float-state))
                   (single-float (single-float-state))
                   (double-float (double-float-state))
                   (long-float (long-float-state))
                   (float (float-state))
                   (integer (integer-state))
                   (rational (rational-state))
                   (real (real-state))
                   ((complex short-float) (complex-short-float-state))
                   ((complex single-float) (complex-single-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (rational-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'rational)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (short-float-state))
                   (single-float (single-float-state))
                   (double-float (double-float-state))
                   (long-float (long-float-state))
                   (float (float-state))
                   (integer (rational-state))
                   (rational (rational-state))
                   (real (real-state))
                   ((complex short-float) (complex-short-float-state))
                   ((complex single-float) (complex-single-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (real-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'real)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (real-state))
                   (single-float (real-state))
                   (double-float (real-state))
                   (long-float (real-state))
                   (float (real-state))
                   (integer (real-state))
                   (rational (real-state))
                   (real (real-state))
                   ((complex short-float) (complex-state))
                   ((complex single-float) (complex-state))
                   ((complex double-float) (complex-state))
                   ((complex long-float) (complex-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (complex-short-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier '(complex short-float))
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (complex-short-float-state))
                   (single-float (complex-single-float-state))
                   (double-float (complex-double-float-state))
                   (long-float (complex-long-float-state))
                   (float (complex-state))
                   (integer (complex-short-float-state))
                   (rational (complex-short-float-state))
                   (real (complex-state))
                   ((complex short-float) (complex-short-float-state))
                   ((complex single-float) (complex-single-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (complex-single-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier '(complex single-float))
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (complex-single-float-state))
                   (single-float (complex-single-float-state))
                   (double-float (complex-double-float-state))
                   (long-float (complex-long-float-state))
                   (float (complex-state))
                   (integer (complex-single-float-state))
                   (rational (complex-single-float-state))
                   (real (complex-state))
                   ((complex short-float) (complex-single-float-state))
                   ((complex single-float) (complex-single-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (complex-double-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier '(complex double-float))
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (complex-double-float-state))
                   (single-float (complex-double-float-state))
                   (double-float (complex-double-float-state))
                   (long-float (complex-long-float-state))
                   (float (complex-state))
                   (integer (complex-double-float-state))
                   (rational (complex-double-float-state))
                   (real (complex-state))
                   ((complex short-float) (complex-double-float-state))
                   ((complex single-float) (complex-double-float-state))
                   ((complex double-float) (complex-double-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (complex-long-float-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier '(complex long-float))
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (short-float (complex-long-float-state))
                   (single-float (complex-long-float-state))
                   (double-float (complex-long-float-state))
                   (long-float (complex-long-float-state))
                   (float (complex-state))
                   (integer (complex-long-float-state))
                   (rational (complex-long-float-state))
                   (real (complex-state))
                   ((complex short-float) (complex-long-float-state))
                   ((complex single-float) (complex-long-float-state))
                   ((complex double-float) (complex-long-float-state))
                   ((complex long-float) (complex-long-float-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (complex-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'complex)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (float (complex-state))
                   (integer (complex-state))
                   (rational (complex-state))
                   (real (complex-state))
                   (complex (complex-state))
                   (t (number-state)))))
           (number-state ()
             (if (null type-codes)
                 (type-code-from-type-specifier 'number)
                 (type-code-subtypecase (pop type-codes)
                   ((not number) (type-code-from-type-specifier 'nil))
                   (t (number-state))))))
    (initial-state)))

(defun numeric-contagion (type-code-1 type-code-2)
  (with-type-code-caching (type-code-1 type-code-2)
    (slow-numeric-contagion type-code-1 type-code-2)))

(defun complex-part-type-code (type-code)
  (type-code-subtypecase type-code
    ((not complex) (type-code-from-type-specifier 'nil))
    ((complex short-float) (type-code-from-type-specifier 'short-float))
    ((complex single-float) (type-code-from-type-specifier 'single-float))
    ((complex double-float) (type-code-from-type-specifier 'double-float))
    ((complex long-float) (type-code-from-type-specifier 'long-float))
    (t (type-code-from-type-specifier 'real))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Addition

(defop (+ integer-+) (integer) (integer integer))
(defop (+ rational-+) (rational) (rational rational))
(defop (+ short-float-+) (short-float) (short-float short-float))
(defop (+ single-float-+) (single-float) (single-float single-float))
(defop (+ double-float-+) (double-float) (double-float double-float))
(defop (+ long-float-+) (long-float) (long-float long-float))
(defop (+ complex-short-float-+) (complex-short-float) (complex-short-float complex-short-float))
(defop (+ complex-single-float-+) (complex-single-float) (complex-single-float complex-single-float))
(defop (+ complex-double-float-+) (complex-double-float) (complex-double-float complex-double-float))
(defop (+ complex-long-float-+) (complex-long-float) (complex-long-float complex-long-float))

(defop (+ binary-+) (number) (number number) (a b)
  (type-code-subtypecase (numeric-contagion a b)
    ((not number) (abort-specialization))
    (integer
     (rewrite-as
      (integer-+
       (the-integer a)
       (the-integer b))))
    (rational
     (rewrite-as
      (rational-+
       (the-rational a)
       (the-rational b))))
    (short-float
     (rewrite-as
      (short-float-+
       (coerce-to-short-float a)
       (coerce-to-short-float b))))
    (single-float
     (rewrite-as
      (single-float-+
       (coerce-to-single-float a)
       (coerce-to-single-float b))))
    (double-float
     (rewrite-as
      (double-float-+
       (coerce-to-double-float a)
       (coerce-to-double-float b))))
    (long-float
     (rewrite-as
      (long-float-+
       (coerce-to-long-float a)
       (coerce-to-long-float b))))
    ((complex short-float)
     (rewrite-as
      (complex-short-float-+
       (coerce-to-complex-short-float a)
       (coerce-to-complex-short-float b))))
    ((complex single-float)
     (rewrite-as
      (complex-single-float-+
       (coerce-to-complex-single-float a)
       (coerce-to-complex-single-float b))))
    ((complex double-float)
     (rewrite-as
      (complex-double-float-+
       (coerce-to-complex-double-float a)
       (coerce-to-complex-double-float b))))
    ((complex long-float)
     (rewrite-as
      (complex-long-float-+
       (coerce-to-complex-long-float a)
       (coerce-to-complex-long-float b))))))

(define-external-rewrite-rule + (&rest numbers)
  (if (null numbers)
      (rewrite-let () 0)
      (labels ((rewrite-+ (number more-numbers)
                 (if (null more-numbers)
                     (rewrite-let ((number (process-argument number)))
                       (rewrite-as (the-number number)))
                     (rewrite-let ((a (process-argument number))
                                   (b (rewrite-+ (first more-numbers) (rest more-numbers))))
                       (rewrite-as (binary-+ a b))))))
        (rewrite-+ (first numbers) (rest numbers)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Multiplication

(defop (* integer-*) (integer) (integer integer))
(defop (* rational-*) (rational) (rational rational))
(defop (* short-float-*) (short-float) (short-float short-float))
(defop (* single-float-*) (single-float) (single-float single-float))
(defop (* double-float-*) (double-float) (double-float double-float))
(defop (* long-float-*) (long-float) (long-float long-float))
(defop (* complex-short-float-*) (complex-short-float) (complex-short-float complex-short-float))
(defop (* complex-single-float-*) (complex-single-float) (complex-single-float complex-single-float))
(defop (* complex-double-float-*) (complex-double-float) (complex-double-float complex-double-float))
(defop (* complex-long-float-*) (complex-long-float) (complex-long-float complex-long-float))

(defop (* binary-*) (number) (number number) (a b)
  (type-code-subtypecase (numeric-contagion a b)
    ((not number) (abort-specialization))
    (integer
     (rewrite-as
      (integer-*
       (the-integer a)
       (the-integer b))))
    (rational
     (rewrite-as
      (rational-*
       (the-rational a)
       (the-rational b))))
    (short-float
     (rewrite-as
      (short-float-*
       (coerce-to-short-float a)
       (coerce-to-short-float b))))
    (single-float
     (rewrite-as
      (single-float-*
       (coerce-to-single-float a)
       (coerce-to-single-float b))))
    (double-float
     (rewrite-as
      (double-float-*
       (coerce-to-double-float a)
       (coerce-to-double-float b))))
    (long-float
     (rewrite-as
      (long-float-*
       (coerce-to-long-float a)
       (coerce-to-long-float b))))
    ((complex short-float)
     (rewrite-as
      (complex-short-float-*
       (coerce-to-complex-short-float a)
       (coerce-to-complex-short-float b))))
    ((complex single-float)
     (rewrite-as
      (complex-single-float-*
       (coerce-to-complex-single-float a)
       (coerce-to-complex-single-float b))))
    ((complex double-float)
     (rewrite-as
      (complex-double-float-*
       (coerce-to-complex-double-float a)
       (coerce-to-complex-double-float b))))
    ((complex long-float)
     (rewrite-as
      (complex-long-float-*
       (coerce-to-complex-long-float a)
       (coerce-to-complex-long-float b))))))
