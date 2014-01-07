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

#define kAutocorectionCheckDeltaTime 5.0

@interface MainViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    TwoThreeTree* tree;
    vector<string> allMedicineNames;
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

-(void)showApropriateSuggestionsForString:(NSString*)typedText
{
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
    [self.tableView reloadData];
    [self.textField resignFirstResponder];
}

#pragma mark - Autocorection methods

-(void)tryToAutoCorrectTheTypedText
{
    if([self.typedText isEqualToString:@""]){
        [self.autocorectionTableView setHidden:YES];
        return;
    }
    string cpp_typed_str([self.typedText UTF8String], [self.typedText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    int minEditDistance = 1000;
    self.autocorectedMedicineNames = [[NSMutableArray alloc] init];
    for (int i = 0; i < allMedicineNames.size(); i++) {
        int current_distance = edit_distance(cpp_typed_str, allMedicineNames[i]);
        if(current_distance < minEditDistance){
            NSString* string = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
            self.autocorectedMedicineNames = [NSMutableArray arrayWithObject:string];
            minEditDistance = current_distance;
        }
        else if(current_distance == minEditDistance){
            NSString* string = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
            [self.autocorectedMedicineNames addObject:string];
        }
    }
    if(self.autocorectedMedicineNames.count > 0){
        [self.autocorectionTableView setHidden:NO];
        [self.autocorectionTableView reloadData];
    }
    else{
        [self.autocorectionTableView setHidden:YES];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.typedText replaceCharactersInRange:range withString:string];
    [self showApropriateSuggestionsForString:self.typedText];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(tryToAutoCorrectTheTypedText) userInfo:nil repeats:NO];

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
    else{
        //chose selected medicine
        NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
        [self handleMedicine: medicineTitle isItExistingOne:YES];
    }
}

#pragma mark - Action methods

-(IBAction)addButtonPressed:(id)sender
{
    string cpp_str([self.textField.text UTF8String], [self.textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    
    vector<string> words = ngramOverlap->getNearestWordsForWord(cpp_str);
    
    NSCharacterSet* whiteSpaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString* typedText = [self.textField.text stringByTrimmingCharactersInSet:whiteSpaces];
    if (![typedText isEqualToString:@""]) {
        BOOL isExisting = [self isMedicineExising: typedText];
        [self handleMedicine:typedText isItExistingOne:isExisting];
    }
}

@end

