//
//  MedicineFinder.mm
//  iDoctor
//
//  Created by Stanimir Nikolov on 2/14/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "MedicineFinder.h"
#include <algorithm>
#include <functional>
#include <cctype>
#include <locale>

// trim from start
static inline std::string &ltrim(std::string &s) {
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
    return s;
}

// trim from end
static inline std::string &rtrim(std::string &s) {
    s.erase(std::find_if(s.rbegin(), s.rend(), std::not1(std::ptr_fun<int, int>(std::isspace))).base(), s.end());
    return s;
}

// trim from both ends
static inline std::string &trim(std::string &s) {
    return ltrim(rtrim(s));
}

MedicineFinder::MedicineFinder() {
    this->ngramTree = new TwoThreeTree();
}

vector<string> MedicineFinder::split(string text) {
    unsigned long start = 0, end = 0;
    vector<string> tokens;
    while ((end = text.find(' ', start)) != string::npos) {
        tokens.push_back(text.substr(start, end - start));
        start = end + 1;
    }
    tokens.push_back(text.substr(start));
    return tokens;
}

void MedicineFinder::insertMedicine(string word) {
   
    vector<string> tokens = split(word);

    
    for (int i = 0; i < tokens.size(); ++i) {
        string token = tokens[i];
        trim(token);
        if(token.compare("") == 0){
            continue;
        }
        string copiedWord;
        copiedWord.assign(word);
        
        Node *nodeWithThisToken = ngramTree->searchData(token);
        if (nodeWithThisToken != NULL) {
            string copiedString;
            copiedString.assign(token);
            transform(copiedString.begin(), copiedString.end(), copiedString.begin(), ::tolower);
            if (copiedString.compare(nodeWithThisToken->minKey->key) == 0) {
                nodeWithThisToken->minKey->words.push_back(copiedWord);
            } else {
                nodeWithThisToken->maxKey->words.push_back(copiedWord);
            }
        } else {
            string copiedString;
            copiedString.assign(token);
            transform(copiedString.begin(), copiedString.end(), copiedString.begin(), ::tolower);
            ngramTree->insertData(copiedString, copiedWord);
            Node *ngramNode = ngramTree->searchData(copiedString);
            if (copiedString.compare(ngramNode->minKey->key) == 0) {
                ngramNode->minKey->words.push_back(copiedWord);
            } else {
                ngramNode->maxKey->words.push_back(copiedWord);
            }
        }
    }
}

//bool wayToSort(pair<string, float>  i, pair<string, float> j) {
//    return i.second > j.second;
//}

vector<string> MedicineFinder::getMedicinesForTypedText(string text) {
    vector<string> words;
    set<string> existing_words;
    vector<string> tokens = split(text);
    for (int i = 0; i < tokens.size(); ++i) {
        string token = tokens[i];
        vector<string> nodeWithThisToken = ngramTree->findDataWithPrefix(token);
            for (int j = 0; j < nodeWithThisToken.size(); ++j) {
                string autocorectionWord = nodeWithThisToken[j];
                const bool is_in_set = existing_words.find(autocorectionWord) != existing_words.end();
                if(!is_in_set){
                    words.push_back(autocorectionWord);
                    existing_words.insert(autocorectionWord);
                }
            }
    }
    //sort(words.begin(), words.end(), wayToSort);
    return words;
}
