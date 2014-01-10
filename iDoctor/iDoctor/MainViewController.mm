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
#import "EditDistance.h"
#import "NGramsOverlap.h"
#import "Constants.h"
#import "SettingsViewController.h"


#define kAutocorectionCheckDeltaTime 5.0

@interface MainViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    TwoThreeTree* tree;
    vector<string> allMedicineNames;
    NGramsOverlap *ngramOverlap;
    dispatch_queue_t workingQueue;
}
@property (nonatomic, strong) CoreDataManager* sharedManager;

@property (nonatomic, strong) NSMutableArray* autocorectedMedicineNames;
@property (nonatomic, strong) NSMutableArray* suggestedMedicineNames;
@property (nonatomic, strong) NSMutableArray* choosedMedicineNames;
@property (nonatomic, strong) NSMutableString* typedText;
@property (nonatomic, assign) CFAbsoluteTime lastTimeTextIsEntered;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) IBOutlet UITableView* autocorectionTableView;
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
    [self loadTree];
	
    [self.suggestionsTableView.layer setCornerRadius:2.0];
    [self.suggestionsTableView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.suggestionsTableView.layer setBorderWidth:1.0];
    
    [self.autocorectionTableView.layer setCornerRadius:2.0];
    [self.autocorectionTableView.layer setBorderColor:[[UIColor redColor] CGColor]];
    [self.autocorectionTableView.layer setBorderWidth:1.0];
    
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

#pragma mark - Autocompletion methods

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
        tree = new TwoThreeTree();
        ngramOverlap = new NGramsOverlap();
        for(NSDictionary* m in array){
            if(m[@"name"] == nil || [m[@"name"] isEqualToString:@""]){
                NSLog(@"a sega");
                
            }
            string cpp_str([m[@"name"] UTF8String], [m[@"name"] lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            allMedicineNames.push_back(cpp_str);
            tree->insertData(cpp_str);
            ngramOverlap->insertWordInNGramTree(cpp_str);
        }
        //        tree->insertData("aaa");
        //        tree->insertData("aba");
        //
        //        tree->insertData("aab");
        //        tree->insertData("bbb");
        //        tree->insertData("bbc");
        //        tree->insertData("aac");
        //        tree->insertData("aa%");
        //        tree->insertData("aak");
        
        
    }
    
    //float c = jaccardIndex("abcdfghij", "abcd00");
    
}

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
    [self.autocorectionTableView setHidden:YES];
    
    [self.tableView reloadData];
    [self.textField resignFirstResponder];
}

#pragma mark - Autocorection methods

-(void)tryToAutoCorrectTheTypedText
{
    if(!workingQueue){
        workingQueue = dispatch_queue_create("AutocorectionQueue", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(workingQueue, ^{
        string cpp_typed_str([self.typedText UTF8String], [self.typedText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        self.autocorectedMedicineNames = [[NSMutableArray alloc] init];

        if ([self.standartsDefaults integerForKey:kAutocorectionType] == AutocorectionEditDistance) {

            //start checking for autocorection match
            if([self.typedText isEqualToString:@""]){
                [self.autocorectionTableView setHidden:YES];
                return;
            }
            int minEditDistance = 1000;
            for (int i = 0; i < allMedicineNames.size(); i++) {
                int current_distance = edit_distance(cpp_typed_str, allMedicineNames[i]);
                BOOL areTypedTextCloseToExistingWord = current_distance <= cpp_typed_str.length() / 3;
                
                if(current_distance < minEditDistance && areTypedTextCloseToExistingWord){
                    NSString* string = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
                    self.autocorectedMedicineNames = [NSMutableArray arrayWithObject:string];
                    minEditDistance = current_distance;
                }
                else if(current_distance == minEditDistance && areTypedTextCloseToExistingWord){
                    NSString* string = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
                    [self.autocorectedMedicineNames addObject:string];
                }
            }
        }
        else if([self.standartsDefaults integerForKey:kAutocorectionType] == AutocorectionTypeNGram){
            vector<pair<string, float> > words = ngramOverlap->getNearestWordsForWord(cpp_typed_str);
            for(int i = 0; i < words.size(); i++){
                NSString* string = [NSString stringWithCString:words[i].first.c_str() encoding:NSUTF8StringEncoding];
                [self.autocorectedMedicineNames addObject:string];
            }
        }
        else{
            
        }
        
        //update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.autocorectedMedicineNames.count > 0){
                [self.autocorectionTableView setHidden:NO];
                [self.autocorectionTableView reloadData];
            }
            else{
                [self.autocorectionTableView setHidden:YES];
            }
        });
        
    });
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
        [self.autocorectionTableView setHidden:YES];
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tryToAutoCorrectTheTypedText) userInfo:nil repeats:NO];
    
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
    else{
        return self.autocorectedMedicineNames.count;
    }
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
    else{
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AutocorectedMedicineCell"];
        NSString* medicineTitle = self.autocorectedMedicineNames[indexPath.row];
        cell.textLabel.text = medicineTitle;
        return cell;
    }
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
    else {
        //chose autocorected medicine
        NSString* medicineTitle = self.autocorectedMedicineNames[indexPath.row];
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

