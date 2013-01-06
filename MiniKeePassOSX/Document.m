//
//  Document.m
//  Test
//
//  Created by Andreas Bentele on 30.12.12.
//  Copyright (c) 2012 Andreas Bentele. All rights reserved.
//

#import "Document.h"
#import "AppSettings.h"
#import "Kdb.h"
#import "Kdb3Node.h"
#import "Kdb4Node.h"
#import "KdbPassword.h"
#import "KdbReaderFactory.h"
#import "PasswordViewControllerOSX.h"
#import "ImageAndTextCell.h"
#import "ImageCache.h"
#import "EditEntryWindowController.h"
#import "KdbWriterFactory.h"

@interface Document ()

@property (nonatomic, strong) KdbTree *kdbTree;
@property (nonatomic, strong) KdbPassword *kdbPassword;
@property (nonatomic, strong) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSView *overlayView;
@property (nonatomic, strong) PasswordViewControllerOSX *passwordViewController;
@property (nonatomic, strong) EditEntryWindowController *editEntryWindowController;
@property (nonatomic, strong) IBOutlet NSSearchField *searchField;

/* Cache: <parent, array of filtered children> */
@property (nonatomic, strong) NSMutableDictionary *filteredChildren;


- (IBAction)showPasswordDialog:(id)sender;

@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        self.filteredChildren = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Standard NSDocument methods

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    self.outlineView.doubleAction = @selector(doubleClick:);
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    [KdbWriterFactory persist:self.kdbTree file:url.path withPassword:self.kdbPassword];
    return YES;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    // Load the database
    @try {
        self.kdbTree = [KdbReaderFactory load:absoluteURL.path withPassword:self.kdbPassword];
    } @catch (NSException * exception) {
        NSLog(@"Error loading keepass 2.x file: %@", exception);
        [self performSelector:@selector(showPasswordDialog:)
                   withObject:self
                   afterDelay:0.5];
    }
    
    return YES;
}

#pragma mark -
#pragma mark OutlineView Delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // no inline editing is allowed
    return NO;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if (tableColumn == nil) {
        return nil;
    }
    else if ([tableColumn.identifier isEqualToString:@"title"]) {
        return [[ImageAndTextCell alloc] init];
    }
    else {
        return [[NSTextFieldCell alloc] init];
    }
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([tableColumn.identifier isEqualToString:@"title"]) {
        NSInteger imageIndex = -1;
        if ([item isKindOfClass:[KdbGroup class]]) {
            KdbGroup *group = (KdbGroup*)item;
            imageIndex = group.image;
        }
        else if ([item isKindOfClass:[KdbEntry class]]) {
            KdbEntry *entry = (KdbEntry*)item;
            imageIndex = entry.image;
        }
        
        NSImage *image;
        if (imageIndex != -1) {
            image = [[ImageCache sharedInstance] getImage:imageIndex];
        }
        else {
            image = nil;
        }
        //NSLog(@"Image: %@", image);
        ImageAndTextCell *cell = (ImageAndTextCell*)aCell;
        [cell setImage: image];
    }
}

#pragma mark -
#pragma mark Search filter

// search field delegate method
- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if([aNotification object] == self.searchField)
    {
        // trigger filtering
        //NSLog(@"filter with text: %@", self.searchText);
        
        // invalidate cache
        [self.filteredChildren removeAllObjects];
        
        // invalidate view
        [self.outlineView reloadData];
        
        // expand all items in search mode
        if ([self.searchText length] > 0) {
            [self.outlineView expandItem:nil expandChildren:YES];
        }
        else {
            [self.outlineView collapseItem:nil collapseChildren:YES];
        }
    }
}

