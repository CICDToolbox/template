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
# -u (nounset)  = Treat unset variables and parameters other than the special      #
#                 parameters ‘@’ or ‘*’, or array variables subscripted with ‘@’   #
#                 or ‘*’, as an error when performing parameter expansion.         #
# -o pipefail   = Return value of a pipeline is the value of the last command to   #
#                 exit with a non-zero status, or zero if all commands are exit    #
#                 successfully.                                                    #
# -------------------------------------------------------------------------------- #

set -uo pipefail

# -------------------------------------------------------------------------------- #
# Debugging Mode                                                                   #
# -------------------------------------------------------------------------------- #
# Set to true to enable extra logging                                              #
# -------------------------------------------------------------------------------- #

DEBUG_MODE=false

# -------------------------------------------------------------------------------- #
# Global Variables for Configuration                                               #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# Python / Pip based packages only. If in doubt leave both as false!               #
#     UPDATE_PIP = Force an update to pip before installing the package.           #
#     INSTALL_REQUIREMENTS_FROM_REPO - pip install -r requirements.txt.            #
# -------------------------------------------------------------------------------- #

UPDATE_PIP=false
INSTALL_REQUIREMENTS_FROM_REPO=false

# -------------------------------------------------------------------------------- #
# What prerequisites does this pipeline have?                                      #
# -------------------------------------------------------------------------------- #
PREREQUISITE_COMMANDS=()

# -------------------------------------------------------------------------------- #
# What package are we installing (or url for repo to install from)?                #
# -------------------------------------------------------------------------------- #
PACKAGE_NAME=''

# -------------------------------------------------------------------------------- #
# What is base name of the package?                                                #
# -------------------------------------------------------------------------------- #
BASE_COMMAND="${PACKAGE_NAME}"

# -------------------------------------------------------------------------------- #
# How do we check to see if it is already installed?                               #
#                                                                                  #
# Leave empty if you want to force install (docker for example)                    #
# -------------------------------------------------------------------------------- #
CHECK_COMMAND=()

# -------------------------------------------------------------------------------- #
# How to install the require tool?                                                 #
#                                                                                  #
#     Note: This can be empty if it is a built in bash command or similar.         #
# -------------------------------------------------------------------------------- #
INSTALL_COMMAND=()

# -------------------------------------------------------------------------------- #
# The complete command string to run when running a tests.                         #
#                                                                                  #
#     default: ${TEST_COMMAND[@]} ${EXTRA_PARAMETERS[@]} ${filename}               #
# -------------------------------------------------------------------------------- #
TEST_COMMAND=()

# -------------------------------------------------------------------------------- #
# Extra parameters are options that are passed as configuration to the script that #
# are needed for the command execution.                                            #
# -------------------------------------------------------------------------------- #
EXTRA_PARAMETERS=()

# -------------------------------------------------------------------------------- #
# This is only needed for tools that require file contents to be redirected rather #
# than accessed via a path.                                                        #
# -------------------------------------------------------------------------------- #
REDIRECTED=false

# -------------------------------------------------------------------------------- #
# How to get the current version of the tool that we are using.                    #
#                                                                                  #
#     Note: | tr -d '\n' | head -n 1 | sed -E 's/[^0-9.]*([0-9.]+).*/\1/' is added #
#     automatically to filter out the actual version number.                       #
# -------------------------------------------------------------------------------- #
VERSION_COMMAND=("${BASE_COMMAND}" --version)

# -------------------------------------------------------------------------------- #
# Banner will have ${VERSION} appended to it in the final output / report.         #
# -------------------------------------------------------------------------------- #
BANNER_NAME="${BASE_COMMAND}"

# -------------------------------------------------------------------------------- #
# File type to match (comes from file -b). Regex based but ignored if left empty.  #
# -------------------------------------------------------------------------------- #
FILE_TYPE_SEARCH_PATTERN=''

# -------------------------------------------------------------------------------- #
# File name to match. Regex based - used if FILE_TYPE_SEARCH_PATTERN doesn't match #
# a file or is empty. If a file doesn't match either pattern it is 'unmatched'.    #
# -------------------------------------------------------------------------------- #
FILE_NAME_SEARCH_PATTERN='\.*'

