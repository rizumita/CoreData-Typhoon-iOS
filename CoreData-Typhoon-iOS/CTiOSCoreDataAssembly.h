//
// Created by rizumita on 2013/12/23.
//


#import <Foundation/Foundation.h>
#import "Typhoon.h"


@interface CTiOSCoreDataAssembly : TyphoonAssembly

- (id)mainManagedObjectContext;

- (id)childManagedObjectContext;

- (id)persistentStoreCoordinator;

- (id)managedObjectModel;

@end