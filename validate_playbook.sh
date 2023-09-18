#!/bin/bash
# set -x 

# Usage: ./validate_playbook.sh path_to_playbook.yml
# install ansible lint if desired.
# $> pip install ansible-lint


# Check if playbook supplied...
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_playbook>"
    exit 1
fi

PLAYBOOK=$1


# Check if playbook exists..
if [ ! -f "$PLAYBOOK" ]; then
    echo "Error: $PLAYBOOK does not exist."
    exit 1
fi


# 1. Check syntax
echo "Check playbook syntax..."
ansible-playbook --syntax-check "$PLAYBOOK"
if [ $? -ne 0 ]; then
    echo "Syntax check failed!"
    exit 1
fi
echo "Syntax check passed"
echo "-----------------------------------------\n"


# 2. List targeted hosts
echo "Listing targeted hosts..."
ansible-playbook --list-hosts "$PLAYBOOK"
echo "-----------------------------------------\n"


# 3. List tasks in playbook
echo "Listing tasks in playbook..."
ansible-playbook --list-tasks "$PLAYBOOK"
echo "-----------------------------------------\n"


# 4. Perform a DRY RUN using check mode...
echo "Performing a dry run..."
ansible-playbook --check "$PLAYBOOK"
if [ $? -ne 0 ]; then
    echo "Dry run check failed!"
    exit 1
fi
echo "Dry run check passed"
echo "-----------------------------------------\n"


# 5. Lint the playbook if ansible-lint is installed
if command -v ansible-lint &> /dev/null; then
    echo "Linting the playbook..."
    ansible-lint "$PLAYBOOK"
    if [ $? -ne 0 ]; then
        echo "Linting failed!"
        exit 1
    fi
    echo "Linting passed"
    echo "-----------------------------------------\n"
else
    echo "ansible-lint is not installed. Skipping linting."
fi

echo "Playbook validated"
#__END__
