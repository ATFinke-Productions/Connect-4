//
//  CreditsTableViewController.m
//  StockTable
//
//  Created by Andrew on 6/16/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "CreditsTableViewController.h"
#import "CreditsWebViewController.h"
@interface CreditsTableViewController ()

@end

@implementation CreditsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"showWeb" sender:@"http://developer.apple.com/wwdc/"];
            }
            else if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"showWeb" sender:@"http://github.com/nicklockwood"];
            }
        case 1:
            if (indexPath.row == 0) {
                [self showAppStore];
            }
            else if (indexPath.row == 1) {
                [self emailSupport];
            }
            break;
        case 2:
            if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"showWeb" sender:@"http://www.atfinkeproductions.com"];
            }
            break;
        default:
            break;
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showWeb"]) {
        [[segue destinationViewController] setWebItem:sender];
    }
}
                 
- (void) emailSupport {
    MFMailComposeViewController * vc = [[MFMailComposeViewController alloc]init];
    [vc setToRecipients:@[@"andrew@atfinkeproductions.com"]];
    [vc setSubject:@"Connect 4 App Support"];
    vc.mailComposeDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) showAppStore {
    NSNumber * AppStoreNSID = [NSNumber numberWithInt:[@"681285235" intValue]];
    SKStoreProductViewController * productController = [[SKStoreProductViewController alloc] init];
    productController.delegate = (id<SKStoreProductViewControllerDelegate>)self;
    NSDictionary *productParameters = @{SKStoreProductParameterITunesItemIdentifier:AppStoreNSID};
    [productController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
    }];
    [self presentViewController:productController animated:YES completion:nil];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
