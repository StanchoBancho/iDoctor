//
//  NodeKey.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 2/15/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#ifndef __iDoctor__NodeKey__
#define __iDoctor__NodeKey__

#include <iostream>
#import <stdlib.h>
#import <string>
#import <vector>
#import <set>

using namespace std;

class NodeKey {
public:
    string key;
    vector <string> words;
    NodeKey(string key);
};

#endif /* defined(__iDoctor__NodeKey__) */
