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

using namespace std;

@protocol AutocorectionDataProviderAndPresenter <NSObject>

-(NSString*)typedTextForAutocorrection;
-(void)presentAutocorectionViewController;
-(void)hideAutocorectionViewController;
-(void)replaceWrongWords:(NSString*)wrongWord withAutocorectedWords:(NSString*)autocorectedWord;

@end

@interface AutocorectionViewController : UIViewController

@property (nonatomic, assign) id<AutocorectionDataProviderAndPresenter> delegate;

-(void)setNGramDataStructure:(NGramsOverlap*) ngramOverlap;
-(void)setAllMedicineNamesWords:(set<string>) allMedicineNamesWords;


-(void)tryToAutoCorrectTheTypedText;

@end
