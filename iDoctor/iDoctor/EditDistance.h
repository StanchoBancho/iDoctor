//
//  EditDistance.h
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/28/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#ifndef ___3Tree__EditDistance__
#define ___3Tree__EditDistance__

#include <iostream>
#include <cstring>
#include "string.h"

using namespace std;

unsigned int edit_distance(const string& s1, const string& s2);

int OptimalStringAlignmentDistance(string str1, string str2);

int editDistance(string text, string target);

#endif /* defined(___3Tree__EditDistance__) */
