//
//  TwoThreeTree.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#import "TwoThreeTree.h"
#import <vector>
#import <queue>
#import "stdlib.h"

using namespace std;

TwoThreeTree::TwoThreeTree() {
    this->root = NULL;
}

void TwoThreeTree::insertData(string data, string word) {
    //empty tree
    if (this->root == NULL) {
        NodeKey *newNode = new NodeKey(data);
        newNode->words.push_back(word);
        
        this->root = new Node(newNode, NULL);
        this->root->numberOfItems = 1;
        //one node tree
    } else if (this->root->numberOfChildren == 0) {
        //not full node
        
        string minKeyLow, maxKeyLow, dataLow;
        minKeyLow.assign(this->root->minKey->key);
        maxKeyLow.assign(this->root->maxKey->key);
        dataLow.assign(data);
        
        transform(minKeyLow.begin(), minKeyLow.end(), minKeyLow.begin(), ::tolower);
        transform(maxKeyLow.begin(), maxKeyLow.end(), maxKeyLow.begin(), ::tolower);
        transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
        
        
        if (this->root->numberOfItems == 1) {
            if (dataLow.compare(minKeyLow) < 0) {
                NodeKey *temp = this->root->minKey;
                this->root->minKey = new NodeKey(dataLow);
                this->root->minKey->words.push_back(word);
                this->root->maxKey = temp;
            } else {
                this->root->maxKey = new NodeKey(dataLow);
                this->root->maxKey->words.push_back(word);
            }
            this->root->numberOfItems = 2;
            
            //full node, should split
        } else if (this->root->numberOfItems == 2) {
            string newMinKey, newMidKey, newMaxKey;
            
            string minKeyLow, maxKeyLow, dataLow;
            minKeyLow.assign(this->root->minKey->key);
            maxKeyLow.assign(this->root->maxKey->key);
            dataLow.assign(data);
            
            transform(minKeyLow.begin(), minKeyLow.end(), minKeyLow.begin(), ::tolower);
            transform(maxKeyLow.begin(), maxKeyLow.end(), maxKeyLow.begin(), ::tolower);
            transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
            
            NodeKey *newMinNodeKey, *newMidNodeKey, *newMaxNodeKey;
            
            if (dataLow.compare(minKeyLow) < 0) {
                newMinNodeKey = new NodeKey(dataLow);
                newMinNodeKey->words.push_back(word);

                newMidNodeKey = this->root->minKey;
                newMaxNodeKey = this->root->maxKey;
            } else if (minKeyLow.compare(dataLow) <= 0 && dataLow.compare(maxKeyLow) < 0) {
                newMinNodeKey = this->root->minKey;
                newMidNodeKey = new NodeKey(dataLow);
                newMidNodeKey->words.push_back(word);

                newMaxNodeKey = this->root->maxKey;
            } else {
                newMinNodeKey = this->root->minKey;
                newMidNodeKey = this->root->maxKey;
                newMaxNodeKey = new NodeKey(dataLow);
                newMaxNodeKey->words.push_back(word);
            }
            
            this->root = new Node(newMidNodeKey, NULL);
            
            Node *leftChild = new Node(newMinNodeKey, this->root);
            leftChild->numberOfItems = 1;
            Node *rightChild = new Node(newMaxNodeKey, this->root);
            rightChild->numberOfItems = 1;
            
            this->root->children.insert(this->root->children.begin(), leftChild);
            this->root->children.insert(this->root->children.begin()+1, rightChild);
            this->root->numberOfChildren = 2;
        }
    } else {
        Node *parent = findParent(this->root, data);
        insertDataIntoParentTree(parent, data, word);
    }
}

