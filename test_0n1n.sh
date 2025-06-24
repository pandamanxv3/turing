#!/bin/bash

# Script de test spécialisé pour la machine 0^n1^n
# Tests exhaustifs pour le langage 0^n1^n

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MACHINE="machines/unary_0n1n.json"
TOTAL=0
PASSED=0
FAILED=0

test_0n1n() {
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
        # Analyser pour déterminer accept/reject
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
echo -e "${BLUE}TESTS EXHAUSTIFS - MACHINE 0^n1^n${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# === TESTS VALIDES (0^n1^n) ===
echo -e "${BLUE}=== Tests valides 0^n1^n ===${NC}"
test_0n1n "" "ACCEPT" "n=0: chaîne vide"
test_0n1n "01" "ACCEPT" "n=1: un zéro, un un"
test_0n1n "0011" "ACCEPT" "n=2: deux zéros, deux uns"
test_0n1n "000111" "ACCEPT" "n=3: trois zéros, trois uns"
test_0n1n "00001111" "ACCEPT" "n=4: quatre zéros, quatre uns"
test_0n1n "0000011111" "ACCEPT" "n=5: cinq zéros, cinq uns"
test_0n1n "000000111111" "ACCEPT" "n=6: six zéros, six uns"
test_0n1n "00000001111111" "ACCEPT" "n=7: sept zéros, sept uns"
test_0n1n "0000000011111111" "ACCEPT" "n=8: huit zéros, huit uns"
test_0n1n "000000000111111111" "ACCEPT" "n=9: neuf zéros, neuf uns"
test_0n1n "00000000001111111111" "ACCEPT" "n=10: dix zéros, dix uns"

# === TESTS INVALIDES - MAUVAIS ORDRE ===
echo -e "${BLUE}=== Tests invalides - mauvais ordre ===${NC}"
test_0n1n "10" "REJECT" "Ordre inversé: un puis zéro"
test_0n1n "1100" "REJECT" "Ordre inversé: deux uns puis deux zéros"
test_0n1n "110011" "REJECT" "Ordre inversé: 11 puis 00 puis 11"
test_0n1n "111000" "REJECT" "Ordre inversé: trois uns puis trois zéros"
test_0n1n "11110000" "REJECT" "Ordre inversé: quatre uns puis quatre zéros"
test_0n1n "101010" "REJECT" "Alternance: 101010"
test_0n1n "010101" "REJECT" "Alternance: 010101"
test_0n1n "1001" "REJECT" "Mélange: 1001"
test_0n1n "0110" "REJECT" "Mélange: 0110"

# === TESTS INVALIDES - NOMBRES INÉGAUX (plus de 0) ===
echo -e "${BLUE}=== Tests invalides - plus de zéros ===${NC}"
test_0n1n "0" "REJECT" "Un zéro seul"
test_0n1n "00" "REJECT" "Deux zéros seuls"
test_0n1n "000" "REJECT" "Trois zéros seuls"
test_0n1n "0000" "REJECT" "Quatre zéros seuls"
test_0n1n "001" "REJECT" "Deux zéros, un un"
test_0n1n "0001" "REJECT" "Trois zéros, un un"
test_0n1n "00011" "REJECT" "Trois zéros, deux uns"
test_0n1n "000011" "REJECT" "Quatre zéros, deux uns"
test_0n1n "0000111" "REJECT" "Quatre zéros, trois uns"
test_0n1n "00000111" "REJECT" "Cinq zéros, trois uns"

# === TESTS INVALIDES - NOMBRES INÉGAUX (plus de 1) ===
echo -e "${BLUE}=== Tests invalides - plus de uns ===${NC}"
test_0n1n "1" "REJECT" "Un un seul"
test_0n1n "11" "REJECT" "Deux uns seuls"
test_0n1n "111" "REJECT" "Trois uns seuls"
test_0n1n "1111" "REJECT" "Quatre uns seuls"
test_0n1n "011" "REJECT" "Un zéro, deux uns"
test_0n1n "0111" "REJECT" "Un zéro, trois uns"
test_0n1n "00111" "REJECT" "Deux zéros, trois uns"
test_0n1n "001111" "REJECT" "Deux zéros, quatre uns"
test_0n1n "0001111" "REJECT" "Trois zéros, quatre uns"
test_0n1n "00011111" "REJECT" "Trois zéros, cinq uns"

# === TESTS INVALIDES - MÉLANGES COMPLEXES ===
echo -e "${BLUE}=== Tests invalides - mélanges complexes ===${NC}"
test_0n1n "0101" "REJECT" "Alternance simple: 0101"
test_0n1n "1010" "REJECT" "Alternance simple: 1010"
test_0n1n "001011" "REJECT" "Mélange: 001011"
test_0n1n "110100" "REJECT" "Mélange: 110100"
test_0n1n "010110" "REJECT" "Mélange: 010110"
test_0n1n "101001" "REJECT" "Mélange: 101001"
test_0n1n "001101" "REJECT" "Mélange: 001101"
test_0n1n "110010" "REJECT" "Mélange: 110010"
test_0n1n "0011001" "REJECT" "Mélange avec répétition"
test_0n1n "1100110" "REJECT" "Mélange avec répétition inverse"

# === TESTS LIMITES ET PERFORMANCE ===
echo -e "${BLUE}=== Tests limites et performance ===${NC}"
test_0n1n "000000000000111111111111" "ACCEPT" "n=12: douze zéros, douze uns"
test_0n1n "00000000000001111111111111" "ACCEPT" "n=13: treize zéros, treize uns"
test_0n1n "000000000000001111111111111" "REJECT" "Treize zéros, douze uns"
test_0n1n "00000000000011111111111111" "REJECT" "Douze zéros, treize uns"
test_0n1n "0000000000000011111111111111" "ACCEPT" "n=14: quatorze zéros, quatorze uns"
test_0n1n "00000000000000111111111111111" "ACCEPT" "n=15: quinze zéros, quinze uns"

# === TESTS AVEC PATTERNS SPÉCIAUX ===
echo -e "${BLUE}=== Tests avec patterns spéciaux ===${NC}"
test_0n1n "01010101" "REJECT" "Alternance longue"
test_0n1n "10101010" "REJECT" "Alternance longue inverse"
test_0n1n "00110011" "REJECT" "Pattern répétitif 0011"
test_0n1n "11001100" "REJECT" "Pattern répétitif 1100"
test_0n1n "000111000111" "REJECT" "Pattern répétitif 000111"
test_0n1n "111000111000" "REJECT" "Pattern répétitif 111000"

# === TESTS DE ROBUSTESSE ===
echo -e "${BLUE}=== Tests de robustesse ===${NC}"
test_0n1n "000000000000000011111111111111111" "ACCEPT" "n=16: seize zéros, seize uns"
test_0n1n "0000000000000000111111111111111111" "ACCEPT" "n=17: dix-sept zéros, dix-sept uns"
test_0n1n "00000000000000001111111111111111111" "ACCEPT" "n=18: dix-huit zéros, dix-huit uns"
test_0n1n "000000000000000011111111111111111111" "ACCEPT" "n=19: dix-neuf zéros, dix-neuf uns"
test_0n1n "0000000000000000111111111111111111111" "ACCEPT" "n=20: vingt zéros, vingt uns"

# === RÉSUMÉ ===
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}RÉSUMÉ - MACHINE 0^n1^n${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}Total: $TOTAL${NC}"
echo -e "${GREEN}Réussis: $PASSED${NC}"
echo -e "${RED}Échoués: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUS LES TESTS 0^n1^n ONT RÉUSSI! 🎉${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  CERTAINS TESTS 0^n1^n ONT ÉCHOUÉ ⚠️${NC}"
    echo -e "${YELLOW}Taux de réussite: $(( PASSED * 100 / TOTAL ))%${NC}"
    exit 1
fi
