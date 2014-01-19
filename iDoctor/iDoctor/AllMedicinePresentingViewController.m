//
//  ViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "AllMedicinePresentingViewController.h"
#import "URLs.h"
#import "LatestURLs.h"
#import "TFHpple.h"
#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Medicine.h"
#import "MedicineDetailViewController.h"

@interface AllMedicinePresentingViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end

@implementation AllMedicinePresentingViewController

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != _fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        _fetchedResultsController.delegate = self;
        
        if (_fetchedResultsController) {
            NSError *error;
            [_fetchedResultsController performFetch:&error];
            if (error) {
                NSLog(@"setFetchedResultsController: %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
            }
        }
    }
    
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //         [self startFetching];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Medicine"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[ sortDescriptor ];
    [request setFetchBatchSize:20];
    
    UIManagedDocument* document = [CoreDataManager sharedManager].document;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:document.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Creating / updating the database

-(void)startFetching
{
    for(int i = 0; i < 10184; i++)
    {
        NSString* url = kLatestURLs[i];
        if ([[url substringToIndex:33] isEqualToString:@"http://fdb.rxlist.com/drugs/drug-"]){
            [self downloadAndParseTheDataForUrl:url shouldSave:(i % 100 == 0)];
        }
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

#pragma mark - TableView Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger result = [[self.fetchedResultsController sections] count];
    return result;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger result = [sectionInfo numberOfObjects];
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"medicineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Medicine *medicine = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = medicine.name;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DetailViewSegue"]){
        MedicineDetailViewController* detailViewController = segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Medicine* selectedMedicine = [self.fetchedResultsController objectAtIndexPath:path];
        [detailViewController setMedicineUrl:selectedMedicine.descriptionUrl];
        [detailViewController setMedicineName:selectedMedicine.name];
    }
}


#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
