//
//  CoreDataManager.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/12/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Medicine.h"

static NSInteger count = 0;

static CoreDataManager* sharedManager;
@interface CoreDataManager()

@property(nonatomic, copy) void(^setupCompletion)(UIManagedDocument* document, NSError *error);

@end

@implementation CoreDataManager

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)init
{
    if (sharedManager){
        return sharedManager;
    }
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Public methods

+ (CoreDataManager*)sharedManager
{
    if(!sharedManager){
        @synchronized(self){
            if(!sharedManager){
                sharedManager = [[super allocWithZone:NULL] init];
            }
        }
    }
    return sharedManager;
}


- (void)setupDocument:(void(^)(UIManagedDocument* document, NSError* error))completion
{
    self.setupCompletion = completion;
    [self setUpDocument:NO];
}

- (void)updateMedicineWithName:(NSString*)name andURL:(NSString*)url shouldSave:(BOOL)shouldSave;
{
    [self.document.managedObjectContext performBlockAndWait:^{
        
        
        
        NSManagedObjectContext* context = self.document.managedObjectContext;
        
        //fetch all existing tags
        NSFetchRequest *medicineRequest = [NSFetchRequest fetchRequestWithEntityName:@"Medicine"];
        [medicineRequest setPredicate:[NSPredicate predicateWithFormat:@"name like %@",name]];
        NSError *error = nil;
        NSMutableArray *prevMedicine = [[context executeFetchRequest:medicineRequest error:&error] mutableCopy];
        
        //check for existing tip
        if ([prevMedicine count] > 0){
            Medicine* existingMedicine = prevMedicine[0];
            //reset tags
            existingMedicine.descriptionUrl = url;
        }
        //if such tip is not existing create new tip
        else{
            Medicine* newMedicine = (Medicine*)[NSEntityDescription insertNewObjectForEntityForName:@"Medicine" inManagedObjectContext:context];
            [newMedicine setName:name];
            [newMedicine setDescriptionUrl:url];
        }
        NSLog(@"updating medicine number: %ld with name :%@ and url %@ ",(long)count ++, name, url);
        
        NSSet *inserts = [self.document.managedObjectContext insertedObjects];
        
        if ([inserts count])
        {
            NSError * error = nil;
            
            if ([self.document.managedObjectContext obtainPermanentIDsForObjects:[inserts allObjects] error:&error] == NO)
            {
                NSLog(@"Error getting permanent ID for object! %@", error);
            }
        }
        
        [self.document updateChangeCount:UIDocumentChangeDone];
    }];
    
}


#pragma mark - Core Data Document Methods

- (void)setUpDocument:(BOOL)retry;
{
    //check do we have to copy the preloaded database
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *documentsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Medicine"];
    if (![fileManager fileExistsAtPath:documentsFolderPath]) {
        //copy the preloaded database
        NSError *error = nil;
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Medicine"];
        if([fileManager copyItemAtPath:bundlePath toPath:documentsFolderPath error:&error]) {
            
            NSLog(@"copying of preload data done.");
        }
    }
    
    //open the document
    NSURL *documentsUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentsUrl = [documentsUrl URLByAppendingPathComponent:@"Medicine"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:documentsUrl];
    // NSLog(@"Type of document %d", self.document.managedObjectContext );
    if (![fileManager fileExistsAtPath:[self.document.fileURL path]]) {
        // Not created on disk yet, so create it
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [self documentReady:self.document];
                // [self startFetches];
            }
            else if (retry) {
                [self reportDocumentOpenError];
            }
            else {
                NSLog(@"Error creating document, deleting and starting over");
                self.document = nil;
                NSError *error = nil;
                if (![fileManager removeItemAtURL:documentsUrl error:&error]) {
                    NSLog(@"Error deleting document: %@", error);
                    [self reportDocumentOpenError];
                }
                else {
                    [self setUpDocument:YES];
                }
            }
        }];
    }
	else if (self.document.documentState == UIDocumentStateClosed) {
        // Created on disk, so open it
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentReady:self.document];
                //[self startFetches];
            }
            else if (retry) {
                [self reportDocumentOpenError];
            }
            else {
                DLog(@"Error opening document, deleting and starting over");
                self.document = nil;
                NSError *error = nil;
                if (![fileManager removeItemAtURL:documentsUrl error:&error]) {
                    DLog(@"Error deleting document: %@", error);
                    [self reportDocumentOpenError];
                }
                else {
                    [self setUpDocument:YES];
                }
            }
        }];
    }
}

- (void)documentReady:(UIManagedDocument *)document
{
    if(self.setupCompletion){
        self.setupCompletion(document, nil);
    }
}

- (void)reportDocumentOpenError
{
    UIAlertView* __alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"System Error", @"") message:[NSString stringWithFormat:NSLocalizedString(@"An unexpected error has occurred trying to create application data. Possible causes may be due to inadequate storage capacity or hardware failure.", @""), NSProcessInfo.processInfo.processName] delegate:nil cancelButtonTitle:NSLocalizedString(@"Quit", @"") otherButtonTitles:nil];
    
    //abort();
    
#warning  TO MAKE ABORT or something else
    [__alertView show];
}

@end
