//
//  Document.h
//  Test
//
//  Created by Andreas Bentele on 30.12.12.
//  Copyright (c) 2012 Andreas Bentele. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PasswordViewControllerOSX.h"
#import "EditEntryWindowController.h"

@interface Document : NSDocument <NSOutlineViewDataSource, PasswordViewControllerDelegate, EditEntryWindowControllerDelegate, NSTextFieldDelegate>
@end
