//
//  ViewController.m
//  lowpolytest
//
//  Created by consoar on 16/9/2.
//  Copyright © 2016年 com. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Convolution.h"
#import "UIImage+Color.h"
#import "Sobel.h"
#import "Delaunay.h"

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define DEBUG 0

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"iron2.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //边缘检测
    UIImage *edgeDetectorImage = [Sobel sobelEdgeDetector:image];
    
    imageView.image = edgeDetectorImage;
    [self.view addSubview:imageView];
    
    //边缘取点
    NSMutableArray *points = [[Sobel getPointsArray:edgeDetectorImage] mutableCopy];
    NSMutableArray *newPoints = [NSMutableArray array];
    [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(image.size.width * 2.0, 0)]];
    [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(image.size.width * 2.0, image.size.height * 2.0)]];
    [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, image.size.height * 2.0)]];

    //选取非边缘的点
//    int pointCount = 10;
//    for (int i = 0; i < pointCount; i++) {
//        NSValue *value = [NSValue valueWithCGPoint:CGPointMake((int) ((double)arc4random() / 0x100000000 * image.size.width), (int) ((double)arc4random() / 0x100000000 * image.size.height))];
//        [newPoints addObject:value];
//    }
    
    int accuracy = 8; //比例因子选取1/accuracy的点加入到生成三角型的顶点集合中
    int len = (int)points.count / accuracy;
    for (int i = 0; i < len; i++) {
        int random = (int) ((double)arc4random() / 0x100000000 * points.count);
        [newPoints addObject:[points objectAtIndex:random]];
        [points removeObjectAtIndex:random];
    }

    NSArray *pointsIndex = [Delaunay triangulate:newPoints];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width* 2, image.size.height* 2), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context,NO);//取消抗锯齿
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);//线框颜色
    CGContextSetLineWidth(context, 0.5);//线的宽度
    if (DEBUG) {
        CGContextSetLineWidth(context, 0.5);//线的宽度
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);//线框颜色
    }
    for (int i = 0; i < pointsIndex.count; i = i+3) {
        CGPoint p1 = [newPoints[[pointsIndex[i] intValue]] CGPointValue];
        CGPoint p2 = [newPoints[[pointsIndex[i+1] intValue]] CGPointValue];
        CGPoint p3 = [newPoints[[pointsIndex[i+2] intValue]] CGPointValue];
        if (DEBUG) {
            CGContextSetStrokeColorWithColor(context, getPixelColor(image,(p1.x+p2.x+p3.x)/3,(p1.y+p2.y+p3.y)/3).CGColor);//线框颜色
        }
        CGContextSetFillColorWithColor(context, getPixelColor(image,(p1.x+p2.x+p3.x)/3,(p1.y+p2.y+p3.y)/3).CGColor);
        CGContextMoveToPoint(context, p1.x,p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextAddLineToPoint(context, p3.x, p3.y);
        CGContextAddLineToPoint(context, p1.x, p1.y);
        CGContextClosePath(context);
        if (DEBUG) {
            CGContextStrokePath(context);
        }
        CGContextFillPath(context);
    }

    UIImage *mergeImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imageView.image = mergeImg;
}

@end
