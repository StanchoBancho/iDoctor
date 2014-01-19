//
//  MedicineCell.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/18/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "MedicineCell.h"
#import "EventPassingScrollView.h"

#define kCatchWidth 150

@interface MedicineCell() <UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* scrollViewButtonView;
@property (nonatomic, strong) UIView* scrollViewContentView;

@end

@implementation MedicineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    EventPassingScrollView *scrollView = [[EventPassingScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kCatchWidth, 0, kCatchWidth, CGRectGetHeight(self.bounds))];
    self.scrollViewButtonView = scrollViewButtonView;
    [self.scrollView addSubview:scrollViewButtonView];
    
    UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    noteButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];

    noteButton.frame = CGRectMake(0, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    [noteButton setTitle:@"Note" forState:UIControlStateNormal];
    [noteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [noteButton addTarget:self action:@selector(addEditNoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton = noteButton;
    [self.scrollViewButtonView addSubview:noteButton];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
    deleteButton.frame = CGRectMake(kCatchWidth / 2.0f, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteButton = deleteButton;
    [self.scrollViewButtonView addSubview:deleteButton];
    
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    scrollViewContentView.backgroundColor = [UIColor whiteColor];

    [self.scrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
    
    //CGRectInset(self.scrollViewContentView.bounds, 10, 0)
    UILabel *scrollViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10., 0.0, scrollViewContentView.bounds.size.width, 20.0)];
    [scrollViewLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    self.scrollViewLabel = scrollViewLabel;

    [self.scrollViewContentView addSubview:scrollViewLabel];
    
    UILabel *scrollViewNotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20., 35.0, scrollViewContentView.bounds.size.width, 15.0)];
    self.scrollViewNotesLabel = scrollViewNotesLabel;
    [self.scrollViewContentView addSubview:scrollViewNotesLabel];

}


- (void)prepareForReuse
{
    [self.scrollView setContentOffset:CGPointZero];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - UIScrollViewDelegate methods

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.contentOffset.x < kCatchWidth / 2){
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(kCatchWidth, 0.0) animated:YES];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointZero;
        
    }
    if(self.hasAccessoryView){
        if(scrollView.contentOffset.x > 0){
            [self setAccessoryType:UITableViewCellAccessoryNone];
        }
        else{
            [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - kCatchWidth), 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
    
}

#pragma mark - Actions methods

-(IBAction)addEditNoteButtonPressed:(id)sender
{
    [sender setUserInteractionEnabled:NO];
    if([self.delegate respondsToSelector:@selector(addEditNoteButtonPressedForCell:)]){
        [self.delegate addEditNoteButtonPressedForCell:self];
    }
    [sender setUserInteractionEnabled:YES];
}

-(IBAction)deleteButtonPressed:(id)sender
{
    [sender setUserInteractionEnabled:NO];
    if([self.delegate respondsToSelector:@selector(deleteButtonPressedForCell:)]){
        [self.delegate deleteButtonPressedForCell:self];
    }
    [sender setUserInteractionEnabled:YES];
}


@end
