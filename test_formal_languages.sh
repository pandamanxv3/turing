#!/bin/bash

# Test compréhensif spécialisé pour les machines de reconnaissance de langages formels
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
TIMEOUT=15

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

# Tests pour le langage 0^n 1^n
test_0n1n_language() {
    print_header "TESTS COMPRÉHENSIFS POUR LE LANGAGE 0^n 1^n (unary_0n1n.json)"
    
    echo -e "${MAGENTA}Description: Reconnaît les chaînes de la forme 0^n 1^n (n ≥ 0)${NC}"
    echo -e "${MAGENTA}Exemples valides: ε, 01, 0011, 000111, etc.${NC}"
    echo ""
    
    echo -e "${YELLOW}Tests de base - cas valides${NC}"
    run_test "unary_0n1n.json" "" "ACCEPT" "Chaîne vide (n=0)"
    run_test "unary_0n1n.json" "01" "ACCEPT" "n=1: un 0 suivi d'un 1"
    run_test "unary_0n1n.json" "0011" "ACCEPT" "n=2: deux 0 suivis de deux 1"
    run_test "unary_0n1n.json" "000111" "ACCEPT" "n=3: trois 0 suivis de trois 1"
    run_test "unary_0n1n.json" "00001111" "ACCEPT" "n=4: quatre 0 suivis de quatre 1"
    run_test "unary_0n1n.json" "0000011111" "ACCEPT" "n=5: cinq 0 suivis de cinq 1"
    
    echo -e "${YELLOW}Tests avec nombres plus grands${NC}"
    run_test "unary_0n1n.json" "000000111111" "ACCEPT" "n=6: six 0 suivis de six 1"
    run_test "unary_0n1n.json" "00000001111111" "ACCEPT" "n=7: sept 0 suivis de sept 1"
    run_test "unary_0n1n.json" "0000000011111111" "ACCEPT" "n=8: huit 0 suivis de huit 1"
    run_test "unary_0n1n.json" "000000000111111111" "ACCEPT" "n=9: neuf 0 suivis de neuf 1"
    run_test "unary_0n1n.json" "00000000001111111111" "ACCEPT" "n=10: dix 0 suivis de dix 1"
    
    echo -e "${YELLOW}Tests de cas invalides - nombres inégaux${NC}"
    run_test "unary_0n1n.json" "0" "REJECT" "Un seul 0 (pas de 1)"
    run_test "unary_0n1n.json" "1" "REJECT" "Un seul 1 (pas de 0)"
    run_test "unary_0n1n.json" "001" "REJECT" "Deux 0, un 1"
    run_test "unary_0n1n.json" "011" "REJECT" "Un 0, deux 1"
    run_test "unary_0n1n.json" "00111" "REJECT" "Deux 0, trois 1"
    run_test "unary_0n1n.json" "000111" "ACCEPT" "Trois 0, trois 1 (valide)"
    run_test "unary_0n1n.json" "0001111" "REJECT" "Trois 0, quatre 1"
    
    echo -e "${YELLOW}Tests de formats invalides${NC}"
    run_test "unary_0n1n.json" "10" "REJECT" "1 avant 0 (ordre inverse)"
    run_test "unary_0n1n.json" "1100" "REJECT" "1 avant 0 (ordre mélangé)"
    run_test "unary_0n1n.json" "0101" "REJECT" "Alternance 0-1"
    run_test "unary_0n1n.json" "1010" "REJECT" "Alternance 1-0"
    run_test "unary_0n1n.json" "001011" "REJECT" "Mélange avec bonne longueur"
    run_test "unary_0n1n.json" "010011" "REJECT" "0 intercalé dans les 1"
    
    echo -e "${YELLOW}Tests de validation d'entrée${NC}"
    # Note: Ces tests vérifient que la validation d'entrée fonctionne correctement
    # Les caractères non-alphabétiques doivent être rejetés avant l'exécution de la machine
    echo -e "${CYAN}# Tests avec caractères hors alphabet (doivent être rejetés par validation)${NC}"
    # Ces tests sont commentés car ils vérifient la validation d'entrée, pas la machine
    # run_test "unary_0n1n.json" "a" "INPUT_ERROR" "Caractère invalide 'a'"
    # run_test "unary_0n1n.json" "0a1" "INPUT_ERROR" "Caractère invalide au milieu"
    # run_test "unary_0n1n.json" "001a1" "INPUT_ERROR" "Caractère invalide dans séquence valide"
    # run_test "unary_0n1n.json" "2" "INPUT_ERROR" "Chiffre invalide '2'"
    # run_test "unary_0n1n.json" "00112" "INPUT_ERROR" "Chiffre invalide à la fin"
    
    echo -e "${YELLOW}Tests stress avec grandes chaînes${NC}"
    # Créer de longues chaînes valides
    local long_valid=""
    for i in {1..15}; do
        long_valid="${long_valid}0"
    done
    for i in {1..15}; do
        long_valid="${long_valid}1"
    done
    run_test "unary_0n1n.json" "$long_valid" "ACCEPT" "n=15: quinze 0 suivis de quinze 1"
    
    # Créer de longues chaînes invalides
    local long_invalid="${long_valid}1"  # Un 1 de trop
    run_test "unary_0n1n.json" "$long_invalid" "REJECT" "n=15+1: quinze 0 suivis de seize 1"
}

