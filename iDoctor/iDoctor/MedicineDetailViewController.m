//
//  MedicineDetailViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 12/31/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "MedicineDetailViewController.h"

@interface MedicineDetailViewController ()

@property (nonatomic, strong) IBOutlet UIWebView* detailWebView;

@end

@implementation MedicineDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setTitle:self.medicineName];
    
    NSURL* url = [NSURL URLWithString:self.medicineUrl];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.detailWebView loadRequest:request];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
