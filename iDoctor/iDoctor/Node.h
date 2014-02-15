//
//  Node.h
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#ifndef ___3Tree__Node__
#define ___3Tree__Node__

#import <stdlib.h>
#import <string>
#import <vector>
#import <set>

using namespace std;

class Node {
    public:
        string minKey, maxKey;
        Node *parent;
        vector <Node*> children;
        int numberOfItems;
        int numberOfChildren;
        vector<string> words;
        Node(string minKey, Node *parent);
};

#endif /* defined(___3Tree__Node__) */
