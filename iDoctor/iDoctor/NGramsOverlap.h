//
//  NGramsOverlap.h
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/29/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#ifndef ___3Tree__NGramsOverlap__
#define ___3Tree__NGramsOverlap__

#include <iostream>
#include <vector>
#include <string>
#include "TwoThreeTree.h"
#include "NGramNode.h"


using namespace std;

class NGramsOverlap {
public:
    TwoThreeTree *ngramTree;
    void insertWordInNGramTree(string word);
    float jaccardIndex(string word, string otherWord);
    
    NGramsOverlap();
private:
    vector<string> getNGramsForWord(string word);
};
#endif /* defined(___3Tree__NGramsOverlap__) */
