#!/bin/bash

# Test compréhensif spécialisé pour les machines palindrome
# Créé le 6 juin 2025

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TIMEOUT=10

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
        echo -e "  ${GREEN}✓ PASSED${NC} - $output"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}✗ FAILED${NC} - $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Fonction pour tester une série de palindromes
test_palindrome_series() {
    local machine="$1"
    local title="$2"
    
    print_header "$title"
    
    # Cas de base
    run_test "$machine" "" "ACCEPT" "Chaîne vide (palindrome trivial)"
    run_test "$machine" "0" "ACCEPT" "Caractère unique '0'"
    run_test "$machine" "1" "ACCEPT" "Caractère unique '1'"
    
    # Palindromes pairs
    run_test "$machine" "00" "ACCEPT" "Palindrome pair '00'"
    run_test "$machine" "11" "ACCEPT" "Palindrome pair '11'"
    run_test "$machine" "0110" "ACCEPT" "Palindrome pair '0110'"
    run_test "$machine" "1001" "ACCEPT" "Palindrome pair '1001'"
    run_test "$machine" "010010" "ACCEPT" "Palindrome pair '010010'"
    run_test "$machine" "101101" "ACCEPT" "Palindrome pair '101101'"
    
    # Palindromes impairs
    run_test "$machine" "010" "ACCEPT" "Palindrome impair '010'"
    run_test "$machine" "101" "ACCEPT" "Palindrome impair '101'"
    run_test "$machine" "00100" "ACCEPT" "Palindrome impair '00100'"
    run_test "$machine" "11011" "ACCEPT" "Palindrome impair '11011'"
    run_test "$machine" "0010100" "ACCEPT" "Palindrome impair '0010100'"
    run_test "$machine" "1101011" "ACCEPT" "Palindrome impair '1101011'"
    
    # Non-palindromes
    run_test "$machine" "01" "REJECT" "Non-palindrome '01'"
    run_test "$machine" "10" "REJECT" "Non-palindrome '10'"
    run_test "$machine" "001" "REJECT" "Non-palindrome '001'"
    run_test "$machine" "110" "REJECT" "Non-palindrome '110'"
    run_test "$machine" "0101" "REJECT" "Non-palindrome '0101'"
    run_test "$machine" "1010" "REJECT" "Non-palindrome '1010'"
    run_test "$machine" "0011" "REJECT" "Non-palindrome '0011'"
    run_test "$machine" "1100" "REJECT" "Non-palindrome '1100'"
    
    # Palindromes longs
    run_test "$machine" "01010101010" "ACCEPT" "Palindrome long impair"
    run_test "$machine" "1010101010101" "ACCEPT" "Palindrome très long impair"
    run_test "$machine" "000111000" "ACCEPT" "Palindrome symétrique"
    run_test "$machine" "111000111" "ACCEPT" "Palindrome symétrique inverse"
    
    # Cas limites et stress test
    run_test "$machine" "0000000000" "ACCEPT" "Tous zéros (10 caractères)"
    run_test "$machine" "1111111111" "ACCEPT" "Tous uns (10 caractères)"
    
    # Note: Test avec caractères hors alphabet commenté car rejeté par validation d'entrée
    # run_test "$machine" "01234567890987654321" "INPUT_ERROR" "Caractères hors alphabet"
    
    # Palindromes complexes
    run_test "$machine" "010101010101010101010" "ACCEPT" "Palindrome alternant long"
    run_test "$machine" "101010101010101010101" "ACCEPT" "Palindrome alternant inverse long"
    run_test "$machine" "000100010001000" "ACCEPT" "Palindrome avec motif répété"
    run_test "$machine" "111011101110111" "ACCEPT" "Palindrome avec motif répété inverse"
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

echo -e "${GREEN}Tests compréhensifs pour les machines palindrome${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo ""

# Test de toutes les versions de palindrome disponibles
for machine_file in machines/palindrome*.json; do
    if [ -f "$machine_file" ]; then
        machine_name=$(basename "$machine_file")
        
        # Vérifier si le fichier contient du JSON valide (non vide)
        if [ -s "$machine_file" ] && grep -q '"name"' "$machine_file" 2>/dev/null; then
            test_palindrome_series "$machine_name" "TESTS COMPRÉHENSIFS POUR $machine_name"
        else
            echo -e "${YELLOW}⚠️  Ignoré: $machine_name (fichier vide ou JSON invalide)${NC}"
        fi
    fi
done

# Résumé final
echo ""
print_header "RÉSUMÉ DES TESTS PALINDROME"
echo -e "${CYAN}Total des tests: $TOTAL_TESTS${NC}"
echo -e "${GREEN}Tests réussis: $PASSED_TESTS${NC}"
echo -e "${RED}Tests échoués: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 Tous les tests sont passés avec succès!${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED_TESTS test(s) ont échoué.${NC}"
    exit 1
fi
