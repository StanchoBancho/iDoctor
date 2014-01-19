//
//  NotesViewController.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/18/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotesHandler <NSObject>

-(void)setNotesText:(NSString*)noteText;

@end

@interface NotesViewController : UIViewController

@property (nonatomic, assign) id<NotesHandler> delegate;
@property (nonatomic, strong) NSString* medicineTitle;
@property (nonatomic, strong) NSString* medicineNotes;

@end
