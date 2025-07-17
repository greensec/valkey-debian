#!/bin/bash

echo "::group::Debug Information"
echo "Script started with parameters: $@"
echo "GITHUB_REPOSITORY_OWNER: ${GITHUB_REPOSITORY_OWNER:-Not set}"
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY:-Not set}"
echo "GITHUB_OUTPUT: ${GITHUB_OUTPUT:-Not set}"

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

if [ -z "$1" ]; then
    echo "::error::Required parameter missing!"
    echo "Usage: $0 <github_repo> [distribution] [package_name]"
    echo "Example: $0 NLnetLabs/nsd bookworm nsd"
    exit 1
fi

echo "Checking for updates for repository: $1"
echo "Distribution: ${2:-Not specified, using default}"
echo "Package name: ${3:-Not specified, using default}"

set -e

echo "Fetching latest release from GitHub for $1..."
remote_current_release=$(curl -sL https://api.github.com/repos/$1/releases/latest | jq -r ".tag_name")
echo "Raw tag name from GitHub: ${remote_current_release}"
remote_current_release="${remote_current_release/Release\//}"
echo "remote_current_tag=${remote_current_release}" >> $GITHUB_OUTPUT

echo "remote_current_release=${remote_current_release}" >> $GITHUB_OUTPUT
if [ -z "$remote_current_release" ]; then
    echo "::error::Failed to get remote current release!"
    exit 1
fi

repo_url="https://${GITHUB_REPOSITORY_OWNER}.github.io/${GITHUB_REPOSITORY##*/}/repo"
echo "Checking current package version from: $repo_url/dists/${2}/main/binary-amd64/Packages"
own_current_release=$(curl -sL "$repo_url/dists/${2}/main/binary-amd64/Packages" | \
    grep -A 3 "^Package: ${3}$" | \
    grep '^Version:' | \
    cut -d ' ' -f 2 | \
    head -n 1 | \
    sed -e 's/-.*//' -e 's/\+.*//' -e 's/\~.*//')
echo "Current package version in repository: ${own_current_release:-Not found}"

echo "own_current_release=${own_current_release}" >> $GITHUB_OUTPUT
if [ -z "$own_current_release" ]; then
    echo "::warning::Could not determine current package version in repository"
    echo "This might be the first release or the package is not yet published"
fi

set +e
echo "Comparing versions:"
echo "- Remote version: ${remote_current_release}"
echo "- Local version:  ${own_current_release:-None (first release)}"

if [ -z "$own_current_release" ]; then
    echo "No local version found, treating as new release"
    op='newer'
else
    vercomp "${remote_current_release}" "${own_current_release}"
    case $? in
        0) op='equal' ;;
        1) op='newer' ;;
        2) op='older' ;;
    esac
fi

echo "Version comparison result: ${op}"
echo "vercomp=${op}" >> $GITHUB_OUTPUT
echo "::endgroup::"

echo "::group::Version Comparison Summary"
echo "Remote version: ${remote_current_release}"
echo "Local version:  ${own_current_release:-Not found}"
echo "Result:         ${op}"
echo "::endgroup::"