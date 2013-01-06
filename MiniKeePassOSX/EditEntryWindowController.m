//
//  EditEntryWindowController.m
//  MiniKeePass
//
//  Created by Andreas Bentele on 02.01.13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "EditEntryWindowController.h"
#import "Kdb.h"

@interface EditEntryWindowController ()

@property (nonatomic, assign) BOOL readonly;
@property (nonatomic, assign) BOOL dirty;

// array with all input fields
@property (nonatomic, strong) NSArray *fields;

// action buttons
@property (nonatomic, strong) IBOutlet NSButton *okButton;
@property (nonatomic, strong) IBOutlet NSButton *cancelButton;
@property (nonatomic, strong) IBOutlet NSButton *modifyButton;

// super view of controls of page "General"
@property (nonatomic, strong) IBOutlet NSView *generalView;

// labels of page "General"
@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;
@property (nonatomic, strong) IBOutlet NSTextField *urlLabel;
@property (nonatomic, strong) IBOutlet NSTextField *usernameLabel;
@property (nonatomic, strong) IBOutlet NSTextField *passwordLabel;
@property (nonatomic, strong) IBOutlet NSTextField *passwordRepeatLabel;
@property (nonatomic, strong) IBOutlet NSTextField *passwordExpiresLabel;
@property (nonatomic, strong) IBOutlet NSTextField *descriptionLabel;
@property (nonatomic, strong) IBOutlet NSTextField *iconLabel;

// controls on page "General"
@property (nonatomic, strong) IBOutlet NSTextField *titleField;
@property (nonatomic, strong) IBOutlet NSTextField *urlField;
@property (nonatomic, strong) IBOutlet NSTextField *usernameField;
@property (nonatomic, strong) IBOutlet NSTextField *passwordField;
@property (nonatomic, strong) IBOutlet NSButton *passwordLockUnlockButton;
@property (nonatomic, strong) IBOutlet NSTextField *passwordRepeatField;
@property (nonatomic, strong) IBOutlet NSTextField *passwordExpiresField;
@property (nonatomic, strong) IBOutlet NSTextField *descriptionField;
@property (nonatomic, strong) IBOutlet NSImageView *iconView;

// controls on page "Additional attributes"
@property (nonatomic, strong) IBOutlet NSTableView *additionalAttributesTableView;

// controls on page "Attachments"
@property (nonatomic, strong) IBOutlet NSTableView *attachmentsTableView;

// controls on page "History"
@property (nonatomic, strong) IBOutlet NSTableView *historyTableView;

// additional properties for binding
@property (nonatomic, strong) NSString *repeatPassword;

// outlets for localization
@property (nonatomic, weak) IBOutlet NSTabViewItem *generalTabViewItem;
@property (nonatomic, weak) IBOutlet NSTabViewItem *additionalAttributesTabViewItem;
@property (nonatomic, weak) IBOutlet NSTableColumn *additionalAttributesNameColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *additionalAttributesTextColumn;
@property (nonatomic, weak) IBOutlet NSTabViewItem *attachmentsTabViewItem;
@property (nonatomic, weak) IBOutlet NSTableColumn *attachmentsFileNameColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *attachmentsSizeColumn;
@property (nonatomic, weak) IBOutlet NSTabViewItem *historyTabViewItem;
@property (nonatomic, weak) IBOutlet NSTableColumn *historyLastModifiedColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *historyTitleColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *historyUsernameColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *historyURLColumn;

- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)modifyClicked:(id)sender;

@end

@implementation EditEntryWindowController

- (id)initWithEntry:(KdbEntry*)aEntry unchangedEntry:(KdbEntry *)unchangedEntry {
    self = [super initWithWindowNibName:@"EditEntryWindowController"];
    if (self) {
        self.entry = aEntry;
        self.unchangedEntry = unchangedEntry;
        modeNewEntry = (aEntry == nil);
        self.dirty = false;
    }
    return self;
}

