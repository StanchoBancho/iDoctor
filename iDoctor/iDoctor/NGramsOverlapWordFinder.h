//
//  NGramsOverlap.h
//  23Tree
//
//  Created by Dobrinka Tabakova on 12/29/13.
//  Copyright (c) 2013 Dobrinka Tabakova. All rights reserved.
//

#ifndef ___3Tree__NGramsOverlapWordFinder__
#define ___3Tree__NGramsOverlapWordFinder__

#import "TwoThreeTree.h"

using namespace std;

class NGramsOverlapWordFinder {
public:
    TwoThreeTree *ngramTree;
    void insertWordInNGramTree(string word);
    float jaccardIndex(string word, string otherWord);
    vector<pair<string, float> > getNearestWordsForWord(string word);
    NGramsOverlapWordFinder();
private:
    vector<string> getNGramsForWord(string word);
};
#endif /* defined(___3Tree__NGramsOverlap__) */
