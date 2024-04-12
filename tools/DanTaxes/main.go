package main

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"reflect"
	"regexp"
	"strconv"
	"strings"

	"github.com/otiai10/gosseract/v2"
)

var verbose bool

func main() {
	verbose = false
	// Set verbose mode for debugging purposes
	if (len(os.Args) > 1) && (os.Args[1] == "-v" || os.Args[1] == "--v") {
		verbose = true
	}

	var amounts []float64

	client := gosseract.NewClient()
	defer client.Close()

	folderPath := "./files"

	// pattern to remove chars like 628R | Mont.Deduct ...
	numberPattern := regexp.MustCompile(`[0-9]+[ ,]*[0-9]*\.[0-9]+`)

	err := filepath.Walk(folderPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		// only accept jpg files because why not
		if filepath.Ext(path) != ".jpg" {
			return nil
		}

		client.SetImage(path)

		text, err := client.Text()
		if err != nil {
			return err
		}

		lines := strings.Split(text, "\n")

		for _, line := range lines {
			if strings.Contains(line, "Mont") {
				matches := numberPattern.FindAllString(line, -1)
				for _, match := range matches {
					// Some amount came with a space between thousands and hundreds
					cleanValue := strings.ReplaceAll(match, " ", "")

					debugPrint(cleanValue)

					value, err := strconv.ParseFloat(cleanValue, 64)
					if err != nil {
						// Handle the error
						fmt.Println("Error parsing float:", err)
						return nil
					}
					amounts = append(amounts, value)
				}
			}
		}
		return nil
	})
	if err != nil {
		log.Fatalf("Error walking the path %q: %v\n", folderPath, err)
	}

	debugPrint(amounts)
	fmt.Printf("System was able to found %d items\n", len(amounts))

	sum := 0.0
	for _, number := range amounts {
		sum += number
	}

	fmt.Println("Total amount to use for taxes: ", sum)
}

func debugPrint(args ...interface{}) {
	if verbose {
		for _, arg := range args {
			fmt.Printf("Type: %v, Value: %v\n", reflect.TypeOf(arg), arg)
		}
	}
}
