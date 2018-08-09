#!/bin/bash

GIT_DIR="$(git rev-parse --show-toplevel)/.git"

if [[ "$?" != "0" ]]; then
    echo 'Please run this script from inside your repository!' >&2
    exit 1
fi

GIT_CLANG_FORMAT_SCRIPT="git-clang-format-6.0"
mkdir -p $GIT_DIR/hooks

# 'git-clang-format' is installed with the 'clang-format' package.
#GIT_CLANG_FORMAT_URL="https://raw.githubusercontent.com/llvm-mirror/clang/master/tools/clang-format/git-clang-format"

#wget -O $GIT_CLANG_FORMAT_SCRIPT $GIT_CLANG_FORMAT_URL
#chmod +x $GIT_CLANG_FORMAT_SCRIPT

# Add a Git alias to more easily invoke the script manually
echo "Adding git alias..."
git config alias.clang-format "!$GIT_CLANG_FORMAT_SCRIPT"

# Write the format code to the pre-commit hook.
echo "Writing pre-commit hook..."
if [ ! -x "$GIT_DIR/hooks/pre-commit" ]; then
    if [ ! -e "$GIT_DIR/hooks/pre-commit" ]; then
        echo '#!/bin/bash' > $GIT_DIR/hooks/pre-commit
    fi
    chmod +x $GIT_DIR/hooks/pre-commit
fi
cat ${BASH_SOURCE} | sed -n '/Automatic Clang Formatting[^/]*$/,$ p' \
    | sed "s|\\\$GIT_CLANG_FORMAT_SCRIPT|$GIT_CLANG_FORMAT_SCRIPT|" \
    >> $GIT_DIR/hooks/pre-commit

echo "Done!"
exit 0

# Below this line are the contents to append to the pre-commit hook
## Automatic Clang Formatting ##

# Run clang-format on only the changed lines of code
function format_diff() {
    local files=$(git status --porcelain | sed -n 's/^[MARC]. \(.* -> \)\?\(.*\)$/\2/ p')

    # Try to format the diff
    echo "Running clang-format on the changes..."
    $GIT_CLANG_FORMAT_SCRIPT
    if [[ "$?" != "0" ]]; then
        # Abort the commit
        # The most likely reason for this is that there are unstaged changes
        # that would have been formatted
        exit 1
    fi

    # Add the changes made by clang-format back into the index
    git add $files
}

format_diff