#pragma mark -
#pragma mark Handling Modify state

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // localization
    self.generalTabViewItem.label = LocalizedStringOSX(@"General");
    self.additionalAttributesTabViewItem.label = LocalizedStringOSX(@"Additional Attributes");
    self.attachmentsTabViewItem.label = LocalizedStringOSX(@"Attachments");
    self.historyTabViewItem.label = LocalizedStringOSX(@"History");
    self.titleLabel.stringValue = LocalizedString(@"Title");
    self.urlLabel.stringValue = LocalizedString(@"URL");
    self.usernameLabel.stringValue = LocalizedString(@"Username");
    self.passwordLabel.stringValue = LocalizedString(@"Password");
    self.passwordLockUnlockButton.toolTip = LocalizedStringOSX(@"Show password"); // changes text to @"Hide password"
    self.passwordRepeatLabel.stringValue = LocalizedString(@"Confirm Password");
    self.passwordExpiresLabel.stringValue = LocalizedStringOSX(@"Expires");
    self.descriptionLabel.stringValue = LocalizedString(@"Comments");
    self.iconLabel.stringValue = LocalizedStringOSX(@"Icon");
    self.iconView.toolTip = LocalizedStringOSX(@"Change icon"); // changes text to @"Hide password"
    self.modifyButton.title = LocalizedString(@"Edit"); // changes text to @"Finished"
    self.okButton.title = LocalizedStringOSX(@"Close"); // changes text to @"OK"
    self.cancelButton.title = LocalizedString(@"Cancel");
    [self.additionalAttributesNameColumn.headerCell setStringValue:LocalizedStringOSX(@"Additional attribute - Name")];
    [self.additionalAttributesTextColumn.headerCell setStringValue:LocalizedStringOSX(@"Additional attribute - Text")];
    [self.attachmentsFileNameColumn.headerCell setStringValue:LocalizedStringOSX(@"Attachments - File name")];
    [self.attachmentsSizeColumn.headerCell setStringValue:LocalizedStringOSX(@"Attachments - Size")];
    [self.historyLastModifiedColumn.headerCell setStringValue:LocalizedString(@"Last Modified")];
    [self.historyTitleColumn.headerCell setStringValue:LocalizedString(@"Title")];
    [self.historyUsernameColumn.headerCell setStringValue:LocalizedString(@"Username")];
    [self.historyURLColumn.headerCell setStringValue:LocalizedString(@"URL")];
    
    // initialize fields array
    self.fields = [[NSArray alloc] initWithObjects:
                   self.titleField,
                   self.urlField,
                   self.usernameField,
                   self.passwordField,
                   self.passwordRepeatField,
                   self.passwordExpiresField,
                   self.descriptionField,
                   self.iconView,
                   nil];

    if (modeNewEntry) {
        // start with edit view, and no modify button
        [self.modifyButton setHidden:YES];
        self.readonly = YES;
        [self switchReadonlyMode:NO];
    }
    else {
        // start with readonly view
        self.readonly = NO;
        [self switchReadonlyMode:YES];
    }
    
    // hide password with bullets
    [self lockUnlockPassword:self];
    
    self.repeatPassword = [self.entry password];

    [self.titleField becomeFirstResponder];
}

// set properties for all controls based on the readonly state
- (void)setStyleOfTextFieldsWithReadonly:(BOOL)readonly {
    NSColor *fieldBackgroundColor;
    if (readonly) {
        fieldBackgroundColor = [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    }
    else {
        fieldBackgroundColor = [NSColor textBackgroundColor];
    }
    for (id field in self.fields) {
        if ([field isKindOfClass:[NSTextField class]]) {
            [field setBordered:!readonly];
            [field setBezeled:YES];
            [field setDrawsBackground:YES];
            [field setBackgroundColor:fieldBackgroundColor];
            [field setEditable:!readonly];
            if (readonly) {
                [field resignFirstResponder];
            }
        }
    }
    [self.iconView resignFirstResponder];
    [self.iconView setEditable:!readonly];
    [self.additionalAttributesTableView setBackgroundColor:fieldBackgroundColor];
    [self.attachmentsTableView setBackgroundColor:fieldBackgroundColor];
    [self.historyTableView setBackgroundColor:fieldBackgroundColor];
    
    // select first field
    if (!readonly) {
        [self.titleField becomeFirstResponder];
    }
}

- (void)switchReadonlyMode:(BOOL)readonly {
    if (readonly == self.readonly) {
        return;
    }
    
    if (readonly) {
        self.modifyButton.title = LocalizedString(@"Edit");
    }
    else {
        self.modifyButton.title = LocalizedStringOSX(@"Finish");
    }

    [self setStyleOfTextFieldsWithReadonly:readonly];
    
    // Remove / Add password repeat field
    if (readonly) {
        [self.passwordRepeatField removeFromSuperview];
        [self.passwordRepeatLabel removeFromSuperview];
    }
    else {
        [self.generalView addSubview:self.passwordRepeatField];
        [self.passwordLockUnlockButton setNextKeyView:self.passwordRepeatField];
        [self.passwordRepeatField setNextKeyView:self.passwordExpiresField];
        [self.generalView addSubview:self.passwordRepeatLabel];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordRepeatField
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordField
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:8]];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordExpiresField
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordRepeatField
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:8]];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordField
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordRepeatField
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordField
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordRepeatField
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordField
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordRepeatField
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordRepeatLabel
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                        toItem:self.generalView
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0f
                                                                      constant:17.f]];

        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordRepeatLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0]];
        [self.generalView addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordRepeatLabel
                                                                     attribute:NSLayoutAttributeBaseline
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.passwordRepeatField
                                                                     attribute:NSLayoutAttributeBaseline
                                                                    multiplier:1.0
                                                                      constant:0]];
    }

    self.readonly = readonly;
}

