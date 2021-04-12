# bash completion for op                                   -*- shell-script -*-

__op_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__op_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__op_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__op_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__op_handle_go_custom_completion()
{
    __op_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly op allows to handle aliases
    args=("${words[@]:1}")
    requestComp="${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __op_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __op_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __op_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __op_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __op_debug "${FUNCNAME[0]}: the completions are: ${out[*]}"

    if [ $((directive & 1)) -ne 0 ]; then
        # Error code.  No completion.
        __op_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & 2)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __op_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & 4)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __op_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi

        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out[*]}" -- "$cur")
    fi
}

__op_handle_reply()
{
    __op_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __op_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __op_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        completions=()
        __op_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __op_custom_func >/dev/null; then
			# try command name qualified custom func
			__op_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__op_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__op_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__op_handle_flag()
{
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __op_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __op_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __op_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __op_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __op_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__op_handle_noun()
{
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __op_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __op_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__op_handle_command()
{
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_op_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __op_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__op_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __op_handle_reply
        return
    fi
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __op_handle_flag
    elif __op_contains_word "${words[c]}" "${commands[@]}"; then
        __op_handle_command
    elif [[ $c -eq 0 ]]; then
        __op_handle_command
    elif __op_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __op_handle_command
        else
            __op_handle_noun
        fi
    else
        __op_handle_noun
    fi
    __op_handle_word
}

_op_add_group()
{
    last_command="op_add_group"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_add_user()
{
    last_command="op_add_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--role=")
    two_word_flags+=("--role")
    local_nonpersistent_flags+=("--role=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_add()
{
    last_command="op_add"

    command_aliases=()

    commands=()
    commands+=("group")
    commands+=("user")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_completion()
{
    last_command="op_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_confirm()
{
    last_command="op_confirm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_create_document()
{
    last_command="op_create_document"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filename=")
    two_word_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_create_group()
{
    last_command="op_create_group"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_create_item()
{
    last_command="op_create_item"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--generate-password")
    local_nonpersistent_flags+=("--generate-password")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_create_user()
{
    last_command="op_create_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--language=")
    two_word_flags+=("--language")
    local_nonpersistent_flags+=("--language=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_create_vault()
{
    last_command="op_create_vault"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-admins-to-manage=")
    two_word_flags+=("--allow-admins-to-manage")
    local_nonpersistent_flags+=("--allow-admins-to-manage=")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_create()
{
    last_command="op_create"

    command_aliases=()

    commands=()
    commands+=("document")
    commands+=("group")
    commands+=("item")
    commands+=("user")
    commands+=("vault")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete_document()
{
    last_command="op_delete_document"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete_group()
{
    last_command="op_delete_group"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete_item()
{
    last_command="op_delete_item"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete_trash()
{
    last_command="op_delete_trash"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete_user()
{
    last_command="op_delete_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete_vault()
{
    last_command="op_delete_vault"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_delete()
{
    last_command="op_delete"

    command_aliases=()

    commands=()
    commands+=("document")
    commands+=("group")
    commands+=("item")
    commands+=("trash")
    commands+=("user")
    commands+=("vault")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_edit_document()
{
    last_command="op_edit_document"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filename=")
    two_word_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_edit_group()
{
    last_command="op_edit_group"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_edit_item()
{
    last_command="op_edit_item"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--generate-password")
    local_nonpersistent_flags+=("--generate-password")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_edit_user()
{
    last_command="op_edit_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--travelmode=")
    two_word_flags+=("--travelmode")
    local_nonpersistent_flags+=("--travelmode=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_edit_vault()
{
    last_command="op_edit_vault"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_edit()
{
    last_command="op_edit"

    command_aliases=()

    commands=()
    commands+=("document")
    commands+=("group")
    commands+=("item")
    commands+=("user")
    commands+=("vault")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_encode()
{
    last_command="op_encode"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_forget()
{
    last_command="op_forget"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_account()
{
    last_command="op_get_account"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_document()
{
    last_command="op_get_document"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--include-trash")
    local_nonpersistent_flags+=("--include-trash")
    flags+=("--output=")
    two_word_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_group()
{
    last_command="op_get_group"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_item()
{
    last_command="op_get_item"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--fields=")
    two_word_flags+=("--fields")
    local_nonpersistent_flags+=("--fields=")
    flags+=("--format=")
    two_word_flags+=("--format")
    local_nonpersistent_flags+=("--format=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--include-trash")
    local_nonpersistent_flags+=("--include-trash")
    flags+=("--share-link")
    local_nonpersistent_flags+=("--share-link")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_template()
{
    last_command="op_get_template"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_totp()
{
    last_command="op_get_totp"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_user()
{
    last_command="op_get_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--fingerprint")
    local_nonpersistent_flags+=("--fingerprint")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--publickey")
    local_nonpersistent_flags+=("--publickey")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get_vault()
{
    last_command="op_get_vault"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_get()
{
    last_command="op_get"

    command_aliases=()

    commands=()
    commands+=("account")
    commands+=("document")
    commands+=("group")
    commands+=("item")
    commands+=("template")
    commands+=("totp")
    commands+=("user")
    commands+=("vault")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_documents()
{
    last_command="op_list_documents"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--include-trash")
    local_nonpersistent_flags+=("--include-trash")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_events()
{
    last_command="op_list_events"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--eventid=")
    two_word_flags+=("--eventid")
    local_nonpersistent_flags+=("--eventid=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--older")
    local_nonpersistent_flags+=("--older")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_groups()
{
    last_command="op_list_groups"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_items()
{
    last_command="op_list_items"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--categories=")
    two_word_flags+=("--categories")
    local_nonpersistent_flags+=("--categories=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--include-trash")
    local_nonpersistent_flags+=("--include-trash")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_templates()
{
    last_command="op_list_templates"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_users()
{
    last_command="op_list_users"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list_vaults()
{
    last_command="op_list_vaults"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_list()
{
    last_command="op_list"

    command_aliases=()

    commands=()
    commands+=("documents")
    commands+=("events")
    commands+=("groups")
    commands+=("items")
    commands+=("templates")
    commands+=("users")
    commands+=("vaults")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_reactivate()
{
    last_command="op_reactivate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_remove_group()
{
    last_command="op_remove_group"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_remove_user()
{
    last_command="op_remove_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_remove()
{
    last_command="op_remove"

    command_aliases=()

    commands=()
    commands+=("group")
    commands+=("user")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_signin()
{
    last_command="op_signin"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--raw")
    flags+=("-r")
    local_nonpersistent_flags+=("--raw")
    flags+=("--shorthand=")
    two_word_flags+=("--shorthand")
    local_nonpersistent_flags+=("--shorthand=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_signout()
{
    last_command="op_signout"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--forget")
    local_nonpersistent_flags+=("--forget")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_suspend()
{
    last_command="op_suspend"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_update()
{
    last_command="op_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--directory=")
    two_word_flags+=("--directory")
    local_nonpersistent_flags+=("--directory=")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_root_command()
{
    last_command="op"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("completion")
    commands+=("confirm")
    commands+=("create")
    commands+=("delete")
    commands+=("edit")
    commands+=("encode")
    commands+=("forget")
    commands+=("get")
    commands+=("list")
    commands+=("reactivate")
    commands+=("remove")
    commands+=("signin")
    commands+=("signout")
    commands+=("suspend")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_op()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __op_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("op")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function
    local last_command
    local nouns=()

    __op_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_op op
else
    complete -o default -o nospace -F __start_op op
fi

# ex: ts=4 sw=4 et filetype=sh
