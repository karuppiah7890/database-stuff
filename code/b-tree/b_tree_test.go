package pkg

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestInsert(t *testing.T) {
	// TODO: Temporarily disabled. Remove skip later one Insert is being implemented
	t.Skip()
	tree := NewBTree()
	tree.Insert(1)
}

func TestMarshalJson(t *testing.T) {
	tree := &BTree{
		leftMostKeyLeftSubTree: &BTree{
			leftMostKeyLeftSubTree: &BTree{
				keys: &BTreeKeys{
					key: 1,
					nextKey: &BTreeKeys{
						key: 2,
					},
				},
			},
			keys: &BTreeKeys{
				key: 10,
				rightSubTree: &BTree{
					keys: &BTreeKeys{
						key: 11,
						nextKey: &BTreeKeys{
							key: 12,
						},
					},
				},
			},
		},
		keys: &BTreeKeys{
			key: 20,
			rightSubTree: &BTree{
				leftMostKeyLeftSubTree: &BTree{
					keys: &BTreeKeys{
						key: 21,
						nextKey: &BTreeKeys{
							key: 22,
						},
					},
				},
				keys: &BTreeKeys{
					key: 30,
					rightSubTree: &BTree{
						keys: &BTreeKeys{
							key: 31,
						},
					},
					nextKey: &BTreeKeys{
						key: 32,
						rightSubTree: &BTree{
							keys: &BTreeKeys{
								key: 33,
								nextKey: &BTreeKeys{
									key: 34,
								},
							},
						},
					},
				},
			},
		},
	}

	jsonBytes, err := tree.MarshalJSON()
	assert.NoError(t, err)
	assert.Equal(t, `{"keys":[20],"children":[{"keys":[10],"children":[{"keys":[1,2]},{"keys":[11,12]}]},{"keys":[30,32],"children":[{"keys":[21,22]},{"keys":[31]},{"keys":[33,34]}]}]}`, string(jsonBytes))
}
