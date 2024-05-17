#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# This script will locate and process all relevant files within the given git      #
# repository. Errors will be stored and a final exit status used to show if a      #
# failure occurred during the processing.                                          #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# Configure the shell.                                                             #
# -------------------------------------------------------------------------------- #

set -Eeuo pipefail

# -------------------------------------------------------------------------------- #
# Global Variables                                                                 #
# -------------------------------------------------------------------------------- #
INSTALL_COMMAND=("")

TEST_COMMAND='file'
FILE_TYPE_SEARCH_PATTERN=''
FILE_NAME_SEARCH_PATTERN=''

# -------------------------------------------------------------------------------- #
# Tool Specific Functions                                                          #
# -------------------------------------------------------------------------------- #

function install_prerequisites()
{
    stage "Install Prerequisites"

    if ! command -v "${TEST_COMMAND}" &> /dev/null; then
        # shellcheck disable=SC2310
        if ! errors=$(run_command "${INSTALL_COMMAND[@]}"); then
            fail "${INSTALL_COMMAND[*]}" "${errors}" true
            exit "${EXIT_VALUE}"
        else
            success "${INSTALL_COMMAND[*]}"
        fi
    else
        success "${TEST_COMMAND} is already installed"
    fi
}

function get_version_information() {
    VERSION=$("${TEST_COMMAND}" --version | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    BANNER="Run ${TEST_COMMAND} (v${VERSION})"
}

function handle_non_standard_parameters()
{
    # Do Nothing
    :
}

function check_file() {
    local filename=$1
    local errors

    file_count=$((file_count + 1))
    # shellcheck disable=SC2310
    if ! errors=$(run_command "${TEST_COMMAND}" "${filename}"); then
        fail "${filename}" "${errors}"
        fail_count=$((fail_count + 1))
    else
        success "${filename}"
        ok_count=$((ok_count + 1))
    fi
}

# -------------------------------------------------------------------------------- #
# Stop Here                                                                        #
#                                                                                  #
# Everything below here is standard and designed to work with all of the tools     #
# that have been built and released as part of the CICDToolbox.                    #
# -------------------------------------------------------------------------------- #

EXIT_VALUE=0
CURRENT_STAGE=0

# -------------------------------------------------------------------------------- #
# Utility Functions                                                                #
# -------------------------------------------------------------------------------- #

function run_command() {
    local command=("$@")
    if ! output=$("${command[@]}" 2>&1); then
        echo "${output}"
        return 1
    fi
    echo "${output}"
    return 0
}

function stage() {
    local message=${1:-}
    CURRENT_STAGE=$((CURRENT_STAGE + 1))
    align_right "${bold_text}${cyan_text}Stage ${CURRENT_STAGE}: ${message}${reset}"
}

function success() {
    local message=${1:-}
    printf ' [  %s%sOK%s  ] %s\n' "${bold_text}" "${green_text}" "${reset}" "${message}"
}

function fail() {
    local message=${1:-}
    local errors=${2:-}
    local override=${3:-false}

    printf ' [ %s%sFAIL%s ] %s\n' "${bold_text}" "${red_text}" "${reset}" "${message}"

    if [[ "${SHOW_ERRORS}" == true || "${override}" == true ]]; then
        if [[ -n "${errors}" ]]; then
            echo
            echo "${errors}" | while IFS= read -r err; do
                echo "          ${err}"
            done
            echo
        fi
    fi

    EXIT_VALUE=1
}

function skip() {
    local message=${1:-}
    if [[ "${SHOW_SKIPPED}" == true ]]; then
        skip_count=$((skip_count + 1))
        printf ' [ %s%sSkip%s ] Skipping %s\n' "${bold_text}" "${yellow_text}" "${reset}" "${message}"
    fi
}

function is_excluded() {
    local needle=$1
    for pattern in "${exclude_list[@]}"; do
        if [[ "${needle}" =~ ${pattern} ]]; then
            return 0
        fi
    done
    return 1
}

function is_included() {
    local needle=$1
    for pattern in "${include_list[@]}"; do
        if [[ "${needle}" =~ ${pattern} ]]; then
            return 0
        fi
    done
    return 1
}

function align_right() {
    local message=${1:-}
    local offset=${2:-2}
    local width=${screen_width}

    local clean
    clean=$(strip_colours "${message}")
    local textsize=${#clean}

    local left_line='-' left_width=$((width - (textsize + offset + 2)))
    local right_line='-' right_width=${offset}

    while ((${#left_line} < left_width)); do left_line+="${left_line}"; done
    while ((${#right_line} < right_width)); do right_line+="${right_line}"; done

    printf '%s %s %s\n' "${left_line:0:left_width}" "${message}" "${right_line:0:right_width}"
}

function strip_colours() {
    local orig=${1:-}
    if ! shopt -q extglob; then
        shopt -s extglob
        local on=true
    fi
    local clean="${orig//$'\e'[\[(]*([0-9;])[@-n]/}"
    [[ "${on}" == true ]] && shopt -u extglob
    echo "${clean}"
}

# -------------------------------------------------------------------------------- #
# Core Functions                                                                   #
# -------------------------------------------------------------------------------- #



function check() {
    local filename=$1

    # shellcheck disable=SC2310
    if is_included "${filename}"; then
        check_file "${filename}"
        return
    fi

    # shellcheck disable=SC2310
    if is_excluded "${filename}"; then
        skip "${filename}"
        return
    fi

    if [[ "${#include_list[@]}" -ne 0 ]]; then
        return
    fi
    check_file "${filename}"
}

function scan_files() {
    while IFS= read -r filename; do
        if file -b "${filename}" | grep -qE "${FILE_TYPE_SEARCH_PATTERN}"; then
            check "${filename}"
        elif [[ "${filename}" =~ ${FILE_NAME_SEARCH_PATTERN} ]]; then
            check "${filename}"
        fi
    done < <(find . -type f -not -path "./.git/*" | sed 's|^./||' | sort -Vf || true)
}

function handle_parameters() {
    stage "Parameters"

    if [[ -n "${REPORT_ONLY-}" ]] && [[ "${REPORT_ONLY}" = true ]]; then
        REPORT_ONLY=true
        echo " Report Only: ${cyan_text}true${reset}"
        parameters=true
    else
        REPORT_ONLY=false
    fi

    if [[ -n "${SHOW_ERRORS-}" ]] && [[ "${SHOW_ERRORS}" = false ]]; then
        SHOW_ERRORS=false
        echo " Show Errors: ${cyan_text}true${reset}"
        parameters=true
    else
        SHOW_ERRORS=true
    fi

    if [[ -n "${SHOW_SKIPPED-}" ]] && [[ "${SHOW_SKIPPED}" == true ]]; then
        SHOW_SKIPPED=true
        echo " Show Skipped: ${cyan_text}true${reset}"
        parameters=true
    else
        SHOW_SKIPPED=false
    fi

    if [[ -n "${INCLUDE_FILES-}" ]]; then
        IFS=',' read -r -a include_list <<< "${INCLUDE_FILES}"
        echo " Included Files: ${cyan_text}${INCLUDE_FILES}${reset}"
        parameters=true
    else
        include_list=()
    fi

    if [[ -n "${EXCLUDE_FILES-}" ]] && [[ "${#include_list[@]}" -eq 0 ]]; then
        IFS=',' read -r -a exclude_list <<< "${EXCLUDE_FILES}"
        echo " Excluded Files: ${cyan_text}${EXCLUDE_FILES}${reset}"
        parameters=true
    else
        exclude_list=()
    fi

    handle_non_standard_parameters

    if [[ "${parameters}" != true ]]; then
        echo " No parameters given"
    fi
}

function handle_color_parameters() {
    if [[ -z "${CI-}" ]]; then
        if [[ -n "${NO_COLOR-}" ]]; then
            if [[ "${NO_COLOR}" == true ]]; then
                NO_COLOR=true
                # echo " Color: ${green_text}Disabled${reset}"
            else
                NO_COLOR=false
                # echo " Color: ${green_text}Enabled${reset}"
            fi
        else
            NO_COLOR=false
            # echo " Color: ${cyan_text}not set, defaulting to Enabled${reset}"
        fi
    else
        NO_COLOR=true
        # echo " Colour: Disabled due to running in a pipeline"
    fi
}

function footer() {
    stage "Report"
    printf ' %sTotal%s: %s, %s%sOK%s: %s, %s%sFailed%s: %s, %s%sSkipped%s: %s\n' "${bold_text}" "${reset}" "${file_count}" "${bold_text}" "${green_text}" "${reset}" "${ok_count}" "${bold_text}" "${red_text}" "${reset}" "${fail_count}" "${bold_text}" "${yellow_text}" "${reset}" "${skip_count}"
    stage 'Complete'
}

function setup() {
    export TERM=xterm

    handle_color_parameters

    screen_width=0
    # shellcheck disable=SC2034
    bold_text=''
    # shellcheck disable=SC2034
    reset=''
    # shellcheck disable=SC2034
    black_text='' 
    # shellcheck disable=SC2034
    red_text=''
    # shellcheck disable=SC2034
    green_text=''
    # shellcheck disable=SC2034
    yellow_text=''
    # shellcheck disable=SC2034
    blue_text=''
    # shellcheck disable=SC2034
    magenta_text=''
    # shellcheck disable=SC2034
    cyan_text=''
    # shellcheck disable=SC2034
    white_text=''

    if [[ "${NO_COLOR}" == false ]]; then
        screen_width=$(tput cols)
        screen_width=$((screen_width - 2))

        # shellcheck disable=SC2034
        bold_text=$(tput bold)
        # shellcheck disable=SC2034
        reset=$(tput sgr0)
        # shellcheck disable=SC2034
        black_text=$(tput setaf 0)
        # shellcheck disable=SC2034
        red_text=$(tput setaf 1)
        # shellcheck disable=SC2034
        green_text=$(tput setaf 2)
        # shellcheck disable=SC2034
        yellow_text=$(tput setaf 3)
        # shellcheck disable=SC2034
        blue_text=$(tput setaf 4)
        # shellcheck disable=SC2034
        magenta_text=$(tput setaf 5)
        # shellcheck disable=SC2034
        cyan_text=$(tput setaf 6)
        # shellcheck disable=SC2034
        white_text=$(tput setaf 7)
    fi

    (( screen_width < 140 )) && screen_width=140
    file_count=0
    ok_count=0
    fail_count=0
    skip_count=0
    parameters=false
}

# -------------------------------------------------------------------------------- #
# Main                                                                             #
# -------------------------------------------------------------------------------- #

setup
handle_parameters
install_prerequisites
get_version_information
stage "${BANNER}"
scan_files
footer

[[ "${REPORT_ONLY}" == true ]] && EXIT_VALUE=0

exit "${EXIT_VALUE}"
