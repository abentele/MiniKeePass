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

#import "HelpViewController.h"
#import "AutorotatingViewController.h"

@interface HelpViewController ()

@property (nonatomic, retain) NSArray *helpTopics;

@end

@implementation HelpTopic

- (id)initWithTitle:(NSString*)title resource:(NSString*)resource {
    self = [super init];
    if (self) {
        self.title = title;
        self.resource = resource;
    }
    return self;
}

@end

@implementation HelpViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Help", nil);
        self.helpTopics = [[NSArray alloc] initWithObjects:
                           [[HelpTopic alloc] initWithTitle:@"iTunes Import/Export" resource:@"itunes"],
                           [[HelpTopic alloc] initWithTitle:@"Dropbox Import/Export" resource:@"dropbox"],
                           [[HelpTopic alloc] initWithTitle:@"Safari/Email Import" resource:@"safariemail"],
                           [[HelpTopic alloc] initWithTitle:@"Create New Database" resource:@"createdb"],
                           [[HelpTopic alloc] initWithTitle:@"Key Files" resource:@"keyfiles"],
                           nil];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.helpTopics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell
    HelpTopic *helpTopic = (HelpTopic*)[self.helpTopics objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString(helpTopic.title, nil);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the title and resource of the selected help page
    HelpTopic *helpTopic = (HelpTopic*)[self.helpTopics objectAtIndex:indexPath.row];
    NSString *title = helpTopic.title;
    NSString *resource = helpTopic.resource;
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *localizedResource = [NSString stringWithFormat:@"%@-%@", language, resource];

    NSString *path = [[NSBundle mainBundle] pathForResource:localizedResource ofType:@"html"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSBundle mainBundle] pathForResource:resource ofType:@"html"];
    }
    
    // Get the URL of the respurce
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // Create a web view to display the help page
    UIWebView *webView = [[UIWebView alloc] init];
    webView.backgroundColor = [UIColor whiteColor];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    UIViewController *viewController = [[AutorotatingViewController alloc] init];
    viewController.title = NSLocalizedString(title, nil);
    viewController.view = webView;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
