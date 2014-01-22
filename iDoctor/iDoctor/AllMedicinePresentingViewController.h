//
//  ViewController.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MedicinePresenter<NSObject>

-(void)handleAddingMedicines:(NSArray*)medicinNames;

@end


@interface AllMedicinePresentingViewController : UIViewController

@property (nonatomic, strong) id<MedicinePresenter>delegate;

@end
