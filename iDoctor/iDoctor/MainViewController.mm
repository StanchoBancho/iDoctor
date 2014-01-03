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

@interface MainViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    TwoThreeTree* tree;
}
@property (nonatomic, strong) CoreDataManager* sharedManager;

@property (nonatomic, strong) NSMutableArray* suggestedMedicineNames;
@property (nonatomic, strong) NSMutableArray* choosedMedicineNames;
@property (nonatomic, strong) NSMutableString* typedText;

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
    self.sharedManager = [CoreDataManager sharedManager];
    [self.sharedManager setupDocument:^(UIManagedDocument *document, NSError *error) {
        [self loadTree];
    }];
	
    [self.suggestionsTableView.layer setCornerRadius:2.0];
    [self.suggestionsTableView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.suggestionsTableView.layer setBorderWidth:1.0];
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

- (void)loadTree
{
    // NOTE: if str is nil this will produce an empty C++ string
    // instead of dereferencing the NULL pointer from UTF8String.
    
    //fetch all medicines
    NSManagedObjectContext* context = self.sharedManager.document.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Medicine" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error || array == nil){
        NSLog(@"GOLQM ERROR :%@", error);
    }
    else{
        //create tree
        tree = new TwoThreeTree();
        for(Medicine* m in array){
            if(m.name == nil || [m.name isEqualToString:@""]){
                NSLog(@"a sega");
                
            }
            string cpp_str([m.name UTF8String], [m.name lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            tree->insertData(cpp_str);
        }
    }
}

#pragma marl - Autocompletion methods

-(void)showApropriateSuggestionsForString:(NSString*)typedText
{
    if([typedText isEqualToString:@""]){
        [self.suggestionsTableView setHidden:YES];
    }
    else{
        [self.suggestionsTableView setHidden:NO];
    }
    
    //get the suggestion strings for typedText and put them in the self.suggestedMedicineNames
    
    [self.suggestionsTableView reloadData];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.typedText replaceCharactersInRange:range withString:string];
    [self showApropriateSuggestionsForString:self.typedText];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString* enteredText = textField.text;
    string cpp_str([enteredText UTF8String], [enteredText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    Node* node = tree->searchData(cpp_str);
    if(node){
        NSLog(@"we have match");
    }
    else{
        NSLog(@"we do not have match");
    }
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
    else{
        return self.choosedMedicineNames.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.suggestionsTableView){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MedicineCell"];
        NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
        cell.textLabel.text = medicineTitle;
        return cell;
    }
    else
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
                }
            }
        }
    }
    else{
        //chose selected medicine
        NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
        NSDictionary* newObject = @{@"name":medicineTitle, @"isExisting":@NO};
        [self.choosedMedicineNames insertObject:newObject atIndex:0];
        [self.textField setText:@""];
        [self.tableView reloadData];
    }
}



#pragma mark - Action methods

-(IBAction)addButtonPressed:(id)sender
{
    NSCharacterSet* whiteSpaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString* typedText = [self.textField.text stringByTrimmingCharactersInSet:whiteSpaces];
    if (![typedText isEqualToString:@""]) {
        NSDictionary* newObject = @{@"name":typedText, @"isExisting":@NO};
        [self.choosedMedicineNames insertObject:newObject atIndex:0];
        [self.textField setText:@""];
    }
}

@end
