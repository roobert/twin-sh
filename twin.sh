#!/usr/bin/env bash

set -euo pipefail

function header() {
	echo "========================================================="
	echo
	echo "        This Week in NeoVIM Contribution Wizard!         "
	echo
	echo " https://github.com/phaazon/this-week-in-neovim-contents "
	echo
	echo "========================================================="
}

function check_dependencies() {
	if ! command -v gh &>/dev/null; then
		echo "please install the github cli: https://cli.github.com/"
		exit 1
	fi
}

function fork_twin_repo() {
	echo "Forking this-week-in-neovim-contents repository..."

	if [ -d this-week-in-neovim-contents ]; then
		echo "this-week-in-neovim-contents directory already exists!"
		read -r -p "Do you want to delete it? [y/N] "
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			rm -rf this-week-in-neovim-contents/
		else
			echo "Aborting!"
			exit 1
		fi
	fi

	gh repo fork https://github.com/phaazon/this-week-in-neovim-contents
}

# FIXME: improve this..
function latest_branch() {
	local LATEST_BRANCH

	LATEST_BRANCH=$(
		git branch -l -r --no-color |
			tr -d ' ' |
			grep --color=never -E 'upstream/' |
			grep -v '/master'
	)

	if [[ $(echo "${LATEST_BRANCH}" | wc -l) -eq 1 ]]; then
		echo "${LATEST_BRANCH}" | sed 's/upstream\///'
	else
		echo "error: detected more than one branch!"
		exit 1
	fi
}

function fetch_branch_checkout() {
	local LATEST_BRANCH
	LATEST_BRANCH="${1}"

	echo
	echo "Attempting to switch to latest branch: ${LATEST_BRANCH}"
	git branch -f "${LATEST_BRANCH}" "upstream/${LATEST_BRANCH}"
	git checkout "${LATEST_BRANCH}"
}

