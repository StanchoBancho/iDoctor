//
//  TwoThreeTree.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#include "TwoThreeTree.h"
#include <vector>
#include "stdlib.h"

using namespace std;

TwoThreeTree::TwoThreeTree() {
    this->root = NULL;
}

void TwoThreeTree::insertData(string data) {
    //empty tree
    if (this->root == NULL) {
        this->root = new Node(data, NULL);
        this->root->numberOfItems = 1;
    //one node tree
    } else if (this->root->numberOfChildren == 0) {
        //not full node
        if (this->root->numberOfItems == 1) {
            if (data.compare(this->root->minKey) < 0) {
                string temp;
                temp.assign(this->root->minKey);
                this->root->minKey.assign(data);
                this->root->maxKey.assign(temp);
            } else {
                this->root->maxKey = data;
            }
            this->root->numberOfItems = 2;
        //full node, should split
        } else if (this->root->numberOfItems == 2) {
            string newMinKey, newMidKey, newMaxKey;
            if (data.compare(this->root->minKey) < 0) {
                newMinKey.assign(data);
                newMidKey.assign(this->root->minKey);
                newMaxKey.assign(this->root->maxKey);
            } else if (this->root->minKey.compare(data) <= 0 && data.compare(this->root->maxKey) < 0) {
                newMinKey.assign(this->root->minKey);
                newMidKey.assign(data);
                newMaxKey.assign(this->root->maxKey);
            } else {
                newMinKey.assign(this->root->minKey);
                newMidKey.assign(this->root->maxKey);
                newMaxKey.assign(data);
            }
            
            this->root = new Node(newMidKey, NULL);
            
            Node *leftChild = new Node(newMinKey, this->root);
            leftChild->numberOfItems = 1;
            Node *rightChild = new Node(newMaxKey, this->root);
            rightChild->numberOfItems = 1;
            
            this->root->children.insert(this->root->children.begin(), leftChild);
            this->root->children.insert(this->root->children.begin()+1, rightChild);
            this->root->numberOfChildren = 2;
        }
    } else {
        Node *parent = findParent(this->root, data);
        insertDataIntoParentTree(parent, data);
    }
}

Node *TwoThreeTree::findParent(Node *node, string data) {
    Node *leftChild = node->children[0];
    Node *middleChild = node->children[1];
    Node *rightChild = node->children[2];
    
    //node children are leaves
    if (leftChild->numberOfChildren == 0) {
        return node;
    //should go to left child
    } else if (data.compare(node->minKey) < 0) {
        return findParent(leftChild, data);
    //should go to middle or right child
    } else {
        if (node->numberOfChildren == 3) {
            if (data.compare(node->maxKey) < 0) {
                return findParent(middleChild, data);
            } else {
                return findParent(rightChild, data);
            }
        } else {
            return findParent(middleChild, data);
        }
    }
    return NULL;
}

void TwoThreeTree::insertDataIntoParentTree(Node *parent, string data) {
    Node *leaf = NULL;
    //find leaf node to insert data

    if (data.compare(parent->minKey) < 0) {
        leaf = parent->children[0];
    } else {
        if (parent->numberOfChildren == 3) {
            if (data.compare(parent->maxKey) < 0) {
                leaf = parent->children[1];
            } else {
                leaf = parent->children[2];
            }
        } else {
            leaf = parent->children[1];
        }
    }
    //not full leaf
    if (leaf->numberOfItems == 1) {
        if (data.compare(leaf->minKey) < 0) {
            string temp;
            temp.assign(leaf->minKey);
            leaf->minKey.assign(data);
            leaf->maxKey.assign(temp);
        } else {
            leaf->maxKey = data;
        }
        leaf->numberOfItems = 2;
    //full leaf
    } else if (leaf->numberOfItems == 2) {
        //should split
        split(leaf, data);
    }
}

