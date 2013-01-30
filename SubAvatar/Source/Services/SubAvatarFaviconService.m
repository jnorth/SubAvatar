// SubAvatarFaviconService.m
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

#import "SubAvatarFaviconService.h"

@implementation SubAvatarFaviconService

+ (id)service {
  return [[self alloc] init];
}

#pragma mark -

- (NSImage *)imageForIdentity:(NSString *)identity {
  if (!identity) {
    return nil;
  }

  // Look for domain
  NSRange atRange = [identity rangeOfString:@"@"];
  if (atRange.location == NSNotFound) return nil;
  NSString *domain = [identity substringFromIndex:atRange.location + atRange.length];

  // Loop over subdomains
  while (1) {
    NSArray *parts = [domain componentsSeparatedByString:@"."];
    if (parts.count < 2) return nil;

    // Search for image
    NSImage *image = [self imageForDomain:domain];
    if (image) return image;

    // Try cutting off a subdomain
    NSInteger offset = parts.count - 2;
    NSInteger length = parts.count - offset;
    if (offset <= 0) return nil;

    parts = [parts subarrayWithRange:NSMakeRange(offset, length)];
    domain = [parts componentsJoinedByString:@"."];
  }

  return nil;
}

#pragma mark -

//
// 
- (NSImage *)imageForDomain:(NSString *)domain {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domain]];
  NSString *page = [self contentsAtURL:url];
  if (!page) return nil;

  // Extract link and meta tags
  NSString *link = [self extractLinkFromElements:@[@"link", @"meta"] inString:page];

  if (link) {
    NSURL *linkURL = [NSURL URLWithString:link relativeToURL:url];
    NSImage *linkImage = [[NSImage alloc] initWithContentsOfURL:linkURL];
    if (linkImage) return linkImage;
  }

  // Try falling back to /apple-touch-icon.png
  NSURL *touchURL = [NSURL URLWithString:@"/apple-touch-icon.png" relativeToURL:url];
  NSImage *touchImage = [[NSImage alloc] initWithContentsOfURL:touchURL];
  if (touchImage) return touchImage;

  // If all else fails, try to use /favicon.ico
  NSURL *linkURL = [NSURL URLWithString:@"/favicon.ico" relativeToURL:url];
  return [[NSImage alloc] initWithContentsOfURL:linkURL];
}

- (NSString *)contentsAtURL:(NSURL *)URL {
  // Synchronously fetch the URL
  NSURLResponse *rsp;
  NSURLRequest *req = [NSURLRequest requestWithURL:URL cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:10];
  NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&rsp error:nil];;
  if (!data) return nil;
  if (!rsp) return nil;

  // Convert encoding name to constant
  NSStringEncoding encoding = NSUTF8StringEncoding;

  if (rsp.textEncodingName) {
    CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)rsp.textEncodingName);
    if (enc != kCFStringEncodingInvalidId) {
      encoding = CFStringConvertEncodingToNSStringEncoding(enc);
    }
  }

  // Convert data to string
  return [[NSString alloc] initWithData:data encoding:encoding];
}

- (NSString *)extractLinkFromElements:(NSArray *)elements inString:(NSString *)page {
  NSString *link;

  for (NSString *element in elements) {
    NSError *error;
    NSString *pattern = [NSString stringWithFormat:@"<%@[^>]*>", element];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) continue;

    NSArray *matches = [regex matchesInString:page options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, page.length)];

    for (NSTextCheckingResult *check in matches) {
      link = [self extractLinkInElement:[page substringWithRange:check.range]];
      if (link) break;
    }

    if (link) break;
  }

  return link;
}

- (NSString *)extractLinkInElement:(NSString *)element {
  NSString *link;
  NSRange range = NSMakeRange(0, element.length);
  NSDictionary *groups = @{
    @"href": @[
      @"rel=[^>]*apple-touch-icon",
      @"rel=[^>]*icon",
    ],

    @"content": @[
      @"property=[^>]*og:image",
      @"itemprop=[^>]*image",
    ],

    @"value": @[
      @"name=[^>]*twitter:image",
    ],
  };

  for (NSString *attribute in groups) {
    NSArray *patterns = groups[attribute];

    for (NSString *pattern in patterns) {
      NSError *error;
      NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
      if (error) continue;

      if ([regex numberOfMatchesInString:element options:0 range:range]) {
        link = [self extractLinkFromAttribute:attribute inElement:element];
        if (link) return link;
      }
    }
  }

  return link;
}

- (NSString *)extractLinkFromAttribute:(NSString *)attribute inElement:(NSString *)element {
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:@"%@=[\'\"]?([^>\'\"]*)[\'\"]?", attribute];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
  if (error) return nil;

  NSTextCheckingResult *check = [regex firstMatchInString:element options:0 range:NSMakeRange(0, element.length)];
  if (!check) return nil;
  if (check.numberOfRanges != 2) return nil;
  return [element substringWithRange:[check rangeAtIndex:1]];
}

@end