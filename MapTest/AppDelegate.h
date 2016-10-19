//
//  AppDelegate.h
//  MapTest
//
//  Created by MD313 on 10/11/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#define MAP_API_KEY @"AIzaSyABHEmRnrnf-KU_7Pbelkx5vI_ida5lZ08"
#define APPDELEGATE [AppDelegate sharedDelegate]

#import <UIKit/UIKit.h>
#import "PlaceModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong, nonatomic)PlaceModel *place0;
@property(strong, nonatomic)PlaceModel *place1;

+ (AppDelegate*) sharedDelegate;

@end

