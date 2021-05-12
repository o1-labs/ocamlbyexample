all:
	dune exec ./tools/bin/main.exe

watch:
	dune exec ./tools/bin/main.exe -- watch 
	
deps:
	opam install fileutils
