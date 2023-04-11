// a solver for https://www.nytimes.com/games/digits
package main

import (
	"fmt"
	"reflect"
	"testing"
)

func TestSearch(t *testing.T) {
	testCases := []struct {
		Digits          [6]int
		Goal            int
		Expected        []string
		ExpectedLongest []string
	}{
		{
			Digits:          [6]int{1, 3, 4, 5, 10, 25},
			Goal:            66,
			Expected:        []string{"1", "+", "25", "26", "-", "4", "22", "x", "3"},
			ExpectedLongest: []string{"25", "x", "10", "5", "x", "3", "250", "-", "1", "15", "+", "249", "264", "÷", "4"},
		},
		{
			Digits:          [6]int{5, 7, 11, 19, 20, 23},
			Goal:            476,
			Expected:        []string{"5", "+", "11", "20", "x", "23", "460", "+", "16"},
			ExpectedLongest: []string{"23", "x", "20", "19", "-", "11", "7", "-", "5", "8", "x", "2", "16", "+", "460"},
		},
	}
	for i := range testCases {
		tc := testCases[i]
		t.Run(fmt.Sprintf("%v", tc), func(t *testing.T) {
			t.Parallel()
			result := search(tc.Digits, tc.Goal, false)
			if !reflect.DeepEqual(result, tc.Expected) {
				t.Errorf("Expected: %v", tc.Expected)
				t.Fatalf("Received: %v", result)
			}
			resultLongest := search(tc.Digits, tc.Goal, true)
			if !reflect.DeepEqual(resultLongest, tc.ExpectedLongest) {
				t.Errorf("Expected Longest: %v", tc.ExpectedLongest)
				t.Fatalf("Received Longest: %v", resultLongest)
			}
		})
	}
}
