//
//  TwoThreeTree.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#include "TwoThreeTree.h"
#include <vector>
#include <queue>
#include <algorithm>
#include "stdlib.h"

using namespace std;

template <class NodeType> TwoThreeTree<NodeType>::TwoThreeTree() {
    this->root = NULL;
}

template <class NodeType> void TwoThreeTree<NodeType>::insertData(string data) {
    //empty tree
    if (this->root == NULL) {
        this->root = new Node(data, NULL);
        this->root->numberOfItems = 1;
        //one node tree
    } else if (this->root->numberOfChildren == 0) {
        //not full node
        
        string minKeyLow, maxKeyLow, dataLow;
        minKeyLow.assign(this->root->minKey);
        maxKeyLow.assign(this->root->maxKey);
        dataLow.assign(data);
        
        transform(minKeyLow.begin(), minKeyLow.end(), minKeyLow.begin(), ::tolower);
        transform(maxKeyLow.begin(), maxKeyLow.end(), maxKeyLow.begin(), ::tolower);
        transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
        
        
        if (this->root->numberOfItems == 1) {
            if (dataLow.compare(minKeyLow) < 0) {
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
            if (dataLow.compare(minKeyLow) < 0) {
                newMinKey.assign(data);
                newMidKey.assign(this->root->minKey);
                newMaxKey.assign(this->root->maxKey);
            } else if (minKeyLow.compare(dataLow) <= 0 && dataLow.compare(maxKeyLow) < 0) {
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

template <class NodeType> NodeType *TwoThreeTree<NodeType>::findParent(NodeType *node, string data) {
    Node *leftChild = node->children[0];
    Node *middleChild = node->children[1];
    Node *rightChild = node->children[2];
    
    string minKeyLow, maxKeyLow, dataLow;
    minKeyLow.assign(node->minKey);
    maxKeyLow.assign(node->maxKey);
    dataLow.assign(data);
    
    transform(minKeyLow.begin(), minKeyLow.end(), minKeyLow.begin(), ::tolower);
    transform(maxKeyLow.begin(), maxKeyLow.end(), maxKeyLow.begin(), ::tolower);
    transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
    
    //node children are leaves
    if (leftChild->numberOfChildren == 0) {
        return node;
        //should go to left child
    } else if (dataLow.compare(minKeyLow) < 0) {
        return findParent(leftChild, data);
        //should go to middle or right child
    } else {
        if (node->numberOfChildren == 3) {
            if (dataLow.compare(maxKeyLow) < 0) {
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

template <class NodeType> void TwoThreeTree<NodeType>::insertDataIntoParentTree(NodeType *parent, string data) {
    Node *leaf = NULL;
    //find leaf node to insert data
    
    string parentMinKeyLow, parentMaxKeyLow, dataLow;
    parentMinKeyLow.assign(parent->minKey);
    parentMaxKeyLow.assign(parent->maxKey);
    dataLow.assign(data);
    
    transform(parentMinKeyLow.begin(), parentMinKeyLow.end(), parentMinKeyLow.begin(), ::tolower);
    transform(parentMaxKeyLow.begin(), parentMaxKeyLow.end(), parentMaxKeyLow.begin(), ::tolower);
    transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
    
    if (dataLow.compare(parentMinKeyLow) < 0) {
        leaf = parent->children[0];
    } else {
        if (parent->numberOfChildren == 3) {
            if (dataLow.compare(parentMaxKeyLow) < 0) {
                leaf = parent->children[1];
            } else {
                leaf = parent->children[2];
            }
        } else {
            leaf = parent->children[1];
        }
    }
    
    string leafMinKeyLow;
    leafMinKeyLow.assign(leaf->minKey);
    transform(leafMinKeyLow.begin(), leafMinKeyLow.end(), leafMinKeyLow.begin(), ::tolower);
    
    //not full leaf
    if (leaf->numberOfItems == 1) {
        if (dataLow.compare(leafMinKeyLow) < 0) {
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

template <class NodeType> void TwoThreeTree<NodeType>::split(NodeType *node, string data) {
    Node *parent = node->parent;
    bool isNewParent = false;
    if (parent == NULL) {
        isNewParent = true;
        parent = new Node("", NULL);
        parent->children.insert(parent->children.begin(), node);
        parent->numberOfChildren = 1;
    }
    
    string newMinKey, newMidKey, newMaxKey;
    
    string minKeyLow, maxKeyLow, dataLow;
    minKeyLow.assign(node->minKey);
    maxKeyLow.assign(node->maxKey);
    dataLow.assign(data);
    
    transform(minKeyLow.begin(), minKeyLow.end(), minKeyLow.begin(), ::tolower);
    transform(maxKeyLow.begin(), maxKeyLow.end(), maxKeyLow.begin(), ::tolower);
    transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
    
    if (dataLow.compare(minKeyLow) < 0) {
        newMinKey.assign(data);
        newMidKey.assign(node->minKey);
        newMaxKey.assign(node->maxKey);
    } else if (minKeyLow.compare(dataLow) <= 0 && dataLow.compare(maxKeyLow) < 0) {
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
    
    string parentMinKeyLow, newMidKeyLow;
    parentMinKeyLow.assign(parent->minKey);
    newMidKeyLow.assign(newMidKey);
    
    transform(parentMinKeyLow.begin(), parentMinKeyLow.end(), parentMinKeyLow.begin(), ::tolower);
    transform(newMidKeyLow.begin(), newMidKeyLow.end(), newMidKeyLow.begin(), ::tolower);
    
    if (isNewParent) {
        parent->minKey.assign(newMidKey);
        parent->numberOfItems = 1;
        this->root = parent;
    } else if (parent->numberOfItems == 1) {
        if (newMidKeyLow.compare(parentMinKeyLow) < 0) {
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

template <class NodeType> NodeType *TwoThreeTree<NodeType>::searchData(string data) {
    return searchDataInRoot(this->root, data);
}

template <class NodeType> NodeType *TwoThreeTree<NodeType>::searchDataInRoot(NodeType *node, string data) {
    string minKey, maxKey;
    minKey.assign(node->minKey);
    maxKey.assign(node->maxKey);
    
    transform(minKey.begin(), minKey.end(), minKey.begin(), ::tolower);
    transform(maxKey.begin(), maxKey.end(), maxKey.begin(), ::tolower);
    
    if (data.compare(minKey) == 0 || data.compare(maxKey) == 0) {
        return node;
    } else if (node->numberOfChildren == 0) {
        return NULL;
    } else if (data.compare(minKey) < 0) {
        return searchDataInRoot(node->children[0], data);
    } else {
        if (node->numberOfItems == 2) {
            if (data.compare(minKey) > 0 && data.compare(maxKey) < 0) {
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

template <class NodeType> vector<string> TwoThreeTree<NodeType>::findDataWithPrefix(string prefix) {
    vector<string> nodes;
    transform(prefix.begin(), prefix.end(), prefix.begin(), ::tolower);
    
    Node *parent = findFirstNodeWithPrefix(this->root, prefix);
    if(parent){
        queue<Node*> q;
        q.push(parent);
        while (!q.empty()) {
            Node *n = q.front();
            
            string minKey, maxKey;
            minKey.assign(n->minKey);
            maxKey.assign(n->maxKey);
            
            transform(minKey.begin(), minKey.end(), minKey.begin(), ::tolower);
            transform(maxKey.begin(), maxKey.end(), maxKey.begin(), ::tolower);
            
            q.pop();
            
            bool shouldAddChildren = false;
            if (checkPrefix(prefix, minKey)) {
                nodes.push_back(n->minKey);
                shouldAddChildren = true;
            }
            if (checkPrefix(prefix, maxKey)) {
                nodes.push_back(n->maxKey);
                shouldAddChildren = true;
            }
            
            if (shouldAddChildren) {
                for (int i = 0; i < n->numberOfChildren; ++i) {
                    q.push(n->children[i]);
                }
            }
        }
    }
    return nodes;
}

template <class NodeType> NodeType *TwoThreeTree<NodeType>::findFirstNodeWithPrefix(NodeType *node, string prefix) {
    
    string minKey, maxKey;
    minKey.assign(node->minKey);
    maxKey.assign(node->maxKey);
    
    transform(minKey.begin(), minKey.end(), minKey.begin(), ::tolower);
    transform(maxKey.begin(), maxKey.end(), maxKey.begin(), ::tolower);
    
    if (checkPrefix(prefix, minKey) || checkPrefix(prefix, maxKey)) {
        return node;
    } else if (node->numberOfChildren == 0) {
        return NULL;
    } else if (prefix.compare(minKey) < 0) {
        return findFirstNodeWithPrefix(node->children[0], prefix);
    } else {
        if (node->numberOfItems == 2) {
            if (prefix.compare(minKey) > 0 && prefix.compare(maxKey) < 0) {
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

template <class NodeType> bool TwoThreeTree<NodeType>::checkPrefix(string prefix, string str) {
    if (str == "") {
        return false;
    }
    string strPrefix = str.substr(0, prefix.length());
    if (prefix == strPrefix) {
        return true;
    }
    
    return false;
}


template <class NodeType> void TwoThreeTree<NodeType>:: test(){
   TwoThreeTree<Node>* tree = new TwoThreeTree<Node>();
    

}
