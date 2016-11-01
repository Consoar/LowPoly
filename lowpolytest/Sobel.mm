//
//  Sobel.m
//  lowpolytest
//
//  Created by consoar on 16/9/2.
//  Copyright © 2016年 com. All rights reserved.
//

#import "Sobel.h"

double kernelX[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
double kernelY[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

@implementation Sobel

+ (UIImage *)sobelEdgeDetector:(UIImage *)image {
    CGImageRef inImage = image.CGImage;
    CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    CFDataRef m_OutDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    UInt8 * m_OutPixelBuf = (UInt8 *) CFDataGetBytePtr(m_OutDataRef);
    
    int h = (int)CGImageGetHeight(inImage);
    int w = (int)CGImageGetWidth(inImage);
    UIImage *result = nil;
    
    double t = 0;
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            t = t + getGray(image, x, y);
        }
    }
    t = t/w/h;
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            int pixelX = (
                          (kernelX[0][0] * getGray(image, x - 1, y - 1)) +
                          (kernelX[0][1] * getGray(image, x, y - 1)) +
                          (kernelX[0][2] * getGray(image, x + 1, y - 1)) +
                          (kernelX[1][0] * getGray(image, x - 1, y)) +
                          (kernelX[1][1] * getGray(image, x, y)) +
                          (kernelX[1][2] * getGray(image, x + 1, y)) +
                          (kernelX[2][0] * getGray(image, x - 1, y + 1)) +
                          (kernelX[2][1] * getGray(image, x, y + 1)) +
                          (kernelX[2][2] * getGray(image, x + 1, y + 1))
                          );
            int pixelY = (
                          (kernelY[0][0] * getGray(image, x - 1, y - 1)) +
                          (kernelY[0][1] * getGray(image, x, y - 1)) +
                          (kernelY[0][2] * getGray(image, x + 1, y - 1)) +
                          (kernelY[1][0] * getGray(image, x - 1, y)) +
                          (kernelY[1][1] * getGray(image, x, y)) +
                          (kernelY[1][2] * getGray(image, x + 1, y)) +
                          (kernelY[2][0] * getGray(image, x - 1, y + 1)) +
                          (kernelY[2][1] * getGray(image, x, y + 1)) +
                          (kernelY[2][2] * getGray(image, x + 1, y + 1))
                          );
            int pixelInfo = ((w * y) + x ) * 4; // 4 bytes per pixel
            double G = sqrt((pixelX * pixelX) + (pixelY * pixelY));
            if (G > t) {
                m_OutPixelBuf[pixelInfo]     = 0;
                m_OutPixelBuf[pixelInfo + 1] = 0;
                m_OutPixelBuf[pixelInfo + 2] = 0;
                m_OutPixelBuf[pixelInfo + 3] = 255;
            } else {
                m_OutPixelBuf[pixelInfo]     = 255;
                m_OutPixelBuf[pixelInfo + 1] = 255;
                m_OutPixelBuf[pixelInfo + 2] = 255;
                m_OutPixelBuf[pixelInfo + 3] = 255;
            }
        }
    }
    
    CGContextRef ctx = CGBitmapContextCreate(m_OutPixelBuf,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),
                                             CGImageGetColorSpace(inImage),
                                             CGImageGetBitmapInfo(inImage)
                                             );
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(m_DataRef);
    CFRelease(m_OutDataRef);
    return result;
}

double getGray(UIImage* image, int x, int y) {
    CGImageRef imageRef = [image CGImage];
    NSUInteger w = CGImageGetWidth(imageRef);
    NSUInteger h = CGImageGetHeight(imageRef);
    if (x < 0 || y < 0 || x >= w || y >= h) {
        return 0;
    }
    static CFDataRef pixelData = nil;
    static UInt8* data = nil;
    if (!pixelData) {
        pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
        data = (UInt8*)CFDataGetBytePtr(pixelData);
    }
    
    int pixelInfo = ((w * y) + x ) * 4; // 4 bytes per pixel
    
    UInt8 red   = data[pixelInfo + 0];
    UInt8 green = data[pixelInfo + 1];
    UInt8 blue  = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    return (0.30 * red + 0.59 * green + 0.11 * blue);
}

+ (NSArray *)getPointsArray:(UIImage *) image {
    CGImageRef imageRef = [image CGImage];
    NSUInteger w = CGImageGetWidth(imageRef);
    NSUInteger h = CGImageGetHeight(imageRef);

    CFDataRef pixelData = nil;
    UInt8* data = nil;
    pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    data = (UInt8*)CFDataGetBytePtr(pixelData);
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            int pixelInfo = ((w * y) + x ) * 4; // 4 bytes per pixel
            
            UInt8 red   = data[pixelInfo + 0];
            UInt8 green = data[pixelInfo + 1];
            UInt8 blue  = data[pixelInfo + 2];
            UInt8 alpha = data[pixelInfo + 3];
            
            if (red == 0 && green == 0 && blue == 0) {
                CGPoint point1 = CGPointMake(x, y);
                NSValue *value = [NSValue valueWithCGPoint:point1];
                [pointsArray addObject:value];
            }
        }
    }
    return pointsArray;
}

UIColor* getPixelColor(UIImage* image, int x, int y) {
    CGImageRef imageRef = [image CGImage];
    NSUInteger w = CGImageGetWidth(imageRef);
    NSUInteger h = CGImageGetHeight(imageRef);
    if (x < 0 || y < 0 || x >= w || y >= h) {
        return nil;
    }
    static CFDataRef pixelData = nil;
    static UInt8* data = nil;
    if (!pixelData) {
        pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
        data = (UInt8*)CFDataGetBytePtr(pixelData);
    }
    
    int pixelInfo = ((w * y) + x ) * 4; // 4 bytes per pixel
    
    UInt8 red   = data[pixelInfo + 0];
    UInt8 green = data[pixelInfo + 1];
    UInt8 blue  = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

@end
