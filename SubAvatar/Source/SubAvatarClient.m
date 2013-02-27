// SubAvatarClient.m
// SubAvatar
//
// Copyright (c) 2012 Joseph North (http://sublink.ca/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SubAvatarClient.h"
#import "SubAvatarOperation.h"

@implementation SubAvatarClient {
  NSMutableArray *_services;

  NSMutableDictionary *_activeLookups;
  NSOperationQueue *_queue;
}

+ (id)client {
  return [[self alloc] initWithOperationQueue:nil];
}

+ (id)clientWithOperationQueue:(NSOperationQueue *)queue {
  return [[self alloc] initWithOperationQueue:queue];
}

- (id)initWithOperationQueue:(NSOperationQueue *)queue {
  self = [self init];

  if (self) {
    _services = [NSMutableArray array];

    _activeLookups = [NSMutableDictionary dictionary];

    if (queue) {
      _queue = queue;
    } else {
      _queue = [[NSOperationQueue alloc] init];
      _queue.maxConcurrentOperationCount = 16;
    }
  }

  return self;
}

#pragma mark -

- (void)addService:(id<SubAvatarService>)service {
  if (service && ![_services containsObject:service]) {
    [_services addObject:service];
  }
}

- (void)removeService:(id<SubAvatarService>)service {
  if (service && [_services containsObject:service]) {
    [_services removeObject:service];
  }
}

- (void)removeAllServices {
  [_services removeAllObjects];
}

- (void)lookupIdentity:(NSString *)identity block:(SubAvatarCompletionBlock)block {
  if (!identity) {
    if (block) block(identity, nil);
    return;
  }

  // Image cache hit -- just dispatch the block directly

  if ([self hasCachedImageForIdentity:identity]) {
    if (block) block(identity, [self cachedImageForIdentity:identity]);
    return;
  }

  // Image cache miss...

  // If there is already an operation for the identity, piggy-back on that one
  __weak SubAvatarOperation *activeOperation = _activeLookups[identity];

  if (activeOperation) {
    void (^tBlock)(void) = activeOperation.completionBlock;

    activeOperation.completionBlock = ^{
      if (tBlock) tBlock();

      dispatch_async(dispatch_get_main_queue(), ^{
        block(activeOperation.identity, [self cachedImageForIdentity:activeOperation.identity]);
      });
    };

    return;
  }

  // Otherwise, create a new operation
  __weak SubAvatarOperation *operation = [SubAvatarOperation operationWithIdentity:identity services:_services];

  operation.completionBlock = ^{
    // Remove operation from active list
    [_activeLookups removeObjectForKey:operation.identity];

    // Process image
    if (operation.image && self.imageProcessingBlock) {
      operation.image = self.imageProcessingBlock(operation.identity, operation.image);
    }

    // Cache result
    // We use NSNull to indicate that no image was found
    _cache[operation.identity] = operation.image ?: [NSNull null];

    // Call block
    if (block) {
      dispatch_async(dispatch_get_main_queue(), ^{
        block(operation.identity, operation.image);
      });
    }
  };

  _activeLookups[identity] = operation;

  // Add operation to queue
  [_queue addOperation:operation];
}

#pragma mark -
#pragma mark Cache

- (BOOL)hasCachedImageForIdentity:(NSString *)identity {
  if (!self.cache) {
    return NO;
  }

  if (!identity) {
    return NO;
  }

  return self.cache[identity] != nil;
}

- (NSImage *)cachedImageForIdentity:(NSString *)identity {
  id image = self.cache[identity];
  return [image isKindOfClass:[NSNull class]] ? nil : image;
}

@end