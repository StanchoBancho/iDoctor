//
//  AutocorectionViewController.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/17/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <string>
#include <set>
#import "NGramsOverlap.h"
#import "TypingHelper.h"

using namespace std;

@protocol AutocorectionTypingHelper <TypingHelper>

-(void)replaceWrongWords:(NSString*)wrongWord withAutocorectedWords:(NSString*)autocorectedWord;

@end

@interface AutocorectionViewController : UIViewController

@property (nonatomic, assign) id<AutocorectionTypingHelper> delegate;

-(void)setNGramDataStructure:(NGramsOverlap*) ngramOverlap;
-(void)setAllMedicineNamesWords:(set<string>) allMedicineNamesWords;

-(void)tryToAutoCorrectTheTypedText;

@end
