#!/usr/bin/env sh

###############################################################################
# SHELLFORGE
#
#   File :     shellforge.sh
#   Version :  0.1.0
#
#   Note : Do not run file directly. Source it.
#
#   eg.    source shellforge.sh
#          . ./shellforge.sh
###############################################################################
# ADMIN [at] DTRH [dot] NET

###############################################################################
# SHELLCHECK DIRECTIVES
###############################################################################

# Disable SC1090 - https://www.shellcheck.net/wiki/SC1090
# shellcheck disable=SC1090

###############################################################################
# POSIX compliant logic to determine if script is run directly or sourced
###############################################################################
#
# If the script is run directly, it'll return a $0 value of the scriptname.ext
# If it is sourced, it will return $SHELL. Because $SHELL will not return a 
# shell with any '.' in its path, I '.sh' against $0 after assuming it is run
# directly, and stripping it down to its extension including that '.' eg '.sh'
#
# This is not perfect. POSIX doesn't support most methods of determining if a 
# script is directly run or sourced. This is a bit of a hack, and has some 
# limitations. 
#
# It all falls apart if the script name is changed to an extensionless filename
# 
#
if [ ".${0##*.}" = ".sh" ]; then
    >&2 echo "Don't run $0, source it"
    exit 1
fi

# echo "Script sourced successfully!"

###############################################################################
# Native Output functions
###############################################################################
#
# The whole idea behind shellforge is to allow addition of modules to extend the
# basic shell environment. These are for formatting output before any modules 
# have been loaded, and can be considered as the built-in basic and always 
# accessible functions to use
#
#
BOLD=$(printf '\033[1m')
RESET=$(printf '\033[0m')

# TODO: These could be better..
nfHeader() { printf "\n> [ %s %s %s ]\n\n" "${BOLD}" "$1" "${RESET}"; }
nfInfo() { printf "\n%s\n" "$1"; }
nfError() { printf "\n%sError:%s %s" "${BOLD}" "${RESET}" "$1" >&2; }
nfListCMD() { printf "  %-20s %-50s\n" "$1" "$2"; }


###############################################################################
# Welcome  Banner
###############################################################################
#
# Lets define some constants here, as it seems fitting

_NAME_="ShellForge"
_VERSION_="0.0.1"
_AUTHOR_="KBS <admin[at]dtrh[dot]net>"
_DATE_="January 2, 2025"


welcome() {
    cat <<EOF


============================================================
                      SHELLFORGE TOOLKIT
------------------------------------------------------------
   Version: $_VERSION_
   Author:  $_AUTHOR_
   Date:    $_DATE_
============================================================

Shellforge is initializing...
DONE!

TIP : See README.md for detalied use information.
      Use the command "shellforge" without options or parameters for basic usage info. 

EOF

}


###############################################################################
# Initialization
###############################################################################
#
#

welcome   # TODO: Something less boring

# Ensure GLOBAL_REGISTRY is initialized only if it is not already set
if [ -z "$GLOBAL_REGISTRY" ]; then
    GLOBAL_REGISTRY=""
fi

# Export GLOBAL_REGISTRY to ensure it persists across shell runs
export GLOBAL_REGISTRY

# State file to persist the environment
# TODO: This could be written much better, plus less hardcoded
STATE_DIR="states"
STATE_FILE="$STATE_DIR/module_state.env"

# Ensure LOADED_MODULES is initialized only if it is not already set
if [ -z "$LOADED_MODULES" ]; then
    LOADED_MODULES=""
fi

# Export LOADED_MODULES to ensure it persists across shell runs
export LOADED_MODULES


###############################################################################
# State Management Functions
###############################################################################
#
# GLOBAL_REGISTRY - This variable is used to track, enable, and disable the 
#                   command index
# LOADED_MODULES - This variable tracks which modules are loaded
#
# We handle persistence across the shell environment, including the ability to 
# save, load, unload, auto-save, and auto-load shellforge using 'states'. States
# can be seen as a save of the environment, which can be loaded once to bring a
# user back to a customized environment, reducing the redundency of loading each
# module everytime a new shell is started.
#
# This system will be expanded on, adding more functionality for saving to 
# specific files, which can then be imported to the shell such as .bashrc, etc.
#
#


saveState() { 
    echo "GLOBAL_REGISTRY='$GLOBAL_REGISTRY'" > "$STATE_FILE"
    echo "LOADED_MODULES='$LOADED_MODULES'" >> "$STATE_FILE"
    nfInfo "State saved to $STATE_FILE"
}

loadState() {
    if [ -f "$STATE_FILE" ]; then
        . "$STATE_FILE"
        export GLOBAL_REGISTRY
        export LOADED_MODULES
        nfInfo "State loaded from $STATE_FILE"
    else
        nfError "No saved state found."
    fi
}

###############################################################################
# Module Management Functions
###############################################################################
#
#

