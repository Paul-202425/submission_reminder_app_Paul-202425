#!/bin/bash
read -p "INPUT YOUR NAME: " UserName
dirName="submission_reminder_${UserName}"

mkdir -p "$dirName"
cd "$dirName" || { echo "Failed changing directory to $dirName"; exit 1; }

mkdir -p app modules assets config

touch app/reminder.sh
touch modules/functions.sh
touch assets/submissions.txt
touch config/config.env
touch startup.sh

# Create reminder.sh script
echo '#!/bin/bash

# Determine the directory of the current script
DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source environment variables and helper functions
source "$DIR_SCRIPT/../config/config.env"
source "$DIR_SCRIPT/../modules/functions.sh"

# Path to the submissions file
submissions_file="$DIR_SCRIPT/../assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions "$submissions_file"' > ./app/reminder.sh

# Create functions.sh script
echo '#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is "not submitted"
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}' > ./modules/functions.sh

# Create config.env file
echo '# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2' > ./config/config.env

# Create submissions.txt file
echo 'Betty, Shell Navigation, submitted
Sami, Shell Navigation, not submitted
Eyerus, Shell Navigation, not submitted
Dagi, Shell Navigation, submitted
Hana, Shell Navigation, submitted' > ./assets/submissions.txt
 
echo bash app/reminder.sh > ./startup.sh

# Make the scripts executable
chmod +x ./app/reminder.sh
chmod +x ./modules/functions.sh
chmod +x ./startup.sh

