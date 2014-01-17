//
//  MainViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/31/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "MainViewController.h"
#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Medicine.h"
#import "TwoThreeTree.h"
#import "MedicineDetailViewController.h"
#import "AutocorectionViewController.h"
#import "AutocompletionViewController.h"
#import "Constants.h"
#import "SettingsViewController.h"
#include <string>
#include <set>

#define kAutocorectionCheckDeltaTime 5.0

@interface MainViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, AutocorectionTypingHelper, AutocompletionTypeHelper>
{
    
}
@property (nonatomic, strong) CoreDataManager* sharedManager;

@property (nonatomic, strong) NSMutableArray* suggestedMedicineNames;
@property (nonatomic, strong) NSMutableArray* choosedMedicineNames;
@property (nonatomic, strong) NSMutableString* typedText;
@property (nonatomic, assign) CFAbsoluteTime lastTimeTextIsEntered;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) AutocorectionViewController* autocorectionViewController;
@property (nonatomic, strong) AutocompletionViewController* autocompletionViewController;

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITextField* textField;
@property (nonatomic, strong) NSUserDefaults* standartsDefaults;

@property (nonatomic, strong) UIPopoverController *settingsPopover;

@end

@implementation MainViewController

#pragma mark - view lifecycle

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
    self.choosedMedicineNames = [NSMutableArray array];
    self.typedText = [[NSMutableString alloc] init];
    
    [self setupAutocorectionViewController];
    [self setupAutocompletionViewController];
    [self loadTree];
    
    self.standartsDefaults = [NSUserDefaults standardUserDefaults];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization

-(void)setupAutocorectionViewController
{
    self.autocorectionViewController = [[AutocorectionViewController alloc] initWithNibName:@"AutocorectionViewController" bundle:nil];
    [self.autocorectionViewController setDelegate:self];
    [self addChildViewController:self.autocorectionViewController];
    [self.view addSubview:self.autocorectionViewController.view];
    
    NSDictionary *views = @{@"v1" : self.autocorectionViewController.view, @"v2" : self.textField};
    [self.autocorectionViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v1(280@1000)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1(450@1000)]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v2]-6-[v1]" options:0 metrics:nil views:views]];
    [self.autocorectionViewController.view setHidden:YES];
    [self.autocorectionViewController didMoveToParentViewController:self];
}

-(void)setupAutocompletionViewController
{
    self.autocompletionViewController = [[AutocompletionViewController alloc] initWithNibName:@"AutocompletionViewController" bundle:nil];
    [self.autocompletionViewController setDelegate:self];
    
    [self addChildViewController:self.autocompletionViewController];
    [self.view addSubview:self.autocompletionViewController.view];
    
    NSDictionary *views = @{@"v1" : self.autocompletionViewController.view, @"v2" : self.textField};
    [self.autocompletionViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v1(280@1000)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1(450@1000)]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[v1]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v2]-6-[v1]" options:0 metrics:nil views:views]];
    [self.autocompletionViewController.view setHidden:YES];
    [self.autocompletionViewController didMoveToParentViewController:self];
}

