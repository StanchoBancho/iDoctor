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


@interface MainViewController ()<UITextFieldDelegate>
{
    TwoThreeTree* tree;
}
@property (nonatomic, strong) CoreDataManager* sharedManager;

@end

@implementation MainViewController

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
    self.sharedManager = [CoreDataManager sharedManager];
    [self.sharedManager setupDocument:^(UIManagedDocument *document, NSError *error) {
        [self loadTree];
    }];
	// Do any additional setup after loading the view.
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

#pragma mark - UITextFieldDelegate methods

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


@end
