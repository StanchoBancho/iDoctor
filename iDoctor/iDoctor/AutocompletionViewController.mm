//
//  AutocompletionViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/17/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "AutocompletionViewController.h"
#import "Constants.h"

@interface AutocompletionViewController ()
{
    TwoThreeTree* tree;
    vector<string> allMedicineNames;
}
@property (nonatomic, strong) NSMutableArray* suggestedMedicineNames;
@property (nonatomic, strong) IBOutlet UITableView* suggestionsTableView;
@property (nonatomic, strong) NSString* typedText;
@property (nonatomic, strong) NSUserDefaults* standartsDefaults;

@end

@implementation AutocompletionViewController

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
    [self.view.layer setCornerRadius:6.0];
    [self.view.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.view.layer setBorderWidth:1.0];
    self.standartsDefaults = [NSUserDefaults standardUserDefaults];
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

#pragma mark - Setters

-(void)setTwoThreeTreeDataStructure:(TwoThreeTree*) twoThreeTree
{
    tree = twoThreeTree;
}

-(void)setAllMedicineNames:(vector<string>)_allMedicineNames
{
    allMedicineNames = _allMedicineNames;
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
        [self.suggestedMedicineNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString*)obj1 compare:(NSString*)obj2 options:NSCaseInsensitiveSearch];
        }];
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
            if(medicineName.find(typed_cpp_string) != -1){
                NSString* medicineName = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
                [self.suggestedMedicineNames addObject:medicineName];
            }
        }
        //get the suggestion strings for typedText and put them in the self.suggestedMedicineNames
        [self.suggestedMedicineNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString*)obj1 compare:(NSString*)obj2];
        }];
    }
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Time needed for autocompletion with LINEAR SEARCH is %f", endTime - startTime);
    [self.suggestionsTableView reloadData];
}

-(void)tryToAutoCompleteTheTypedText
{
    self.typedText = nil;
    if([self.delegate respondsToSelector:@selector(typedTextForTypingHelper)]){
        self.typedText = [[self.delegate typedTextForTypingHelper] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if(!self.typedText){
        if([self.delegate respondsToSelector:@selector(hideTypingHelperViewController:)]){
            [self.delegate hideTypingHelperViewController:self];
        }
        return;
    }
    
    if([self.standartsDefaults integerForKey:kAutocompetionType] == AutocompetionType23Tree){
        [self showApropriateSuggestionsUsing23TreeSearch:self.typedText];
    }
    else{
        [self showApropriateSuggestionsUsingLinearSearch:self.typedText];
    }
    if(self.suggestedMedicineNames.count > 0){
        if ([self.delegate respondsToSelector:@selector(presentTypingHelperViewController:)]) {
            [self.delegate presentTypingHelperViewController:self];
        }
        [self.suggestionsTableView reloadData];
    }
    else{
        if ([self.delegate respondsToSelector:@selector(hideTypingHelperViewController:)]) {
            [self.delegate hideTypingHelperViewController:self];
        }
    }

}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestedMedicineNames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* tableViewCellIdentifier = @"SuggestedMedicineCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellIdentifier];
    }
    NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
    cell.textLabel.text = medicineTitle;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //chose selected medicine
    if ([self.delegate respondsToSelector:@selector(handleAutocompletion:)]) {
        NSString* medicineTitle = self.suggestedMedicineNames[indexPath.row];
        [self.delegate handleAutocompletion:medicineTitle];
    }
    if ([self.delegate respondsToSelector:@selector(hideTypingHelperViewController:)]) {
        [self.delegate hideTypingHelperViewController:self];
    }
}

@end
