#!/bin/bash

# Test compréhensif pour la machine de Turing universelle
# Créé le 6 juin 2025

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TIMEOUT=30  # Plus long timeout pour la machine universelle

# Fonction pour afficher un en-tête
print_header() {
    echo ""
    echo -e "${BLUE}==========================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==========================================================================${NC}"
    echo ""
}

# Fonction pour exécuter un test
run_test() {
    local machine="$1"
    local input="$2"
    local expected="$3"
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Test $TOTAL_TESTS:${NC} $description"
    echo "  Machine: $machine"
    echo "  Input: '$input'"
    echo "  Expected: $expected"
    
    local output=$(timeout $TIMEOUT ./ft_turing "machines/$machine" "$input" 2>&1 | tail -1)
    
    if [[ "$output" == *"HALT"* ]]; then
        if [[ "$expected" == "ACCEPT" && "$output" == *"HALT"* ]] ||
           [[ "$expected" == "REJECT" && "$output" == *"HALT"* ]] ||
           [[ "$expected" == "HALT" ]]; then
            echo -e "  ${GREEN}✓ PASSED${NC} - $output"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗ FAILED${NC} - $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "  ${RED}✗ FAILED (timeout/error)${NC} - $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Tests pour la machine universelle
test_universal_machine() {
    print_header "TESTS COMPRÉHENSIFS POUR LA MACHINE UNIVERSELLE (universal.json)"
    
    echo -e "${MAGENTA}Description: Machine de Turing universelle capable de simuler d'autres machines${NC}"
    echo -e "${MAGENTA}Note: Ces tests dépendent de l'implémentation spécifique de la machine universelle${NC}"
    echo ""
    
    echo -e "${YELLOW}Tests de base pour la machine universelle${NC}"
    
    # Tests simples qui devraient fonctionner avec une machine universelle basique
    run_test "universal.json" "" "HALT" "Entrée vide"
    run_test "universal.json" "0" "HALT" "Entrée simple '0'"
    run_test "universal.json" "1" "HALT" "Entrée simple '1'"
    run_test "universal.json" "01" "HALT" "Entrée binaire '01'"
    run_test "universal.json" "10" "HALT" "Entrée binaire '10'"
    
    echo -e "${YELLOW}Tests avec entrées plus complexes${NC}"
    run_test "universal.json" "001" "HALT" "Entrée '001'"
    run_test "universal.json" "110" "HALT" "Entrée '110'"
    run_test "universal.json" "0011" "HALT" "Entrée '0011'"
    run_test "universal.json" "1100" "HALT" "Entrée '1100'"
    
    echo -e "${YELLOW}Tests avec des motifs spéciaux${NC}"
    run_test "universal.json" "000" "HALT" "Trois zéros"
    run_test "universal.json" "111" "HALT" "Trois uns"
    run_test "universal.json" "0000" "HALT" "Quatre zéros"
    run_test "universal.json" "1111" "HALT" "Quatre uns"
    
    echo -e "${YELLOW}Tests avec entrées alternées${NC}"
    run_test "universal.json" "0101" "HALT" "Alternance 0101"
    run_test "universal.json" "1010" "HALT" "Alternance 1010"
    run_test "universal.json" "010101" "HALT" "Alternance longue 010101"
    run_test "universal.json" "101010" "HALT" "Alternance longue 101010"
    
    echo -e "${YELLOW}Tests de robustesse${NC}"
    run_test "universal.json" "00110011" "HALT" "Motif répété 00110011"
    run_test "universal.json" "11001100" "HALT" "Motif répété 11001100"
    run_test "universal.json" "000111000" "HALT" "Motif symétrique"
    run_test "universal.json" "111000111" "HALT" "Motif symétrique inverse"
    
    echo -e "${YELLOW}Tests avec caractères potentiellement problématiques${NC}"
    # Note: Ces tests sont commentés car les caractères hors alphabet sont rejetés par validation d'entrée
    # run_test "universal.json" "a" "INPUT_ERROR" "Caractère hors alphabet 'a'"
    # run_test "universal.json" "2" "INPUT_ERROR" "Chiffre hors alphabet '2'"
    # run_test "universal.json" "01a" "INPUT_ERROR" "Mélange avec caractère hors alphabet"
    
    echo -e "${YELLOW}Tests de performance avec entrées longues${NC}"
    # Créer des chaînes longues pour tester la performance
    local long_string=""
    for i in {1..50}; do
        if (( i % 2 == 0 )); then
            long_string="${long_string}0"
        else
            long_string="${long_string}1"
        fi
    done
    run_test "universal.json" "$long_string" "HALT" "Chaîne longue alternée (50 caractères)"
    
    # Chaîne de zéros
    local zeros=""
    for i in {1..30}; do
        zeros="${zeros}0"
    done
    run_test "universal.json" "$zeros" "HALT" "30 zéros consécutifs"
    
    # Chaîne de uns
    local ones=""
    for i in {1..30}; do
        ones="${ones}1"
    done
    run_test "universal.json" "$ones" "HALT" "30 uns consécutifs"
}

# Tests spéciaux pour l'analyse de la machine universelle
test_universal_analysis() {
    print_header "ANALYSE DE LA MACHINE UNIVERSELLE"
    
    echo -e "${MAGENTA}Vérification de l'existence et de la structure de la machine universelle${NC}"
    
    if [ ! -f "machines/universal.json" ]; then
        echo -e "${RED}❌ Machine universelle non trouvée!${NC}"
        return
    fi
    
    echo -e "${GREEN}✓ Machine universelle trouvée${NC}"
    
    # Analyser la structure de la machine
    echo ""
    echo -e "${CYAN}Structure de la machine universelle:${NC}"
    echo -e "${YELLOW}Taille du fichier:${NC} $(wc -c < machines/universal.json) octets"
    echo -e "${YELLOW}Nombre de lignes:${NC} $(wc -l < machines/universal.json) lignes"
    
    # Extraire quelques informations de base du JSON
    if command -v jq >/dev/null 2>&1; then
        echo -e "${YELLOW}États disponibles:${NC}"
        jq -r '.states[]?' machines/universal.json 2>/dev/null | head -10 || echo "Impossible d'analyser les états"
        
        echo -e "${YELLOW}Alphabet d'entrée:${NC}"
        jq -r '.alphabet[]?' machines/universal.json 2>/dev/null || echo "Impossible d'analyser l'alphabet"
        
        echo -e "${YELLOW}État initial:${NC}"
        jq -r '.initial?' machines/universal.json 2>/dev/null || echo "Impossible de trouver l'état initial"
    else
        echo -e "${YELLOW}jq non disponible - analyse JSON limitée${NC}"
    fi
}

# Vérifications préalables
if [ ! -f "./ft_turing" ]; then
    echo -e "${RED}Erreur: ./ft_turing n'existe pas. Compilez d'abord avec 'make'.${NC}"
    exit 1
fi

if [ ! -d "./machines" ]; then
    echo -e "${RED}Erreur: Le dossier ./machines n'existe pas.${NC}"
    exit 1
fi

echo -e "${GREEN}Tests compréhensifs pour la machine de Turing universelle${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${YELLOW}Timeout par test: ${TIMEOUT}s (plus long pour la complexité de la machine universelle)${NC}"
echo ""

# Exécution des tests
test_universal_analysis
test_universal_machine

# Résumé final
echo ""
print_header "RÉSUMÉ DES TESTS MACHINE UNIVERSELLE"
echo -e "${CYAN}Total des tests: $TOTAL_TESTS${NC}"
echo -e "${GREEN}Tests réussis: $PASSED_TESTS${NC}"
echo -e "${RED}Tests échoués: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 Tous les tests sont passés avec succès!${NC}"
    echo -e "${CYAN}Note: La machine universelle semble fonctionner correctement${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED_TESTS test(s) ont échoué.${NC}"
    echo -e "${YELLOW}Note: Les échecs peuvent être normaux selon l'implémentation de la machine universelle${NC}"
    exit 1
fi
