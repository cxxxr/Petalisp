;;; © 2016-2017 Marco Heisig - licensed under AGPLv3, see the file COPYING

(in-package :petalisp)

;;; this function is derived from CLOCC, credit goes to Sam Steingold
(defun function-lambda-list (function)
  "Return the lambda list of FUNCTION. Signal an error if the
implementation has no means to determine the function's lambda list."
  #+allegro (excl:arglist function)
  #+clisp (sys::arglist function)
  #+(or cmu scl)
  (let ((f (coerce function 'function)))
    (etypecase f
      (standard-generic-function (pcl:generic-function-lambda-list f))
      (eval:interpreted-function (eval:interpreted-function-arglist f))
      (function (read-from-string (kernel:%function-arglist f)))))
  #+cormanlisp (ccl:function-lambda-list
                (typecase function
                  (symbol (fdefinition function))
                  (t function)))
  #+gcl (let ((f (etypecase function
                   (symbol function)
                   (function (si:compiled-function-name function)))))
          (get f 'si:debug))
  #+lispworks (lw:function-lambda-list function)
  #+lucid (lcl:arglist function)
  #+sbcl (sb-introspect:function-lambda-list function)
  #-(or allegro clisp cmu scl cormanlisp gcl lispworks lucid sbcl)
  (error "Not implemented."))

(defun check-arity (function arity)
  "Signal an error of type SIMPLE-PROGRAM-ERROR if FUNCTION cannot be
  called with ARITY arguments."
  (let ((mandatory-arguments 0)
        (max-arguments 0)
        (upper-bound? t)
        (mandatory-increment 1)
        (max-increment 1))
    (declare
     (type (integer 0 #.call-arguments-limit)
           arity
           mandatory-arguments max-arguments
           mandatory-increment max-increment)
     (type boolean upper-bound?))
    (dolist (item (function-lambda-list function))
      (case item
        (&key      (setf max-increment 2) (setf mandatory-increment 0))
        (&optional (setf max-increment 1) (setf mandatory-increment 0))
        (&aux      (setf max-increment 0) (setf mandatory-increment 0))
        ((&rest &allow-other-keys)
         (setf max-increment 0)
         (setf mandatory-increment 0)
         (setf upper-bound? nil))
        (t
         (incf mandatory-arguments mandatory-increment)
         (incf max-arguments max-increment))))
    (when (< arity mandatory-arguments)
      (simple-program-error
       "Only ~R argument~:P given for a function with ~R mandatory argument~:P."
       arity mandatory-arguments))
    (when (and upper-bound? (> arity max-arguments))
      (simple-program-error
       "Received ~R argument~:P for a function that accepts at most ~R argument~:P."
       arity max-arguments))))
