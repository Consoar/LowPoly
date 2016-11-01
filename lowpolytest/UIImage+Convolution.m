//
//  UIImage+Convolution.m
//  lowpolytest
//
//  Created by consoar on 16/9/3.
//  Copyright © 2016年 com. All rights reserved.
//

#import "UIImage+Convolution.h"

#define SAFECOLOR(color) MIN(255,MAX(0,color))

@implementation UIImage (Convolution)

- (UIImage *)edgeDetect
{
    double dKernel[5][5] = {
        {0,  0.0,  1.0,  0.0, 0},
        {0,  1.0, -4.0,  1.0, 0},
        {0,  0.0,  1.0,  0.0, 0}
    };
    
    NSMutableArray *kernel = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:5];
        for (int j = 0; j < 5; j++) {
            [row addObject:[NSNumber numberWithDouble:dKernel[i][j]]];
        }
        [kernel addObject:row];
    }
    
    return [self applyConvolution:kernel];
}

- (UIImage*)applyConvolution:(NSArray*)kernel
{
    CGImageRef inImage = self.CGImage;
    CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    CFDataRef m_OutDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    UInt8 * m_OutPixelBuf = (UInt8 *) CFDataGetBytePtr(m_OutDataRef);
    
    int h = (int)CGImageGetHeight(inImage);
    int w = (int)CGImageGetWidth(inImage);
    
    int kh = (int)[kernel count] / 2;
    int kw = (int)[[kernel objectAtIndex:0] count] / 2;
    int i = 0, j = 0, n = 0, m = 0;
    
    for (i = 0; i < h; i++) {
        for (j = 0; j < w; j++) {
            int outIndex = (i*w*4) + (j*4);
            double r = 0, g = 0, b = 0;
            for (n = -kh; n <= kh; n++) {
                for (m = -kw; m <= kw; m++) {
                    if (i + n >= 0 && i + n < h) {
                        if (j + m >= 0 && j + m < w) {
                            double f = [[[kernel objectAtIndex:(n + kh)] objectAtIndex:(m + kw)] doubleValue];
                            if (f == 0) {continue;}
                            int inIndex = ((i+n)*w*4) + ((j+m)*4);
                            r += m_PixelBuf[inIndex] * f;
                            g += m_PixelBuf[inIndex + 1] * f;
                            b += m_PixelBuf[inIndex + 2] * f;
                        }
                    }
                }
            }
            m_OutPixelBuf[outIndex]     = SAFECOLOR((int)r);
            m_OutPixelBuf[outIndex + 1] = SAFECOLOR((int)g);
            m_OutPixelBuf[outIndex + 2] = SAFECOLOR((int)b);
            m_OutPixelBuf[outIndex + 3] = 255;
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
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(m_DataRef);
    CFRelease(m_OutDataRef);
    
    return finalImage;
}

@end
