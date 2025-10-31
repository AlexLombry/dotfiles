package main

import (
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"os"
)

func main() {
	// Define command-line flags for input CSV file and output JSON file.
	csvPath := flag.String("csv", "", "Path to the input CSV file")
	jsonPath := flag.String("json", "", "Path to the output JSON file")
	flag.Parse()

	// Check that both CSV and JSON file paths are provided.
	if *csvPath == "" || *jsonPath == "" {
		fmt.Println("You must provide both -csv and -json file paths.")
		fmt.Println("Usage: go run main.go -csv=\"./data.csv\" -json=\"./data.json\"")
		os.Exit(1)
	}

	// Open the CSV file.
	csvFile, err := os.Open(*csvPath)
	if err != nil {
		fmt.Printf("Error opening CSV file: %v\n", err)
		os.Exit(1)
	}
	defer csvFile.Close()

	// Initialize CSV reader.
	reader := csv.NewReader(csvFile)
	reader.FieldsPerRecord = -1 // allow variable number of fields per row

	// Read all CSV data.
	csvData, err := reader.ReadAll()
	if err != nil {
		fmt.Printf("Error reading CSV data: %v\n", err)
		os.Exit(1)
	}

	// Check if CSV contains any data.
	if len(csvData) < 1 {
		fmt.Println("CSV is empty")
		os.Exit(1)
	}

	// The first row is used as the header.
	headers := csvData[0]
	var records []map[string]string

	// Process each row starting from the second line.
	for i, row := range csvData {
		if i == 0 {
			continue // Skip header row.
		}
		record := make(map[string]string)
		for j, value := range row {
			if j < len(headers) {
				record[headers[j]] = value
			}
		}
		records = append(records, record)
	}

	// Marshal the slice of records into JSON.
	jsonData, err := json.MarshalIndent(records, "", "  ")
	if err != nil {
		fmt.Printf("Error marshalling JSON: %v\n", err)
		os.Exit(1)
	}

	// Print JSON to stdout.
	fmt.Println(string(jsonData))

	// Create the output JSON file.
	jsonFile, err := os.Create(*jsonPath)
	if err != nil {
		fmt.Printf("Error creating JSON file: %v\n", err)
		os.Exit(1)
	}
	defer jsonFile.Close()

	// Write JSON data to the file.
	_, err = jsonFile.Write(jsonData)
	if err != nil {
		fmt.Printf("Error writing JSON file: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("CSV has been successfully converted to JSON!")
}
