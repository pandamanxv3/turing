#!/bin/bash

# Script de test spécialisé pour la machine d'addition unaire
# Tests exhaustifs pour l'addition en notation unaire

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MACHINE="machines/unary_add.json"
TOTAL=0
PASSED=0
FAILED=0

test_addition() {
    local input="$1"
    local expected_result="$2"
    local description="$3"
    
    TOTAL=$((TOTAL + 1))
    
    echo -e "${YELLOW}Test $TOTAL: $description${NC}"
    echo "  Input: '$input'"
    echo "  Expected result: $expected_result"
    
    local output=$(timeout 15 ./ft_turing "$MACHINE" "$input" 2>&1)
    
    if [[ "$output" == *"Machine halted in final state: HALT"* ]]; then
        # Extraire le contenu de la bande finale
        local tape_line=$(echo "$output" | grep -E "\[.*\]" | tail -1)
        local result_tape=$(echo "$tape_line" | sed 's/.*\[\(.*\)\].*/\1/' | tr -d ' .<>')
        local ones_count=$(echo "$result_tape" | grep -o "1" | wc -l)
        
        if [ "$ones_count" -eq "$expected_result" ]; then
            echo -e "  ${GREEN}✓ PASSED (résultat: $ones_count)${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "  ${RED}✗ FAILED (got $ones_count, expected $expected_result)${NC}"
            echo "    Tape: $result_tape"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "  ${RED}✗ FAILED (n'a pas atteint HALT)${NC}"
        echo "    Output: $(echo "$output" | tail -3)"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TESTS EXHAUSTIFS - MACHINE ADDITION UNAIRE${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# === TESTS DE BASE (0 + n, n + 0) ===
echo -e "${BLUE}=== Tests de base avec zéro ===${NC}"
test_addition "+" 0 "Addition 0+0"
test_addition "1+" 1 "Addition 1+0"
test_addition "+1" 1 "Addition 0+1"
test_addition "11+" 2 "Addition 2+0"
test_addition "+11" 2 "Addition 0+2"
test_addition "111+" 3 "Addition 3+0"
test_addition "+111" 3 "Addition 0+3"

# === ADDITIONS SIMPLES ===
echo -e "${BLUE}=== Additions simples ===${NC}"
test_addition "1+1" 2 "Addition 1+1"
test_addition "11+1" 3 "Addition 2+1"
test_addition "1+11" 3 "Addition 1+2"
test_addition "111+1" 4 "Addition 3+1"
test_addition "1+111" 4 "Addition 1+3"
test_addition "11+11" 4 "Addition 2+2"
test_addition "111+11" 5 "Addition 3+2"
test_addition "11+111" 5 "Addition 2+3"
test_addition "111+111" 6 "Addition 3+3"

# === ADDITIONS MOYENNES ===
echo -e "${BLUE}=== Additions moyennes ===${NC}"
test_addition "1111+1" 5 "Addition 4+1"
test_addition "1+1111" 5 "Addition 1+4"
test_addition "1111+11" 6 "Addition 4+2"
test_addition "11+1111" 6 "Addition 2+4"
test_addition "1111+111" 7 "Addition 4+3"
test_addition "111+1111" 7 "Addition 3+4"
test_addition "1111+1111" 8 "Addition 4+4"
test_addition "11111+1" 6 "Addition 5+1"
test_addition "1+11111" 6 "Addition 1+5"
test_addition "11111+11" 7 "Addition 5+2"
test_addition "11+11111" 7 "Addition 2+5"

# === ADDITIONS PLUS IMPORTANTES ===
echo -e "${BLUE}=== Additions plus importantes ===${NC}"
test_addition "11111+111" 8 "Addition 5+3"
test_addition "111+11111" 8 "Addition 3+5"
test_addition "11111+1111" 9 "Addition 5+4"
test_addition "1111+11111" 9 "Addition 4+5"
test_addition "11111+11111" 10 "Addition 5+5"
test_addition "111111+1111" 10 "Addition 6+4"
test_addition "1111+111111" 10 "Addition 4+6"
test_addition "111111+111111" 12 "Addition 6+6"

# === TESTS AVEC NOMBRES PLUS GRANDS ===
echo -e "${BLUE}=== Tests avec nombres plus grands ===${NC}"
test_addition "1111111+1" 8 "Addition 7+1"
test_addition "1+1111111" 8 "Addition 1+7"
test_addition "1111111+111" 10 "Addition 7+3"
test_addition "111+1111111" 10 "Addition 3+7"
test_addition "1111111+1111111" 14 "Addition 7+7"
test_addition "11111111+11" 10 "Addition 8+2"
test_addition "11+11111111" 10 "Addition 2+8"
test_addition "11111111+11111111" 16 "Addition 8+8"

# === TESTS DE PERFORMANCE ===
echo -e "${BLUE}=== Tests de performance ===${NC}"
test_addition "111111111+1" 10 "Addition 9+1"
test_addition "1+111111111" 10 "Addition 1+9"
test_addition "111111111+111111111" 18 "Addition 9+9"
test_addition "1111111111+1111111111" 20 "Addition 10+10"

# === TESTS ASYMÉTRIQUES ===
echo -e "${BLUE}=== Tests asymétriques ===${NC}"
test_addition "1+11111111111" 12 "Addition 1+11 (asymétrique)"
test_addition "11111111111+1" 12 "Addition 11+1 (asymétrique)"
test_addition "111+1111111111111" 16 "Addition 3+13 (très asymétrique)"
test_addition "1111111111111+111" 16 "Addition 13+3 (très asymétrique)"

# === TESTS LIMITES ===
echo -e "${BLUE}=== Tests limites ===${NC}"
test_addition "1111111111111111+1111111111111111" 32 "Addition 16+16 (grande)"
test_addition "11111111111111111111+1" 21 "Addition 20+1 (très asymétrique)"
test_addition "1+11111111111111111111" 21 "Addition 1+20 (très asymétrique)"

# === RÉSUMÉ ===
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}RÉSUMÉ - MACHINE ADDITION UNAIRE${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Total: $TOTAL${NC}"
echo -e "${GREEN}Réussis: $PASSED${NC}"
echo -e "${RED}Échoués: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUS LES TESTS ADDITION ONT RÉUSSI! 🎉${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  CERTAINS TESTS ADDITION ONT ÉCHOUÉ ⚠️${NC}"
    echo -e "${YELLOW}Taux de réussite: $(( PASSED * 100 / TOTAL ))%${NC}"
    exit 1
fi
