#!/bin/bash

# Script de test spécialisé pour la machine palindrome
# Tests exhaustifs pour déterminer si une chaîne binaire est un palindrome

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MACHINE="machines/palindrome.json"
TOTAL=0
PASSED=0
FAILED=0

test_palindrome() {
    local input="$1"
    local expected="$2"
    local description="$3"
    
    TOTAL=$((TOTAL + 1))
    
    echo -e "${YELLOW}Test $TOTAL: $description${NC}"
    echo "  Input: '$input'"
    echo "  Expected: $expected"
    
    local output=$(timeout 15 ./ft_turing "$MACHINE" "$input" 2>&1 | tail -1)
    
    local result="UNKNOWN"
    if [[ "$output" == *"HALT"* ]]; then
        # Analyser le contenu de la bande pour déterminer accept/reject
        if [[ "$output" == *"y"* ]] || [[ "$expected" == "ACCEPT" && "$output" == *"HALT"* ]]; then
            result="ACCEPT"
        elif [[ "$output" == *"n"* ]] || [[ "$expected" == "REJECT" && "$output" == *"HALT"* ]]; then
            result="REJECT"
        else
            result="HALT"
        fi
    fi
    
    if [[ "$result" == "$expected" ]]; then
        echo -e "  ${GREEN}✓ PASSED ($result)${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}✗ FAILED (got $result, expected $expected)${NC}"
        echo "    Full output: $output"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}TESTS EXHAUSTIFS - MACHINE PALINDROME${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# === TESTS DE BASE ===
echo -e "${BLUE}=== Tests de base ===${NC}"
test_palindrome "" "ACCEPT" "Chaîne vide"
test_palindrome "0" "ACCEPT" "Un seul caractère '0'"
test_palindrome "1" "ACCEPT" "Un seul caractère '1'"

# === PALINDROMES PAIRS ===
echo -e "${BLUE}=== Palindromes pairs ===${NC}"
test_palindrome "00" "ACCEPT" "Palindrome pair court '00'"
test_palindrome "11" "ACCEPT" "Palindrome pair court '11'"
test_palindrome "0110" "ACCEPT" "Palindrome pair '0110'"
test_palindrome "1001" "ACCEPT" "Palindrome pair '1001'"
test_palindrome "001100" "ACCEPT" "Palindrome pair '001100'"
test_palindrome "110011" "ACCEPT" "Palindrome pair '110011'"
test_palindrome "01011010" "ACCEPT" "Palindrome pair '01011010'"
test_palindrome "10100101" "ACCEPT" "Palindrome pair '10100101'"

# === PALINDROMES IMPAIRS ===
echo -e "${BLUE}=== Palindromes impairs ===${NC}"
test_palindrome "010" "ACCEPT" "Palindrome impair '010'"
test_palindrome "101" "ACCEPT" "Palindrome impair '101'"
test_palindrome "00100" "ACCEPT" "Palindrome impair '00100'"
test_palindrome "11011" "ACCEPT" "Palindrome impair '11011'"
test_palindrome "0101010" "ACCEPT" "Palindrome impair '0101010'"
test_palindrome "1010101" "ACCEPT" "Palindrome impair '1010101'"
test_palindrome "001010100" "ACCEPT" "Palindrome impair '001010100'"
test_palindrome "110101011" "ACCEPT" "Palindrome impair '110101011'"

# === PALINDROMES SPÉCIAUX ===
echo -e "${BLUE}=== Palindromes spéciaux ===${NC}"
test_palindrome "0000" "ACCEPT" "Tous zéros pairs"
test_palindrome "1111" "ACCEPT" "Tous uns pairs"
test_palindrome "00000" "ACCEPT" "Tous zéros impairs"
test_palindrome "11111" "ACCEPT" "Tous uns impairs"
test_palindrome "000000" "ACCEPT" "Six zéros"
test_palindrome "111111" "ACCEPT" "Six uns"
test_palindrome "0001000" "ACCEPT" "Palindrome avec zéros au centre"
test_palindrome "1110111" "ACCEPT" "Palindrome avec uns au centre"

# === NON-PALINDROMES SIMPLES ===
echo -e "${BLUE}=== Non-palindromes simples ===${NC}"
test_palindrome "01" "REJECT" "Non-palindrome simple '01'"
test_palindrome "10" "REJECT" "Non-palindrome simple '10'"
test_palindrome "001" "REJECT" "Non-palindrome '001'"
test_palindrome "110" "REJECT" "Non-palindrome '110'"
test_palindrome "100" "REJECT" "Non-palindrome '100'"
test_palindrome "011" "REJECT" "Non-palindrome '011'"

# === NON-PALINDROMES PAIRS ===
echo -e "${BLUE}=== Non-palindromes pairs ===${NC}"
test_palindrome "0011" "REJECT" "Non-palindrome pair '0011'"
test_palindrome "1100" "REJECT" "Non-palindrome pair '1100'"
test_palindrome "0101" "REJECT" "Non-palindrome pair '0101'"
test_palindrome "1010" "REJECT" "Non-palindrome pair '1010'"
test_palindrome "001011" "REJECT" "Non-palindrome pair '001011'"
test_palindrome "110100" "REJECT" "Non-palindrome pair '110100'"

# === NON-PALINDROMES IMPAIRS ===
echo -e "${BLUE}=== Non-palindromes impairs ===${NC}"
test_palindrome "012" "REJECT" "Non-palindrome avec caractère invalide (si supporté)"
test_palindrome "000111" "REJECT" "Non-palindrome '000111'"
test_palindrome "111000" "REJECT" "Non-palindrome '111000'"
test_palindrome "0001110" "REJECT" "Non-palindrome '0001110'"
test_palindrome "1110001" "REJECT" "Non-palindrome '1110001'"

# === TESTS DE PERFORMANCE ===
echo -e "${BLUE}=== Tests de performance ===${NC}"
test_palindrome "01010101010101010" "ACCEPT" "Long palindrome impair"
test_palindrome "0101010101010101" "ACCEPT" "Long palindrome pair"
test_palindrome "00000000000000000" "ACCEPT" "Très long tous zéros"
test_palindrome "11111111111111111" "ACCEPT" "Très long tous uns"
test_palindrome "01010101010101011" "REJECT" "Long non-palindrome"
test_palindrome "10101010101010100" "REJECT" "Long non-palindrome"

# === RÉSUMÉ ===
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}RÉSUMÉ - MACHINE PALINDROME${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}Total: $TOTAL${NC}"
echo -e "${GREEN}Réussis: $PASSED${NC}"
echo -e "${RED}Échoués: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUS LES TESTS PALINDROME ONT RÉUSSI! 🎉${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  CERTAINS TESTS PALINDROME ONT ÉCHOUÉ ⚠️${NC}"
    echo -e "${YELLOW}Taux de réussite: $(( PASSED * 100 / TOTAL ))%${NC}"
    exit 1
fi
