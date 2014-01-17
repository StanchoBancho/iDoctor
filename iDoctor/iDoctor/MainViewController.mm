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
#import "Constants.h"
#import "SettingsViewController.h"
#include <string>
#include <set>

#define kAutocorectionCheckDeltaTime 5.0

@interface MainViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, AutocorectionDataProviderAndPresenter>
{
    TwoThreeTree* tree;
    vector<string> allMedicineNames;
}
@property (nonatomic, strong) CoreDataManager* sharedManager;

@property (nonatomic, strong) NSMutableArray* suggestedMedicineNames;
@property (nonatomic, strong) NSMutableArray* choosedMedicineNames;
@property (nonatomic, strong) NSMutableString* typedText;
@property (nonatomic, assign) CFAbsoluteTime lastTimeTextIsEntered;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) AutocorectionViewController* autocorectionViewController;

@property (nonatomic, strong) IBOutlet UITableView* suggestionsTableView;
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

    [self setupAutocorectionPresentation];
    [self loadTree];

	
    [self.suggestionsTableView.layer setCornerRadius:2.0];
    [self.suggestionsTableView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.suggestionsTableView.layer setBorderWidth:1.0];
    
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

-(void)dealloc
{
    delete tree;
}

#pragma mark - Initialization

-(void)setupAutocorectionPresentation
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
        tree = new TwoThreeTree();
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
    }
}

#pragma mark - Autocompletion methods

-(void)showApropriateSuggestionsUsing23TreeSearch:(NSString*)typedText
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    self.suggestedMedicineNames = [NSMutableArray array];
    if([typedText isEqualToString:@""]){
        [self.suggestionsTableView setHidden:YES];
    }
    else{
        [self.suggestionsTableView setHidden:NO];
        
        string cpp_str([typedText UTF8String], [typedText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        vector<string> result = tree->findDataWithPrefix(cpp_str);
        
        for (int i = 0; i < result.size(); i++) {
            NSString* medicineName = [NSString stringWithCString: result[i].c_str() encoding:NSUTF8StringEncoding];
            [self.suggestedMedicineNames addObject:medicineName];
        }
        //get the suggestion strings for typedText and put them in the self.suggestedMedicineNames
    }
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Time needed for autocompletion with 2-3 TREE SEARCH is %f", endTime - startTime);
    [self.suggestionsTableView reloadData];
}

-(void)showApropriateSuggestionsUsingLinearSearch:(NSString*)typedText
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    self.suggestedMedicineNames = [NSMutableArray array];
    if([typedText isEqualToString:@""]){
        [self.suggestionsTableView setHidden:YES];
    }
    else{
        [self.suggestionsTableView setHidden:NO];
        
        string typed_cpp_string([typedText UTF8String], [typedText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        std::transform(typed_cpp_string.begin(), typed_cpp_string.end(), typed_cpp_string.begin(), ::tolower);
        
        for (int i = 0; i < allMedicineNames.size(); i++) {
            string medicineName = allMedicineNames[i];
            std::transform(medicineName.begin(), medicineName.end(), medicineName.begin(), ::tolower);
            if(medicineName.find(typed_cpp_string) == 0){
                NSString* medicineName = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
                [self.suggestedMedicineNames addObject:medicineName];
            }
        }
        //get the suggestion strings for typedText and put them in the self.suggestedMedicineNames
    }
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Time needed for autocompletion with LINEAR SEARCH is %f", endTime - startTime);
    [self.suggestionsTableView reloadData];
}


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
    [self.suggestionsTableView setHidden:YES];
    [self.autocorectionViewController.view setHidden:YES];
    
    [self.tableView reloadData];
    [self.textField resignFirstResponder];
}

#pragma mark - AutocorectionDataProviderAndPresenter methods

-(void)presentAutocorectionViewController
{
    [self.autocorectionViewController.view setHidden:NO];
}

-(void)hideAutocorectionViewController
{
    [self.autocorectionViewController.view setHidden:YES];
}

-(NSString *)typedTextForAutocorrection
{
    return self.typedText;
}

-(void)replaceWrongWords:(NSString *)wrongWord withAutocorectedWords:(NSString *)autocorectedWord
{
    [self.typedText replaceOccurrencesOfString:wrongWord withString:autocorectedWord options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.typedText.length)];
    self.textField.text = self.typedText;
    
    if([self.standartsDefaults integerForKey:kAutocompetionType] == AutocompetionType23Tree){
        [self showApropriateSuggestionsUsing23TreeSearch:self.typedText];
    }
    else{
        [self showApropriateSuggestionsUsingLinearSearch:self.typedText];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //auto completion
    [self.typedText replaceCharactersInRange:range withString:string];
    
    if([self.standartsDefaults integerForKey:kAutocompetionType] == AutocompetionType23Tree){
        [self showApropriateSuggestionsUsing23TreeSearch:self.typedText];
    }
    else{
        [self showApropriateSuggestionsUsingLinearSearch:self.typedText];
        
    }
    
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
    if (tableView == self.suggestionsTableView) {
        return self.suggestedMedicineNames.count;
    }
    else if(tableView == self.tableView){
        return self.choosedMedicineNames.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.suggestionsTableView){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestedMedicineCell"];
        NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
        cell.textLabel.text = medicineTitle;
        return cell;
    }
    else if(tableView == self.tableView)
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
    return nil;
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
    else if(tableView == self.suggestionsTableView){
        //chose selected medicine
        NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
        [self handleMedicine: medicineTitle isItExistingOne:YES];
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

