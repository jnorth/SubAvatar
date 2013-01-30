// SubAvatarGravatarService.m
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

#import "SubAvatarGravatarService.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SubAvatarGravatarService

+ (id)service {
  return [[self alloc] init];
}

- (NSImage *)imageForIdentity:(NSString *)identity {
  NSURL *url = [self URLForIdentity:identity];

  if (!url) {
    return nil;
  }

  return [[NSImage alloc] initWithContentsOfURL:url];
}

- (NSURL *)URLForIdentity:(NSString *)identity {
  if (!identity) {
    return nil;
  }

  // Gravatar can only search by email address
  NSRange range = [identity rangeOfString:@"@"];

  if (range.location == NSNotFound) {
    return nil;
  }

  // Build URL
  NSString *hash = [self md5HexDigest:identity];
  NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%i&d=%@", hash, 48, @"404"];
  return [NSURL URLWithString:url];
}

- (NSString*)md5HexDigest:(NSString*)input {
  const char *bytes = [input UTF8String];
  unsigned char hashBytes[CC_MD5_DIGEST_LENGTH];
  CC_MD5(bytes, (CC_LONG)strlen(bytes), hashBytes);

  NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [hash appendFormat:@"%02x", hashBytes[i]];
  }

  return hash;
}

@end