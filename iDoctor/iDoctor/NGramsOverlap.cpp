//
//  NGramsOverlap.cpp
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/29/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#include "NGramsOverlap.h"
#include <vector>
#include <string>
#include <algorithm>

vector<string> insertNGramsForWord(string word) {
    vector<string> ngrams;
    
    for (int i = 0; i < word.length() - 1; ++i) {
        string ngram = word.substr(i, 2);
        ngrams.push_back(ngram);
    }
    return ngrams;
}

float jaccardIndex(string word, string otherWord) {
    string wordLow, otherWordLow;
    wordLow.assign(word);
    otherWordLow.assign(otherWord);
    transform(wordLow.begin(), wordLow.end(), wordLow.begin(), ::tolower);
    transform(otherWordLow.begin(), otherWordLow.end(), otherWordLow.begin(), ::tolower);
    
    vector<string> wordNGrams = insertNGramsForWord(wordLow);
    vector<string> otherWordsNGrams = insertNGramsForWord(otherWordLow);
    
    vector<string> intersectionSet;

    
    return 0.0;
}
