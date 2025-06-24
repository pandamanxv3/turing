NAME = ft_turing
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLFIND = ocamlfind

# Vérification des dépendances
PACKAGES = yojson

# Sources
SOURCES = ft_turing.ml

# Fichiers objets
OBJECTS = $(SOURCES:.ml=.cmo)
NATIVE_OBJECTS = $(SOURCES:.ml=.cmx)

.PHONY: all clean fclean re install_deps check_deps

all: check_deps $(NAME)

# Vérification et installation des dépendances
check_deps:
	@echo "Checking dependencies..."
	@command -v opam >/dev/null 2>&1 || { echo "OPAM is required but not installed. Please install OPAM first."; exit 1; }
	@for pkg in $(PACKAGES); do \
		if ! $(OCAMLFIND) query $$pkg >/dev/null 2>&1; then \
			echo "Installing missing package: $$pkg"; \
			opam install $$pkg -y; \
		fi; \
	done

install_deps:
	@echo "Installing dependencies via OPAM..."
	@for pkg in $(PACKAGES); do \
		opam install $$pkg -y; \
	done

# Compilation native (optimisée)
$(NAME): $(SOURCES)
	$(OCAMLFIND) $(OCAMLOPT) -package $(PACKAGES) -linkpkg -o $(NAME) $(SOURCES)

# Compilation bytecode (pour debug)
debug: $(SOURCES)
	$(OCAMLFIND) $(OCAMLC) -package $(PACKAGES) -linkpkg -o $(NAME)_debug $(SOURCES)

clean:
	rm -f *.cmo *.cmi *.cmx *.o

fclean: clean
	rm -f $(NAME) $(NAME)_debug

re: fclean all

# Test avec l'exemple fourni
test: $(NAME)
	./$(NAME) machines/unary_sub.json "111-11="