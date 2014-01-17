//
//  AutocorectionViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/17/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "AutocorectionViewController.h"
#import "EditDistance.h"
#import "Constants.h"

@interface AutocorectionViewController ()
{
    set<string> allMedicineNamesWords;
    NGramsOverlap *ngramOverlap;
    dispatch_queue_t workingQueue;
}
@property (nonatomic, strong) IBOutlet UITableView* autocorectionTableView;
@property (nonatomic, strong) NSMutableArray* autocorectedMedicineNames;
@property (nonatomic, strong) NSString* typedText;
@property (nonatomic, strong) NSUserDefaults* standartsDefaults;

@end

@implementation AutocorectionViewController

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
    [self.view.layer setCornerRadius:6.0];
    [self.view.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.view.layer setBorderWidth:1.0];
    self.standartsDefaults = [NSUserDefaults standardUserDefaults];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters

-(void)setNGramDataStructure:(NGramsOverlap*)_ngramOverlap
{
    ngramOverlap = _ngramOverlap;
}
-(void)setAllMedicineNamesWords:(set<string>)_allMedicineNamesWords
{
    allMedicineNamesWords = _allMedicineNamesWords;
}

#pragma mark - Autocorection methods

-(void)populateAutoCorectionsWordsViaNgrams
{
    NSArray* allTypedWords = [self.typedText.lowercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString* word in allTypedWords) {
        if(![word isEqualToString:@""]){
            NSMutableArray* autocorectionForWord = [NSMutableArray array];
            string cpp_typed_word([word UTF8String], [word lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            vector<pair<string, float> > words = ngramOverlap->getNearestWordsForWord(cpp_typed_word);
            for(int i = 0; i < words.size(); i++){
                if(cpp_typed_word.compare(words[i].first) == 0){
                    autocorectionForWord = nil;
                    break;
                }
                NSString* string = [NSString stringWithCString:words[i].first.c_str() encoding:NSUTF8StringEncoding];
                [autocorectionForWord addObject:@{@"wrongWord": word, @"autocorection": string}];
            }
            [self.autocorectedMedicineNames addObjectsFromArray:autocorectionForWord];
        }
    }
}

-(void)populateAutoCorectionsWordsViaEdigDistance
{
    NSArray* allTypedWords = [self.typedText.lowercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString* word in allTypedWords) {
        if(![word isEqualToString:@""]){
            int minEditDistance = (int)word.length;
            string cpp_typed_word([word UTF8String], [word lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            
            NSMutableArray* autocorectionForWord = [NSMutableArray array];
            for (set<string>::iterator it=allMedicineNamesWords.begin(); it!=allMedicineNamesWords.end(); ++it){
                string existing_word = *it;
                if(existing_word.compare(cpp_typed_word) == 0){
                    autocorectionForWord = nil;
                    break;
                }
                int current_distance = edit_distance(cpp_typed_word, existing_word);
                BOOL areTypedTextCloseToExistingWord = current_distance <= existing_word.length() / 3;
                if(current_distance < minEditDistance && areTypedTextCloseToExistingWord){
                    NSString* existingWord = [NSString stringWithCString:existing_word.c_str() encoding:NSUTF8StringEncoding];
                    autocorectionForWord = [NSMutableArray arrayWithObject:@{@"wrongWord": word, @"autocorection": existingWord}];
                    minEditDistance = current_distance;
                }
                else if(current_distance == minEditDistance && areTypedTextCloseToExistingWord){
                    NSString* existingWord = [NSString stringWithCString:existing_word.c_str() encoding:NSUTF8StringEncoding];
                    [autocorectionForWord addObject:@{@"wrongWord": word, @"autocorection": existingWord}];
                }
            }
            [self.autocorectedMedicineNames addObjectsFromArray:autocorectionForWord];
        }
    }
}

-(void)tryToAutoCorrectTheTypedText
{
    self.typedText = nil;
    if([self.delegate respondsToSelector:@selector(typedTextForAutocorrection)]){
        self.typedText = [self.delegate typedTextForAutocorrection];
    }
    if(!self.typedText){
        if([self.delegate respondsToSelector:@selector(hideAutocorectionViewController)]){
            [self.delegate hideAutocorectionViewController];
        }
        return;
    }
    if(!workingQueue){
        workingQueue = dispatch_queue_create("AutocorectionQueue", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(workingQueue, ^{
        
        self.autocorectedMedicineNames = [[NSMutableArray alloc] init];
        
        if ([self.standartsDefaults integerForKey:kAutocorectionType] == AutocorectionEditDistance) {
            [self populateAutoCorectionsWordsViaEdigDistance];
        }
        else if([self.standartsDefaults integerForKey:kAutocorectionType] == AutocorectionTypeNGram){
            [self populateAutoCorectionsWordsViaNgrams];
        }
        
        //update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.autocorectedMedicineNames.count > 0){
                if ([self.delegate respondsToSelector:@selector(presentAutocorectionViewController)]) {
                    [self.delegate presentAutocorectionViewController];
                }
                [self.autocorectionTableView reloadData];
            }
            else{
                if ([self.delegate respondsToSelector:@selector(hideAutocorectionViewController)]) {
                    [self.delegate hideAutocorectionViewController];
                }
            }
        });
    });
}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autocorectedMedicineNames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AutocorectedMedicineCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AutocorectedMedicineCell"];
    }
    NSString* wrongWord =[self.autocorectedMedicineNames[indexPath.row] objectForKey:@"wrongWord"];
    NSString* autocorection =[self.autocorectedMedicineNames[indexPath.row] objectForKey:@"autocorection"];
    NSString* medicineTitle = [NSString stringWithFormat:@"%@ -> %@", wrongWord, autocorection];
    cell.textLabel.text = medicineTitle;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.delegate respondsToSelector:@selector(replaceWrongWords:withAutocorectedWords:)]){
        NSString* wrongWord =[self.autocorectedMedicineNames[indexPath.row] objectForKey:@"wrongWord"];
        NSString* autocorection =[self.autocorectedMedicineNames[indexPath.row] objectForKey:@"autocorection"];
        [self.delegate replaceWrongWords:wrongWord withAutocorectedWords:autocorection];
    }
    if ([self.delegate respondsToSelector:@selector(hideAutocorectionViewController)]) {
        [self.delegate hideAutocorectionViewController];
    }
}

@end
