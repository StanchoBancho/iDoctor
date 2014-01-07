//
//  TwoThreeTree.h
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/24/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#ifndef ___3Tree__TwoThreeTree__
#define ___3Tree__TwoThreeTree__

#include "Node.h"
#include <vector>

using namespace std;

template <class NodeType>
class TwoThreeTree {
public:
    NodeType *root;
    void insertData(string data);
    NodeType *searchData(string data);
    vector<string> findDataWithPrefix(string prefix);
    TwoThreeTree();
    void test();

    
private:
    void insertDataIntoParentTree(NodeType *parent, string data);
    void split(NodeType *leaf, string data);
    NodeType *findParent(NodeType *node, string data);
    NodeType *searchDataInRoot(NodeType *node, string data);
    bool checkPrefix(string prefix, string str);
    NodeType *findFirstNodeWithPrefix(NodeType *node, string prefix);
};

#endif /* defined(___3Tree__TwoThreeTree__) */
