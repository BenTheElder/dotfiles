// a solver for https://www.nytimes.com/games/digits
package main

import (
	"log"
	"os"
	"strconv"

	"github.com/oleiade/lane/v2"
)

var operations = map[string]func(x, y int) int{
	"+": func(x, y int) int {
		return x + y
	},
	"-": func(x, y int) int {
		return x - y
	},
	"x": func(x, y int) int {
		return x * y
	},
	"÷": func(x, y int) int {
		return x / y
	},
}

type Node struct {
	Digits []int
	Path   []string
}

func bfs(digits [6]int, goal int) []string {
	log.Println("BFS search for Digits:", digits, "Goal:", goal)
	queue := lane.NewDeque(Node{
		Digits: digits[:],
		Path:   []string{},
	})
	for queue.Size() > 0 {
		v, _ := queue.Pop()
		// low effort select all pairs
		for i := 0; i < len(v.Digits); i++ {
			for j := 0; j < len(v.Digits); j++ {
				if i == j {
					continue
				}
				x, y := v.Digits[i], v.Digits[j]
				for operation, do := range operations {
					// NYT puzzle doesn't allow some operations
					// no negative values
					if operation == "-" && y > x {
						continue
					}
					// no divide by zero and only integer division
					if operation == "÷" && (y == 0 || x%y != 0) {
						continue
					}
					val := do(x, y)
					if val == goal {
						return append(v.Path, strconv.Itoa(x), operation, strconv.Itoa(y))
					}
					newDigits := make([]int, 0, len(v.Digits)-1)
					newDigits = append(newDigits, val)
					for k := 0; k < len(v.Digits); k++ {
						if k != i && k != j {
							newDigits = append(newDigits, v.Digits[k])
						}
					}
					queue.Prepend(
						Node{
							Digits: newDigits,
							Path:   append(append([]string{}, v.Path...), strconv.Itoa(x), operation, strconv.Itoa(y)),
						})
				}
			}
		}
	}
	return nil
}

func main() {
	// parse 6 digits + goal from arguments
	args := os.Args
	if len(args) != 8 {
		log.Println(args)
		log.Fatal("exactly 6 digits and 1 goal required arguments")
	}
	digits := [6]int{}
	for i := range digits {
		digit, err := strconv.Atoi(args[i+1])
		if err != nil {
			log.Fatalf("failed to parse digit: %v", err)
		}
		digits[i] = digit
	}
	goal, err := strconv.Atoi(args[7])
	if err != nil {
		log.Fatalf("failed to parse goal: %v", err)
	}
	// find solution
	solution := bfs(digits, goal)
	log.Println("Solution:", solution)
}