void TwoThreeTree::split(Node *node, string data) {
    Node *parent = node->parent;
    bool isNewParent = false;
    if (parent == NULL) {
        isNewParent = true;
        parent = new Node("", NULL);
        parent->children.insert(parent->children.begin(), node);
        parent->numberOfChildren = 1;
    }
    
    string newMinKey, newMidKey, newMaxKey;
    if (data.compare(node->minKey) < 0) {
        newMinKey.assign(data);
        newMidKey.assign(node->minKey);
        newMaxKey.assign(node->maxKey);
    } else if (node->minKey.compare(data) <= 0 && data.compare(node->maxKey) < 0) {
        newMinKey.assign(node->minKey);
        newMidKey.assign(data);
        newMaxKey.assign(node->maxKey);
    } else {
        newMinKey.assign(node->minKey);
        newMidKey.assign(node->maxKey);
        newMaxKey.assign(data);
    }
    
    Node *node1 = new Node(newMinKey, parent);
    node1->numberOfItems = 1;
    Node *node2 = new Node(newMaxKey, parent);
    node2->numberOfItems = 1;

    for (int i = 0; i < parent->numberOfChildren; ++i) {
        if (parent->children[i] == node) {
            parent->children.erase(parent->children.begin()+i);
            parent->children.insert(parent->children.begin()+i, node1);
            parent->children.insert(parent->children.begin()+i+1, node2);
            break;
        }
    }
    parent->numberOfChildren = (int)parent->children.size();
    
    if (node->numberOfChildren != 0) {
        vector<Node*>::iterator it = node->children.begin();
        node1->children.insert(node1->children.begin(), it, it+2);
        node1->numberOfChildren = 2;
        for (int i = 0; i < node1->numberOfChildren; ++i) {
            node1->children[i]->parent = node1;
        }
        it += 2;
        node2->children.insert(node2->children.begin(), it, it+2);
        node2->numberOfChildren = 2;
        for (int i = 0; i < node2->numberOfChildren; ++i) {
            node2->children[i]->parent = node2;
        }
    }

    delete node;
    
    if (isNewParent) {
        parent->minKey.assign(newMidKey);
        parent->numberOfItems = 1;
        this->root = parent;
    } else if (parent->numberOfItems == 1) {
        if (newMidKey.compare(parent->minKey) < 0) {
            string temp;
            temp.assign(parent->minKey);
            parent->minKey.assign(newMidKey);
            parent->maxKey.assign(temp);
        } else {
            parent->maxKey.assign(newMidKey);
        }
        parent->numberOfItems = 2;
    } else {
        split(parent, newMidKey);
    }
}

Node *TwoThreeTree::searchData(string data) {
    return searchDataInRoot(this->root, data);
}

Node *TwoThreeTree::searchDataInRoot(Node *node, string data) {
    if (data.compare(node->minKey) == 0 || data.compare(node->maxKey) == 0) {
        return node;
    } else if (node->numberOfChildren == 0) {
        return NULL;
    } else if (data.compare(node->minKey) < 0) {
        return searchDataInRoot(node->children[0], data);
    } else {
        if (node->numberOfItems == 2) {
            if (data.compare(node->minKey) > 0 && data.compare(node->maxKey) < 0) {
                return searchDataInRoot(node->children[1], data);
            } else {
                return searchDataInRoot(node->children[2], data);
            }
        } else {
            return searchDataInRoot(node->children[1], data);
        }
    }
    return NULL;
}

vector<Node*> TwoThreeTree::findDataWithPrefix(string prefix) {
    vector<Node*> nodes;
    
    Node *parent = findFirstNodeWithPrefix(this->root, prefix);
    
    
    return nodes;
}

Node *TwoThreeTree::findFirstNodeWithPrefix(Node *node, string prefix) {
    if (checkPrefix(prefix, node->minKey) || checkPrefix(prefix, node->maxKey)) {
        return node;
    } else if (node->numberOfChildren == 0) {
        return NULL;
    } else if (prefix.compare(node->minKey) < 0) {
        return findFirstNodeWithPrefix(node->children[0], prefix);
    } else {
        if (node->numberOfItems == 2) {
            if (prefix.compare(node->minKey) > 0 && prefix.compare(node->maxKey) < 0) {
                return findFirstNodeWithPrefix(node->children[1], prefix);
            } else {
                return findFirstNodeWithPrefix(node->children[2], prefix);
            }
        } else {
            return findFirstNodeWithPrefix(node->children[1], prefix);
        }
    }
    return NULL;
}

bool TwoThreeTree::checkPrefix(string prefix, string str) {
    if (str == "") {
        return false;
    }
    string strPrefix = str.substr(0, prefix.length());
    if (prefix == strPrefix) {
        return true;
    }
    
    return false;
}

