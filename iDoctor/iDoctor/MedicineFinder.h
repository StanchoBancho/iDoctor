//
//  MedicineFinder.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 2/14/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#ifndef ___3Tree__MedicineFinder__
#define ___3Tree__MedicineFinder__

#ifndef ___3Tree__NGramsOverlapWordFinder__

#import "TwoThreeTree.h"

#endif

using namespace std;

class MedicineFinder {
public:
    TwoThreeTree *ngramTree;
    void insertMedicine(string medicine);
    vector<string> getMedicinesForTypedText(string text);
    MedicineFinder();
private:
    vector<string> split(const string text);
};
#endif /* defined(___3Tree__MedicineFinder__) */
