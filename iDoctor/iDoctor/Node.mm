//
//  Node.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#include "Node.h"

using namespace std;

Node::Node(string minKey, Node *parent) {
    this->minKey = minKey;
    this->maxKey = "";
    this->parent = parent;
    this->numberOfItems = 1;
    this->numberOfChildren = 0;
}
