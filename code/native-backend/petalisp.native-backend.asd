(defsystem "petalisp.native-backend"
  :author "Marco Heisig <marco.heisig@fau.de>"
  :license "AGPLv3"

  :depends-on
  ("alexandria"
   "bordeaux-threads"
   "lparallel"
   "trivia"
   "petalisp.core"
   "petalisp.ir")

  :serial t
  :components
  ((:file "packages")
   (:file "utilities")
   (:file "basic-block")
   (:file "lambda-block")
   (:file "loop-block")
   (:file "tail-block")
   (:file "translation-unit")
   (:file "blueprint-compiler")
   (:file "memory-pool")
   (:file "native-backend")
   (:file "execution")))
