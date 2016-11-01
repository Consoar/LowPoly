//
//  Delaunay.m
//  lowpolytest
//
//  Created by consoar on 16/9/19.
//  Copyright © 2016年 com. All rights reserved.
//

#import "Delaunay.h"

@implementation Circumcircle

@end

@implementation Delaunay

double EPSILON = 0.00001f;


NSArray * supertriangle(NSArray *vertices) {
    int xmin = INT_MAX;
    int ymin = INT_MAX;
    int xmax = INT_MIN;
    int ymax = INT_MIN;
    
    float dx, dy, dmax, xmid, ymid;
    
    for (int i = vertices.count - 1; i >= 0; i--) {
        CGPoint p = [vertices[i] CGPointValue];
        if (p.x < xmin) xmin = p.x ;
        if (p.x > xmax) xmax = p.x ;
        if (p.y < ymin) ymin = p.y;
        if (p.y > ymax) ymax = p.y;
    }
    
    dx = xmax - xmin;
    dy = ymax - ymin;
    
    dmax = dx>dy?dx:dy;
    
    xmid = (xmin + dx * 0.5f);
    ymid = (ymin + dy * 0.5f);
    
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:[NSValue valueWithCGPoint:CGPointMake((int) (xmid - 20 * dmax), (int) (ymid - dmax))]];
    [result addObject:[NSValue valueWithCGPoint:CGPointMake((int) xmid, (int) (ymid + 20 * dmax))]];
    [result addObject:[NSValue valueWithCGPoint:CGPointMake((int) (xmid + 20 * dmax), (int) (ymid - dmax))]];

    return result;
}

Circumcircle *circumcircle(NSArray *vertices, int i, int j, int k) {
    CGPoint a = [vertices[i] CGPointValue];
    CGPoint b = [vertices[j] CGPointValue];
    CGPoint c = [vertices[k] CGPointValue];

    double x1 = a.x;
    double y1 = a.y;
    double x2 = b.x;
    double y2 = b.y;
    double x3 = c.x;
    double y3 = c.y;
    
    
    double fabsy1y2 = fabs(y1 - y2);
    double fabsy2y3 = fabs(y2 - y3);
    
    float xc, yc, m1, m2, mx1, mx2, my1, my2, dx, dy;
    
    if (fabsy1y2 <= EPSILON) {
        m2 = -((float) (x3 - x2) / (y3 - y2));
        mx2 = (x2 + x3) / 2.0;
        my2 = (y2 + y3) / 2.0;
        xc = (x2 + x1) / 2.0;
        yc = m2 * (xc - mx2) + my2;
    } else if (fabsy2y3 <= EPSILON) {
        m1 = -((float) (x2 - x1) / (y2 - y1));
        mx1 = (x1 + x2) / 2.0;
        my1 = (y1 + y2) / 2.0;
        xc = (x3 + x2) / 2.0;
        yc = m1 * (xc - mx1) + my1;
    } else {
        m1 = -((float) (x2 - x1) / (y2 - y1));
        m2 = -((float) (x3 - x2) / (y3 - y2));
        mx1 = (x1 + x2) / 2.0;
        mx2 = (x2 + x3) / 2.0;
        my1 = (y1 + y2) / 2.0;
        my2 = (y2 + y3) / 2.0;
        xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
        yc = (fabsy1y2 > fabsy2y3) ?
        m1 * (xc - mx1) + my1 :
        m2 * (xc - mx2) + my2;
    }
    
    dx = x2 - xc;
    dy = y2 - yc;

    Circumcircle *circumcircle = [Circumcircle new];
    circumcircle.i = i;
    circumcircle.j = j;
    circumcircle.k = k;
    circumcircle.x = xc;
    circumcircle.y = yc;
    circumcircle.r = (dx * dx + dy * dy);
    
    return circumcircle;
}

