//
//  AutocompletionViewController.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/17/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypingHelper.h"
#import "TwoThreeTree.h"

@protocol AutocompletionTypeHelper <TypingHelper>

-(void)handleAutocompletion:(NSString*)autocompletedText;

@end

@interface AutocompletionViewController : UIViewController

-(void)setTwoThreeTreeDataStructure:(TwoThreeTree*) twoThreeTree;
-(void)setAllMedicineNames:(vector<string>) allMedicineNames;

@property (nonatomic, assign) id<AutocompletionTypeHelper>delegate;

-(void)tryToAutoCompleteTheTypedText;

@end
