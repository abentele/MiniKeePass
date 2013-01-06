//
//  EditEntryWindowController.h
//  MiniKeePass
//
//  Created by Andreas Bentele on 02.01.13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EditEntryWindowControllerDelegate;
@class KdbEntry;

@interface EditEntryWindowController : NSWindowController {
    BOOL modeNewEntry;
}

@property (nonatomic, strong) KdbEntry *entry;
@property (nonatomic, strong) KdbEntry *unchangedEntry;
@property (nonatomic, unsafe_unretained) id<EditEntryWindowControllerDelegate> delegate;

- (id)initWithEntry:(KdbEntry*)entry unchangedEntry:(KdbEntry*)unchangedEntry;

@end

@protocol EditEntryWindowControllerDelegate <NSObject>

- (void)didSaveEditEntry:(KdbEntry*)entry unchangedEntry:(KdbEntry*)unchangedEntry;

@end
