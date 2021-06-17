all:
	dune exec bin/main.exe --root ./tools 

watch:
	dune exec bin/main.exe --root ./tools -- watch 

deps:
	opam install . --deps-only
