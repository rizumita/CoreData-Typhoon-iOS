//
//  CoreData_Typhoon_iOSTests.m
//  CoreData-Typhoon-iOSTests
//
//  Created by 和泉田 領一 on 2014/04/29.
//  Copyright (c) 2014年 CAPH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Typhoon.h"
#import "CTiOSCoreDataAssembly.h"
#import "TyphoonPatcher.h"

@interface CoreData_Typhoon_iOSTests : XCTestCase

@end

@implementation CoreData_Typhoon_iOSTests

+ (void)initialize
{
    TyphoonComponentFactory *factory = [[TyphoonBlockComponentFactory alloc] initWithAssemblies:@[[CTiOSCoreDataAssembly assembly]]];

    id <TyphoonResource> configurationProperties = [TyphoonBundleResource withName:@"Configuration.properties"];
    [factory attachPostProcessor:[TyphoonPropertyPlaceholderConfigurer configurerWithResource:configurationProperties]];
    [factory makeDefault];

    TyphoonPatcher* patcher = [[TyphoonPatcher alloc] init];
    [patcher patchDefinitionWithKey:@"mainBundle" withObject:^id {
        return [NSBundle bundleForClass:self];
    }];
    [patcher patchDefinitionWithKey:@"storeType" withObject:^id {
        return NSInMemoryStoreType;
    }];

    [factory attachPostProcessor:patcher];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMainManagedObjectContext
{
    NSManagedObjectContext *mainContext1 = [(CTiOSCoreDataAssembly *)[TyphoonComponentFactory defaultFactory] mainManagedObjectContext];
    XCTAssertNotNil(mainContext1);
    XCTAssertNil(mainContext1.parentContext);
    XCTAssertNotNil(mainContext1.persistentStoreCoordinator);

    NSManagedObjectContext *mainContext2 = [(CTiOSCoreDataAssembly *)[TyphoonComponentFactory defaultFactory] mainManagedObjectContext];
    XCTAssertEqual(mainContext1, mainContext2);
}

- (void)testChildManagedObjectContext
{
    NSManagedObjectContext *childContext1 = [(CTiOSCoreDataAssembly *)[TyphoonComponentFactory defaultFactory] childManagedObjectContext];
    XCTAssertNotNil(childContext1);

    NSManagedObjectContext *mainContext = [(CTiOSCoreDataAssembly *)[TyphoonComponentFactory defaultFactory] mainManagedObjectContext];
    XCTAssertEqual(childContext1.parentContext, mainContext);

    NSManagedObjectContext *childContext2 = [(CTiOSCoreDataAssembly *)[TyphoonComponentFactory defaultFactory] childManagedObjectContext];
    XCTAssertNotEqual(childContext1, childContext2);
}

@end
