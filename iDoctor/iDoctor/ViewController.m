//
//  ViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "ViewController.h"
#import "URLs.h"
#import "TFHpple.h"
#import "CoreDataManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[CoreDataManager sharedManager] setupDocument:^(UIManagedDocument *document, NSError *error) {
        if(!error && document){
            [self startFetching];
        }
    }];
}

-(void)startFetching
{
    for(int i = 0; i < 10763; i++)
    {
        
//        if([CoreDataManager sharedManager].document.documentState != UIDocumentStateNormal){
//            i--;
//            continue;
//        }
        
        NSString* url = kURLs[i];
        if ([[url substringToIndex:33] isEqualToString:@"http://fdb.rxlist.com/drugs/drug-"]){
            [self downloadAndParseTheDataForUrl:url shouldSave:(i % 100 == 0)];
        }
//        if(i % 10 == 0){
//            NSLog(@"START SAVING");
//            
//            [[CoreDataManager sharedManager].document saveToURL:[CoreDataManager sharedManager].document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
//                if(success){
//                    NSLog(@"SAVING SUCCESSFULL");
//                }
//                else{
//                    NSLog(@"ERROR ON SAVING FOR %d", i);
//                }
//            }];
//        }
    }
}

-(void)downloadAndParseTheDataForUrl:(NSString*)url shouldSave:(BOOL)shouldSave
{
    //download
    NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *medicineUrl = [NSURL URLWithString:webStringURL];
    NSData *medicineHtmlData = [NSData dataWithContentsOfURL:medicineUrl];
    
    
    //parse
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:medicineHtmlData];
    NSString *tutorialsXpathQueryString = @"//div[@id='fdbMonograph']/h1";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    TFHppleElement* node = tutorialsNodes.count?tutorialsNodes[0]:nil;
    if(node){
        TFHppleElement* firstChild = node.firstChild;
        if(firstChild){
            NSString* medicineName = firstChild.content;
            if(medicineName){
                //store or update if necessary
                [[CoreDataManager sharedManager] updateMedicineWithName:medicineName andURL:url shouldSave:shouldSave];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
