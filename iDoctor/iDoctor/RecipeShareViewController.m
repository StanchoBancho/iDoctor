//
//  RecipeShareViewController.m
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/18/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#import "RecipeShareViewController.h"
#import "CoreText/CoreText.h"
#import "Constants.h"

@interface RecipeShareViewController ()

@property (nonatomic, strong) IBOutlet UIWebView* webview;
@property (nonatomic, strong) IBOutlet UITextField* textField;
@property (nonatomic, strong) NSString* enteredName;
@property (nonatomic, strong) NSDate* enteredNameDate;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* shareButton;

@property (nonatomic, strong) UIPopoverController* sharePopover;
@end

@implementation RecipeShareViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PDF creation methods

-(NSAttributedString*)createMedicineList
{
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    
    //add name
    NSString* nameString = [NSString stringWithFormat:@"Recipient name: %@\n", self.enteredName];
    NSMutableAttributedString* recipentName = [[NSMutableAttributedString alloc] initWithString:nameString];
    [recipentName setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0]} range:NSMakeRange(0, recipentName.length)];
    [string appendAttributedString: recipentName];
    
    //add creation date
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss-dd-MM-yyyy"];
    NSString* createdOnString = [NSString stringWithFormat:@"Medical Recipe created on: %@\n\n\n", [dateFormatter stringFromDate:self.enteredNameDate]];
    NSMutableAttributedString* recipeCreatedOn = [[NSMutableAttributedString alloc] initWithString:createdOnString];
    [recipeCreatedOn setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0]} range:NSMakeRange(0, recipeCreatedOn.length)];
    [string appendAttributedString: recipeCreatedOn];
    
    
    //add medicines
    for(NSDictionary* medicineInfo in self.medicines){
        // add name
        NSMutableAttributedString* medicineName = [[NSMutableAttributedString alloc] initWithString:[medicineInfo objectForKey:kMedicineNameKey]];
        [medicineName setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0]} range:NSMakeRange(0, medicineName.length)];
        [string appendAttributedString: medicineName];
        
        // add notes
        NSString* description = [medicineInfo objectForKey:kMedicineNoteKey];
        NSString *medicineNotesString = @"";
        if(description){
            medicineNotesString = [NSString stringWithFormat:@" - %@\n",description];
        }
        NSMutableAttributedString* medicineNotes = [[NSMutableAttributedString alloc] initWithString:medicineNotesString];
        [medicineNotes setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0]} range:NSMakeRange(0, medicineNotes.length)];
        [string appendAttributedString: medicineNotes];
    }
    
    
    return string;
}

-(NSString*)getPDFFileName
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss-dd-MM-yyyy"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString* pdfName = [NSString stringWithFormat:@"%@-%@.pdf", self.enteredName, [dateFormatter stringFromDate:self.enteredNameDate]];
    documentPath = [documentPath stringByAppendingPathComponent:pdfName];
    return documentPath;
}

- (void)savePDFFile
{
    // Prepare the text using a Core Text Framesetter.
    
    NSAttributedString* listOfMedicines = [self createMedicineList];
    CFAttributedStringRef currentText = (__bridge CFAttributedStringRef)listOfMedicines;
    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            NSString *pdfFileName = [self getPDFFileName];
            // Create the PDF context using the default page size of 612 x 792.
            UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL done = NO;
            
            do {
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++;
                [self drawPageNumber:currentPage];
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                currentRange = [self renderPage:currentPage withTextRange:currentRange wandFramesetter:framesetter];
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                    done = YES;
            } while (!done);
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            
            // Release the framewetter.
            CFRelease(framesetter);
            
        } else {
            NSLog(@"Could not create the framesetter needed to lay out the atrributed string.");
        }
        // Release the attributed string.
        //CFRelease(currentText);
    } else {
        NSLog(@"Could not create the attributed string for the framesetter");
    }
}

// Use Core Text to draw the text in a frame on the page.
- (CFRange)renderPage:(NSInteger)pageNum withTextRange:(CFRange)currentRange wandFramesetter:(CTFramesetterRef)framesetter
{
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect    frameRect = CGRectMake(72, 72, 468, 648);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef);
    currentRange.location += currentRange.length;
    currentRange.length = 0;
    CFRelease(frameRef);
    
    return currentRange;
}

- (void)drawPageNumber:(NSInteger)pageNum
{
    NSString *pageString = [NSString stringWithFormat:@"Page %ld", (long)pageNum];
    CGSize maxSize = CGSizeMake(612, 72);
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12] forKey: NSFontAttributeName];
    
    CGSize pageStringSize = [pageString boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil].size;
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   pageStringSize.width,
                                   pageStringSize.height);
    
    [pageString drawInRect:stringRect withAttributes:stringAttributes];
}
#pragma mark - Utility methods

-(void)presentPDF
{
    NSString* pdfPath = [self getPDFFileName];
    NSURL *targetURL = [NSURL fileURLWithPath:pdfPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webview loadRequest:request];
}

#pragma mark - Action methods

-(IBAction)completeNameButtonPressed:(id)sender
{
    [sender setEnabled:NO];
    [self.textField resignFirstResponder];
    self.enteredNameDate = [NSDate date];
    self.enteredName = self.textField.text;
    if([self.enteredName isEqualToString:@""]){
        UIAlertView* noNameAlertView = [[UIAlertView alloc] initWithTitle:@"No recipient name enterd" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [noNameAlertView show];
    }
    else{
        UIButton* button = (UIButton*)sender;
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [button setTitle:@"Edit" forState:UIControlStateHighlighted];
        [self savePDFFile];
        [self presentPDF];
        [button addTarget:self action:@selector(editNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.textField setEnabled:NO];
        [self.shareButton setEnabled:YES];
    }
    [sender setEnabled:YES];
}

-(IBAction)editNameButtonPressed:(id)sender
{
    [self.textField setEnabled:YES];
    [self.shareButton setEnabled:NO];
    UIButton* button = (UIButton*)sender;
    [button setTitle:@"Complete" forState:UIControlStateNormal];
    [button setTitle:@"Complete" forState:UIControlStateHighlighted];
    [self.textField becomeFirstResponder];
}

-(IBAction)shareButtonPressed:(id)sender
{
    if (self.sharePopover.isPopoverVisible) {
        [self.sharePopover dismissPopoverAnimated:YES];
        self.sharePopover = nil;
        return;
    }
    NSString* pdfPath = [self getPDFFileName];
    NSURL *targetURL = [NSURL fileURLWithPath:pdfPath];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[targetURL] applicationActivities:@[]];
    self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
    [self.sharePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

@end
