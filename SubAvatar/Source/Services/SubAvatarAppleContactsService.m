// SubAvatarAppleContactsService.m
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

#import "SubAvatarAppleContactsService.h"
#import <AddressBook/AddressBook.h>

@implementation SubAvatarAppleContactsService

+ (id)service {
  return [[self alloc] init];
}

- (NSImage *)imageForIdentity:(NSString *)identity {
  ABAddressBook *contacts = [ABAddressBook sharedAddressBook];
  ABSearchElement *search = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:identity comparison:kABEqualCaseInsensitive];
  NSArray *people = [contacts recordsMatchingSearchElement:search];
  NSImage *result;

  for (ABPerson *person in people) {
    NSData *imageData = [person imageData];

    if (imageData) {
      result = [[NSImage alloc] initWithData:imageData];
      break;
    }
  }

  return result;
}

@end