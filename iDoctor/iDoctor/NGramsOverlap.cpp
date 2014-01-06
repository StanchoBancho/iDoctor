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
    if (word.length() == 0 || otherWord.length() == 0) {
        return 0.0;
    }
    string wordLow, otherWordLow;
    wordLow.assign(word);
    otherWordLow.assign(otherWord);
    transform(wordLow.begin(), wordLow.end(), wordLow.begin(), ::tolower);
    transform(otherWordLow.begin(), otherWordLow.end(), otherWordLow.begin(), ::tolower);
    
    vector<string> wordNGrams = insertNGramsForWord(wordLow);
    vector<string> otherWordsNGrams = insertNGramsForWord(otherWordLow);
    
    vector<string> intersectionSet;
    for (int i = 0; i < wordNGrams.size(); ++i) {
        string iNGram = wordNGrams[i];
        for (int j = 0; j < otherWordsNGrams.size(); ++j) {
            string jNgram = otherWordsNGrams[j];
            if (iNGram.compare(jNgram) == 0) {
                intersectionSet.push_back(iNGram);
                break;
            }
        }
    }
    
    vector<string> unionSet;
    for (int i = 0; i < wordNGrams.size(); ++i) {
        string iNGram = wordNGrams[i];
        bool isIn = false;
        for (int j = 0; j < unionSet.size(); ++j) {
            string jNGram = unionSet[j];
            if (iNGram.compare(jNGram) == 0) {
                isIn = true;
                break;
            }
        }
        if (!isIn) {
            unionSet.push_back(iNGram);
        }
    }
    for (int i = 0; i < otherWordsNGrams.size(); ++i) {
        string iNGram = otherWordsNGrams[i];
        bool isIn = false;
        for (int j = 0; j < unionSet.size(); ++j) {
            string jNGram = unionSet[j];
            if (iNGram.compare(jNGram) == 0) {
                isIn = true;
                break;
            }
        }
        if (!isIn) {
            unionSet.push_back(iNGram);
        }
    }
    
    return (float)intersectionSet.size()/(float)unionSet.size();
}
