//
//  TwoThreeTree.h
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#ifndef ___3Tree__TwoThreeTree__
#define ___3Tree__TwoThreeTree__

#import "Node.h"

using namespace std;

class TwoThreeTree {
public:
    Node *root;
    void insertData(string data, string word);
    Node *searchData(string data);
    vector<string> findDataWithPrefix(string prefix);
    TwoThreeTree();
    
private:
    void insertDataIntoParentTree(Node *parent, string data, string word);
    void split(Node *node, NodeKey *data);
    Node *findParent(Node *node, string data);
    Node *searchDataInRoot(Node *node, string data);
    bool checkPrefix(string prefix, string str);
    Node *findFirstNodeWithPrefix(Node *node, string prefix);
};

#endif /* defined(___3Tree__TwoThreeTree__) */
