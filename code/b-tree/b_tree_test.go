package pkg

import (
	"testing"
)

func TestInsert(t *testing.T) {
	tree := NewBTree()
	tree.Insert(1)
}
