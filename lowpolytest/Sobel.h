//
//  Sobel.h
//  lowpolytest
//
//  Created by consoar on 16/9/2.
//  Copyright © 2016年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Sobel : NSObject

UIColor* getPixelColor(UIImage* image, int x, int y);

+ (UIImage *)sobelEdgeDetector:(UIImage *)image;
+ (NSArray *)getPointsArray:(UIImage *)image;

@end
