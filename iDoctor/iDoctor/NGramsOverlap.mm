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
#import <set>

NGramsOverlap::NGramsOverlap() {
    this->ngramTree = new TwoThreeTree();
}

void NGramsOverlap::insertWordInNGramTree(string word) {
    vector<string> ngrams = getNGramsForWord(word);
    for (int i = 0; i < ngrams.size(); ++i) {
        string ngram = ngrams[i];
        Node *ngramNode = ngramTree->searchData(ngram);
        if (ngramNode != NULL) {
            ngramNode->words.push_back(word);
        } else {
            ngramTree->insertData(ngram);
            Node *ngramNode = ngramTree->searchData(ngram);
            ngramNode->words.push_back(word);
        }
    }
}

bool wayToSort(pair<string, float>  i, pair<string, float> j)
{
    return i.second > j.second;
}

vector<pair<string, float> > NGramsOverlap::getNearestWordsForWord(string word) {
    vector<pair<string, float> > words;
    set<string> existingWord;
    vector<string> ngrams = getNGramsForWord(word);
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
    words.erase(words.begin() + 10, words.end());
    
    
    return words;
}




vector<string> NGramsOverlap::getNGramsForWord(string word) {
    vector<string> ngrams;
    
    string wordLow;
    wordLow.assign(word);
    transform(wordLow.begin(), wordLow.end(), wordLow.begin(), ::tolower);
    
    for (int i = 0; i < wordLow.length() - 1; ++i) {
        string ngram = wordLow.substr(i, 2);
        bool shouldInsertNGram = true;
        for (int j = 0; j < ngrams.size(); ++j) {
            string insertedNGram = ngrams[j];
            if (insertedNGram.compare(ngram) == 0) {
                shouldInsertNGram = false;
                break;
            }
        }
        if (shouldInsertNGram) {
            ngrams.push_back(ngram);
        }
    }
    return ngrams;
}

float NGramsOverlap::jaccardIndex(string word, string otherWord) {
    if (word.length() == 0 || otherWord.length() == 0) {
        return 0.0;
    }
    
    vector<string> wordNGrams = getNGramsForWord(word);
    vector<string> otherWordsNGrams = getNGramsForWord(otherWord);
    
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