Node *TwoThreeTree::findParent(Node *node, string data) {
    Node *leftChild = node->children[0];
    Node *middleChild = node->children[1];
    Node *rightChild = node->children[2];
    
    string minKeyLow, maxKeyLow, dataLow;
    minKeyLow.assign(node->minKey->key);
    maxKeyLow.assign(node->maxKey->key);
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

void TwoThreeTree::insertDataIntoParentTree(Node *parent, string data, string word) {
    Node *leaf = NULL;
    //find leaf node to insert data
    
    string parentMinKeyLow, parentMaxKeyLow, dataLow;
    parentMinKeyLow.assign(parent->minKey->key);
    parentMaxKeyLow.assign(parent->maxKey->key);
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
    leafMinKeyLow.assign(leaf->minKey->key);
    transform(leafMinKeyLow.begin(), leafMinKeyLow.end(), leafMinKeyLow.begin(), ::tolower);
    
    //not full leaf
    if (leaf->numberOfItems == 1) {
        if (dataLow.compare(leafMinKeyLow) < 0) {
            NodeKey *temp = leaf->minKey;
            leaf->minKey = new NodeKey(dataLow);
            leaf->minKey->words.push_back(word);
            leaf->maxKey = temp;
        } else {
            leaf->maxKey = new NodeKey(dataLow);
            leaf->maxKey->words.push_back(word);
        }
        leaf->numberOfItems = 2;
        //full leaf
    } else if (leaf->numberOfItems == 2) {
        //should split
        NodeKey *newNode = new NodeKey(data);
        newNode->words.push_back(word);

        split(leaf, newNode);
    }
}

void TwoThreeTree::split(Node *node, NodeKey *data) {
    Node *parent = node->parent;
    bool isNewParent = false;
    if (parent == NULL) {
        isNewParent = true;
        NodeKey *newNode = new NodeKey("");
        parent = new Node(newNode, NULL);
        parent->children.insert(parent->children.begin(), node);
        parent->numberOfChildren = 1;
    }
    
    string newMinKey, newMidKey, newMaxKey;
    
    string minKeyLow, maxKeyLow, dataLow;
    minKeyLow.assign(node->minKey->key);
    maxKeyLow.assign(node->maxKey->key);
    dataLow.assign(data->key);
    
    transform(minKeyLow.begin(), minKeyLow.end(), minKeyLow.begin(), ::tolower);
    transform(maxKeyLow.begin(), maxKeyLow.end(), maxKeyLow.begin(), ::tolower);
    transform(dataLow.begin(), dataLow.end(), dataLow.begin(), ::tolower);
    
    NodeKey *newMinNodeKey, *newMidNodeKey, *newMaxNodeKey;
    
    if (dataLow.compare(minKeyLow) < 0) {
        newMinKey.assign(data->key);
        newMinNodeKey = data;
        newMidKey.assign(node->minKey->key);
        newMidNodeKey = node->minKey;
        newMaxKey.assign(node->maxKey->key);
        newMaxNodeKey = node->maxKey;
    } else if (minKeyLow.compare(dataLow) <= 0 && dataLow.compare(maxKeyLow) < 0) {
        newMinKey.assign(node->minKey->key);
        newMinNodeKey = node->minKey;
        newMidKey.assign(data->key);
        newMidNodeKey = data;
        newMaxKey.assign(node->maxKey->key);
        newMaxNodeKey = node->maxKey;
    } else {
        newMinKey.assign(node->minKey->key);
        newMinNodeKey = node->minKey;
        newMidKey.assign(node->maxKey->key);
        newMidNodeKey = node->maxKey;
        newMaxKey.assign(data->key);
        newMaxNodeKey = data;
    }
    Node *node1 = new Node(newMinNodeKey, parent);
    node1->numberOfItems = 1;
    Node *node2 = new Node(newMaxNodeKey, parent);
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
    
    node->parent = NULL;    
    string parentMinKeyLow, newMidKeyLow;
    parentMinKeyLow.assign(parent->minKey->key);
    newMidKeyLow.assign(newMidKey);
    
    transform(parentMinKeyLow.begin(), parentMinKeyLow.end(), parentMinKeyLow.begin(), ::tolower);
    transform(newMidKeyLow.begin(), newMidKeyLow.end(), newMidKeyLow.begin(), ::tolower);
    
    if (isNewParent) {
        parent->minKey = newMidNodeKey;
        parent->numberOfItems = 1;
        this->root = parent;
    } else if (parent->numberOfItems == 1) {
        if (newMidKeyLow.compare(parentMinKeyLow) < 0) {
            NodeKey *temp = parent->minKey;
            parent->minKey = newMidNodeKey;
            parent->maxKey = temp;
        } else {
            parent->maxKey = newMidNodeKey;
        }
        
        parent->numberOfItems = 2;
    } else {
        split(parent, newMidNodeKey);
    }
}

Node *TwoThreeTree::searchData(string data) {
    if (this->root == NULL) {
        return NULL;
    }
    return searchDataInRoot(this->root, data);
}

Node *TwoThreeTree::searchDataInRoot(Node *node, string data) {
    string minKey, maxKey;
    minKey.assign(node->minKey->key);
    maxKey.assign(node->maxKey->key);
    
    transform(minKey.begin(), minKey.end(), minKey.begin(), ::tolower);
    transform(maxKey.begin(), maxKey.end(), maxKey.begin(), ::tolower);
    
    string lowData;
    lowData.assign(data);
    transform(lowData.begin(), lowData.end(), lowData.begin(), ::tolower);

    if (lowData.compare(minKey) == 0 || lowData.compare(maxKey) == 0) {
        return node;
    } else if (node->numberOfChildren == 0) {
        return NULL;
    } else if (lowData.compare(minKey) < 0) {
        return searchDataInRoot(node->children[0], lowData);
    } else {
        if (node->numberOfItems == 2) {
            if (lowData.compare(minKey) > 0 && lowData.compare(maxKey) < 0) {
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

vector<string> TwoThreeTree::findDataWithPrefix(string prefix) {
    vector<string> nodes;
    transform(prefix.begin(), prefix.end(), prefix.begin(), ::tolower);
    
    Node *parent = findFirstNodeWithPrefix(this->root, prefix);
    if(parent){
        queue<Node*> q;
        q.push(parent);
        while (!q.empty()) {
            Node *n = q.front();
            
            string minKey, maxKey;
            minKey.assign(n->minKey->key);
            maxKey.assign(n->maxKey->key);
            
            transform(minKey.begin(), minKey.end(), minKey.begin(), ::tolower);
            transform(maxKey.begin(), maxKey.end(), maxKey.begin(), ::tolower);
            
            q.pop();
            for (int i = 0; i < n->minKey->words.size(); ++i) {
                    string lowWord;
                    lowWord.assign(n->minKey->words[i]);
                    transform(lowWord.begin(), lowWord.end(), lowWord.begin(), ::tolower);
                    if (lowWord.find(prefix) != -1) {
                        nodes.push_back(n->minKey->words[i]);
                    }
            }
            for (int i = 0; i < n->maxKey->words.size(); ++i) {
                string lowWord;
                lowWord.assign(n->maxKey->words[i]);
                transform(lowWord.begin(), lowWord.end(), lowWord.begin(), ::tolower);
                if (lowWord.find(prefix) != -1) {
                    nodes.push_back(n->maxKey->words[i]);
                }
            }
            
            //test
            for (int j = 0; j < n->numberOfChildren; ++j) {
                q.push(n->children[j]);
            }
            continue;
            if (n->numberOfChildren == 0) {
                continue;
            }
            bool goLeft = false;
            bool goRight = false;
            bool goMiddle = false;
            
            string minSubstr = minKey.substr(0, prefix.length());
            string maxSubstr = maxKey.substr(0, prefix.length());
            bool hasMaxKey = false;
            if (n->numberOfItems > 1) {
                hasMaxKey = true;
                if (minSubstr.compare(prefix) >= 0) {
                    goLeft = true;
                }
                if (minSubstr.compare(prefix) == 0 || maxSubstr.compare(prefix) == 0 || (minSubstr.compare(prefix) < 0 && maxSubstr.compare(prefix) > 0)) {
                    goMiddle = true;
                }
                if (maxSubstr.compare(prefix) <= 0) {
                    goRight = true;
                }
            } else {
                if (minSubstr.compare(prefix) >= 0) {
                    goLeft = true;
                }
                if (maxSubstr.compare(prefix) <= 0) {
                    goRight = true;
                }
            }
            
            if (hasMaxKey) {
                if (goLeft) {
                    q.push(n->children[0]);
                }
                if (goMiddle) {
                    q.push(n->children[1]);
                }
                if (goRight) {
                    q.push(n->children[2]);
                }
            } else {
                if (goLeft) {
                    q.push(n->children[0]);
                }
                if (goRight) {
                    q.push(n->children[1]);
                }
            }
        }
    }
    return nodes;
}

Node *TwoThreeTree::findFirstNodeWithPrefix(Node *node, string prefix) {
    
    string minKey, maxKey;
    minKey.assign(node->minKey->key);
    maxKey.assign(node->maxKey->key);
    
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
            if (prefix.compare(minKey) >= 0 && prefix.compare(maxKey) < 0) {
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
    if (prefix.compare(strPrefix) == 0) {
        return true;
    }
    
    return false;
}

