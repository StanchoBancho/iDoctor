//
//  EditDistance.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/28/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#include "EditDistance.h"
#include "stdlib.h"
#include <iostream>
#include <cstring>
#include "string.h"

using namespace std;

int editDistance(char *text, char *target) {
    int textLen, targetLen;
    if (text != NULL) {
        textLen = (int)strlen(text);
    }
    if (target != NULL) {
        targetLen = (int)strlen(target);
    }
    
    if (!textLen) {
        return targetLen;
    }
    if (!targetLen) {
        return textLen;
    }
    
    int matrix[textLen + 1][targetLen + 1];
    for (int i = 0; i < textLen; ++i) {
        matrix[i][0] = i;
    }
    for (int i = 0; i < targetLen; ++i) {
        matrix[0][i] = i;
    }
    
    int lastRow[256];
    
    for (int i = 1; i <= textLen; ++i) {
        char textChar = text[i-1];
        int lastMatchingCol = 0;
        for (int j = 1; j <= targetLen; ++j) {
            char targetChar = target[j-1];
            int lastMatchingRow = lastRow[targetChar];
            
            int cost = (targetChar == textChar) ? 0 : 1;
            
            int distAdd = matrix[i-1][j] + 1;
            int distDelete = matrix[i][j-1] + 1;
            int distSubstitution = matrix[i-1][j-1] + cost;
            
            int distTransposition = matrix[lastMatchingRow-1][lastMatchingCol-1] + (i - lastMatchingRow - 1) + 1 + (j - lastMatchingCol - 1);
            
            int min = distAdd;
            if (distDelete < min)
                min = distDelete;
            if (distSubstitution < min)
                min = distSubstitution;
            if (distTransposition < min)
                min = distTransposition;
            
            matrix[i][j] = min;
            
            if (cost == 0) {
                lastMatchingCol = j;
            }
        }
        lastRow[textChar] = i;
    }
    int result = matrix[textLen-1][targetLen-1];
    return result;
}
