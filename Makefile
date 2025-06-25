NAME = ft_turing
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLFIND = ocamlfind

PACKAGES = yojson

SRC_DIR = src
BUILD_DIR = build

ML_FILES = types.ml parsing.ml validation.ml display.ml execution.ml main.ml
ML_PATHS = $(addprefix $(SRC_DIR)/,$(ML_FILES))
CMX_FILES = $(patsubst $(SRC_DIR)/%.ml,$(BUILD_DIR)/%.cmx,$(ML_PATHS))
CMO_FILES = $(patsubst $(SRC_DIR)/%.ml,$(BUILD_DIR)/%.cmo,$(ML_PATHS))

.PHONY: all clean fclean re install_deps check_deps debug test

all: check_deps $(NAME)

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

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLOPT) -package $(PACKAGES) -I $(BUILD_DIR) -c -o $@ $<

$(BUILD_DIR)/%.cmo: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -package $(PACKAGES) -I $(BUILD_DIR) -c -o $@ $<

$(NAME): $(BUILD_DIR) $(CMX_FILES)
	$(OCAMLFIND) $(OCAMLOPT) -package $(PACKAGES) -linkpkg -I $(BUILD_DIR) -o $(NAME) $(CMX_FILES)

debug: $(BUILD_DIR) $(CMO_FILES)
	$(OCAMLFIND) $(OCAMLC) -package $(PACKAGES) -linkpkg -I $(BUILD_DIR) -o $(NAME)_debug $(CMO_FILES)

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(NAME) $(NAME)_debug

fclean: clean

re: fclean all

test: $(NAME)
	./$(NAME) machines/unary_sub.json "111-11="