- (void)loadTree
{
    // NOTE: if str is nil this will produce an empty C++ string
    // instead of dereferencing the NULL pointer from UTF8String.
    
    //fetch all medicines
    self.sharedManager = [CoreDataManager sharedManager];
    NSManagedObjectContext* context = self.sharedManager.document.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Medicine" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setResultType:NSDictionaryResultType];
    
    [request setEntity:entityDescription];
    [request setPropertiesToFetch:@[@"name"]];
    NSError *error;
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error || array == nil){
        NSLog(@"GOLQM ERROR :%@", error);
    }
    else{
        //create tree
        // @autoreleasepool {
        vector<string> allMedicineNames;
        TwoThreeTree* tree = new TwoThreeTree();
        NGramsOverlap* ngramOverlap = new NGramsOverlap();
        set<string>allMedicineNamesWords;
        for(NSDictionary* m in array){
            if(m[@"name"] == nil || [m[@"name"] isEqualToString:@""]){
                NSLog(@"a sega");
                
            }
            string cpp_str([m[@"name"] UTF8String], [m[@"name"] lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            tree->insertData(cpp_str);
            allMedicineNames.push_back(cpp_str);
            
            //create ngramoverlap structure
            NSArray* allWordsOfTheMedicine = [((NSString*)m[@"name"]).lowercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            for (NSString* word in allWordsOfTheMedicine) {
                if(![word isEqualToString:@""]){
                    string cpp_word([word UTF8String], [word lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
                    if(allMedicineNamesWords.count(cpp_str) == 0){
                        allMedicineNamesWords.insert(cpp_word);
                        ngramOverlap->insertWordInNGramTree(cpp_word);
                    }
                }
            }
            // }
        }
        [self.autocorectionViewController setNGramDataStructure:ngramOverlap];
        [self.autocorectionViewController setAllMedicineNamesWords:allMedicineNamesWords];
        ngramOverlap = NULL;
        
        [self.autocompletionViewController setTwoThreeTreeDataStructure:tree];
        [self.autocompletionViewController setAllMedicineNames:allMedicineNames];
    }
}

#pragma mark - AutocompletionTypingHelper methods

-(BOOL)isMedicineExising:(NSString*)medicineTitle
{
    NSManagedObjectContext* context = self.sharedManager.document.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Medicine" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name like %@",medicineTitle]];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error || array == nil || array.count != 1){
        NSLog(@"GOLQM ERROR :%@", error);
        return NO;
    }
    return YES;
}

-(void)handleMedicine:(NSString*)medicineTitle isItExistingOne:(BOOL)isExisting
{
    NSDictionary* newObject = @{@"name":medicineTitle, @"isExisting":@(isExisting)};
    [self.choosedMedicineNames insertObject:newObject atIndex:0];
    self.typedText =  [NSMutableString string];
    [self.textField setText:@""];
    [self.autocompletionViewController.view setHidden:YES];
    [self.autocorectionViewController.view setHidden:YES];
    
    [self.tableView reloadData];
    [self.textField resignFirstResponder];
}

-(void)handleAutocompletion:(NSString*)autocompletedText
{
    [self handleMedicine: autocompletedText isItExistingOne:YES];
}

#pragma mark - TypingHelper methods

-(void)presentTypingHelperViewController:(UIViewController*)typeHelperViewController
{
    [typeHelperViewController.view setHidden:NO];
}

-(void)hideTypingHelperViewController:(UIViewController*)typeHelperViewController
{
    [typeHelperViewController.view setHidden:YES];
}

-(NSString *)typedTextForTypingHelper
{
    return self.typedText;
}

#pragma mark - AutocorectionTypingHelper methods

-(void)replaceWrongWords:(NSString *)wrongWord withAutocorectedWords:(NSString *)autocorectedWord
{
    [self.typedText replaceOccurrencesOfString:wrongWord withString:autocorectedWord options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.typedText.length)];
    self.textField.text = self.typedText;
    
    [self.autocompletionViewController tryToAutoCompleteTheTypedText];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.typedText replaceCharactersInRange:range withString:string];
    
    //auto completion
    [self.autocompletionViewController tryToAutoCompleteTheTypedText];
    
    //auto correction
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength < textField.text.length){
        //we are deleting => hide the auto correction
        [self.autocorectionViewController.view setHidden:YES];
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.autocorectionViewController selector:@selector(tryToAutoCorrectTheTypedText) userInfo:nil repeats:NO];
    
    return YES;
}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.choosedMedicineNames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MedicineCell"];
    NSString* medicineTitle = [self.choosedMedicineNames[indexPath.row] objectForKey:@"name"];
    cell.textLabel.text = medicineTitle;
    BOOL isExisting = [[self.choosedMedicineNames[indexPath.row] objectForKey:@"isExisting"] boolValue];
    if (isExisting) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == self.tableView){
        BOOL isExisting = [[self.choosedMedicineNames[indexPath.row] objectForKey:@"isExisting"] boolValue];
        if (isExisting) {
            //fetch the existing medicine
            NSManagedObjectContext* context = self.sharedManager.document.managedObjectContext;
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Medicine" inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            NSString* medicineTitle = [self.choosedMedicineNames[indexPath.row] objectForKey:@"name"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"name like %@", medicineTitle]];
            NSError *error;
            NSArray *array = [context executeFetchRequest:request error:&error];
            if (error || array == nil || array.count < 1){
                NSLog(@"GOLQM ERROR :%@", error);
            }
            else{
                Medicine * selectedMedicine = [array objectAtIndex:0];
                if(selectedMedicine && selectedMedicine.descriptionUrl){
                    MedicineDetailViewController* detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MedicineDetailViewController"];
                    [detailViewController setMedicineUrl:selectedMedicine.descriptionUrl];
                    [self.navigationController pushViewController:detailViewController animated:YES];
                }
            }
        }
    }
}

#pragma mark - Action methods

-(IBAction)addButtonPressed:(id)sender
{
    NSCharacterSet* whiteSpaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString* typedText = [self.textField.text stringByTrimmingCharactersInSet:whiteSpaces];
    if (![typedText isEqualToString:@""]) {
        BOOL isExisting = [self isMedicineExising: typedText];
        [self handleMedicine:typedText isItExistingOne:isExisting];
    }
}

- (IBAction)settingsButtonTapped:(id)sender {
    if (self.settingsPopover.isPopoverVisible) {
        [self.settingsPopover dismissPopoverAnimated:YES];
        return;
    } else if (!self.settingsPopover) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
        SettingsViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        
        self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:myController];
    }
    [self.settingsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

@end

