
/*
     File: RootViewController.m
 Abstract:  Abstract: The table view controller responsible for displaying the list of books, supporting additional functionality:
 
 * Drill-down to display more information about a selected book using an instance of DetailViewController;
 * Addition of new books using an instance of AddViewController;
 * Deletion of existing books using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 
 The root view controller creates and configures an instance of NSFetchedResultsController to manage the collection of books.  The view controller's managed object context is supplied by the application's delegate. When the user adds a new book, the root view controller creates a new managed object context to pass to the add view controller; this ensures that any changes made in the add controller do not affect the main managed object context, and they can be committed or discarded as a whole.
 
  Version: 1.1
 
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
#import "MovieViewController.h"

#import "DetailViewController.h"
#import "AddViewController.h"
#import "Movie.h"



@implementation MovieViewController

@synthesize fetchedResultsController, managedObjectContext, addingManagedObjectContext;
@synthesize sortTypes;
@synthesize searchBar;
@synthesize searchDC;

#pragma mark -
#pragma mark View lifecycle

-(id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self != nil) {
		
        self.title = @"Movie";
        self.tabBarItem.image = [UIImage imageNamed:@"name_gray.png"];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    sortTypes = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Title", @"label", @"Year", @"year", @"Director", @"director", @"date Added", @"dateAdded", nil];
	currentSort = @"label";
	// Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
	// Configure the add button.
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMovie)];
//    self.navigationItem.rightBarButtonItem = addButton;
//    [addButton release];
    
    // View 3 - Custom right bar button with a view
    UISegmentedControl *sortToggle = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:@"Sort",
                                             @"Add", nil]];
    
    sortToggle.segmentedControlStyle = UISegmentedControlStyleBar;
    sortToggle.selectedSegmentIndex = 0;
    sortToggle.momentary = TRUE;
    [sortToggle addTarget:self action:@selector(sortOrAdd:)
         forControlEvents:UIControlEventValueChanged];
    
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:sortToggle];
    [sortToggle release];
    
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
    
    //Add the search bar
    // Create a search bar - you can add this in the viewDidLoad
	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeAlphabet;
	self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
    
    // Create the search display controller
	self.searchDC = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
    
    searching = NO;
    letUserSelectRow = YES;
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (IBAction)sortOrAdd:(id)sender
{
    // The segmented control was clicked, handle it here 
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSLog(@"Segment clicked: %d", segmentedControl.selectedSegmentIndex);
    if (segmentedControl.selectedSegmentIndex == 1)
    {
        [self addMovie];
    }
    else
    {
        [self switchSort];
    }
}


- (void)viewWillAppear {
    [((iHaveNoNameAppDelegate*)[UIApplication sharedApplication].delegate) updateMovies];
	[self.tableView reloadData];
}


- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.fetchedResultsController = nil;
}


#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
		Movie *movie = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.textLabel.text = movie.label;
	cell.detailTextLabel.text = movie.tagline;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[fetchedResultsController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }   
}

#pragma mark -
#pragma mark Selection and moving

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];                 
    NSLog(@"test %@",[[[self fetchedResultsController] objectAtIndexPath:indexPath] valueForKey:@"year"]);
  
}
 
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Create and push a detail view controller.
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    Movie *selectedBook = (Movie *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected book to the new view controller.
    detailViewController.movie = selectedBook;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark SearchBar delegate

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    searching = YES;
    letUserSelectRow = NO;
    self.tableView.scrollEnabled = NO;
    
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    // Recover query
    [fetchedResultsController release];
    fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:@"Movies"];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    [self.tableView reloadData];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    
    searching = NO;
    letUserSelectRow = YES;
    self.tableView.scrollEnabled = YES;
}


#pragma mark -
#pragma mark Adding a Book

/**
 Creates a new book, an AddViewController to manage addition of the book, and a new managed object context for the add controller to keep changes made to the book discrete from the application's managed object context until the book is saved.
 IMPORTANT: It's not necessary to use a second context for this. You could just use the existing context, which would simplify some of the code -- you wouldn't need to merge changes after a save, for example. This implementation, though, illustrates a pattern that may sometimes be useful (where you want to maintain a separate set of edits).  The root view controller sets itself as the delegate of the add controller so that it can be informed when the user has completed the add operation -- either saving or canceling (see addViewController:didFinishWithSave:).
*/
- (IBAction)addMovie {
	
    AddViewController *addViewController = [[AddViewController alloc] initWithStyle:UITableViewStyleGrouped];
	addViewController.delegate = self;
	
	// Create a new managed object context for the new book -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingContext release];
	
	[addingManagedObjectContext setPersistentStoreCoordinator:[[fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
		
	addViewController.movie = (Movie *)[NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:addingContext];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[addViewController release];
	[navController release];
}

/**
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new book.
 */
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		/*
		 The new book is associated with the add controller's managed object context.
		 This is good because it means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad -- but it does make it more difficult to get the new book registered with the fetched results controller.
		 First, you have to save the new book.  This means it will be added to the persistent store.  Then you can retrieve a corresponding managed object into the application delegate's context.  Normally you might do this using a fetch or using objectWithID: -- for example
		 
		 NSManagedObjectID *newBookID = [controller.book objectID];
		 NSManagedObject *newBook = [applicationContext objectWithID:newBookID];
		 
		 These techniques, though, won't update the fetch results controller, which only observes change notifications in its context.
		 You don't want to tell the fetch result controller to perform its fetch again because this is an expensive operation.
		 You can, though, update the main context using mergeChangesFromContextDidSaveNotification: which will emit change notifications that the fetch results controller will observe.
		 To do this:
		 1	Register as an observer of the add controller's change notifications
		 2	Perform the save
		 3	In the notification method (addControllerContextDidSave:), merge the changes
		 4	Unregister as an observer
		 */
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;

	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}


/**
 Notification from the add controller's context's save operation. This is used to update the fetched results controller's managed object context with the new book instead of performing a fetch (which would be a much more computationally expensive operation).
 */
- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	// Merging changes causes the fetched results controller to update its results
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
}

- (void)switchSort 
{
	[fetchedResultsController release];
    fetchedResultsController = nil;
    if ([currentSort compare:@"label"] == NSOrderedSame )
    {
        currentSort = @"year";
    }
    else if ([currentSort compare:@"year"] == NSOrderedSame )
    {
        currentSort = @"dateAdded";
    }
    else if ([currentSort compare:@"dateAdded"] == NSOrderedSame )
    {
        currentSort = @"director";
    }
    else if ([currentSort compare:@"director"] == NSOrderedSame )
    {
        currentSort = @"label";
    }
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init ];
    
    // Create and initialize the fetch results controller.
    NSString *query = self.searchBar.text;
	if (query && query.length) fetchRequest.predicate = [NSPredicate predicateWithFormat:@"label contains[cd] %@", query];
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *directorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"director" ascending:YES];
	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES];
	NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
	NSSortDescriptor *dateAddedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:titleDescriptor, yearDescriptor, directorDescriptor, dateAddedDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	

    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:currentSort cacheName:@"Movies"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[directorDescriptor release];
	[titleDescriptor release];
	[yearDescriptor release];
	[dateAddedDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = self.tableView;

	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
	[addingManagedObjectContext release];
    
    [searchBar release];
    [super dealloc];
}

@end

