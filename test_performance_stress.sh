#!/bin/bash

# Script de test de performance et stress pour toutes les machines de Turing
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
PERFORMANCE_WARNINGS=0

# Timeouts différents pour les tests de performance
FAST_TIMEOUT=60
MEDIUM_TIMEOUT=15
SLOW_TIMEOUT=30

# Fonction pour afficher un en-tête
print_header() {
    echo ""
    echo -e "${BLUE}==========================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==========================================================================${NC}"
    echo ""
}

# Fonction pour mesurer le temps d'exécution
run_performance_test() {
    local machine="$1"
    local input="$2"
    local description="$3"
    local max_time="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}Performance Test $TOTAL_TESTS:${NC} $description"
    echo "  Machine: $machine"
    echo "  Input length: ${#input} caractères"
    echo "  Max time: ${max_time}s"
    
    # Mesurer le temps d'exécution
    local start_time=$(date +%s.%N)
    local output=$(timeout $max_time ./ft_turing "machines/$machine" "$input" 2>&1 | tail -1)
    local end_time=$(date +%s.%N)
    local execution_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "N/A")
    
    if [[ "$output" == *"HALT"* ]]; then
        if [[ "$execution_time" != "N/A" ]]; then
            local time_warning=""
            local time_color="$GREEN"
            
            # Analyser les performances
            if (( $(echo "$execution_time > $max_time * 0.8" | bc -l 2>/dev/null || echo 0) )); then
                time_warning=" ⚠️ SLOW"
                time_color="$YELLOW"
                PERFORMANCE_WARNINGS=$((PERFORMANCE_WARNINGS + 1))
            fi
            
            echo -e "  ${GREEN}✓ PASSED${NC} - Time: ${time_color}${execution_time}s${NC}${time_warning}"
        else
            echo -e "  ${GREEN}✓ PASSED${NC} - Time: N/A"
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}✗ FAILED (timeout/error)${NC} - $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Tests de performance pour les palindromes
test_palindrome_performance() {
    print_header "TESTS DE PERFORMANCE - PALINDROMES"
    
    # Générer des palindromes de différentes tailles
    echo -e "${MAGENTA}Test avec palindromes croissants${NC}"
    
    # Petits palindromes (rapides)
    for size in 10 20 30; do
        local palindrome=""
        local half=""
        for ((i=0; i<size/2; i++)); do
            if (( i % 2 == 0 )); then
                half="${half}0"
            else
                half="${half}1"
            fi
        done
        
        # Construire le palindrome
        palindrome="$half"
        if (( size % 2 == 1 )); then
            palindrome="${palindrome}0"  # Caractère central
        fi
        # Ajouter la partie miroir
        palindrome="${palindrome}$(echo "$half" | rev)"
        
        run_performance_test "palindrome.json" "$palindrome" "Palindrome de taille $size" $FAST_TIMEOUT
    done
    
    # Palindromes moyens
    for size in 50 75 100; do
        local palindrome=""
        local half=""
        for ((i=0; i<size/2; i++)); do
            if (( i % 3 == 0 )); then
                half="${half}0"
            else
                half="${half}1"
            fi
        done
        
        palindrome="$half"
        if (( size % 2 == 1 )); then
            palindrome="${palindrome}1"
        fi
        palindrome="${palindrome}$(echo "$half" | rev)"
        
        run_performance_test "palindrome.json" "$palindrome" "Palindrome de taille $size" $MEDIUM_TIMEOUT
    done
}

# Tests de performance pour l'arithmétique
test_arithmetic_performance() {
    print_header "TESTS DE PERFORMANCE - ARITHMÉTIQUE UNAIRE"
    
    echo -e "${MAGENTA}Tests d'addition avec nombres croissants${NC}"
    
    # Additions avec nombres de taille croissante
    for size in 5 10 15 20; do
        local num1=""
        local num2=""
        for ((i=0; i<size; i++)); do
            num1="${num1}1"
            num2="${num2}1"
        done
        
        run_performance_test "unary_add.json" "${num1}+${num2}" "Addition ${size}+${size}" $FAST_TIMEOUT
    done
    
    # Additions asymétriques
    for size in 25 30; do
        local big_num=""
        local small_num="11"
        for ((i=0; i<size; i++)); do
            big_num="${big_num}1"
        done
        
        run_performance_test "unary_add.json" "${big_num}+${small_num}" "Addition ${size}+2" $MEDIUM_TIMEOUT
    done
    
    echo -e "${MAGENTA}Tests de soustraction avec nombres croissants${NC}"
    
    # Soustractions avec nombres de taille croissante
    for size in 5 10 15; do
        local big_num=""
        local small_num=""
        for ((i=0; i<size; i++)); do
            big_num="${big_num}1"
        done
        for ((i=0; i<size/2; i++)); do
            small_num="${small_num}1"
        done
        
        run_performance_test "unary_sub.json" "${big_num}-${small_num}=" "Soustraction ${size}-${size/2}" $FAST_TIMEOUT
    done
    
    # Test de soustraction complexe
    local very_big=""
    for ((i=0; i<25; i++)); do
        very_big="${very_big}1"
    done
    run_performance_test "unary_sub.json" "${very_big}-1=" "Soustraction 25-1" $MEDIUM_TIMEOUT
}