void dedup(NSMutableArray *edges) {
    int a, b, m, n;
    for (int j = edges.count; j > 0; ) {
        while (j > edges.count) {
            j--;
        }
        if (j <= 0) {
            break;
        }
        b = [[edges objectAtIndex:--j] intValue];
        a = [[edges objectAtIndex:--j] intValue];
        
        for (int i = j; i > 0; ) {
            n = [[edges objectAtIndex:--i] intValue];
            m = [[edges objectAtIndex:--i] intValue];
            
            if ((a == m && b == n) || (a == n && b == m)) {
                if (j + 1 < edges.count)
                    [edges removeObjectAtIndex:(j + 1)];
                [edges removeObjectAtIndex:j];
                if (i + 1 < edges.count)
                    [edges removeObjectAtIndex:(i + 1)];
                [edges removeObjectAtIndex:i];
                break;
            }
        }
    }
}

NSArray *triangulate(NSMutableArray *vertices) {
    int n = vertices.count;
    
    if (n < 3) {
        return nil;
    }
    
    NSMutableArray *indices = [NSMutableArray array];
    
    for (int i = 0; i < n; i++) {
        [indices addObject:@(i)];
    }
    
    indices = [[indices sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CGPoint p1 = [vertices[[obj1 intValue]] CGPointValue];
        CGPoint p2 = [vertices[[obj2 intValue]] CGPointValue];

        if (p1.x > p2.x) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (p1.x < p2.x){
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            if (p1.y > p2.y) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if (p1.y < p2.y){
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }
    }] mutableCopy];
    
    NSArray *st = supertriangle(vertices);
    
    [vertices addObject:st[0]];
    [vertices addObject:st[1]];
    [vertices addObject:st[2]];
    
    NSMutableArray *open = [NSMutableArray array];
    [open addObject:circumcircle(vertices, n, n + 1, n + 2)];
    
    NSMutableArray *closed = [NSMutableArray array];

    NSMutableArray *edges = [NSMutableArray array];

    for (int i = n - 1; i >= 0; i--) {
        
        int c = [indices[i] intValue];
        
        for (int j = open.count - 1; j >= 0; j--) {
            
            Circumcircle *cj = open[j];
            CGPoint vj = [vertices[c] CGPointValue];
            
            float dx = vj.x - cj.x;
            
            if (dx > 0 && dx * dx > cj.r) {
                [closed addObject:cj];
                [open removeObjectAtIndex:j];
                continue;
            }
            
            float dy = vj.y - cj.y;
            
            if (dx * dx + dy * dy - cj.r > EPSILON) {
                continue;
            }
            
            [edges addObject:@(cj.i)];
            [edges addObject:@(cj.j)];
            [edges addObject:@(cj.j)];
            [edges addObject:@(cj.k)];
            [edges addObject:@(cj.k)];
            [edges addObject:@(cj.i)];
            
            [open removeObjectAtIndex:j];
        }
        
        dedup(edges);
        
        for (int j = edges.count; j > 0; ) {
            int b = [[edges objectAtIndex:--j] intValue];
            int a = [[edges objectAtIndex:--j] intValue];
            [open addObject:circumcircle(vertices, a, b, c)];
        }
        
        [edges removeAllObjects];
    }
    
    for (int i = open.count - 1; i >= 0; i--) {
        [closed addObject:open[i]];
    }
    
    [open removeAllObjects];
    
    NSMutableArray *outResult = [NSMutableArray array];
    
    for (int i = closed.count - 1; i >= 0; i--) {
        Circumcircle *ci = closed[i];
        if (ci.i < n && ci.j < n && ci.k < n) {
            [outResult addObject:@((int) ci.i)];
            [outResult addObject:@((int) ci.j)];
            [outResult addObject:@((int) ci.k)];
        }
    }
    return outResult;
}

+ (NSArray *)triangulate:(NSMutableArray *)points {
    
    return triangulate(points);
}

@end