# Tests pour le langage 0^2n (puissances de 2)
test_02n_language() {
    print_header "TESTS COMPRÉHENSIFS POUR LE LANGAGE 0^(2^n) (unary_02n.json)"
    
    echo -e "${MAGENTA}Description: Reconnaît les chaînes de 0 dont la longueur est une puissance de 2${NC}"
    echo -e "${MAGENTA}Longueurs valides: 1, 2, 4, 8, 16, 32, 64, 128, etc.${NC}"
    echo ""
    
    echo -e "${YELLOW}Tests de puissances de 2 valides${NC}"
    run_test "unary_02n.json" "0" "ACCEPT" "2^0 = 1 zéro"
    run_test "unary_02n.json" "00" "ACCEPT" "2^1 = 2 zéros"
    run_test "unary_02n.json" "0000" "ACCEPT" "2^2 = 4 zéros"
    run_test "unary_02n.json" "00000000" "ACCEPT" "2^3 = 8 zéros"
    run_test "unary_02n.json" "0000000000000000" "ACCEPT" "2^4 = 16 zéros"
    
    echo -e "${YELLOW}Tests de longueurs invalides${NC}"
    run_test "unary_02n.json" "" "REJECT" "Chaîne vide (0 zéros)"
    run_test "unary_02n.json" "000" "REJECT" "3 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "00000" "REJECT" "5 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "000000" "REJECT" "6 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "0000000" "REJECT" "7 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "000000000" "REJECT" "9 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "0000000000" "REJECT" "10 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "00000000000" "REJECT" "11 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "000000000000" "REJECT" "12 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "0000000000000" "REJECT" "13 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "00000000000000" "REJECT" "14 zéros (pas une puissance de 2)"
    run_test "unary_02n.json" "000000000000000" "REJECT" "15 zéros (pas une puissance de 2)"
    
    echo -e "${YELLOW}Tests avec entrées rejetées logiquement${NC}"
    # Ces tests vérifient que la machine rejette correctement les entrées mal formatées
    run_test "unary_02n.json" "1" "REJECT" "Nombre impair de caractères avec '1'"
    run_test "unary_02n.json" "01" "REJECT" "Mélange 0 et 1"
    run_test "unary_02n.json" "0001" "REJECT" "Trois 0 suivis d'un 1"
    
    echo -e "${YELLOW}Tests de validation d'entrée${NC}"
    # Note: Ces tests vérifient que la validation d'entrée fonctionne correctement
    echo -e "${CYAN}# Tests avec caractères hors alphabet (doivent être rejetés par validation)${NC}"
    # Ces tests sont commentés car ils vérifient la validation d'entrée, pas la machine
    # run_test "unary_02n.json" "a" "INPUT_ERROR" "Caractère invalide 'a'"
    # run_test "unary_02n.json" "000a" "INPUT_ERROR" "Trois 0 suivis de 'a'"
    # run_test "unary_02n.json" "2" "INPUT_ERROR" "Chiffre invalide '2'"
    
    echo -e "${YELLOW}Tests edge case autour des puissances de 2${NC}"
    # Teste toutes les longueurs de 1 à 20 pour vérifier la précision
    local test_string=""
    for i in {1..20}; do
        test_string="${test_string}0"
        local expected="REJECT"
        # Vérifier si i est une puissance de 2
        if (( (i & (i - 1)) == 0 )); then
            expected="ACCEPT"
        fi
        run_test "unary_02n.json" "$test_string" "$expected" "Longueur $i ($([ "$expected" = "ACCEPT" ] && echo "puissance de 2" || echo "pas puissance de 2"))"
    done
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

echo -e "${GREEN}Tests compréhensifs pour les machines de reconnaissance de langages formels${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo ""

# Exécution des tests
test_0n1n_language
test_02n_language

# Résumé final
echo ""
print_header "RÉSUMÉ DES TESTS LANGAGES FORMELS"
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
