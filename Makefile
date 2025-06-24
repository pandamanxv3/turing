NAME = ft_turing
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLFIND = ocamlfind

PACKAGES = yojson

SRC_DIR = src
INTF_DIR = interfaces
BUILD_DIR = build

ML_FILES = $(SRC_DIR)/types.ml $(SRC_DIR)/parsing.ml $(SRC_DIR)/validation.ml $(SRC_DIR)/execution.ml $(SRC_DIR)/main.ml
MLI_FILES = $(INTF_DIR)/types.mli $(INTF_DIR)/parsing.mli $(INTF_DIR)/validation.mli $(INTF_DIR)/execution.mli

CMI_FILES = $(BUILD_DIR)/types.cmi $(BUILD_DIR)/parsing.cmi $(BUILD_DIR)/validation.cmi $(BUILD_DIR)/execution.cmi
CMX_FILES = $(BUILD_DIR)/types.cmx $(BUILD_DIR)/parsing.cmx $(BUILD_DIR)/validation.cmx $(BUILD_DIR)/execution.cmx $(BUILD_DIR)/main.cmx
CMO_FILES = $(BUILD_DIR)/types.cmo $(BUILD_DIR)/parsing.cmo $(BUILD_DIR)/validation.cmo $(BUILD_DIR)/execution.cmo $(BUILD_DIR)/main.cmo

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

# Compilation des interfaces
$(BUILD_DIR)/%.cmi: $(INTF_DIR)/%.mli | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -package $(PACKAGES) -c -o $@ $<

$(BUILD_DIR)/types.cmi: $(INTF_DIR)/types.mli | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -package $(PACKAGES) -c -o $@ $<

$(BUILD_DIR)/parsing.cmi: $(INTF_DIR)/parsing.mli $(BUILD_DIR)/types.cmi | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -I $(BUILD_DIR) -package $(PACKAGES) -c -o $@ $<

$(BUILD_DIR)/validation.cmi: $(INTF_DIR)/validation.mli $(BUILD_DIR)/types.cmi | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -I $(BUILD_DIR) -package $(PACKAGES) -c -o $@ $<

$(BUILD_DIR)/execution.cmi: $(INTF_DIR)/execution.mli $(BUILD_DIR)/types.cmi | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -I $(BUILD_DIR) -package $(PACKAGES) -c -o $@ $<

# Compilation des modules
$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml $(BUILD_DIR)/%.cmi | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLOPT) -I $(BUILD_DIR) -package $(PACKAGES) -c -o $@ $<

$(BUILD_DIR)/%.cmo: $(SRC_DIR)/%.ml $(BUILD_DIR)/%.cmi | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) -I $(BUILD_DIR) -package $(PACKAGES) -c -o $@ $<

$(BUILD_DIR)/main.cmx: $(SRC_DIR)/main.ml $(BUILD_DIR)/types.cmi $(BUILD_DIR)/parsing.cmi $(BUILD_DIR)/validation.cmi $(BUILD_DIR)/execution.cmi | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLOPT) -I $(BUILD_DIR) -package $(PACKAGES) -c -o $@ $<

# Lien
$(NAME): $(BUILD_DIR) $(CMX_FILES)
	$(OCAMLFIND) $(OCAMLOPT) -package $(PACKAGES) -linkpkg -o $(NAME) $(CMX_FILES)

debug: $(BUILD_DIR) $(CMO_FILES)
	$(OCAMLFIND) $(OCAMLC) -package $(PACKAGES) -linkpkg -o $(NAME)_debug $(CMO_FILES)

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(NAME) $(NAME)_debug

fclean: clean

re: fclean all

test: $(NAME)
	./$(NAME) machines/unary_sub.json "111-11="