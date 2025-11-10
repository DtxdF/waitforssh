#!/bin/sh
#
# Copyright (c) 2025, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# waitforssh version.
VERSION="%%VERSION%%"

# See sysexits(3)
EX_OK=0
EX_USAGE=64
EX_DATAERR=65
EX_UNAVAILABLE=69

main()
{
    local _o
    local command="true"
    local test_command="true"
    local delay="random"
    local max_retries="1000"

    while getopts ":vC:T:d:r:" _o; do
        case "${_o}" in
            v)
                version
                exit ${EX_OK}
                ;;
            C)
                command="${OPTARG}"
                ;;
            T)
                test_command="${OPTARG}"
                ;;
            d)
                delay="${OPTARG}"
                ;;
            r)
                max_retries="${OPTARG}"

                if ! check_number "${max_retries}" || [ "${max_retries}" -eq 0 ]; then
                    err "${max_retries}: bad number"
                    exit ${EX_DATAERR}
                fi
                ;;
            *)
                usage
                exit ${EX_USAGE}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ $# -eq 0 ]; then
        usage
        exit ${EX_USAGE}
    fi

    local target="$1"

    if [ "${delay}" = "random" ]; then
        delay=`random_number` || exit $?
    fi

    local retries=0

    while [ ${retries} -lt ${max_retries} ]; do
        sleep "${delay}" || exit $?

        if ! wrapssh "${target}" "${command}" "${test_command}"; then
            retries=$((retries+1))
            continue
        fi

        break
    done

    if [ ${retries} -ge ${max_retries} ]; then
        exit ${EX_UNAVAILABLE}
    else
        exit ${EX_OK}
    fi
}

wrapssh()
{
    test $# -lt 4 || exit $?

    local target="$1" command="$2" test_command="$3"

    ssh -T \
        -o LogLevel="${WAITFORSSH_LOGLEVEL:-QUIET}" \
        -o StrictHostKeyChecking="${WAITFORSSH_STRICTHOSTKEYCHECKING:-no}" \
        -o UserKnownHostsFile="${WAITFORSSH_USERKNOWNHOSTSFILE:-/dev/null}" -- "${target}" "${test_command}" || return $?

    if [ "${command}" = "${test_command}" ]; then
        return ${EX_OK}
    fi

    ssh -T \
        -o LogLevel="${WAITFORSSH_LOGLEVEL:-QUIET}" \
        -o StrictHostKeyChecking="${WAITFORSSH_STRICTHOSTKEYCHECKING:-no}" \
        -o UserKnownHostsFile="${WAITFORSSH_USERKNOWNHOSTSFILE:-/dev/null}" -- "${target}" "${command}"

    return ${EX_OK}
}

check_number()
{
    printf "%s" "$1" | grep -qEe "^[0-9]+$"
}

random_number()
{
    local begin="${1:-1}" end="${2:-10}"

    jot -r 1 "${begin}" "${end}"
}

err()
{
    printf "%s\n" "$1" >&2
}

version()
{
    echo "${VERSION}"
}

usage()
{
    echo "usage: waitforssh [-C <command>] [-T <command>] [-d <delay>] [-r <max-retries>] <target>"
    echo "       waitforssh -v"
}

main "$@"
