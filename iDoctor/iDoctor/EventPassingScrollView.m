//
//  EventPassingScrollView.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/19/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "EventPassingScrollView.h"

@implementation EventPassingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesCancelled: touches withEvent:event];
    else
        [super touchesCancelled: touches withEvent: event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesMoved: touches withEvent:event];
    else
        [super touchesMoved: touches withEvent: event];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesBegan: touches withEvent:event];
    else
        [super touchesBegan: touches withEvent: event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging)
        [self.superview touchesEnded: touches withEvent:event];
    else
        [super touchesEnded: touches withEvent: event];
}

@end
