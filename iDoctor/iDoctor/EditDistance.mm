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
#include <vector>

unsigned int edit_distance(const string& s1, const string& s2)
{
	const size_t len1 = s1.size(), len2 = s2.size();
	vector<vector<unsigned int> > d(len1 + 1, vector<unsigned int>(len2 + 1));
    
	d[0][0] = 0;
	for(unsigned int i = 1; i <= len1; ++i) d[i][0] = i;
	for(unsigned int i = 1; i <= len2; ++i) d[0][i] = i;
    
	for(unsigned int i = 1; i <= len1; ++i)
		for(unsigned int j = 1; j <= len2; ++j)
            
            d[i][j] = std::min( std::min(d[i - 1][j] + 1,d[i][j - 1] + 1),
                               d[i - 1][j - 1] + (s1[i - 1] == s2[j - 1] ? 0 : 1) );
	return d[len1][len2];
}


int OptimalStringAlignmentDistance(string str1, string str2){
// d is a table with lenStr1+1 rows and lenStr2+1 columns
    int d[str1.length() + 1][str2.length() + 1];

// i and j are used to iterate over str1 and str2
    int cost;

// for loop is inclusive, need table 1 row/column larger than string length
    for (int i = 0 ; i < str1.length(); i ++){
        d[i][0] = i;
    }
    for(int j = 1; j < str2.length(); j++){
        d[0][j] = j;
    }
// pseudo-code assumes string indices start at 1, not 0
// if implemented, make sure to start comparing at 1st letter of strings
    for( int i = 1; i < str1.length(); i++){
        for(int j = 1; j < str2.length(); j++){
            if (str1[i] == str2[j]){
                cost = 0;
            }
            else{
                cost = 1;
            }
            d[i][j] = MIN(MIN(d[i-1][j] + 1,     // deletion
                              d[i][j-1] + 1),     // insertion
                              d[i-1][j-1] + cost);   // substitution)
            if(i > 1 && j > 1 && str1[i] == str2[j-1] && str1[i-1] == str2[j]){
                d[i][j] = MIN(d[i][j], d[i-2][j-2] + cost);   // transposition
            }
        }
    }

    return d[str1.length()][str2.length()];
}

int editDistance(string text, string target) {
    int textLen = 0, targetLen = 0;
    if (!text.empty()) {
        textLen = (int)text.length();
    }
    if (!target.empty()) {
        targetLen = (int)target.length();
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