# -------------------------------------------------------------------------------- #
# The base path to use when looking for matching files.                            #
# -------------------------------------------------------------------------------- #
SCAN_ROOT='.'

# -------------------------------------------------------------------------------- #
# Global Variables for Parameter Handling                                          #
# -------------------------------------------------------------------------------- #
# DO NOT REMOVE any of the entries below as they are required for the script to    #
# function, however you can ADD more entries to handle any additional parameters   #
# that you need for your specific implementation.                                  #
#                                                                                  #
# Note: If you want to make any of the above global variables into user parameters #
# then you need to add them to the NAMED_VALUE_PARAMS list below and REMOVE them   #
# from the global variables section above, otherwise the global version above will #
# always overwrite any user based parameters!                                      #
# -------------------------------------------------------------------------------- #

# Boolean parameters and their default values
declare -A BOOL_PARAMS=(
    ["REPORT_ONLY"]=false
    ["SHOW_ERRORS"]=true
    ["SHOW_FILTERED"]=false
    ["SHOW_UNMATCHED"]=false
)

# Comma-separated parameters that should be converted into arrays
LIST_PARAMS=("INCLUDE_FILES" "EXCLUDE_FILES")

# Parameters where the default is '' and should be set if provided
SET_IF_PROVIDED_PARAMS=()

# Associative array where the default is overwritten if a matching name is found
declare -A NAMED_VALUE_PARAMS=(
)

# -------------------------------------------------------------------------------- #
# Global Variables for required configuration                                      #
# -------------------------------------------------------------------------------- #
# The following are configuration items that MUST have a non empty value - if the  #
# value is unset or empty the script will error and abort.                         #
# -------------------------------------------------------------------------------- #

REQUIRED_VARIABLES=("PACKAGE_NAME" "BASE_COMMAND")
REQUIRED_ARRAYS=("TEST_COMMAND" "VERSION_COMMAND")
REQUIRED_DIRECTORIES=("SCAN_ROOT")  # The directory must exist

# -------------------------------------------------------------------------------- #
# Script Specific Global Variables                                                 #
# -------------------------------------------------------------------------------- #

#
# Add any script specific custom global variables here
#

# -------------------------------------------------------------------------------- #
# Tool Specific Functions                                                          #
# -------------------------------------------------------------------------------- #

function handle_non_standard_parameters()
{
    local parameters=false
    local extra_params
    declare -g PARAMETERS_BUFFER=""

    if [[ "${parameters}" == false ]]; then
        return 1
    fi

    if [[ -n "${extra_params}" ]]; then
        read -r -a temp_array <<< "${extra_params}"
        EXTRA_PARAMETERS+=("${temp_array[@]}")
    fi
    return 0
}

# -------------------------------------------------------------------------------- #
# Stop Here                                                                        #
#                                                                                  #
# Everything below here is standard and designed to work with all of the tools     #
# that have been built and released as part of the CICDToolbox.                    #
# -------------------------------------------------------------------------------- #

EXIT_VALUE=0

# -------------------------------------------------------------------------------- #
# Utility Functions                                                                #
# -------------------------------------------------------------------------------- #

function passed()
{
    local message=${1:-}

    passed_count=$((passed_count + 1))

    echo " [ ${bold_green_text}✅${reset} ] ${message}"
}

