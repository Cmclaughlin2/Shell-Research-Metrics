# Shell-Research-Metrics

## Prerequisites

Ensure you have the following Linux tools installed before running the script:

- `unzip`
- `xlsx2csv`
- `grep`
- `wc`
- `bc`

You can install these tools using your package manager, for example on Debian-based systems:

```bash
sudo apt-get install unzip xlsx2csv grep wc bc
```

## Usage

To run the script, use the following command:

```bash
./Shell_Productivity_Analysis.sh <path_to_zip_file>
```

## Project Description

This script is designed to analyze research productivity data by processing a set of Excel files within a ZIP archive. It calculates and outputs statistics such as total, mean, median, and standard deviation for submitted, rejected, "r&r" (revise and resubmit), and accepted research papers.

### Step-by-Step Process

1. **Tool Check**: The script first checks if the required Linux tools are installed.
2. **Argument Check**: It ensures exactly one argument (the ZIP file) is provided.
3. **Unzipping**: The script unzips the provided ZIP file.
4. **Initialization**: It initializes counters and arrays for storing data.
5. **Processing**: The script processes each Excel file, converts it to CSV, and extracts data using `grep` and `wc`.
6. **Calculations**: It calculates total, mean, median, and standard deviation for each category of papers.
7. **Output**: The results are printed to the console in a formatted manner.
8. **Cleanup**: The unzipped data is removed.

### Notes

- This project was developed as part of a school assignment to demonstrate the ability to process and analyze research productivity data using basic Linux tools and shell scripting.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
