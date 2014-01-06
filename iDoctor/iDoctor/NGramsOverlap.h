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

using namespace std;

vector<string> insertNGramsForWord(string word);
float jaccardIndex(string word, string otherWord);

#endif /* defined(___3Tree__NGramsOverlap__) */
