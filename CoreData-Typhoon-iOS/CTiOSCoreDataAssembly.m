//
// Created by rizumita on 2013/12/23.
//


#import "CTiOSCoreDataAssembly.h"


@implementation NSPersistentStoreCoordinator (InjectedInitialization)

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)model type:(NSString *)type URL:(NSURL *)storeURL
                                   options:(NSDictionary *)options
{
    self = [self initWithManagedObjectModel:model];
    if (self) {
        [self addPersistentStoreWithType:type configuration:nil URL:storeURL options:options error:nil];
    }
    return self;
}

@end


@implementation CTiOSCoreDataAssembly
{

}

- (id)mainManagedObjectContext
{
    return [TyphoonDefinition withClass:[NSManagedObjectContext class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithConcurrencyType:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:@(NSMainQueueConcurrencyType)];
        }];

        [definition injectMethod:@selector(setPersistentStoreCoordinator:) parameters:^(TyphoonMethod *method) {
            [method injectParameterWith:self.persistentStoreCoordinator];
        }];

        definition.scope = TyphoonScopeSingleton;
        definition.lazy = YES;
    }];
}

- (id)childManagedObjectContext
{
    return [TyphoonDefinition withClass:[NSManagedObjectContext class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithConcurrencyType:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:@(NSConfinementConcurrencyType)];
        }];

        [definition injectMethod:@selector(setParentContext:) parameters:^(TyphoonMethod *method) {
            [method injectParameterWith:self.mainManagedObjectContext];
        }];
    }];
}

#pragma mark - Persistent store coordinator

- (id)persistentStoreCoordinator
{
    return [TyphoonDefinition withClass:[NSPersistentStoreCoordinator class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithManagedObjectModel:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:self.managedObjectModel];
        }];

        [definition injectMethod:@selector(addPersistentStoreWithType:configuration:URL:options:error:) parameters:^(TyphoonMethod *method) {
            [method injectParameterWith:self.storeType];
            [method injectParameterWith:nil];
            [method injectParameterWith:self.storeURL];
            [method injectParameterWith:nil];
            [method injectParameterWith:nil];
        }];
    }];
}

- (id)storeType
{
    return [TyphoonDefinition withClass:[NSString class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithString:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:NSSQLiteStoreType];
        }];
    }];
}

- (id)fileManager
{
    return [TyphoonDefinition withClass:[NSFileManager class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(defaultManager)];
    }];
}

- (id)applicationDocumentsDirectories
{
    return [TyphoonDefinition withClass:[NSArray class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(URLsForDirectory:inDomains:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:@(NSDocumentDirectory)];
            [initializer injectParameterWith:@(NSUserDomainMask)];
        }];

        definition.factory = self.fileManager;
    }];
}

- (id)applicationDocumentsDirectory
{
    return [TyphoonDefinition withClass:[NSURL class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(lastObject)];

        definition.factory = self.applicationDocumentsDirectories;
    }];
}

- (id)storeURL
{
    return [TyphoonDefinition withClass:[NSURL class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(URLByAppendingPathComponent:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:TyphoonConfig(@"coredata.sqlite")];
        }];

        definition.factory = self.applicationDocumentsDirectory;
    }];
}

#pragma mark - Managed object model

- (id)managedObjectModel
{
    return [TyphoonDefinition withClass:[NSManagedObjectModel class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithContentsOfURL:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:self.modelURL];
        }];
    }];
}

- (id)mainBundle
{
    return [TyphoonDefinition withClass:[NSBundle class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(mainBundle)];
    }];
}

- (id)modelURL
{
    return [TyphoonDefinition withClass:[NSURL class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(URLForResource:withExtension:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:TyphoonConfig(@"coredata.filename")];
            [initializer injectParameterWith:@"momd"];
        }];

        definition.factory = self.mainBundle;
    }];
}

@end