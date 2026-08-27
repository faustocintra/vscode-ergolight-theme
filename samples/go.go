package main

import (
	"fmt"
	"regexp"
)

const version = "1.0.0"

type Status string

const (
	Draft Status = "draft"
	Paid  Status = "paid"
)

type Renderer[T any] interface {
	Render(T) string
}

type Order struct {
	ID     int
	Status Status
}

func (o Order) Render(value Order) string {
	match := regexp.MustCompile(`^[a-z]+$`).MatchString(string(value.Status))
	return fmt.Sprintf("%s:%d:%t", version, o.ID, match)
}

func main() {
	fmt.Println(Order{ID: 1, Status: Paid}.Render(Order{ID: 2, Status: Draft}))
}

