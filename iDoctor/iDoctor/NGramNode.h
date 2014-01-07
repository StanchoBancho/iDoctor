//
//  NGramNode.h
//  iDoctor
//
//  Created by Dobrinka Tabakova on 1/7/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#ifndef __iDoctor__NGramNode__
#define __iDoctor__NGramNode__

#include <iostream>
#include "Node.h"
#include <vector>
#include <string>


class NGramNode:public Node {
public:
    vector<string> words;
};

#endif /* defined(__iDoctor__NGramNode__) */