- (NSString*)searchText {
    return [[self.searchField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
}

- (BOOL)searchStringContainedIn:(NSString*)value {
    NSRange range = [[value lowercaseString] rangeOfString:[self searchText]];
    return range.location != NSNotFound;
}

- (BOOL)searchStringMatchesGroup:(KdbGroup*)group {
    if ([self searchStringContainedIn:group.name]) {
        return YES;
    }
    return NO;
}

- (BOOL)searchStringMatchesEntry:(KdbEntry*)entry {
    if ([self searchStringContainedIn:entry.title]) {
        return YES;
    }
    return NO;
}

- (NSArray*)filteredChildrenOfItem:(id)item {
    if (item == nil) {
        item = self.kdbTree.root;
    }

    // construct cache key (using NSString which supports NSCopying!)
    id cacheKey;
    if (item != nil) {
        if ([item isKindOfClass:[KdbEntry class]]) {
            // always return empty array
            cacheKey = @"EMPTYARRAY_KEY";
        }
        else if ([item isKindOfClass:[Kdb3Group class]]) {
            Kdb3Group *group = (Kdb3Group*)item;
            cacheKey = [NSString stringWithFormat:@"Kdb3Group-%d", group.groupId];
        }
        else if ([item isKindOfClass:[Kdb4Group class]]) {
            Kdb4Group *group = (Kdb4Group*)item;
            cacheKey = [NSString stringWithFormat:@"Kdb4Group-%@", group.uuid.description];
        }
    }
    else {
        cacheKey = @"NULL_KEY";
    }
    
    //NSLog(@"Cache key: %@", cacheKey);
    
    NSMutableArray *result = [self.filteredChildren objectForKey:cacheKey];

    if (result == nil) {
        result = [[NSMutableArray alloc] init];
        
        if ([item isKindOfClass:[KdbGroup class]]) {
            KdbGroup *group = (KdbGroup*)item;
            if ([[self searchText] length] == 0) {
                for (KdbGroup *childGroup in group.groups) {
                    [result addObject:childGroup];
                }
                for (KdbEntry *childEntry in group.entries) {
                    [result addObject:childEntry];
                }
            }
            else {
                for (KdbGroup *childGroup in group.groups) {
                    if ([self searchStringMatchesGroup:childGroup] || ([self numberOfFilteredChildrenOfItem:childGroup] > 0)) {
                        [result addObject:childGroup];
                    }
                }
                for (KdbEntry *childEntry in group.entries) {
                    if ([self searchStringMatchesEntry:childEntry]) {
                        [result addObject:childEntry];
                    }
                }
            }
        }
        [self.filteredChildren setObject:result forKey:cacheKey];
    }
    
    return result;
}

- (NSInteger)numberOfFilteredChildrenOfItem:(id)item {
    return [[self filteredChildrenOfItem:item] count];
}

#pragma mark -
#pragma mark OutlineView Datasource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [self numberOfFilteredChildrenOfItem:item];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [self numberOfFilteredChildrenOfItem:item] > 0;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    NSArray *children = [self filteredChildrenOfItem:item];
    return [children objectAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[KdbGroup class]]) {
        KdbGroup *group = (KdbGroup*)item;
        if ([tableColumn.identifier isEqualToString:@"title"]) {
            return group.name;
        }
    }
    else if ([item isKindOfClass:[KdbEntry class]]) {
        KdbEntry *entry = (KdbEntry*)item;
        if ([tableColumn.identifier isEqualToString:@"title"]) {
            return entry.title;
        }
        else if ([tableColumn.identifier isEqualToString:@"username"]) {
            return entry.username;
        }
        else if ([tableColumn.identifier isEqualToString:@"url"]) {
            return entry.url;
        }
    }
    return @"";
}

#pragma mark -
#pragma mark Password dialog

