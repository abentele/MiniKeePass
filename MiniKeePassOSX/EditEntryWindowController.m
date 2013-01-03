//
//  EditEntryWindowController.m
//  MiniKeePass
//
//  Created by Andreas Bentele on 02.01.13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "EditEntryWindowController.h"

@interface EditEntryWindowController ()

@property (nonatomic, strong) IBOutlet NSButton *okButton;
@property (nonatomic, strong) IBOutlet NSButton *cancelButton;
@property (nonatomic, strong) IBOutlet NSButton *closeButton;
@property (nonatomic, strong) IBOutlet NSButton *modifyButton;

- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end

@implementation EditEntryWindowController

- (id)initWithEntry:(KdbEntry*)aEntry {
    self = [super initWithWindowNibName:@"EditEntryWindowController"];
    if (self) {
        self.entry = aEntry;
        modeNewEntry = (aEntry == nil);
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    if (modeNewEntry) {
        // start with edit view
        [self.modifyButton setHidden:YES];
        [self.closeButton setHidden:YES];
    }
    else {
        // start with readonly view
        [self.cancelButton setHidden:YES];
        [self.okButton setHidden:YES];
    }
}

- (IBAction)okClicked:(id)sender {
    
    [[NSApplication sharedApplication] endSheet: self.window];
    [self.delegate didSaveEditEntry:self.entry];
}

- (IBAction)cancelClicked:(id)sender {

    [[NSApplication sharedApplication] endSheet: self.window];
}

@end
