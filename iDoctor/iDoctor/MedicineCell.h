//
//  MedicineCell.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/18/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MedicineCell;

@protocol MedicineCellProtocol <NSObject>

-(void)deleteButtonPressedForCell:(MedicineCell*)cell;
-(void)addEditNoteButtonPressedForCell:(MedicineCell*)cell;

@end

@interface MedicineCell : UITableViewCell

@property (nonatomic, assign) id<MedicineCellProtocol> delegate;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel* scrollViewLabel;
@property (nonatomic, assign) BOOL hasAccessoryView;

@end
