#!/bin/bash

# Script maître pour exécuter tous les tests compréhensifs
# Créé le 6 juin 2025

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Fonction pour afficher un en-tête principal
print_main_header() {
    echo ""
    echo -e "${BOLD}${BLUE}=================================================================================${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}=================================================================================${NC}"
    echo ""
}

# Fonction pour exécuter un script de test
run_test_script() {
    local script="$1"
    local description="$2"
    
    if [ ! -f "$script" ]; then
        echo -e "${RED}❌ Script '$script' non trouvé!${NC}"
        return 1
    fi
    
    if [ ! -x "$script" ]; then
        echo -e "${YELLOW}🔧 Ajout des permissions d'exécution pour '$script'${NC}"
        chmod +x "$script"
    fi
    
    echo -e "${CYAN}🚀 Exécution: $description${NC}"
    echo -e "${MAGENTA}Script: $script${NC}"
    echo ""
    
    if "./$script"; then
        echo -e "${GREEN}✅ $description - SUCCÈS${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - ÉCHEC${NC}"
        return 1
    fi
}

# Fonction pour afficher le résumé des performances système
show_system_info() {
    print_main_header "INFORMATIONS SYSTÈME"
    
    echo -e "${CYAN}Date et heure:${NC} $(date)"
    echo -e "${CYAN}Système:${NC} $(uname -a)"
    
    if command -v lscpu >/dev/null 2>&1; then
        echo -e "${CYAN}CPU:${NC} $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
    fi
    
    if command -v free >/dev/null 2>&1; then
        echo -e "${CYAN}Mémoire:${NC} $(free -h | awk 'NR==2{printf "%.1f/%.1fGB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')"
    fi
    
    echo -e "${CYAN}Espace disque:${NC} $(df -h . | awk 'NR==2 {print $4 " disponible"}')"
    echo ""
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    print_main_header "VÉRIFICATION DES PRÉREQUIS"
    
    local all_good=true
    
    # Vérifier ft_turing
    if [ ! -f "./ft_turing" ]; then
        echo -e "${RED}❌ Binaire './ft_turing' non trouvé${NC}"
        echo -e "${YELLOW}   Compilez avec: make${NC}"
        all_good=false
    else
        echo -e "${GREEN}✅ Binaire './ft_turing' trouvé${NC}"
    fi
    
    # Vérifier le dossier machines
    if [ ! -d "./machines" ]; then
        echo -e "${RED}❌ Dossier './machines' non trouvé${NC}"
        all_good=false
    else
        local machine_count=$(ls machines/*.json 2>/dev/null | wc -l)
        echo -e "${GREEN}✅ Dossier './machines' trouvé avec $machine_count machine(s)${NC}"
        
        # Lister les machines disponibles
        echo -e "${CYAN}   Machines disponibles:${NC}"
        for machine in machines/*.json; do
            if [ -f "$machine" ]; then
                echo -e "   - $(basename "$machine")"
            fi
        done
    fi
    
    # Vérifier les scripts de test
    local test_scripts=(
        "test_all_machines.sh"
        "test_palindrome_comprehensive.sh" 
        "test_unary_arithmetic.sh"
        "test_formal_languages.sh"
        "test_universal_machine.sh"
        "test_performance_stress.sh"
    )
    
    echo ""
    echo -e "${CYAN}Scripts de test disponibles:${NC}"
    for script in "${test_scripts[@]}"; do
        if [ -f "$script" ]; then
            echo -e "${GREEN}✅ $script${NC}"
        else
            echo -e "${RED}❌ $script${NC}"
            all_good=false
        fi
    done
    
    if [ "$all_good" = false ]; then
        echo ""
        echo -e "${RED}❌ Certains prérequis manquent. Veuillez les résoudre avant de continuer.${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Tous les prérequis sont satisfaits!${NC}"
}

# Fonction principale d'exécution des tests
run_comprehensive_tests() {
    local total_suites=0
    local successful_suites=0
    local start_time=$(date +%s)
    
    print_main_header "EXÉCUTION DES TESTS COMPRÉHENSIFS"
    
    # Test suite 1: Tests de base (existant)
    total_suites=$((total_suites + 1))
    if run_test_script "test_all_machines.sh" "Suite de tests de base (toutes machines)"; then
        successful_suites=$((successful_suites + 1))
    fi
    echo ""
    
    # Test suite 2: Tests spécialisés palindromes
    total_suites=$((total_suites + 1))
    if run_test_script "test_palindrome_comprehensive.sh" "Tests compréhensifs palindromes"; then
        successful_suites=$((successful_suites + 1))
    fi
    echo ""
    
    # Test suite 3: Tests arithmétique unaire
    total_suites=$((total_suites + 1))
    if run_test_script "test_unary_arithmetic.sh" "Tests arithmétique unaire"; then
        successful_suites=$((successful_suites + 1))
    fi
    echo ""
    
    # Test suite 4: Tests langages formels
    total_suites=$((total_suites + 1))
    if run_test_script "test_formal_languages.sh" "Tests langages formels"; then
        successful_suites=$((successful_suites + 1))
    fi
    echo ""
    
    # Test suite 5: Tests machine universelle
    total_suites=$((total_suites + 1))
    if run_test_script "test_universal_machine.sh" "Tests machine universelle"; then
        successful_suites=$((successful_suites + 1))
    fi
    echo ""
    
    # Test suite 6: Tests de performance et stress
    total_suites=$((total_suites + 1))
    if run_test_script "test_performance_stress.sh" "Tests de performance et stress"; then
        successful_suites=$((successful_suites + 1))
    fi
    echo ""
    
    # Calcul du temps total
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    local minutes=$((total_time / 60))
    local seconds=$((total_time % 60))
    
    # Résumé final
    print_main_header "RÉSUMÉ FINAL DES TESTS COMPRÉHENSIFS"
    
    echo -e "${CYAN}📊 Statistiques d'exécution:${NC}"
    echo -e "   Suites de tests exécutées: $total_suites"
    echo -e "   Suites réussies: $successful_suites"
    echo -e "   Suites échouées: $((total_suites - successful_suites))"
    echo -e "   Temps total d'exécution: ${minutes}m ${seconds}s"
    echo ""
    
    if [ $successful_suites -eq $total_suites ]; then
        echo -e "${BOLD}${GREEN}🎉🎉🎉 TOUS LES TESTS SONT PASSÉS AVEC SUCCÈS! 🎉🎉🎉${NC}"
        echo -e "${GREEN}Toutes les machines de Turing fonctionnent correctement.${NC}"
        return 0
    else
        echo -e "${BOLD}${RED}❌ CERTAINS TESTS ONT ÉCHOUÉ${NC}"
        echo -e "${RED}$((total_suites - successful_suites)) suite(s) de tests sur $total_suites ont échoué.${NC}"
        echo -e "${YELLOW}Consultez les détails ci-dessus pour identifier les problèmes.${NC}"
        return 1
    fi
}

# Fonction d'aide
show_help() {
    echo -e "${BOLD}USAGE:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "  -h, --help     Afficher cette aide"
    echo "  -q, --quick    Mode rapide (skip les tests de performance)"
    echo "  -s, --system   Afficher seulement les informations système"
    echo "  -c, --check    Vérifier seulement les prérequis"
    echo ""
    echo -e "${BOLD}DESCRIPTION:${NC}"
    echo "  Ce script exécute une suite complète de tests pour toutes les"
    echo "  machines de Turing disponibles, incluant:"
    echo "  - Tests de base et de régression"
    echo "  - Tests spécialisés par type de machine"
    echo "  - Tests de performance et de stress"
    echo "  - Tests de robustesse"
    echo ""
    echo -e "${BOLD}PRÉREQUIS:${NC}"
    echo "  - Binaire './ft_turing' compilé"
    echo "  - Dossier './machines' avec les fichiers JSON"
    echo "  - Scripts de test dans le répertoire courant"
}

# Parsing des arguments
QUICK_MODE=false
SYSTEM_ONLY=false
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -s|--system)
            SYSTEM_ONLY=true
            shift
            ;;
        -c|--check)
            CHECK_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Exécution principale
print_main_header "SUITE COMPLÈTE DE TESTS POUR LES MACHINES DE TURING"

# Afficher les informations système
show_system_info

# Vérifier les prérequis
check_prerequisites

# Si mode check only, s'arrêter ici
if [ "$CHECK_ONLY" = true ]; then
    echo -e "${GREEN}✅ Vérification des prérequis terminée.${NC}"
    exit 0
fi

# Si mode system only, s'arrêter ici
if [ "$SYSTEM_ONLY" = true ]; then
    echo -e "${GREEN}✅ Affichage des informations système terminé.${NC}"
    exit 0
fi

# Exécuter les tests
if [ "$QUICK_MODE" = true ]; then
    echo -e "${YELLOW}⚡ Mode rapide activé - les tests de performance seront ignorés${NC}"
    echo ""
fi

if run_comprehensive_tests; then
    exit 0
else
    exit 1
fi
