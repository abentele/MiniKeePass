//
//  PasswordViewController.m
//  MiniKeePass
//
//  Created by Andreas Bentele on 30.12.12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "PasswordViewControllerOSX.h"

@interface PasswordViewControllerOSX ()

@property (nonatomic, assign) IBOutlet NSTextField *fileNameLabel;
@property (nonatomic, assign) IBOutlet NSButton *passwordCheckbox;
@property (nonatomic, assign) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, assign) IBOutlet NSButton *keyFileCheckbox;
@property (nonatomic, assign) IBOutlet NSTextField *keyFileField;
@property (nonatomic, assign) IBOutlet NSButton *doneButton;

- (IBAction)selectKeyFileButtonClicked:(id)sender;
- (IBAction)passwordCheckboxClicked:(id)sender;
- (IBAction)keyfileCheckboxClicked:(id)sender;

@end

@implementation PasswordViewControllerOSX

- (id)initWithFilename:(NSString*)aFileName {
    self = [super initWithWindowNibName:@"PasswordViewControllerOSX"];
    if (self) {
        self.fileName = aFileName;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.fileNameLabel setStringValue:self.fileName];
    [self.window makeFirstResponder:self.passwordField];
}

- (IBAction)cancelClicked:(id)sender {
    [[NSApplication sharedApplication] endSheet:self.window];
    [self.delegate didCancelPassword];
}

- (IBAction)doneClicked:(id)sender {

    NSString *keyFile = self.keyFileField.stringValue;
    if ([keyFile isEqualToString:@""]) {
        keyFile = nil;
    }

    [[NSApplication sharedApplication] endSheet: self.window];
    [self.delegate didEnterPassword:self.passwordField.stringValue keyFile:keyFile];
}

- (IBAction)selectKeyFileButtonClicked:(id)sender {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    
	[openPanel setResolvesAliases:YES];
	[openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"key"]];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^( NSInteger resultCode )
     {
         if( resultCode )
         {
             [self.keyFileField setStringValue:openPanel.URL.path];
             [self.keyFileCheckbox setState:NSOnState];
         }
     }];
}

- (IBAction)passwordCheckboxClicked:(id)sender {
    if (self.passwordCheckbox.state == NSOffState) {
        [self.passwordField setStringValue:@""];
    }
}

- (IBAction)keyfileCheckboxClicked:(id)sender {
    if (self.keyFileCheckbox.state == NSOffState) {
        [self.keyFileField setStringValue:@""];
    }
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    self.doneButton.enabled = YES;
    if (control == self.passwordField) {
        self.passwordCheckbox.state = NSOnState;
    }
    else if (control == self.keyFileField) {
        self.keyFileCheckbox.state = NSOnState;
    }
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSInteger newState;
    if ([fieldEditor.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        newState = NSOffState;
    }
    else {
        newState = NSOnState;
    }
        
    if (control == self.passwordField) {
        self.passwordCheckbox.state = newState;
    }
    else if (control == self.keyFileField) {
        self.keyFileCheckbox.state = newState;
    }
    return YES;
}

@end