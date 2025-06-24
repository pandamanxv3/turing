#!/bin/bash

# Script de test complet pour toutes les machines de Turing
# Créé le 6 juin 2025

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteurs globaux
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Timeout pour chaque test (en secondes)
TIMEOUT=15

# Fonction pour afficher un en-tête de section
print_header() {
    echo ""
    echo -e "${BLUE}=================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=================================================================================${NC}"
    echo ""
}

# Fonction pour exécuter un test
run_test() {
    local machine="$1"
    local input="$2"
    local expected_result="$3"
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${YELLOW}Test $TOTAL_TESTS: $description${NC}"
    echo "  Machine: $machine"
    echo "  Input: '$input'"
    echo "  Expected: $expected_result"
    
    # Exécution du test avec timeout
    local output=$(timeout $TIMEOUT ./ft_turing "machines/$machine" "$input" 2>&1 | tail -1)
    
    # Vérification du résultat
    if [[ "$output" == *"HALT"* ]]; then
        if [[ "$expected_result" == "ACCEPT" && "$output" == *"HALT"* ]] || 
           [[ "$expected_result" == "REJECT" && "$output" == *"HALT"* ]] ||
           [[ "$expected_result" == "HALT" ]]; then
            echo -e "  ${GREEN}✓ PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗ FAILED${NC}"
            echo "    Output: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "  ${RED}✗ FAILED (No HALT or timeout)${NC}"
        echo "    Output: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Vérification que le binaire existe
if [ ! -f "./ft_turing" ]; then
    echo -e "${RED}Erreur: ./ft_turing n'existe pas. Compilez d'abord avec 'make'.${NC}"
    exit 1
fi

# Vérification que le dossier machines existe
if [ ! -d "./machines" ]; then
    echo -e "${RED}Erreur: Le dossier ./machines n'existe pas.${NC}"
    exit 1
fi

echo -e "${GREEN}Script de test complet pour les machines de Turing${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo ""

# ===============================================================================
# TESTS POUR LA MACHINE PALINDROME
# ===============================================================================

print_header "TESTS POUR LA MACHINE PALINDROME (palindrome.json)"
echo "Cette machine détermine si une chaîne binaire est un palindrome."

# Tests basiques - palindromes valides
run_test "palindrome.json" "0" "ACCEPT" "Un seul caractère '0'"
run_test "palindrome.json" "1" "ACCEPT" "Un seul caractère '1'"

# Tests palindromes courts
run_test "palindrome.json" "00" "ACCEPT" "Palindrome court '00'"
run_test "palindrome.json" "11" "ACCEPT" "Palindrome court '11'"
run_test "palindrome.json" "010" "ACCEPT" "Palindrome impair '010'"
run_test "palindrome.json" "101" "ACCEPT" "Palindrome impair '101'"
run_test "palindrome.json" "0110" "ACCEPT" "Palindrome pair '0110'"
run_test "palindrome.json" "1001" "ACCEPT" "Palindrome pair '1001'"

# Tests palindromes plus longs
run_test "palindrome.json" "01010" "ACCEPT" "Palindrome long '01010'"
run_test "palindrome.json" "10101" "ACCEPT" "Palindrome long '10101'"
run_test "palindrome.json" "001100" "ACCEPT" "Palindrome pair '001100'"
run_test "palindrome.json" "110011" "ACCEPT" "Palindrome pair '110011'"
run_test "palindrome.json" "0001000" "ACCEPT" "Palindrome avec zéros '0001000'"
run_test "palindrome.json" "1110111" "ACCEPT" "Palindrome avec uns '1110111'"

# Tests non-palindromes
run_test "palindrome.json" "01" "REJECT" "Non-palindrome simple '01'"
run_test "palindrome.json" "10" "REJECT" "Non-palindrome simple '10'"
run_test "palindrome.json" "001" "REJECT" "Non-palindrome '001'"
run_test "palindrome.json" "110" "REJECT" "Non-palindrome '110'"
run_test "palindrome.json" "0011" "REJECT" "Non-palindrome '0011'"
run_test "palindrome.json" "1100" "REJECT" "Non-palindrome '1100'"
run_test "palindrome.json" "01011" "REJECT" "Non-palindrome '01011'"
run_test "palindrome.json" "10100" "REJECT" "Non-palindrome '10100'"
run_test "palindrome.json" "000111" "REJECT" "Non-palindrome '000111'"
run_test "palindrome.json" "111000" "REJECT" "Non-palindrome '111000'"

# Tests cas extrêmes
run_test "palindrome.json" "0000" "ACCEPT" "Tous zéros '0000'"
run_test "palindrome.json" "1111" "ACCEPT" "Tous uns '1111'"
run_test "palindrome.json" "00000" "ACCEPT" "Tous zéros impair '00000'"
run_test "palindrome.json" "11111" "ACCEPT" "Tous uns impair '11111'"

# ===============================================================================
# TESTS POUR LA MACHINE ADDITION UNAIRE
# ===============================================================================

print_header "TESTS POUR LA MACHINE ADDITION UNAIRE (unary_add.json)"
echo "Cette machine effectue l'addition en notation unaire avec le symbole '+'."

# Tests basiques
run_test "unary_add.json" "1+1" "HALT" "Addition simple 1+1"
run_test "unary_add.json" "1+" "HALT" "Addition 1+0 (1+)"
run_test "unary_add.json" "+1" "HALT" "Addition 0+1 (+1)"
run_test "unary_add.json" "+" "HALT" "Addition 0+0 (+)"

# Tests additions simples
run_test "unary_add.json" "11+1" "HALT" "Addition 2+1"
run_test "unary_add.json" "1+11" "HALT" "Addition 1+2"
run_test "unary_add.json" "11+11" "HALT" "Addition 2+2"
run_test "unary_add.json" "111+1" "HALT" "Addition 3+1"
run_test "unary_add.json" "1+111" "HALT" "Addition 1+3"

# Tests additions moyennes
run_test "unary_add.json" "111+111" "HALT" "Addition 3+3"
run_test "unary_add.json" "1111+11" "HALT" "Addition 4+2"
run_test "unary_add.json" "11+1111" "HALT" "Addition 2+4"
run_test "unary_add.json" "11111+1" "HALT" "Addition 5+1"
run_test "unary_add.json" "1+11111" "HALT" "Addition 1+5"

# Tests additions plus grandes
run_test "unary_add.json" "1111111+111" "HALT" "Addition 7+3"
run_test "unary_add.json" "111+1111111" "HALT" "Addition 3+7"
run_test "unary_add.json" "11111+11111" "HALT" "Addition 5+5"

# ===============================================================================
# TESTS POUR LA MACHINE 0^2n
# ===============================================================================

print_header "TESTS POUR LA MACHINE 0^2n (unary_02n.json)"
echo "Cette machine accepte les chaînes avec un nombre pair de '0'."

# Tests acceptation (nombre pair de 0)
run_test "unary_02n.json" "00" "ACCEPT" "Deux zéros"
run_test "unary_02n.json" "0000" "ACCEPT" "Quatre zéros"
run_test "unary_02n.json" "000000" "ACCEPT" "Six zéros"
run_test "unary_02n.json" "00000000" "ACCEPT" "Huit zéros"
run_test "unary_02n.json" "0000000000" "ACCEPT" "Dix zéros"

# Tests rejet (nombre impair de 0)
run_test "unary_02n.json" "0" "REJECT" "Un zéro"
run_test "unary_02n.json" "000" "REJECT" "Trois zéros"
run_test "unary_02n.json" "00000" "REJECT" "Cinq zéros"
run_test "unary_02n.json" "0000000" "REJECT" "Sept zéros"
run_test "unary_02n.json" "000000000" "REJECT" "Neuf zéros"

# Tests avec caractères invalides (devrait rejeter)
run_test "unary_02n.json" "1" "REJECT" "Caractère invalide '1'"
run_test "unary_02n.json" "01" "REJECT" "Mélange '01'"
run_test "unary_02n.json" "10" "REJECT" "Mélange '10'"
run_test "unary_02n.json" "001" "REJECT" "Mélange '001'"

# ===============================================================================
# TESTS POUR LA MACHINE 0^n1^n
# ===============================================================================

print_header "TESTS POUR LA MACHINE 0^n1^n (unary_0n1n.json)"
echo "Cette machine accepte les chaînes de la forme 0^n1^n (n ≥ 0)."

# Tests acceptation (0^n1^n valides)
run_test "unary_0n1n.json" "01" "ACCEPT" "n=1: un zéro, un un"
run_test "unary_0n1n.json" "0011" "ACCEPT" "n=2: deux zéros, deux uns"
run_test "unary_0n1n.json" "000111" "ACCEPT" "n=3: trois zéros, trois uns"
run_test "unary_0n1n.json" "00001111" "ACCEPT" "n=4: quatre zéros, quatre uns"
run_test "unary_0n1n.json" "0000011111" "ACCEPT" "n=5: cinq zéros, cinq uns"
run_test "unary_0n1n.json" "000000111111" "ACCEPT" "n=6: six zéros, six uns"

# Tests rejet (mauvais ordre)
run_test "unary_0n1n.json" "10" "REJECT" "Mauvais ordre: '10'"
run_test "unary_0n1n.json" "1100" "REJECT" "Mauvais ordre: '1100'"
run_test "unary_0n1n.json" "110011" "REJECT" "Mauvais ordre: '110011'"
run_test "unary_0n1n.json" "101010" "REJECT" "Alternance: '101010'"

# Tests rejet (nombres inégaux)
run_test "unary_0n1n.json" "0" "REJECT" "Plus de zéros: '0'"
run_test "unary_0n1n.json" "1" "REJECT" "Plus de uns: '1'"
run_test "unary_0n1n.json" "001" "REJECT" "Plus de zéros: '001'"
run_test "unary_0n1n.json" "011" "REJECT" "Plus de uns: '011'"
run_test "unary_0n1n.json" "00011" "REJECT" "Plus de uns: '00011'"
run_test "unary_0n1n.json" "00111" "REJECT" "Plus de uns: '00111'"
run_test "unary_0n1n.json" "000011" "REJECT" "Plus de zéros: '000011'"

# Tests rejet (mélanges)
run_test "unary_0n1n.json" "0101" "REJECT" "Mélange: '0101'"
run_test "unary_0n1n.json" "001011" "REJECT" "Mélange: '001011'"
run_test "unary_0n1n.json" "010101" "REJECT" "Alternance: '010101'"

# ===============================================================================
# TESTS POUR LA MACHINE UNIVERSELLE
# ===============================================================================


# ===============================================================================
# RÉSUMÉ FINAL
# ===============================================================================

print_header "RÉSUMÉ FINAL DES TESTS"

echo -e "${BLUE}Total des tests exécutés: $TOTAL_TESTS${NC}"
echo -e "${GREEN}Tests réussis: $PASSED_TESTS${NC}"
echo -e "${RED}Tests échoués: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUS LES TESTS ONT RÉUSSI! 🎉${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  CERTAINS TESTS ONT ÉCHOUÉ ⚠️${NC}"
    echo -e "${YELLOW}Taux de réussite: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%${NC}"
    exit 1
fi
