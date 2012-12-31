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
#import "KdbPassword.h"
#import "KdbReaderFactory.h"
#import "PasswordViewControllerOSX.h"

@interface Document ()

@property (nonatomic, strong) KdbTree *kdbTree;
@property (nonatomic, strong) KdbPassword *kdbPassword;
@property (nonatomic, assign) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) PasswordViewControllerOSX *passwordViewController;

- (IBAction)showPasswordDialog:(id)sender;

@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    [self.outlineView expandItem:self.kdbTree.root];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    // Load the database
    @try {
        self.kdbTree = [KdbReaderFactory load:absoluteURL withPassword:self.kdbPassword];
    } @catch (NSException * exception) {
        NSLog(@"Error loading keepass 2.x file: %@", exception);
        [self performSelector:@selector(showPasswordDialog:)
                   withObject:self
                   afterDelay:0.5];
    }
    
    return YES;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        item = self.kdbTree.root;
    }
    
    if ([item isKindOfClass:[KdbGroup class]]) {
        KdbGroup *group = (KdbGroup*)item;
        return [[group groups] count] + [[group entries] count];
    }
    
    return 0;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item isKindOfClass:[KdbGroup class]];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        item = self.kdbTree.root;
    }

    KdbGroup *group = (KdbGroup*)item;
    if (index < group.groups.count) {
        return [group.groups objectAtIndex:index];
    }
    else {
        return [group.entries objectAtIndex:index - group.groups.count];
    }
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

- (IBAction)showPasswordDialog:(id)sender {
    // Prompt the user for the password if we haven't loaded the database yet
    if (self.kdbTree == nil) {
        // Prompt the user for a password
        self.passwordViewController = [[PasswordViewControllerOSX alloc] initWithFilename:[self.fileURL absoluteString]];
        self.passwordViewController.delegate = self;
        NSLog(@"Show password sheet");
        [NSApp beginSheet:self.passwordViewController.window
           modalForWindow:self.windowForSheet
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:nil];
        
        
    }
}

- (void)didEnterPassword:(NSString*)password keyFile:(NSString*)keyFile {
    [NSApp endSheet: self.windowForSheet];

    NSStringEncoding passwordEncoding = [[AppSettings sharedInstance] passwordEncoding];

    NSLog(@"Password: %@", password);
    NSLog(@"Keyfile: %@", keyFile);
    self.kdbPassword = [[KdbPassword alloc] initWithPassword:password
                                            passwordEncoding:passwordEncoding
                                                     keyFile:keyFile];

    // Load data
    @try {
        self.kdbTree = [KdbReaderFactory load:self.fileURL withPassword:self.kdbPassword];
        [self.outlineView reloadData];
    } @catch (NSException * exception) {
        NSLog(@"Exception when loading the kdbx file: %@", exception);
        [self performSelector:@selector(showPasswordDialog:)
                   withObject:self
                   afterDelay:0.5];
    }
}

@end
