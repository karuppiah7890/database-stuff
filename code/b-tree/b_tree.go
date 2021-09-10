package pkg

import "encoding/json"

type BTreeKeys struct {
	key          int
	rightSubTree *BTree
	nextKey      *BTreeKeys
}

type BTree struct {
	leftMostKeyLeftSubTree *BTree
	keys                   *BTreeKeys
}

type BTreeJSON struct {
	Keys     []int       `json:"keys"`
	Children []BTreeJSON `json:"children,omitempty"`
}

func NewBTree() *BTree {
	return nil
}

func (tree *BTree) Insert(key int) {
	panic("Print is not implemented yet")
}

func (tree *BTree) Search(key int) {
	panic("Search is not implemented yet")
}

func (tree *BTree) Delete(key int) {
	panic("Delete is not implemented yet")
}

func BTreeToBTreeJson(tree *BTree) BTreeJSON {
	bTreeJSON := BTreeJSON{}
	var childPointers []*BTree
	if tree.leftMostKeyLeftSubTree != nil {
		childPointers = append(childPointers, tree.leftMostKeyLeftSubTree)
	}

	currentKey := tree.keys

	for currentKey != nil {
		bTreeJSON.Keys = append(bTreeJSON.Keys, currentKey.key)
		if currentKey.rightSubTree != nil {
			childPointers = append(childPointers, currentKey.rightSubTree)
		}
		currentKey = currentKey.nextKey
	}

	for _, childPointer := range childPointers {
		bTreeJSON.Children = append(bTreeJSON.Children, BTreeToBTreeJson(childPointer))
	}

	return bTreeJSON
}

func (tree *BTree) MarshalJSON() ([]byte, error) {
	return json.Marshal(BTreeToBTreeJson(tree))
}
