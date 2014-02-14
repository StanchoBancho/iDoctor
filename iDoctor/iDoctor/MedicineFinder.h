//
//  MedicineFinder.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 2/14/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#ifndef ___3Tree__NGramsOverlap__
#define ___3Tree__NGramsOverlap__

#include <iostream>
#include <vector>
#include <string>
#include "TwoThreeTree.h"
#include "NGramNode.h"


using namespace std;

class NGramsOverlapWordFinder {
public:
    TwoThreeTree *ngramTree;
    void insertMedicine(string medicine);
    float jaccardIndex(string word, string otherWord);
    vector<pair<string, float> > getMedicinesForWord(string word);
    NGramsOverlapWordFinder();
private:
    vector<string> split(const string &text);
};
#endif /* defined(___3Tree__NGramsOverlap__) */
