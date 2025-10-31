package main

import (
	"bytes"
	"fmt"
	"image"
	"image/png"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"reflect"
	"regexp"
	"strconv"
	"strings"

	"github.com/gen2brain/go-fitz"
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

	// Create a new Tesseract client
	client := gosseract.NewClient()
	defer client.Close()

	folderPath := "./files"

	// make sure I get a number at the end 
	numberPattern := regexp.MustCompile(`[0-9]+[ ,]*[0-9]*\.[0-9]+`)

	err := filepath.Walk(folderPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		ext := filepath.Ext(path)
		switch ext {
		case ".jpg":
			err = processImageFile(path, client, numberPattern, &amounts)
			if err != nil {
				return err
			}
		case ".pdf":
			err = processPDFFile(path, client, numberPattern, &amounts)
			if err != nil {
				return err
			}
		default:
			// Skip unsupported file types
			return nil
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

// processImageFile processes .jpg files using Tesseract
func processImageFile(path string, client *gosseract.Client, numberPattern *regexp.Regexp, amounts *[]float64) error {
	debugPrint("Processing image file: ", path)
	client.SetImage(path)

	text, err := client.Text()
	if err != nil {
		return err
	}

	extractAmounts(text, numberPattern, amounts)
	return nil
}

// processPDFFile processes .pdf files by converting each page to an image
func processPDFFile(path string, client *gosseract.Client, numberPattern *regexp.Regexp, amounts *[]float64) error {
	debugPrint("Processing PDF file: ", path)
	doc, err := fitz.New(path)
	if err != nil {
		return err
	}
	defer doc.Close()

	for n := 0; n < doc.NumPage(); n++ {
		img, err := doc.Image(n)
		if err != nil {
			debugPrint("Error processing page ", n, ": ", err)
			continue
		}

		// Convert image to bytes in PNG format
		buf, err := encodeToPNG(img)
		if err != nil {
			debugPrint("Error encoding page ", n, ": ", err)
			continue
		}

		client.SetImageFromBytes(buf)
		text, err := client.Text()
		if err != nil {
			debugPrint("Error processing OCR on page ", n, ": ", err)
			continue
		}
		extractAmounts(text, numberPattern, amounts)
	}

	return nil
}

// extractAmounts searches through the provided text and extract numbers that match the pattern.
func extractAmounts(text string, pattern *regexp.Regexp, amounts *[]float64) {
	lines := strings.Split(text, "\n")
	for _, line := range lines {
		if strings.Contains(line, "Mont") {
			matches := pattern.FindAllString(line, -1)
			for _, match := range matches {
				// Remove spaces that might be in the numeric value
				cleanValue := strings.ReplaceAll(match, " ", "")
				debugPrint(cleanValue)
				value, err := strconv.ParseFloat(cleanValue, 64)
				if err != nil {
					fmt.Println("Error parsing float:", err)
					continue
				}
				*amounts = append(*amounts, value)
			}
		}
	}
}

// encodeToPNG encodes an image.Image into PNG format and returns a byte slice.
func encodeToPNG(img image.Image) ([]byte, error) {
	var buf bytes.Buffer
	err := png.Encode(&buf, img)
	if err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func debugPrint(args ...interface{}) {
	if verbose {
		for _, arg := range args {
			fmt.Printf("Type: %v, Value: %v\n", reflect.TypeOf(arg), arg)
		}
	}
}
