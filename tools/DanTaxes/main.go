package main

import (
	"fmt"
	"io/fs"
	"log"
	"path/filepath"
	"regexp"

	"github.com/otiai10/gosseract/v2"
)

func main() {
	client := gosseract.NewClient()
	defer client.Close()

	folderPath := "./files"

	err := filepath.Walk(folderPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// Skip if it's a directory
		if info.IsDir() {
			return nil
		}

		// Assuming you want to process .jpg files only
		if filepath.Ext(path) == ".jpg" {
			err := processImage(client, path)
			if err != nil {
				log.Printf("Error processing %s: %v", path, err)
			}
		}
		return nil
	})

	if err != nil {
		log.Fatalf("Error walking the path %q: %v\n", folderPath, err)
	}
}

func processImage(client *gosseract.Client, imagePath string) error {
	client.SetImage(imagePath)

	text, err := client.Text()
	if err != nil {
		return err
	}

	fmt.Printf("Extracted Text from %s:\n%s\n", imagePath, text)

	pattern := regexp.MustCompile(`Mont\s+(\S+)`)
	matches := pattern.FindStringSubmatch(text)
	if len(matches) > 0 {
		fmt.Printf("Found with value in %s: %s\n", imagePath, matches[1])
	} else {
		fmt.Printf("No value found in text of %s.\n", imagePath)
	}

	return nil
}
