This is a simple class whose central method accepts a list of objects returned by JSON.deserializeUntyped() and iteratively rebuilds that tree as a flat map whose keys are the flattened path to their field values. Typing of values is not guaranteed. 

It employs two parallel "stacks" to avoid blowing the backend callstack and destructively rebuilds its tree parameter to (try to) avoid blowing the heap. 

This is not production-ready code. It is provided as-is and was designed to solve a very specific but non-trivial problem for which I couldn't find any sufficient tooling. Its primary use is exploratory and dev-facing.