- (IBAction)showPasswordDialog:(id)sender {
    
    // Prompt the user for the password if we haven't loaded the database yet
    if (self.kdbTree == nil) {
        // Prompt the user for a password
        self.passwordViewController = [[PasswordViewControllerOSX alloc] initWithFilename:self.fileURL.path];
        self.passwordViewController.delegate = self;
        NSLog(@"windowForSheet = %@", self.windowForSheet);
        NSLog(@"passwordViewController.window = %@", self.passwordViewController.window);
        
        if (self.overlayView == nil) {
            // add gray overlay view
            CGRect rect = CGRectMake(0,
                                     0,
                                     self.outlineView.bounds.size.width,
                                     self.outlineView.bounds.size.height);
            self.overlayView = [[NSView alloc] initWithFrame:rect];
            CALayer *viewLayer = [CALayer layer];
            [viewLayer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.9
                                                                     green:0.9
                                                                      blue:0.9
                                                                     alpha:1.0] CGColor]];
            [self.overlayView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
            [self.overlayView setLayer:viewLayer];
            [self.overlayView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
            [self.outlineView addSubview:self.overlayView];
        }

        
        NSLog(@"Show password sheet");
        
        [[NSApplication sharedApplication] beginSheet:self.passwordViewController.window
                                       modalForWindow:self.windowForSheet
                                        modalDelegate:self
                                       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
                                          contextInfo:nil];
    }
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (void)didEnterPassword:(NSString*)password keyFile:(NSString*)keyFile {
    NSStringEncoding passwordEncoding = [[AppSettings sharedInstance] passwordEncoding];

//    NSLog(@"Password: %@", password);
//    NSLog(@"Keyfile: %@", keyFile);
    self.kdbPassword = [[KdbPassword alloc] initWithPassword:password
                                            passwordEncoding:passwordEncoding
                                                     keyFile:keyFile];

    // Load data
    @try {
        KdbTree * kdbTree = [KdbReaderFactory load:self.fileURL.path withPassword:self.kdbPassword];

        // if the file wasn't loaded yet, assign it (otherwise, don't reload the file, but only check the password)
        if (self.kdbTree == nil) {
            self.kdbTree = kdbTree;
            [self.outlineView reloadData];
        }

        // password was correct => remove overlay view
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
    } @catch (NSException * exception) {
        NSLog(@"Exception when loading the kdbx file: %@", exception);

        NSAlert *alert = [NSAlert alertWithMessageText:@"Unable to open the database."
                                         defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Wrong key or database file is corrupt."];
        alert.alertStyle = NSInformationalAlertStyle;
        [alert beginSheetModalForWindow:self.windowForSheet
                          modalDelegate:self
                         didEndSelector:@selector(didEndPasswordAlert:returnCode:contextInfo:)
                            contextInfo:nil];
        
    }
}

- (void)didEndPasswordAlert:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    // show the password dialog again
    [self performSelector:@selector(showPasswordDialog:)
               withObject:self
               afterDelay:0.1];
}

- (void)didCancelPassword {
    // close the document window
    [self close];
}

#pragma mark -
#pragma mark Edit action

- (IBAction)doubleClick:(id)sender {
    NSLog(@"Double clicked");
    NSInteger row = self.outlineView.clickedRow;
    id item = [self.outlineView itemAtRow:row];
    if ([item isKindOfClass:[KdbEntry class]]) {
        [self editEntry:(KdbEntry*)item];
    }
    else if ([item isKindOfClass:[KdbGroup class]]) {
//        KdbGroup *group = (KdbGroup*)item;
//        [self editGroup:group];
    }
}

- (void)editEntry:(KdbEntry*)entry {
    
    // Prompt the user for a password
    self.editEntryWindowController = [[EditEntryWindowController alloc] initWithEntry:[entry copyWithZone:nil]
                                                                       unchangedEntry:entry];
    self.editEntryWindowController.delegate = self;
    
    [[NSApplication sharedApplication] beginSheet:self.editEntryWindowController.window
                                   modalForWindow:self.windowForSheet
                                    modalDelegate:self
                                   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
                                      contextInfo:nil];
}

- (void)didSaveEditEntry:(KdbEntry*)entry unchangedEntry:(KdbEntry *)unchangedEntry {
    //NSLog(@"Save entry with title:%@", entry.title);
    [[self undoManager] setActionName:[NSString stringWithFormat:@"Modify entry: %@", entry.title]];
    //NSLog(@"Add to undoManager: %@", current.title);
    [[[self undoManager] prepareWithInvocationTarget:self] didSaveEditEntry:unchangedEntry unchangedEntry:entry];
    
    NSLog(@"Replace entry: %@", entry.title);
    [entry.parent replaceEntryWithCopy:entry];
    
    // clear cache, and update view
    [self.filteredChildren removeAllObjects];
    [self.outlineView reloadData];
}

@end
