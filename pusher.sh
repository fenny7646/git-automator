#!/bin/bash

# File to store the counter
COUNTER_FILE=".commit_counter"

# Define an array of remote repositories and their values
declare -A remote_values=( [ [""]=1 )

# Define an array of remote repositories and their values
declare -A file_values=(  ["Main"]=0 ["Templates"]=1 ["Static"]=2 ["Media"]=3)
file_repos=("" "Main" "Templates" "Static")

# Check if the counter file exists; if not, initialize it with 0
if [ ! -f "$COUNTER_FILE" ]; then
    echo 0 > "$COUNTER_FILE"
fi

# Read the current counter value
counter=$(cat "$COUNTER_FILE")

# Display the current counter value
echo "Current Commit Counter: C${counter}"

# Ask if the user wants to set a new counter for future commits
read -p "Change counter for future commits? [Enter to skip][Y/N]? " change_counter

if [[ "$change_counter" == "Y" || "$change_counter" == "y" ]]; then
    # User wants to set a new counter for future commits
    read -p "Enter new commit number: " new_counter

    # Save the new counter value back to the file for future use
    echo "$new_counter" > "$COUNTER_FILE"
    echo "Commit Counter updated to: C${new_counter}"
    counter="$new_counter"

else
    # Read the current counter value
    counter=$(cat "$COUNTER_FILE")
fi

# Get the current date and time
current_date=$(date +"%B %d,%-I:%M %p")

# Display available Initial Text and prompt user to select one
echo "Available  FIle Text for Commit:"

for key in "${!file_values[@]}"; do
    value=${file_values[$key]}
    echo "$value : $key"
done

read -p "Select initial file text by index (press enter to skip): " file_index

if [[ -z "$file_index" ]]; then
    selected_file=""  # Set file to an empty value
else
    for key in "${!file_values[@]}"; do
        if [[ "${file_values[$key]}" == "$file" ]]; then
            selected_file="$key>"
            break
        fi
    done 
fi

# Prompt for the commit message with the counter and date
read -p "Enter the commit message [C${counter} | ${current_date}]: " commit_message

# Format the commit message with autoincremented number and user input
formatted_message="C${counter} | ${current_date} | ${selected_file}${commit_message}"

echo "Commit message: $formatted_message"

# Display available remote repositories and prompt user to select one
echo "Available remote repositories:"
for key in "${!remote_values[@]}"; do
    value=${remote_values[$key]}
    echo "$key : $value"
done

read -p "Select a remote repository by index (default:'origin'): " repo_index

if [[ -z "$repo_index" ]]; then
    selected_repo="origin"  # Set file to an empty value
else
    for key in "${!remote_values[@]}"; do
        if [[ "${remote_values[$key]}" == "$key" ]]; then
            selected_repo="$key"
            break
        fi
    done
fi

read -p "Enter repo branch:" repo_branch

# Run Git commands (example)
echo "Staging changes..."
if ! git add .; then
    echo "Error: Failed to stage changes."
    exit 1
fi

echo "Committing changes..."
if ! git commit -m "$formatted_message"; then
    echo "Error: Failed to commit changes. Make sure there are changes to commit."
    exit 1
fi

echo "Pushing changes to $selected_repo..."
if ! git push -u "$selected_repo" "$repo_branch"; then
    echo "Error: Failed to push changes to $selected_repo."
    exit 1
fi

echo "Changes pushed successfully with commit message: $formatted_message"

# Increment the counter
new_counter=$((counter + 1))
# Save the updated counter back to the file for future use
echo "$new_counter" > "$COUNTER_FILE"