# Is the module already loaded? This ensures we aren't registering the same 
# commands or modules more than once.
chkMod() {
    module_name="$1"
    echo "$LOADED_MODULES" | grep -qw "$module_name"
}

findMod() {

    # TODO: There is no intention in keeping the module search hardcoded in the
    #       shellforge/modules directory. For now, this simpliies testing
    dir="$(pwd)/modules"

    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist." >&2
        return 1
    fi

    # TODO: Will utilize the find command to return if the file is valid
    find "$dir" -type f -name "*.sfmod" 2>/dev/null
}


loadMod() {
    module_file="$1"

    # This snippet is for gracefully loading modules, which to adhere to POSIX standards, cannot 
    # use the command 'source' but rather '. ./${file}'. This bit simply removes the possibility
    # of a module failing to load due to the strict necessity of the './' preceeding the file 
    # to be sourced. TLDR - It checks to see if './' is there, if it is it does nothing, and if
    # it isn't, it adds it.
    case "$module_file" in
        /*|./*) ;;
        *) module_file="./$module_file" ;;
    esac

    if [ ! -f "$module_file" ]; then
        nfError "Module file '$module_file' not found."
        return 1
    fi

    # Source the module
    . "$module_file"

    if ! command -v MOD_INFO >/dev/null || ! command -v MOD_COMMANDS >/dev/null; then
        nfError "Module '$module_file' does not implement required functions (MOD_INFO, MOD_COMMANDS)."
        return 1
    fi

    # Capture module information from MOD_INFO
    MOD_INFO_OUTPUT=$(MOD_INFO)

    MOD_NAME=""
    MOD_VERSION=""
    MOD_AUTHOR=""
    i=0
    while IFS= read -r line; do
        case $i in
            0) MOD_NAME="$line" ;;
            1) MOD_VERSION="$line" ;;
            2) MOD_AUTHOR="$line" ;;
        esac
        i=$((i + 1))
    done <<EOF
$MOD_INFO_OUTPUT
EOF

    if chkMod "$MOD_NAME"; then
        nfError "Module '$MOD_NAME' is already loaded."
        return 1
    fi

    MOD_COMMANDS_OUTPUT=$(MOD_COMMANDS)
    for cmd in $MOD_COMMANDS_OUTPUT; do
        if echo "$GLOBAL_REGISTRY" | grep -qw ":$cmd:"; then
            existing_module=$(echo "$GLOBAL_REGISTRY" | awk -F ':' -v cmd="$cmd" '$2 == cmd {print $1}')
            nfError "Command '$cmd' already exists in module '$existing_module'."
            return 1
        fi

        # TODO: Unfortunately I didn't look forward enough to notice that this works only for grabbing
        # summary info for modules being loaded. It would be nice to get summary info from modules 
        # when they aren't loaded, and apply that to the 'found modules' while listing modules. So, 
        # that is to be done
        summary_var="${cmd}_summary"
        eval "summary_text=\${$summary_var}"
        if [ -z "$summary_text" ]; then
            summary_text="No summary available for $cmd"
        fi
        GLOBAL_REGISTRY="${GLOBAL_REGISTRY}${MOD_NAME}:${cmd}:${summary_text};"
    done

    # Add to the list and export + save state
    LOADED_MODULES="${LOADED_MODULES} ${MOD_NAME}"
    export GLOBAL_REGISTRY LOADED_MODULES
    saveState

    # 
    nfInfo "Module '$MOD_NAME' (v$MOD_VERSION) by $MOD_AUTHOR loaded successfully!"
}


unloadMod() {
    module_name="$1"

    if [ -z "$module_name" ]; then
        nfError "No module name provided for unloading."
        return 1
    fi

    # Check if the module is loaded
    if ! chkMod "$module_name"; then
        nfError "Module '$module_name' is not loaded."
        return 1
    fi

    # Retrieve commands associated with the module
    commands_to_unload=$(echo "$GLOBAL_REGISTRY" | tr ';' '\n' | awk -F ':' -v mod="$module_name" '$1 == mod {print $2}')

    # Unset each command from the shell environment
    # This took forever to figure, and now thqt I look at it - it seems so logical
    # aka - SLEEP IS NOT FOR THE WEAK
    for cmd in $commands_to_unload; do
        unset -f "$cmd" 2>/dev/null || unset "$cmd" 2>/dev/null
    done

    # Remove all entries belonging to the module from GLOBAL_REGISTRY
    GLOBAL_REGISTRY=$(echo "$GLOBAL_REGISTRY" | awk -F ':' -v mod="$module_name" '$1 != mod {print $0}')

    # Remove the module from LOADED_MODULES
    LOADED_MODULES=$(echo "$LOADED_MODULES" | tr ' ' '\n' | grep -v "^$module_name$" | tr '\n' ' ')

    # Export the updated variables
    export GLOBAL_REGISTRY LOADED_MODULES

    # Save the updated state
    saveState

    nfInfo "Module '$module_name' unloaded successfully."
}


###############################################################################
# Command and Module Listing Functions
###############################################################################

# Much clearner output update
listSFcmds() {
    nfHeader "Registered Commands"
    printf "  ${BOLD}%-20s %-20s %-50s${RESET}\n" "Command Name" "Module" "Summary"
    echo "------------------------------------------------------------------"
    echo "$GLOBAL_REGISTRY" | tr ';' '\n' | awk -F ':' '{
        if ($2 && $1) {
            printf "  %-20s %-20s %-50s\n", $2, $1, $3
        }
    }'
    echo ""
}

# Relevant implementation details are found within
listSFmods() {
    nfHeader "Loaded Modules"
    printf "  ${BOLD}%-20s %-50s${RESET}\n" "Module Name" "Summary"
    echo "--------------------------------------"
    for module in $LOADED_MODULES; do
        summary=$(echo "$GLOBAL_REGISTRY" | tr ';' '\n' | awk -F ':' -v mod="$module" '
            $1 == mod {print $3; exit}')
        if [ -z "$summary" ]; then
            summary="No summary available"
        fi
        printf "  %-20s %-50s\n" "$module" "$summary"
    done
    echo ""

    # TODO: Implement module name, summary, error checking, validation. At this point
    #       it will only return a module, in the module directory, entirely based on 
    #       its file extension. 
    nfHeader "Found Modules"
    printf "  ${BOLD}%-20s %-50s${RESET}\n" "Module Name" "Summary"
    echo "--------------------------------------"
    for module in $(findMod); do
        echo "$module"
    done
}


###############################################################################
# Command Execution
###############################################################################
#
# There is really no need to execute commands in this context. I have a feeling 
# this may come in handy while debugging down the road, but this will most 
# certainly be removed in v1.0.0 should no use come of it.
#
#

execute_command() {
    cmd="$1"
    shift

    if [ -z "$cmd" ]; then
        nfError "No command provided for execution."
        return 1
    fi

    module=$(echo "$GLOBAL_REGISTRY" | awk -F ':' -v cmd="$cmd" '$2 == cmd {print $1; exit}')
    if [ -z "$module" ]; then
        nfError "Command '$cmd' not found in the registry."
        return 1
    fi

    . "$(pwd)/module/${module}.sfmod" 2>/dev/null || { nfError "Failed to source module: $module"; return 1; }
    "$cmd" "$@"
}
 
###############################################################################
# Main Logic
###############################################################################
#
# Some considerable changes here - moving to heirarchal style 
# command->subcommand->action. Some rudimentary functionality does exist direct
# in this; so..
#
# TODO: Removal of direct code. It might just be a pet peeve or something nagging
# at me but, I do not like direct code being ran in shellforge(), and would 
# sooner call functions and routines which do work here. 
#
# TODO: I haven't done homework to see if I can also make this run if the user 
# uses 'sf'. Do not want complications with others environments. This could easily
# be implemented as an ALIAS should someone want to do so.
#
#

shellforge () {
    case "$1" in
        module)
            case "$2" in
                load)
                    loadMod "$3"
                    ;;
                unload)
                    unloadMod "$3"
                    ;;
                list)
                    listSFmods
                    ;;
                *)
                    nfHeader "Usage for module"
                    echo "shellforge module <load|unload|list>"
                    ;;
            esac
            ;;
        command)
            case "$2" in
                list)
                    listSFcmds
                    ;;
                *)
                    nfHeader "Usage for command"
                    echo "shellforge command <list>"
                    ;;
            esac
            ;;
        state)
            case "$2" in
                save)
                    saveState "${3:-$STATE_FILE}" # Use $3 if provided, otherwise default to $STATE_FILE
                    ;;
                load)
                    loadState "${3:-$STATE_FILE}" # Use $3 if provided, otherwise default to $STATE_FILE
                    ;;
                info)
                    nfHeader "State Information"
                    echo "Global Registry: $GLOBAL_REGISTRY"
                    echo "Loaded Modules: $LOADED_MODULES"
                    ;;
                *)
                    nfHeader "Usage for state"
                    echo "shellforge state <save [statefile]|load [statefile]|info>"
                    ;;
            esac
            ;;
        env)
            case "$2" in
                info)
                    # TODO: Ugly as hell, make this pretty
                    nfHeader "Environment Variables"
                    echo "GLOBAL_REGISTRY: $GLOBAL_REGISTRY"
                    echo "LOADED_MODULES: $LOADED_MODULES"
                    echo "STATE_FILE: $STATE_FILE"
                    ;;
                *)
                    nfHeader "Usage for env"
                    echo "shellforge env <info>"
                    ;;
            esac
            ;;
        *)
            # TODO: Ugly as hell, make this pretty
            nfHeader "shellforge Usage"
            echo "shellforge module <load|unload|list> [module_name]"
            echo "shellforge command <list>"
            echo "shellforge state <save [statefile]|load [statefile]|info>"
            echo "shellforge env <info>"
            ;;
    esac
}
