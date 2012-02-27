//
//  MainViewController.m
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController


#define BAC_MAX_MEASURED_VALUE .20
#define BAC_BAR_HEIGHT 400.0
#define BAC_THRESHOLD_GREEN 157.0
#define BAC_THRESHOLD_YELLOW 225.0


BOOL isConnected = FALSE;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorStateChangeNotification:) name:@"stateChanged" object:[BACController sharedInstance]];
    }
    return self;
}

//## BAC CONTROLLER DELEGATE METHODS

-(void)receivedSensorStateChangeNotification:(id)sender {
    int state = [[BACController sharedInstance] currentState];
    
    switch (state) {
        case DISCONNECTED:
            //dismiss instructions
            if (popupView) {
                [popupView.view removeFromSuperview];                
                popupView = nil;
            }
            break;
        case OFF:
            //dismiss instructions
            if (popupView) {
                [popupView.view removeFromSuperview];                
                popupView = nil;
            }
            break;
        case ON_WARMING:
            break;
        case ON_READY:
            //swap back to original tab!
            [self setTab:1];
            //show blowing instructions
            popupView = [[InstructionsViewController alloc] init];
            [popupView.view setFrame:CGRectMake(0,0,0,0)];
            [self.view addSubview:popupView.view];
            [UIView transitionWithView:self.view duration:.3 options:UIViewAnimationCurveLinear animations:^{ 
                [popupView.view setFrame:CGRectMake(160, 0, 160, 100)];
            } completion:nil];
            break;
            
            
            break;
        case ON_BLOWING_INTO:
            //swap instructions to say "blow for 4 seconds"
            break;
        case UNKNOWN:
            if (popupView) {
                [popupView.view removeFromSuperview];  
                popupView = nil;
            }
            //dismiss instructions
            break;
        default:
            break;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    statusBar = [[StatusBar alloc] init];
    [statusBarView addSubview:statusBar.view];
    
    [self setTab:1];
    [tabBar setSelectedItem:[[tabBar items] objectAtIndex:1]];
}

-(IBAction)writeTestCharPushed:(id)sender {
    [[BACController sharedInstance] sendTestChar];
}


-(void)updateUIForBAC {
    double bac = [sensorController getCurrentBAC];
    bacLabel.text = [NSString stringWithFormat:@"%00.3f", bac];
    
    int height = (bac/BAC_MAX_MEASURED_VALUE)*BAC_BAR_HEIGHT;
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionCurveEaseOut+UIViewAnimationOptionBeginFromCurrentState animations:^{ 
        [bacBarIV setFrame:CGRectMake(
                                      bacBarIV.frame.origin.x,
                                      460-(height),
                                      bacBarIV.frame.size.width, bacBarIV.frame.size.height)];
    } completion:nil];
    if (height < BAC_THRESHOLD_GREEN) {
        [bacBarIV setImage:[UIImage imageNamed:@"bar_green.png"]];
    }
    if (height > BAC_THRESHOLD_GREEN) {
        [bacBarIV setImage:[UIImage imageNamed:@"bar_yellow.png"]];
    }
    if (height > BAC_THRESHOLD_YELLOW) {
        [bacBarIV setImage:[UIImage imageNamed:@"bar_red.png"]];
    }
    
}

-(void)setTab:(int)tabNum {
    if (tabNum == currentTab) return;
    
    //remove tabs
    switch (currentTab) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            
            break;
            
        default:
            break;
    }
    
    currentTab = tabNum;
    
    //TODO: find a better way to do this switching
    //Could just add backgrounds to tabs...
    for (UIView *view in tabView.subviews) {
        //[view removeFromSuperview];
    }
    [tabBar setSelectedItem:[[tabBar items] objectAtIndex:tabNum]];
    switch (tabNum) {
        case 0:
            //Logs
            if (readingsVC == nil) {
                readingsVC = [[ReadingsViewController alloc] init];
                [tabView addSubview:readingsVC.view];
                
            }
            [tabView bringSubviewToFront:readingsVC.view];
            [readingsVC refreshData];
            break;
        case 1:
            //Measure
            if (measureVC == nil) {
                measureVC = [[[[Theme sharedInstance] getMeasureVCClass] alloc] init];
                [tabView addSubview:measureVC.view];
            }
            
            [tabView bringSubviewToFront:measureVC.view];
            break;
        case 2:
            //More/Prefs
            if (prefsVC == nil) {
                prefsVC = [[PrefsViewController alloc] init];
                [tabView addSubview:prefsVC.view];
                
            }
            
            [tabView bringSubviewToFront:prefsVC.view];
            break;
            
        default:
            break;
    }
}

-(void)themeChanged {
    //[tabView bringSubviewToFront:measureVC.view];
    [self setTab:1];
    //DO IT NOWWWWW
    //THIS SHOULD CEASE TO EXIST
    //theme 1
    //to theme 2
    //add theme 2 to top, hidden
    //animation: view 2 not hidden, view 1 hidden
    //remove view 1
    
    //} else {
    //    nibObjs = [[NSBundle mainBundle] loadNibNamed:@"MeasureViewController" owner:self options:nil];
    //}
    
    //if (!theme) theme = [[Theme alloc] initWithTheme:0 andDelegate:self];
    
    //[theme setTheme:([theme getThemeNum]+1) % NUM_THEMES];
    
    //UIView *aView = [[Theme sharedInstance] getView:self];
    
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    //REMOVES TOP VIEW
    //for (UIView *sub in self.view.subviews) {
    //[sub removeFromSuperview];
    //}
    [measureVC.view removeFromSuperview];
    //[measureVC release];
    measureVC = [[[[Theme sharedInstance] getMeasureVCClass] alloc] init];
    [tabView addSubview:measureVC.view];
    
    
    //[aView setHidden:YES];
    //[self.view addSubview:aView];
    
    //[aView setHidden:NO];
    //[circle setFrame:CGRectMake(arc4random()%320, arc4random()%480, 300, 300)];
    [UIView commitAnimations];
    
    //[tabView addSubview:measureVC.view];
    
}

// TAB BAR METHODS

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self setTab:item.tag];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)dealloc {
    [super dealloc];
}


@end
