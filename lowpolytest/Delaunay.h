//
//  Delaunay.h
//  lowpolytest
//
//  Created by consoar on 16/9/19.
//  Copyright © 2016年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface Circumcircle : NSObject

@property (nonatomic) NSInteger i;
@property (nonatomic) NSInteger j;
@property (nonatomic) NSInteger k;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat r;

@end

@interface Delaunay : NSObject

+ (NSArray *)triangulate:(NSArray *)points;

@end
