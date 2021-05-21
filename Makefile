all:
	dune exec bin/main.exe --root ./tools 

watch:
	dune exec bin/main.exe --root ./tools -- watch 

deps:
	opam install dune core yojson jingoo ppx_deriving
