;;;; © 2016-2020 Marco Heisig         - license: GNU AGPLv3 -*- coding: utf-8 -*-

(in-package #:petalisp.graphviz)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Classes

(defclass data-flow-graph (petalisp-graph)
  ())

(defclass data-flow-edge (petalisp-edge)
  ())

(defmethod graphviz-default-graph ((node petalisp.core:lazy-array))
  'data-flow-graph)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Connectivity

(defmethod graphviz-potential-edges append
    ((graph data-flow-graph)
     (node t))
  (list (make-instance 'data-flow-edge)))

(defmethod graphviz-incoming-edge-origins
    ((graph data-flow-graph)
     (edge data-flow-edge)
     (lazy-array petalisp.core:lazy-array))
  (petalisp.core:lazy-array-inputs lazy-array))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Node Appearance

(defmethod graphviz-node-attributes
    ((graph data-flow-graph)
     (immediate petalisp.core:array-immediate))
  `(:fillcolor "cadetblue1"))

(defmethod graphviz-node-attributes
    ((graph data-flow-graph)
     (immediate petalisp.core:lazy-map))
  `(:fillcolor "burlywood1"))

(defmethod graphviz-node-attributes
    ((graph data-flow-graph)
     (node petalisp.core:lazy-fuse))
  `(:fillcolor "cyan3"))

(defmethod graphviz-node-attributes
    ((graph data-flow-graph)
     (node petalisp.core:lazy-reshape))
  `(:fillcolor "gray"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Node Labels

(defmethod graphviz-node-properties append
    ((graph data-flow-graph)
     (lazy-array petalisp.core:lazy-array))
  `(("shape" . ,(stringify (petalisp.core:array-shape lazy-array)))
    ("element-type" . ,(stringify (petalisp.core:element-type lazy-array)))))

(defmethod graphviz-node-properties append
    ((graph data-flow-graph)
     (array-immediate petalisp.core:array-immediate))
  `(("storage" . ,(stringify (petalisp.core:array-immediate-storage array-immediate)))))

(defmethod graphviz-node-properties append
    ((graph data-flow-graph)
     (range-immediate petalisp.core:range-immediate))
  `())

(defmethod graphviz-node-properties append
    ((graph data-flow-graph)
     (node petalisp.core:lazy-map))
  `(("operator" . ,(stringify (petalisp.core:lazy-map-operator node)))))

(defmethod graphviz-node-properties append
    ((graph data-flow-graph)
     (node petalisp.core:lazy-reshape))
  `(("transformation" . ,(stringify (petalisp.core:transformation node)))))