- (IBAction)modifyClicked:(id)sender {
    [self switchReadonlyMode:!self.readonly];
}

#pragma mark -
#pragma mark Action Buttons

- (IBAction)okClicked:(id)sender {
    [[NSApplication sharedApplication] endSheet: self.window];
    [self.window makeFirstResponder:nil];

    if (self.dirty) {
        [self.delegate didSaveEditEntry:self.entry unchangedEntry:self.unchangedEntry];
    }
}

- (IBAction)cancelClicked:(id)sender {

    [[NSApplication sharedApplication] endSheet: self.window];
}

- (IBAction)lockUnlockPassword:(id)sender {
    // NSTextFieldCell cannot show bullets like in NSSecureTextFieldCell, and NSSecureTextFieldCell cannot be configured to show the plaintext
    // => hack: resign first responder, and then switch between NSTExtFieldCell NSSecureTextFieldCell (not sure if this is an intended API usage)
    [self.window makeFirstResponder:self.titleField];

    if ([self.passwordField.cell isKindOfClass:[NSSecureTextFieldCell class]]) {
        self.passwordField.cell = [[NSTextFieldCell alloc] initTextCell:self.passwordField.stringValue];
        self.passwordRepeatField.cell = [[NSTextFieldCell alloc] initTextCell:self.passwordRepeatField.stringValue];
        [self.passwordLockUnlockButton setImage:[NSImage imageNamed:@"NSLockUnlockedTemplate"]];
        self.passwordLockUnlockButton.toolTip = LocalizedStringOSX(@"Show password");
    }
    else {
        self.passwordField.cell = [[NSSecureTextFieldCell alloc] initTextCell:self.passwordField.stringValue];
        self.passwordRepeatField.cell = [[NSSecureTextFieldCell alloc] initTextCell:self.passwordRepeatField.stringValue];
        [self.passwordLockUnlockButton setImage:[NSImage imageNamed:@"NSLockLockedTemplate"]];
        self.passwordLockUnlockButton.toolTip = LocalizedStringOSX(@"Hide password");
    }
    [self.passwordField setNeedsDisplay:YES];
    [self.passwordRepeatField setNeedsDisplay:YES];
    
    [self setStyleOfTextFieldsWithReadonly:self.readonly];

    // select password field
    [self.passwordField becomeFirstResponder];
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent keyCode] == 53) {
        [self cancelClicked:self];
    }
}

#pragma mark -
#pragma mark Track dirty state

- (void)controlTextDidChange:(NSNotification *)obj {
    // assume that the entry has changed!
    self.dirty = true;
    [self controlButtons];
}

// NSTextFieldDelegate method
- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
    [self validate];
}

- (void)validate {
    NSString *strUnchanged = [self.unchangedEntry stringRepresentationToCheckDirty];
    NSString *strCurrent = [self.entry stringRepresentationToCheckDirty];
    self.dirty = ![strUnchanged isEqualToString:strCurrent];
    [self controlButtons];
}

- (void)controlButtons {
    if (self.dirty) {
        self.okButton.title = LocalizedString(@"OK");
        self.okButton.keyEquivalent = @"\r";
    }
    else {
        self.okButton.title = LocalizedStringOSX(@"Close");
        self.okButton.keyEquivalent = @"\E";
    }
    [self.cancelButton setHidden:!self.dirty];
}

@end
