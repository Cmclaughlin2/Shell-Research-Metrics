#!/bin/bash

#Ensure that we have the proper Linux tools downloaded
required_linux_tools=("unzip" "xlsx2csv" "grep" "wc" "bc")

#Loop through the required_linux_tools array and check if each tool is installed
for required_linux_tool in "${required_linux_tools[@]}"
do
    if command -v "$required_linux_tool" &> /dev/null; then
        echo "$required_linux_tool is installed and ready for usage."
    else
        echo "$required_linux_tool is not installed. Please install it before running this script."
        exit 1
    fi
done

# Set n_args to the number of arguments passed in ($#)
n_args=$#

# Check to see if n_args is exactly 1. If not, echo an error and get out.
if [ $n_args -eq 1 ]; then
    # Unzip the zip file represented by the first argument passed in ($1)
    unzip "$1"
else
    echo "Error... script requires name of zip file"
    exit 1
fi

# Check if the unzip process worked
if [ $? -ne 0 ]; then
    echo -e "\n\nError unzipping the file"
    exit 1
fi

# Write out the file name column headers
echo
echo -e "researcher\t\tsubmitted\t\trejected\t\tr_and_r\t\t\taccepted"
echo

# Create the original totals for each column
total_submitted=0
total_rejected=0
total_r_and_r=0
total_accepted=0

# Create arrays to store the data for each category
declare -a submitted_data=()
declare -a rejected_data=()
declare -a r_and_r_data=()
declare -a accepted_data=()

#Calculate the sample median for the dataset
calculate_median() {
    #Sort the sample data numerically
    data=($(printf '%s\n' "${@}" | sort -n))
    count=${#data[@]}
    middle=$((count / 2))
    if ((count % 2 ==1)); then
        echo "${data[$middle]}"
    else
        median=$(echo "scale=3; (${data[middle -1]} + ${data[middle]}) / 2" | bc)
        echo "$median"
    fi
}

#Calculate the standard deviation for the dataset
calculate_standard_deviation() {
    mean=$1
    shift
    data=("$@")
    sum=0
    for item in "${data[@]}"; do
        difference=$(echo "$item - $mean" | bc)
        square=$(echo "$difference * $difference" | bc)
        sum=$(echo "$sum + $square" | bc)
    done
    variance=$(echo "scale=3; $sum / ${#data[@]}" | bc)
    standard_deviation=$(echo "scale=3; sqrt($variance)" | bc)
    echo "$standard_deviation"
}

# Loop over each of the main files sub-folders
for folder in research_productivity/*
do
    # Get the folder name from the specified file path
    folder_name=$(basename "$folder")
    # Find the Excel file
    xlsx_filename="$folder/$folder_name.xlsx"
    # Convert Excel file to CSV file
    csv_filename="$folder_name.csv"
    xlsx2csv "$xlsx_filename" > "$csv_filename"
    # Count the results of the program runtime using grep and wc
    # Find the total number of submitted papers
    n_of_submissions=$(grep submitted "$csv_filename" | wc -l)
    # Find the total number of rejected papers
    n_of_rejections=$(grep rejected "$csv_filename" | wc -l)
    # Find the total count of "r&r"
    r_and_r_count=$(grep "r&r" "$csv_filename" | wc -l)
    # Find the total count of accepted papers
    accepted_count=$(grep accepted "$csv_filename" | wc -l)
    
    #Set proper formatting depending on folder name character length
    len=${#folder_name}
    if [ $len -gt 15 ]
    then
        echo -e "$folder_name\t$n_of_submissions\t\t$n_of_rejections\t\t$r_and_r_count\t\t$accepted_count"
    else
        echo -e "$folder_name\t\t$n_of_submissions\t\t$n_of_rejections\t\t$r_and_r_count\t\t$accepted_count"
    fi

    # Add to the totals for each specified category
    total_submitted=$((total_submitted + n_of_submissions))
    total_rejected=$((total_rejected + n_of_rejections))
    total_r_and_r=$((total_r_and_r + r_and_r_count))
    total_accepted=$((total_accepted + accepted_count))

    # Add data to arrays
    submitted_data+=("$n_of_submissions")
    rejected_data+=("$n_of_rejections")
    r_and_r_data+=("$r_and_r_count")
    accepted_data+=("$accepted_count")
done

# Print the totals
  echo
  echo -e "totals:\t\t\t$total_submitted\t\t\t$total_rejected\t\t\t$total_r_and_r\t\t\t$total_accepted"
  echo

#Compute the averages for each column
  n_of_researchers=$(ls *.csv | wc -l)
  mean_submitted=$(echo "scale=3; $total_submitted / $n_of_researchers" | bc)
  mean_rejected=$(echo "scale=3; $total_rejected / $n_of_researchers" | bc)
  mean_r_and_r=$(echo "scale=3; $total_r_and_r / $n_of_researchers" | bc)
  mean_accepted=$(echo "scale=3; $total_accepted / $n_of_researchers" | bc)
  echo

#Calculate the median for each category
  median_submitted_papers=$(calculate_median "${submitted_data[@]}")
  median_rejected_papers=$(calculate_median "${rejected_data[@]}")
  median_r_and_r_papers=$(calculate_median "${r_and_r_data[@]}")
  median_accepted_papers=$(calculate_median "${accepted_data[@]}")
  echo

#Calculate the standard deviation for each category
  stdev_submitted_papers=$(calculate_standard_deviation "$mean_submitted" "${submitted_data[@]}")
  stdev_rejected_papers=$(calculate_standard_deviation "$mean_rejected" "${rejected_data[@]}")
  stdev_r_and_r_papers=$(calculate_standard_deviation "$mean_r_and_r" "${r_and_r_data[@]}")
  stdev_accepted_papers=$(calculate_standard_deviation "$mean_accepted" "${accepted_data[@]}")
  echo

#Ensure proper formatting for the mean totals
  echo -e "means:\t\t\t$mean_submitted\t\t$mean_rejected\t\t$mean_r_and_r\t\t$mean_accepted"
  echo

#Ensure proper formatting for the median totals
  echo -e "medians:\t\t$median_submitted_papers\t\t$median_rejected_papers\t\t$median_r_and_r_papers\t\t$median_accepted_papers"
  echo

#Ensure proper formatting for the standard deviation totals
  echo -e "Standard Deviations:\t$stdev_submitted_papers\t\t$stdev_rejected_papers\t\t$stdev_r_and_r_papers\t\t$stdev_accepted_papers"
  echo

# Remove the unzipped research_productivity data
rm -rf ./research_productivity

#Gracefully exit the script after all logical functions have completed
exit 0