function process_template() {
	local LATEST_BRANCH
	LATEST_BRANCH="${1}"

	POST_TYPES=(
		0-core-updates
		1-need-help
		2-guides
		3-new-plugins
		4-new-projects
	)

	while true; do
		echo
		echo "What type of post is this?"

		for i in "${!POST_TYPES[@]}"; do
			ABBREVIATED_POST_TYPE=$(echo "${POST_TYPES[i]}" | cut -d- -f2-)
			echo "[${i}] ${ABBREVIATED_POST_TYPE}"
		done

		read -r -p "Enter a number: " POST_TYPE_INDEX
		if [[ "$POST_TYPE_INDEX" =~ ^[0-9]+$ ]]; then
			if [[ "$POST_TYPE_INDEX" -ge 0 && "$POST_TYPE_INDEX" -le 4 ]]; then
				break
			fi
		fi
		echo "Invalid input"
	done

	POST_TYPE="${POST_TYPES[$POST_TYPE_INDEX]}"

	YEAR=$(echo "${LATEST_BRANCH}" | cut -d '-' -f 1)
	MONTH=$(echo "${LATEST_BRANCH}" | cut -d '-' -f 2)
	DAY=$(echo "${LATEST_BRANCH}" | cut -d '-' -f 3)

	POST_TEMPLATE="template/${POST_TYPE}/1-example.md"
	OUTPUT_DIR="contents/${YEAR}/${MONTH}/${DAY}/${POST_TYPE}"
	POST_FILE=""
	NAME=""

	case "${POST_TYPE}" in
	0-core-updates)
		while true; do
			read -r -p "Enter a hyphenated name for the update (e.g: my-core-update): " UPDATE_NAME
			if [[ -n "${UPDATE_NAME}" ]]; then
				break
			fi

			echo "Invalid input"
		done

		POST_FILE="${OUTPUT_DIR}/${UPDATE_NAME}.md"
		cp -v "${POST_TEMPLATE}" "${POST_FILE}"

		NAME="${UPDATE_NAME}"
		;;

	1-need-help | 3-new-plugins | 4-new-projects)
		while true; do
			read -r -p "Enter the plugin name (e.g: my-new-plugin.nvim): " PLUGIN_NAME
			if [[ -n "${PLUGIN_NAME}" ]]; then
				break
			fi

			echo "Invalid input"
		done

		POST_FILE="${OUTPUT_DIR}/${PLUGIN_NAME}.md"

		sed "s/your-plugin.nvim/${PLUGIN_NAME}/g" "${POST_TEMPLATE}" \
			>"${POST_FILE}"
		sed "s/your-plugin/${PLUGIN_NAME}/g" "${POST_TEMPLATE}" \
			>"${POST_FILE}"

		NAME="${PLUGIN_NAME}"
		;;

	2-guides)
		while true; do
			read -r -p "Enter the content name, hyphenated (e.g: my-new-post): " CONTENT_NAME
			if [[ -n "${CONTENT_NAME}" ]]; then
				break
			fi

			echo "Invalid input"
		done

		POST_FILE="${OUTPUT_DIR}/${CONTENT_NAME}.md"

		sed "s/your-content/${CONTENT_NAME}/g" "${POST_TEMPLATE}" \
			>"${POST_FILE}"

		NAME="${CONTENT_NAME}"
		;;

	*)
		echo "error: invalid post type"
		exit 1
		;;
	esac

	while true; do
		if [[ "${EDITOR:-}" != "" ]]; then
			"${EDITOR}" "${POST_FILE}"
		else
			while true; do
				read -r -p "Please enter a path to your editor: " EDITOR
				if [[ -x "${EDITOR}" ]]; then
					"${EDITOR}" "${POST_FILE}"
					break
				else
					echo "error: input is not executable: ${EDITOR}"
				fi
			done
		fi

		echo "Contents of file: ${POST_FILE}"
		cat "${POST_FILE}"

		read -r -p "Would you like commit your new post? [y/n] "
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			break
		elif [[ $REPLY =~ ^[Nn]$ ]]; then
			read -r -p "Would you like to re-edit your post? [y/n] "
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				continue
			elif [[ $REPLY =~ ^[Nn]$ ]]; then
				ABBREVIATED_POST_TYPE="$(echo "${POST_TYPE}" | cut -d- -f2- | sed 's/s$//')"
				GIT_USER="$(git remote get-url origin | cut -d: -f2 | cut -d'/' -f1)"
				echo
				echo "Please run the following to finish your post:"
				echo
				echo "git add ${POST_FILE}"
				echo "git commit -m \"[${ABBREVIATED_POST_TYPE}] Added ${NAME}\""
				echo "git push origin \"${LATEST_BRANCH}\""
				echo "gh pr create --fill"
				echo "gh pr create --fill --head \"${GIT_USER}:${LATEST_BRANCH}\""
				echo "gh pr --repo \"phaazon/this-week-in-neovim-contents\" create --fill --head \"${GIT_USER}:${LATEST_BRANCH}\" -B \"${LATEST_BRANCH}\""
				echo
				exit 1
			else
				echo "Invalid input"
			fi
		else
			echo "Invalid input"
		fi
	done

	ABBREVIATED_POST_TYPE="$(echo "${POST_TYPE}" | cut -d- -f2- | sed 's/s$//')"
	GIT_USER="$(git remote get-url origin | cut -d: -f2 | cut -d'/' -f1)"

	git add "${POST_FILE}"
	git commit -m "[${ABBREVIATED_POST_TYPE}] Added ${NAME}"
	git push origin "${LATEST_BRANCH}"
	gh pr --repo phaazon/this-week-in-neovim-contents create --fill --head "${GIT_USER}:${LATEST_BRANCH}" -B "${LATEST_BRANCH}"
}

function main() {
	header
	check_dependencies
	fork_twin_repo

	(
		cd this-week-in-neovim-contents

		local LATEST_BRANCH
		LATEST_BRANCH="$(latest_branch)"

		if [[ $? -ne 0 ]]; then
			echo "${LATEST_BRANCH}"
			exit 1
		fi

		fetch_branch_checkout "${LATEST_BRANCH}"

		process_template "${LATEST_BRANCH}"
	)

	echo
	echo "Thank you for contributing to this-week-in-neovim!"
	echo
}

main
