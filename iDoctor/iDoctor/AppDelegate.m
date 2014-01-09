//
//  AppDelegate.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "Constants.h"

@interface AppDelegate()
{

}

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults* standartDefaults = [NSUserDefaults standardUserDefaults];
    if([standartDefaults integerForKey:kAutocompetionType] < 1){
        [standartDefaults setInteger:AutocompetionType23Tree forKey:kAutocompetionType];
        [standartDefaults setInteger:AutocorectionEditDistance forKey:kAutocorectionType];
    }
    
    [[CoreDataManager sharedManager] setupDocument:^(UIManagedDocument *document, NSError *error) {
        if (document && !error) {
            //dissmiss loading screen
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            //display error and do nothing
            UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error with the opening of the database. Please restart the app. If this doesn`t help. Try deleting the app and installing it again. Thanks." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alerView show];
        }
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSUserDefaults* standartDefaults = [NSUserDefaults standardUserDefaults];
    [standartDefaults synchronize];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
