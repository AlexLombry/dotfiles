package main

import (
	"fmt"
	"io/fs"
	"log"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/otiai10/gosseract/v2"
)

func main() {
	client := gosseract.NewClient()
	defer client.Close()

	folderPath := "./files"

	numberPattern := regexp.MustCompile(`[0-9]+[ ,]*[0-9]*\.[0-9]+`)

	err := filepath.Walk(folderPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

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
					fmt.Println(match)
				}
			}
		}
		return nil
	})
	if err != nil {
		log.Fatalf("Error walking the path %q: %v\n", folderPath, err)
	}
}
