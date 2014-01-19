//
//  NotesViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/18/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "NotesViewController.h"

@interface NotesViewController ()

@property (nonatomic, strong) IBOutlet UITextView* notesTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitleItem;

@end

@implementation NotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationTitleItem setTitle:self.medicineTitle];
    [self.notesTextView setText:self.medicineNotes];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.notesTextView becomeFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneButtonPressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(setNotesText:)]){
        [self.delegate setNotesText:self.notesTextView.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
