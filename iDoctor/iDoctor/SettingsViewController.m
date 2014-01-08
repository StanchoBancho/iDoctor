//
//  SettingsViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/31/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@interface SettingsViewController ()

@property (nonatomic, strong) NSUserDefaults* standardDefaults;

@property (nonatomic, strong) IBOutlet UISegmentedControl* autocompletionSegmentControll;
@property (nonatomic, strong) IBOutlet UISegmentedControl* autocorectionSegmentControll;

@end

@implementation SettingsViewController

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
    
	//set autocompletion segment controll
    self.standardDefaults = [NSUserDefaults standardUserDefaults];

    if([self.standardDefaults integerForKey:kAutocorectionType] == AutocompetionTypeLinear){
        [self.autocorectionSegmentControll setSelectedSegmentIndex:0];
    }
    else {
        [self.autocorectionSegmentControll setSelectedSegmentIndex:1];
    }

    //set autocompletion segment controll
    if([self.standardDefaults integerForKey:kAutocompetionType] == AutocorectionTypeNGram){
        [self.autocompletionSegmentControll setSelectedSegmentIndex:0];
    }
    else if([self.standardDefaults integerForKey:kAutocompetionType] == AutocorectionEditDistance){
        [self.autocompletionSegmentControll setSelectedSegmentIndex:1];
    }
    else{
        [self.autocompletionSegmentControll setSelectedSegmentIndex:2];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)autocorectionSegmentControllerTouched:(id)sender
{
    if([(UISegmentedControl*)sender selectedSegmentIndex] == 0){
        [self.standardDefaults setInteger:AutocompetionTypeLinear forKey:kAutocorectionType];
    }
    else{
        [self.standardDefaults setInteger:AutocompetionType23Tree forKey:kAutocorectionType];
    }
}

-(IBAction)autocompletionSegmentControllerTouched:(id)sender
{
    if([(UISegmentedControl*)sender selectedSegmentIndex] == 0){
        [self.standardDefaults setInteger:AutocorectionTypeNGram forKey:kAutocompetionType];
    }
    else if([(UISegmentedControl*)sender selectedSegmentIndex] == 1) {
        [self.standardDefaults setInteger:AutocorectionEditDistance forKey:kAutocompetionType];
    }
    else{
        [self.standardDefaults setInteger:AutocorectionTypeNGram forKey:kAutocompetionType];
    }
}

@end
