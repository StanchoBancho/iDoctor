//
//  MedicineFinder.mm
//  iDoctor
//
//  Created by Stanimir Nikolov on 2/14/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "MedicineFinder.h"
#include <vector>
#include <string>
#include <algorithm>
#import <set>

NGramsOverlapWordFinder::NGramsOverlapWordFinder() {
    this->ngramTree = new TwoThreeTree();
}


vector<string> NGramsOverlapWordFinder::split(const string &text) {
    int start = 0, end = 0;
    vector<string> tokens;
    while ((end = text.find(' ', start)) != string::npos) {
        tokens.push_back(text.substr(start, end - start));
        start = end + 1;
    }
    tokens.push_back(text.substr(start));
    return tokens;
}

void NGramsOverlapWordFinder::insertMedicine(string word) {
   
    vector<string> tokens = split(word);
    for (int i = 0; i < tokens.size(); ++i) {
        string token = tokens[i];
        Node *ngramNode = ngramTree->searchData(token);
        if (ngramNode != NULL) {
            ngramNode->words.push_back(word);
        } else {
            ngramTree->insertData(token);
            Node *ngramNode = ngramTree->searchData(token);
            ngramNode->words.push_back(word);
        }
    }
}

bool wayToSort(pair<string, float>  i, pair<string, float> j) {
    return i.second > j.second;
}

vector<pair<string, float> > NGramsOverlapWordFinder::getMedicinesForWord(string word) {
    vector<pair<string, float> > words;
    set<string> existingWord;
    vector<string> ngrams = split(word);
    for (int i = 0; i < ngrams.size(); ++i) {
        string ngram = ngrams[i];
        Node *ngramNode = ngramTree->searchData(ngram);
        if (ngramNode != NULL) {
            for (int j = 0; j < ngramNode->words.size(); ++j) {
                string autocorectionWord = ngramNode->words[j];
                const bool is_in = existingWord.find(autocorectionWord) != existingWord.end();
                
                if(!is_in){
                    float distance = this->jaccardIndex(word, autocorectionWord);
                    words.push_back(make_pair(autocorectionWord, distance));
                    existingWord.insert(autocorectionWord);
                }
            }
        }
    }
    sort(words.begin(), words.end(), wayToSort);
    
    if(words.size() > 10){
        words.erase(words.begin() + 10, words.end());
    }
    
    return words;
}

float NGramsOverlapWordFinder::jaccardIndex(string word, string otherWord) {
    if (word.length() == 0 || otherWord.length() == 0) {
        return 0.0;
    }
    
    vector<string> wordNGrams = split(word);
    vector<string> otherWordsNGrams = split(otherWord);
    
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

