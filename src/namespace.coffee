# Nib Namespace
#
# This file's purpose is simply to define the nib Namespace
# and serve as a reference to the required load order for nib project files.
root = exports ? this
root.Nib =
  Plugins: {}

# Reqired Load Order:
# 1. Namespace
# 2. Events
# 3. Utils
# 4. Selection Handler
# 5. Editor
# 6. Pugins
