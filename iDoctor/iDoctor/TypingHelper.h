//
//  TypingHelper.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/17/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TypingHelper <NSObject>

-(NSString*)typedTextForTypingHelper;
-(void)presentTypingHelperViewController:(UIViewController*)typeHelperViewController;
-(void)hideTypingHelperViewController:(UIViewController*)typeHelperViewController;

@end