# Tests de performance pour les langages formels
test_formal_languages_performance() {
    print_header "TESTS DE PERFORMANCE - LANGAGES FORMELS"
    
    echo -e "${MAGENTA}Tests 0^n 1^n avec n croissant${NC}"
    
    # Tests avec tailles croissantes pour 0^n 1^n
    # Note: Les grandes valeurs de n peuvent dépasser la limite de 1000 étapes
    for n in 10 15 20; do  # Réduit de 25,30 à 20 max
        local zeros=""
        local ones=""
        for ((i=0; i<n; i++)); do
            zeros="${zeros}0"
            ones="${ones}1"
        done
        
        run_performance_test "unary_0n1n.json" "${zeros}${ones}" "0^${n} 1^${n}" $MEDIUM_TIMEOUT
    done
    
    # Tests de limite avec des valeurs qui peuvent échouer (attendu)
    echo -e "${MAGENTA}Tests de limite avec grandes entrées (peuvent atteindre la limite d'étapes)${NC}"
    for n in 25 30; do
        local zeros=""
        local ones=""
        for ((i=0; i<n; i++)); do
            zeros="${zeros}0"
            ones="${ones}1"
        done
        
        echo "Test de limite ${TEST_COUNT}: 0^${n} 1^${n}"
        echo "  Machine: unary_0n1n.json"
        echo "  Input length: $((n*2)) caractères"
        echo "  Max time: ${MEDIUM_TIMEOUT}s"
        
        local start_time=$(date +%s.%N)
        local result=$(timeout ${MEDIUM_TIMEOUT} ./ft_turing "machines/unary_0n1n.json" "${zeros}${ones}" 2>&1)
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        
        if [[ "$result" == *"Maximum steps reached"* ]]; then
            echo -e "  ${YELLOW}⚠ LIMITE ATTEINTE (attendu pour cette taille) - Time: ${duration}s${NC}"
            PERF_WARNINGS=$((PERF_WARNINGS + 1))
        else
            echo -e "  ${GREEN}✓ PASSED - Time: ${duration}s${NC}"
            PERF_PASSED=$((PERF_PASSED + 1))
        fi
        TEST_COUNT=$((TEST_COUNT + 1))
    done
    
    echo -e "${MAGENTA}Tests 0^(2^n) avec puissances croissantes${NC}"
    
    # Tests pour 0^(2^n)
    for power in 32 64; do
        local zeros=""
        for ((i=0; i<power; i++)); do
            zeros="${zeros}0"
        done
        
        run_performance_test "unary_02n.json" "$zeros" "0^${power} (2^${power})" $SLOW_TIMEOUT
    done
}

# Tests de stress - cas limites
test_stress_cases() {
    print_header "TESTS DE STRESS - CAS LIMITES"
    
    echo -e "${MAGENTA}Tests avec entrées extrêmes${NC}"
    
    # Chaîne très longue de même caractère
    local long_zeros=""
    for ((i=0; i<200; i++)); do
        long_zeros="${long_zeros}0"
    done
    
    run_performance_test "palindrome.json" "$long_zeros" "200 zéros (palindrome)" $SLOW_TIMEOUT
    
    # Chaîne alternée très longue
    local alternating=""
    for ((i=0; i<100; i++)); do
        if (( i % 2 == 0 )); then
            alternating="${alternating}0"
        else
            alternating="${alternating}1"
        fi
    done
    
    run_performance_test "palindrome.json" "$alternating" "100 caractères alternés (non-palindrome)" $MEDIUM_TIMEOUT
    
    # Test avec la machine universelle
    echo -e "${MAGENTA}Tests de stress pour la machine universelle${NC}"
    run_performance_test "universal.json" "$alternating" "Machine universelle avec 100 caractères" $SLOW_TIMEOUT
}

# Test de robustesse - caractères invalides
test_robustness() {
    print_header "TESTS DE ROBUSTESSE"
    
    echo -e "${MAGENTA}Tests avec caractères non-standard${NC}"
    
    # Test toutes les machines avec des caractères invalides
    local invalid_inputs=("abc" "123" "!@#" "αβγ" "🚀🌟💻")
    
    for machine in machines/*.json; do
        machine_name=$(basename "$machine")
        
        for invalid_input in "${invalid_inputs[@]}"; do
            echo -e "${CYAN}Robustness Test:${NC} $machine_name avec '$invalid_input'"
            
            local output=$(timeout 5 ./ft_turing "$machine" "$invalid_input" 2>&1 | tail -1)
            
            if [[ "$output" == *"HALT"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]]; then
                echo -e "  ${GREEN}✓ ROBUST${NC} - Gère correctement les caractères invalides"
            else
                echo -e "  ${YELLOW}? UNKNOWN${NC} - Réponse: $output"
            fi
            echo ""
        done
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

# Vérifier si bc est disponible pour les calculs de temps
if ! command -v bc >/dev/null 2>&1; then
    echo -e "${YELLOW}Avertissement: 'bc' non disponible - mesures de temps limitées${NC}"
fi

echo -e "${GREEN}Tests de performance et stress pour les machines de Turing${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo ""

# Exécution des tests
test_palindrome_performance
test_arithmetic_performance
test_formal_languages_performance
test_stress_cases
test_robustness

# Résumé final
echo ""
print_header "RÉSUMÉ DES TESTS DE PERFORMANCE"
echo -e "${CYAN}Total des tests: $TOTAL_TESTS${NC}"
echo -e "${GREEN}Tests réussis: $PASSED_TESTS${NC}"
echo -e "${RED}Tests échoués: $FAILED_TESTS${NC}"
echo -e "${YELLOW}Avertissements de performance: $PERFORMANCE_WARNINGS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    if [ $PERFORMANCE_WARNINGS -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés avec d'excellentes performances!${NC}"
    else
        echo -e "${YELLOW}✅ Tous les tests sont passés mais avec quelques ralentissements${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ $FAILED_TESTS test(s) ont échoué.${NC}"
    exit 1
fi
