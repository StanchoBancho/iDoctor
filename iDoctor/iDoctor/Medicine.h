//
//  Medicine.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Medicine : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * descriptionUrl;

@end
