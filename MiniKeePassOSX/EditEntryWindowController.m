//
//  EditEntryWindowController.m
//  MiniKeePass
//
//  Created by Andreas Bentele on 02.01.13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "EditEntryWindowController.h"

@interface EditEntryWindowController ()

@end

@implementation EditEntryWindowController

- (id)initWithEntry:(KdbEntry*)aEntry {
    self = [super initWithWindowNibName:@"EditEntryWindowController"];
    if (self) {
        self.entry = aEntry;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