function failed()
{
    local message=${1:-}
    local errors=${2:-}

    failed_count=$((failed_count + 1))

    echo " [ ${bold_red_text}❌${reset} ] ${message}"

    # shellcheck disable=SC2154
    if [[ "${SHOW_ERRORS}" == true ]]; then
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

function filtered()
{
    local message=${1:-}

    filtered_count=$((filtered_count + 1))

    # shellcheck disable=SC2154
    if [[ "${SHOW_FILTERED}" == true ]]; then
        echo " [ ${bold_yellow_text}🟡${reset} ] ${message}"
    fi
}

function unmatched()
{
    local message=${1:-}

    unmatched_count=$((unmatched_count + 1))

    # shellcheck disable=SC2154
    if [[ "${SHOW_UNMATCHED}" == true ]]; then
        echo " [ ${bold_cyan_text}🔵${reset} ] ${message}"
    fi
}

function is_in_list()
{
    local needle=$1
    shift
    local array=("$@")  # Store the remaining arguments as an array

    for pattern in "${array[@]}"; do
        if [[ "${needle}" =~ ${pattern} ]]; then
            return 0  # Match found
        fi
    done
    return 1  # No match found
}

function is_excluded()
{
    local needle=$1

    # shellcheck disable=SC2154
    if is_in_list "${needle}" "${EXCLUDE_FILES[@]}"; then
        return 0;
    fi
    return 1
}

function is_included()
{
    local needle=$1

    # shellcheck disable=SC2154
    if is_in_list "${needle}" "${INCLUDE_FILES[@]}"; then
        return 0
    fi
    return 1
}

function draw_line()
{
    local message=${1:-}
    local offset=${2:-2}
    local width=${screen_width}

    local textsize=${#message}

    local left_line='-' left_width=$((width - (textsize + offset + 2)))
    local right_line='-' right_width=${offset}

    while ((${#left_line} < left_width)); do left_line+="${left_line}"; done
    while ((${#right_line} < right_width)); do right_line+="${right_line}"; done

    printf '%s %s %s\n' "${left_line:0:left_width}" "${bold_cyan_text}${message}${reset}" "${right_line:0:right_width}"
}

# -------------------------------------------------------------------------------- #
# Core Functions                                                                   #
# -------------------------------------------------------------------------------- #

function run_command()
{
    local output
    local -a command=()

    # Flatten all input arguments (arrays + standalone strings)
    for arg in "$@"; do
        if [[ -n "${arg}" ]]; then
            if [[ "${arg}" =~ ^[[:alnum:]_]+[@]$ ]]; then
                # Handle array references like $list1[@]
                local -n ref_array="${arg%@}"  # Remove '@' and get reference to the array
                command+=("${ref_array[@]}")
            else
                # Treat it as a standalone string argument
                command+=("${arg}")
            fi
        fi
    done

    if ! output=$("${command[@]}" 2>&1); then
        if [[ "${DEBUG_MODE}" == true ]]; then
            echo " [ ${bold_red_text}Command Error${reset} ]" >&2
            echo "              Command = ${command[*]}" >&2
            echo "              Result = ${output}" >&2
        else
            echo "${output}"
        fi
        return 1
    fi
    echo "${output}"
    return 0
}

function handle_prerequisites()
{
    local errors
    local errors_found=0
    local buffer=""
    local prefix=" [ ${bold_red_text}Prerequisite Error${reset} ]"
    local suffix="[${bold_cyan_text}Enable DEBUG_MODE for more details${reset}]"

    # Make sure prerequisite_commands are installed
    for i in "${PREREQUISITE_COMMANDS[@]}"
    do
        if ! errors=$(run_command command -v "${i}"); then
            buffer+="${prefix} ${i} is not installed - Aborting! ${suffix}\n"
            ((errors_found++))
        fi
    done

    if [[ "${UPDATE_PIP}" = true ]]; then
        if ! errors=$(run_command python3 -m pip install --quiet --upgrade pip); then
            buffer+="${prefix} Pip update failed - Aborting ${suffix}\n"
            ((errors_found++))
        fi
    fi

    # Is the module installed?
    if [[ ${#CHECK_COMMAND[@]} -gt 0 ]]; then
        if ! errors=$(run_command "${CHECK_COMMAND[@]}"); then
            if [[ ${#INSTALL_COMMAND[@]} -gt 0 ]]; then
                if ! errors=$(run_command "${INSTALL_COMMAND[@]}"); then
                    buffer+="${prefix} Failed to install ${BANNER_NAME} ${suffix}\n"
                    ((errors_found++))
                fi
            fi
        fi
    fi

    if [[ "${INSTALL_REQUIREMENTS_FROM_REPO}" = true ]] ; then
        while IFS= read -r filename
        do
            if ! errors=$(run_command pip install -r "${filename}" ); then
                buffer+="${prefix} ${filename} ${suffix}\n"
                ((errors_found++))
            fi
        done < <(find . -name 'requirements*.txt' -type f -not -path "./.git/*" | sed 's|^./||' | sort -Vf || true)
    fi

    if (( errors_found > 0 )); then
        printf "%b" "${buffer}" >&2
        exit "${EXIT_VALUE}"
    fi
}

function get_version_information()
{
    local output VERSION

    if ! output=$(run_command "${VERSION_COMMAND[@]}" | tr -d '\n' | head -n 1 ); then
        VERSION="Unknown"
    else
        VERSION="$(sed -E 's/[^0-9.]*([0-9.]+).*/\1/' <<<"${output}")"
    fi
    BANNER="${BANNER_NAME} (Version: ${VERSION})"
}

function check_file()
{
    local filename=$1
    local errors

    file_count=$((file_count + 1))

    local command=("${TEST_COMMAND[@]}" "${EXTRA_PARAMETERS[@]}")
    [[ "${REDIRECTED}" = true ]] && command+=("<" "${filename}") || command+=("${filename}")

    if ! errors=$(run_command "${command[@]}"); then
        failed "${filename}" "${errors}"
    else
        passed "${filename}"
    fi
}

function scan_files()
{
    while IFS= read -r filename; do
        if is_included "${filename}"; then
            check_file "${filename}"
        elif is_excluded "${filename}"; then
            filtered "${filename}"
        elif [[ -n "${FILE_TYPE_SEARCH_PATTERN}" ]] && file -b "${filename}" | grep -qE "${FILE_TYPE_SEARCH_PATTERN}"; then
            check_file "${filename}"
        elif [[ -n "${FILE_NAME_SEARCH_PATTERN}" ]] && [[ "${filename}" =~ ${FILE_NAME_SEARCH_PATTERN} ]]; then
            check_file "${filename}"
        else
            unmatched "${filename}"
        fi
    done < <(find "${SCAN_ROOT}" -type f -not -path "./.git/*" | sed 's|^./||' | sort -Vf || true)
}

function handle_parameters()
{
    local parameters=false
    local buffer=""

    # Check and apply boolean parameters
    for param in "${!BOOL_PARAMS[@]}"; do
        if [[ -n "${!param-}" ]]; then
            declare -g "${param}=${!param}"
        else
            declare -g "${param}=${BOOL_PARAMS[${param}]}"
        fi

        if [[ "${!param}" != "${BOOL_PARAMS[${param}]}" ]]; then
            buffer+=" ${param}: ${bold_cyan_text}${!param}${reset}\n"
            parameters=true
        fi
    done

    # Process each list parameter dynamically
    for list_param in "${LIST_PARAMS[@]}"; do
        local array_name="${list_param}"
        local var_value="${!list_param-}"  # Get variable value safely

        # Ensure the array exists by initializing it
        declare -g -a "${array_name}=()"
    
        # Read comma-separated list into a dynamically named array
        eval "${array_name}=()"
        IFS=',' eval "read -r -a ${array_name} <<< \"${var_value}\""

        # Check if array contains elements safely using eval
        local array_length
        array_length=$(eval "echo \${#${array_name}[@]}")

        if (( array_length > 0 )); then
            buffer+=" ${list_param}: ${bold_cyan_text}${!list_param}${reset}\n"
            parameters=true
        fi
    done

    # Process parameters that should be set if provided (default is '')
    for param in "${SET_IF_PROVIDED_PARAMS[@]}"; do
        if [[ -n "${!param-}" ]]; then
            declare -g "${param}=${!param}"

            buffer+=" ${param}: ${bold_cyan_text}${!param}${reset}\n"
            parameters=true
        else
            declare -g "${param}=''"  # Ensure default is empty string
        fi
    done

    # Process named value parameters (overwrite default if different)
    for param in "${!NAMED_VALUE_PARAMS[@]}"; do
        local default_value="${NAMED_VALUE_PARAMS[${param}]}"

        echo "${param} - ${!param} - ${default_value}"
        if [[ -n "${!param-}" && "${!param}" != "${default_value}" ]]; then
            declare -g "${param}=${!param}"
        else
            declare -g "${param}=${default_value}"
        fi

        if [[ "${!param}" != "${default_value}" ]]; then
            buffer+=" ${param}: ${bold_cyan_text}${!param}${reset}\n"
            parameters=true
        fi
    done

    if handle_non_standard_parameters; then
        buffer+=${PARAMETERS_BUFFER}
        parameters=true
    fi

    if [[ "${parameters}" == true ]]; then
        draw_line "Parameters"
        printf "%b" "${buffer}"
    fi
}

function handle_color_parameters()
{
    NO_COLOR=${NO_COLOR:-false}  # Default to false if not set
    NO_COLOR=$([[ "${NO_COLOR}" == true ]] && echo true || echo false)
}

function footer()
{
    draw_line 'Report'

    # Define an array of status labels and their counts
    local stats=(
        "${bold_white_text}Total${reset}: ${file_count}"
        "${bold_green_text}Passed${reset}: ${passed_count}"
        "${bold_red_text}Failed${reset}: ${failed_count}"
        "${bold_yellow_text}Filtered${reset}: ${filtered_count}"
        "${bold_cyan_text}Unmatched${reset}: ${unmatched_count}"
    )

    # Print all stats in a single formatted line
    echo " ${stats[*]}"

    draw_line 'Complete'
}

function setup()
{
    export TERM=xterm

    handle_color_parameters

    screen_width=$(tput cols)
    screen_width=$((screen_width - 2))

    bold_red_text=''
    bold_green_text=''
    bold_yellow_text=''
    bold_cyan_text=''
    bold_white_text=''
    reset=''

    if [[ "${NO_COLOR}" == false ]]; then
        bold_red_text=$(tput bold; tput setaf 1)
        bold_green_text=$(tput bold; tput setaf 2)
        bold_yellow_text=$(tput bold; tput setaf 3)
        bold_cyan_text=$(tput bold; tput setaf 6)
        bold_white_text=$(tput bold; tput setaf 7)
        reset=$(tput sgr0)
    fi

    (( screen_width < 140 )) && screen_width=140
    file_count=0
    passed_count=0
    failed_count=0
    filtered_count=0
    unmatched_count=0
    parameters=false
}

function check_configuration()
{
    local errors_found=0
    local config_buffer=""
    local prefix=" [ ${bold_red_text}Config Error${reset} ]"

    # Check required string variables
    for var in "${REQUIRED_VARIABLES[@]}"; do
        if [[ -z "${!var-}" ]]; then  # Use ${!var-} to avoid unbound variable errors
            config_buffer+="${prefix} ${var} is not set.\n"
            ((errors_found++))
        fi
    done

    # Check required array variables (no unbound variable errors)
    for arr in "${REQUIRED_ARRAYS[@]}"; do
        if ! declare -p "${arr}" &>/dev/null; then
            config_buffer+="${prefix} ${arr} is not set.\n"
            ((errors_found++))
            continue
        fi

        # Safely get array length using indirect expansion
        local arr_length
        arr_length=$(eval "echo \${#${arr}[@]}")

        if (( arr_length == 0 )); then
            config_buffer+="${prefix} ${arr} is empty.\n"
            ((errors_found++))
        fi
    done

    # Check required directory variables
    for dir in "${REQUIRED_DIRECTORIES[@]}"; do
        if [[ ! -d "${!dir-}" ]]; then
            config_buffer+="${prefix} Check ${dir} settings as ${!dir-} does not exist.\n"
            ((errors_found++))
        fi
    done

    if (( errors_found > 0 )); then
        printf "%b" "${config_buffer}" >&2
        exit "${EXIT_VALUE}"
    fi
}

function check_bash_version()
{
    local required_version="4.0.0"  # Associative arrays were introduced in Bash 4.0
    local current_version
    local sorted_versions

    # Extract only the numeric part (major.minor.patch) from BASH_VERSION
    current_version=$(echo "${BASH_VERSION}" | sed -E 's/[^0-9.]*([0-9.]+).*/\1/')

    # Compare versions
    sorted_versions=$(printf '%s\n' "${required_version}" "${current_version}" | sort -V | head -n1)

    if [[ "${sorted_versions}" != "${required_version}" ]]; then
        echo "[ ${bold_red_text}Version Error${reset} ] Bash version ${current_version} is too old. Require ${required_version} or newer." >&2
        exit 1
    fi
}

# -------------------------------------------------------------------------------- #
# Main                                                                             #
# -------------------------------------------------------------------------------- #
function main()
{
    setup
    check_bash_version
    check_configuration
    handle_prerequisites
    handle_parameters
    get_version_information
    draw_line "${BANNER}"
    scan_files
    footer
}

main

# shellcheck disable=SC2154
[[ "${REPORT_ONLY}" == true ]] && EXIT_VALUE=0

exit "${EXIT_VALUE}"
