//
//  Node.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#import "Node.h"

using namespace std;

Node::Node(NodeKey *minKey, Node *parent) {
    this->minKey = minKey;
    this->maxKey = new NodeKey("");
    this->parent = parent;
    this->numberOfItems = 1;
    this->numberOfChildren = 0;
}
