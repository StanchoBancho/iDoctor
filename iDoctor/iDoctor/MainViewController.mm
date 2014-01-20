//
//  MainViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/31/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Medicine.h"

#import "Constants.h"
#include <string>
#include <set>
#import "TwoThreeTree.h"

#import "MainViewController.h"
#import "MedicineDetailViewController.h"
#import "AutocorectionViewController.h"
#import "AutocompletionViewController.h"
#import "NotesViewController.h"
#import "SettingsViewController.h"
#import "MedicineCell.h"
#import "RecipeShareViewController.h"


#define kAutocorectionCheckDeltaTime 5.0

@interface MainViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, AutocorectionTypingHelper, AutocompletionTypeHelper, MedicineCellProtocol, NotesHandler>
{
    
}
@property (nonatomic, strong) CoreDataManager* sharedManager;

@property (nonatomic, strong) NSMutableArray* choosedMedicineNames;
@property (nonatomic, strong) NSMutableString* typedText;
@property (nonatomic, strong) NSDictionary* currentlyEditingMedicine;
@property (nonatomic, strong) NSIndexPath* currentlyEditingIndexPath;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) AutocorectionViewController* autocorectionViewController;
@property (nonatomic, strong) AutocompletionViewController* autocompletionViewController;

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITextField* textField;
@property (nonatomic, strong) NSUserDefaults* standartsDefaults;

@property (nonatomic, strong) UIPopoverController *settingsPopover;

@end

@implementation MainViewController

#pragma mark - View Lifecycle

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
    UIBarButtonItem* allMedicinesButton = [[UIBarButtonItem alloc] initWithTitle:@"A-Z" style:UIBarButtonItemStylePlain target:self action:@selector(viewAllMedicinesButtonPressed:)];
    UIBarButtonItem* fixedSpace =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:30];
    UIBarButtonItem* shareScreenButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(shareRecipeButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[shareScreenButton, fixedSpace, allMedicinesButton];
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
    [request setPropertiesToFetch:@[kMedicineNameKey]];
    NSError *error;
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error || array == nil){
        NSLog(@"We do not have any medicines or theres is an error when we fetch them :%@", error);
    }
    else{
        //create tree
        vector<string> allMedicineNames;
        TwoThreeTree* tree = new TwoThreeTree();
        NGramsOverlap* ngramOverlap = new NGramsOverlap();
        set<string>allMedicineNamesWords;
        for(NSDictionary* m in array){
            if(m[kMedicineNameKey] == nil || [m[kMedicineNameKey] isEqualToString:@""]){
                NSLog(@"There is existing medicine");
            }
            string cpp_str([m[kMedicineNameKey] UTF8String], [m[kMedicineNameKey] lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            tree->insertData(cpp_str);
            allMedicineNames.push_back(cpp_str);
            
            //create ngramoverlap structure
            NSArray* allWordsOfTheMedicine = [((NSString*)m[kMedicineNameKey]).lowercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            for (NSString* word in allWordsOfTheMedicine) {
                if(![word isEqualToString:@""]){
                    string cpp_word([word UTF8String], [word lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
                    if(allMedicineNamesWords.count(cpp_str) == 0){
                        allMedicineNamesWords.insert(cpp_word);
                        ngramOverlap->insertWordInNGramTree(cpp_word);
                    }
                }
            }
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
        NSLog(@"We do not have such medicine :%@", error);
        return NO;
    }
    return YES;
}

-(void)handleMedicine:(NSString*)medicineTitle isItExistingOne:(BOOL)isExisting
{
    NSDictionary* newObject = @{kMedicineNameKey:medicineTitle, kMedicineIsExistingKey:@(isExisting)};
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


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.autocompletionViewController.view setHidden:YES];
    [self.autocorectionViewController.view setHidden:YES];
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
    MedicineCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MedicineCell"];
    NSString* medicineTitle = [self.choosedMedicineNames[indexPath.row] objectForKey:kMedicineNameKey];
    cell.scrollViewLabel.text = medicineTitle;

    
    NSString* medicineNotesTitle = [self.choosedMedicineNames[indexPath.row] objectForKey:kMedicineNoteKey];
    cell.scrollViewNotesLabel.text = medicineNotesTitle;
    
    cell.delegate = self;
    BOOL isExisting = [[self.choosedMedicineNames[indexPath.row] objectForKey:kMedicineIsExistingKey] boolValue];
    if (isExisting) {
        cell.hasAccessoryView = YES;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else{
        cell.hasAccessoryView = NO;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* pressedCell = [tableView cellForRowAtIndexPath:indexPath];
    if(pressedCell.accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if(tableView == self.tableView){
            BOOL isExisting = [[self.choosedMedicineNames[indexPath.row] objectForKey:kMedicineIsExistingKey] boolValue];
            if (isExisting) {
                //fetch the existing medicine
                NSManagedObjectContext* context = self.sharedManager.document.managedObjectContext;
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Medicine" inManagedObjectContext:context];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:entityDescription];
                NSString* medicineTitle = [self.choosedMedicineNames[indexPath.row] objectForKey:kMedicineNameKey];
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
                        [detailViewController setMedicineName:selectedMedicine.name];
                        [self.navigationController pushViewController:detailViewController animated:YES];
                    }
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
        SettingsViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        
        self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:myController];
    }
    [self.settingsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(IBAction)viewAllMedicinesButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"PresentAllMedicineScreen" sender:sender];
}

-(IBAction)shareRecipeButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"pushRecipeShareScreen" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushRecipeShareScreen"]){
        [(RecipeShareViewController*)segue.destinationViewController setMedicines:self.choosedMedicineNames];
    }
}

#pragma mark - MedicineCell Delegate methods

-(void)deleteButtonPressedForCell:(MedicineCell*)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [self.choosedMedicineNames removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)addEditNoteButtonPressedForCell:(MedicineCell*)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    self.currentlyEditingMedicine = [self.choosedMedicineNames objectAtIndex:indexPath.row];
    self.currentlyEditingIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSString* medicine = [self.currentlyEditingMedicine objectForKey:kMedicineNameKey];
    NSString* medicineNotes = [self.currentlyEditingMedicine objectForKey:kMedicineNoteKey];
    
    NotesViewController* notesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"notesViewController"];
    notesViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [notesViewController setDelegate:self];
    [notesViewController setMedicineTitle:medicine];
    [notesViewController setMedicineNotes:medicineNotes];
    [self presentViewController:notesViewController animated:YES completion:^{
       // [notesViewController.notesTextView becomeFirstResponder];
    }];
}

#pragma mark - NotesHandler Delegate methods

-(void)setNotesText:(NSString *)noteText
{
    [self.choosedMedicineNames replaceObjectAtIndex:self.currentlyEditingIndexPath.row withObject:@{kMedicineNoteKey: noteText, kMedicineNameKey: [self.currentlyEditingMedicine objectForKey:kMedicineNameKey], kMedicineIsExistingKey: [self.currentlyEditingMedicine objectForKey:kMedicineIsExistingKey]}];

    self.currentlyEditingMedicine = nil;

    [self.tableView reloadRowsAtIndexPaths:@[self.currentlyEditingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.currentlyEditingIndexPath = nil;

}

@end

