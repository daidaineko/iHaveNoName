/*
     File: TheElementsAppDelegate.m
 Abstract: Application delegate that sets up the application.
  Version: 1.11
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "iHaveNoNameAppDelegate.h"
#import "XBMCCommunicator.h"

#import "XBMCViewController.h"
#import "MovieViewController.h"
#import "ActorsViewController.h"
#import "Movie.h"


@implementation iHaveNoNameAppDelegate

@synthesize tabBarController;
@synthesize portraitWindow;
@synthesize connectionTimer;
@synthesize movieViewController;

//- init {
//	if (self = [super init]) {
//		// initialize  to nil
//		portraitWindow = nil;
//		tabBarController = nil;
//	}
//	return self;
//}

- (void)updateMoviesCoreData:(id)result
{
    if (![[result objectForKey:@"failure"] boolValue])
    {
        NSArray* movies = [[result objectForKey:@"result"] objectForKey:@"movies"];
        NSEnumerator *enumerator = [movies objectEnumerator];
        id anObject;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init ];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        anObject = [enumerator nextObject];
        while (anObject) 
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"movieid == %@", [anObject valueForKey:@"movieid"]];
            [fetchRequest setPredicate:predicate];
            NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (array == nil || [array count] != 1)
            {
                NSManagedObject *movie;
                
                movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:managedObjectContext];
                
                [movie setValue:[anObject valueForKey:@"label"] forKey:@"label"];
                [movie setValue:[anObject valueForKey:@"director"] forKey:@"director"];
                [movie setValue:[anObject valueForKey:@"runtime"] forKey:@"runtime"];
                [movie setValue:[anObject valueForKey:@"writer"] forKey:@"writer"];
                [movie setValue:[anObject valueForKey:@"studio"] forKey:@"studio"];
                [movie setValue:[NSNumber numberWithInt:[[anObject valueForKey:@"movieid"] intValue]] forKey:@"movieid"];
                [movie setValue:[anObject valueForKey:@"plot"] forKey:@"plot"];
                [movie setValue:[anObject valueForKey:@"tagline"] forKey:@"tagline"];
                [movie setValue:[anObject valueForKey:@"plotOutline"] forKey:@"plotoutline"];
                [movie setValue:[anObject valueForKey:@"tagline"] forKey:@"tagline"];
                [movie setValue:[anObject valueForKey:@"genre"] forKey:@"genre"];
                [movie setValue:[anObject valueForKey:@"fanart"] forKey:@"fanart"];
                [movie setValue:[anObject valueForKey:@"thumbnail"] forKey:@"thumbnail"];
                [movie setValue:[anObject valueForKey:@"imdbnumber"] forKey:@"imdbid"];
                [movie setValue:[anObject valueForKey:@"year"] forKey:@"year"];
                NSLog(@"test %@",[anObject valueForKey:@"year"]);
                NSError *error;
                [managedObjectContext save:&error];
            }
            
            anObject = [enumerator nextObject];
        }
    }
}
- (void)updateTVShowsCoreData:(id)result
{
    
}

- (void)pongEvent:(id)result
{
    if ([[result objectForKey:@"failure"] boolValue])
    {
        NSLog(@"ERROR %@", [result objectForKey:@"message"]);
        
    }
    else
    {
        connected = true;
    }
}



- (UINavigationController *)newNavigationControllerForClass:(NSString*)class {
	// this is entirely a convenience method to reduce the repetition of the code
	// in the setupPortaitUserInterface
	// it returns a retained instance of the UINavigationController class. This is unusual, but 
	// it is necessary to limit the autorelease use as much as possible.
	
	// for each tableview 'screen' we need to create a datasource instance (the class that is passed in)
	// we then need to create an instance of ElementsTableViewController with that datasource instance
	// finally we need to return a UINaviationController for each screen, with the ElementsTableViewController
	// as the root view controller.
	
	// many of these require the temporary creation of objects that need to be released after they are configured
	// and factoring this out makes the setup code much easier to follow, but you can still see the actual
	// implementation here
	
	
	// the class type for the datasource is not crucial, but that it implements the 
	// ElementsDataSource protocol and the UITableViewDataSource Protocol is.
//	id<ElementsDataSource,UITableViewDataSource> dataSource = [[datasourceClass alloc] init];
	
	// create the ElementsTableViewController and set the datasource
	MovieViewController *theViewController;	
	theViewController = [[MovieViewController alloc] initWithStyle:UITableViewStylePlain];
	theViewController.managedObjectContext = self.managedObjectContext;
	
	// create the navigation controller with the view controller
	UINavigationController *theNavigationController;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:theViewController];
	
	// before we return we can release the dataSource (it is now managed by the ElementsTableViewController instance
//	[dataSource release];
	
	// and we can release the viewController because it is managed by the navigation controller
	[theViewController release];
	
	return theNavigationController;
}


- (void)setupPortraitUserInterface {
	// a local navigation variable
	// this is reused several times
	UINavigationController *localNavigationController;

    // Set up the portraitWindow and content view
	UIWindow *localPortraitWindow;
	localPortraitWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.portraitWindow = localPortraitWindow;

	// the localPortraitWindow data is now retained by the application delegate
	// so we can release the local variable
	[localPortraitWindow release];

	
    [portraitWindow setBackgroundColor:[UIColor blackColor]];
    
	// Create a tabbar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] init];
	
	// setup the view controllers for the different data representations
    
    XBMCViewController* xbmcViewController = [[XBMCViewController alloc] initWithNibName:@"XBMCView" bundle:nil];
	[localViewControllersArray addObject:xbmcViewController];
    [xbmcViewController release];
	
	// create the view controller and datasource for the ElementsSortedByNameDataSource
	// wrap it in a UINavigationController, and add that navigationController to the 
	// viewControllersArray array

	movieViewController = [[MovieViewController alloc] initWithStyle:UITableViewStylePlain];
	movieViewController.managedObjectContext = self.managedObjectContext;
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:movieViewController];
	[localViewControllersArray addObject:localNavigationController];
    [localNavigationController release];

    ActorsViewController* theViewController;
	theViewController = [[ActorsViewController alloc] initWithStyle:UITableViewStylePlain];
	theViewController.managedObjectContext = self.managedObjectContext;
    localNavigationController = [[UINavigationController alloc] initWithRootViewController:theViewController];
	[theViewController release];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = localViewControllersArray;
	
	// the localViewControllersArray data is now retained by the tabBarController
	// so we can release this version
	[localViewControllersArray release];
	
	// set the window subview as the tab bar controller
	[portraitWindow addSubview:tabBarController.view];
	
	// make the window visible
	[portraitWindow makeKeyAndVisible];


}


- (void) checkConnection: (NSTimer *) theTimer
{
    connected = false;
    NSDictionary *request = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"JSONRPC.Ping", @"cmd", [NSArray array], @"params"
                             ,nil];
    [[XBMCCommunicator sharedInstance] addJSONRequest:self selector:@selector(pongEvent:) request:request];    
}

- (void) updateMovies
{
    NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSArray arrayWithObjects:@"plot", @"director", @"writer", @"studio", @"genre", @"year", @"runtime", @"rating", @"tagline", @"plotoutline", @"imdbnumber", @"streamDetails", @"actors", nil], @"fields", nil];

    NSDictionary *request = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"VideoLibrary.GetMovies", @"cmd", requestParams, @"params",nil];
    [[XBMCCommunicator sharedInstance] addJSONRequest:self selector:@selector(updateMoviesCoreData:) request:request];    
}

- (void) updateTVShows
{
    NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSArray arrayWithObjects:@"plot", @"director", @"writer", @"studio", @"genre", @"year", @"runtime", @"rating", @"tagline", @"plotoutline", @"imdbnumber", @"actors", nil], @"fields", nil];
    NSDictionary *request = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"VideoLibrary.GetTvShows", @"cmd", requestParams, @"params",nil];
    [[XBMCCommunicator sharedInstance] addJSONRequest:self selector:@selector(updateTVShowsCoreData:) request:request];     
   
}

- (void) updateLibrary
{
    [self updateMovies];
    [self updateTVShows];
}




- (void)applicationDidFinishLaunching:(UIApplication *)application {
    movieViewController = nil;
	connected = false;
    
    connectionTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                              target: self
                                            selector: @selector(checkConnection:)
                                                      userInfo: nil repeats:TRUE];

    [[XBMCCommunicator sharedInstance] setAddress:@"192.168.1.13" port:@"2081" login:@"tintin" password:@"tintin"];
    [self updateLibrary];

    
    
	// configure the portrait user interface
	[self setupPortraitUserInterface];
	
	
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application 
{
    [movieViewController release];
	[connectionTimer invalidate];
    [connectionTimer release];
    connectionTimer = nil;
    
   
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CoreXBMC.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"CoreXBMC" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
    
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
	NSError *error;
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (void)dealloc {
	[tabBarController release];
	[portraitWindow release];  
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [super dealloc];
}

@end

