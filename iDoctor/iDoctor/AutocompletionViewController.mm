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
    MedicineFinder* tree;
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

-(void)setTwoThreeTreeDataStructure:(MedicineFinder*) twoThreeTree
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
        vector<string> result = tree->getMedicinesForTypedText(cpp_str);
        
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
            vector<string> tokens = split(medicineName);
            
            for (int j = 0; j < tokens.size(); ++j) {
                trim(tokens[j]);
                if (checkPrefix(typed_cpp_string, tokens[j])){
                    NSString* medicineName = [NSString stringWithCString:allMedicineNames[i].c_str() encoding:NSUTF8StringEncoding];
                    [self.suggestedMedicineNames addObject:medicineName];
                    break;
                }
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

#pragma marks - Utilities

// trim from start
static inline std::string &ltrim(std::string &s) {
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
    return s;
}

// trim from end
static inline std::string &rtrim(std::string &s) {
    s.erase(std::find_if(s.rbegin(), s.rend(), std::not1(std::ptr_fun<int, int>(std::isspace))).base(), s.end());
    return s;
}

// trim from both ends
static inline std::string &trim(std::string &s) {
    return ltrim(rtrim(s));
}

vector<string> split(string text) {
    unsigned long start = 0, end = 0;
    vector<string> tokens;
    while ((end = text.find(' ', start)) != string::npos) {
        tokens.push_back(text.substr(start, end - start));
        start = end + 1;
    }
    tokens.push_back(text.substr(start));
    return tokens;
}

bool checkPrefix(string prefix, string str) {
    if (str == "") {
        return false;
    }
    string strPrefix = str.substr(0, prefix.length());
    if (prefix.compare(strPrefix) == 0) {
        return true;
    }
    
    return false;
}

@end
