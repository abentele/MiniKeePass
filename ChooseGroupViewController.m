/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ChooseGroupViewController.h"
#import "MiniKeePassAppDelegate.h"

#define INDENT_LEVEL 3

@interface ChooseGroupViewController () {
    NSMutableArray *allGroups;
    MiniKeePassAppDelegate *appDelegate;
}

@end

@implementation ChooseGroupViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Choose Group", nil);
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    return self;
}

- (void)addGroups:(NSArray *)groups toArray:(NSMutableArray *)array atLevel:(NSInteger)level {
    // Add subgroups
    NSArray *sortedGroups = [groups sortedArrayUsingComparator:^NSComparisonResult(KdbGroup *group1, KdbGroup *group2) {
        return [group1.name localizedCaseInsensitiveCompare:group2.name];
    }];
    BOOL valid;
    for (KdbGroup *group in sortedGroups) {
        // Add this group
        valid = [self.delegate checkChoiceValidity:group success:nil failure:nil];
        [array addObject:@{@"group" : group, @"level" : [NSNumber numberWithUnsignedInteger:level], @"valid" : [NSNumber numberWithBool:valid]}];

        // Add its subgroups
        [self addGroups:group.groups toArray:array atLevel:level + INDENT_LEVEL];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (MiniKeePassAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    allGroups = [[NSMutableArray alloc] initWithCapacity:50];
}

- (void)viewWillAppear:(BOOL)animated {
    // Contruct table
    KdbGroup *rootGroup = appDelegate.databaseDocument.kdbTree.root;
    NSString *filename = [appDelegate.databaseDocument.filename lastPathComponent];
    BOOL valid = [self.delegate checkChoiceValidity:rootGroup success:nil failure:nil];

    // Add root group
    [allGroups addObject:@{@"group" : rootGroup, @"level" : [NSNumber numberWithUnsignedInteger:0], @"name" : filename, @"valid" : [NSNumber numberWithBool:valid]}];
    
    // Recursivly add subgroups
    [self addGroups:rootGroup.groups toArray:allGroups atLevel:INDENT_LEVEL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [allGroups objectAtIndex:indexPath.row];
    return [[dict objectForKey:@"level"] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *dict = [allGroups objectAtIndex:indexPath.row];
    KdbGroup *group = [dict objectForKey:@"group"];
    
    NSString *name = [dict objectForKey:@"name"];
    cell.textLabel.text = name ? name : group.name;
    cell.imageView.image = [appDelegate loadImage:group.image];
    
    BOOL valid = [[dict objectForKey:@"valid"] boolValue];
    if (valid) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *groupDict = [allGroups objectAtIndex:indexPath.row];
    KdbGroup *chosenGroup = [groupDict objectForKey:@"group"];
    [self.delegate checkChoiceValidity:chosenGroup success:^{
        [self.delegate chooseGroup:chosenGroup];
        [self dismissModalViewControllerAnimated:YES];
    } failure:^(NSString *errorMessage) {
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        NSLog(@"%@", errorMessage);
    }];
}

@end
