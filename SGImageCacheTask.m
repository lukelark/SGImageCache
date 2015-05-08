//
//  Created by matt on 22/05/14.
//

#import "SGImageCacheTask.h"
#import "SGCacheTaskPrivate.h"
#import "SGCachePrivate.h"
#import "SGImageCache.h"

@implementation SGImageCacheTask

- (void)completedWithFile:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];

    if (image) {
        [SGImageCache addData:data forURL:self.url requestHeaders:self.requestHeaders];
    } else {
        [self finish];
        return;
    }

    // force a decompress
    if (self.forceDecompress) {
        UIGraphicsBeginImageContext(CGSizeMake(1, 1));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
        UIGraphicsEndImageContext();
    }

    // call the completion blocks on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        for (SGCacheFetchCompletion completion in self.completions) {
            completion(image);
        }
    });

    self.succeeded = YES;
    [self finish];
}

@end
