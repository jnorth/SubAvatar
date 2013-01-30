// SubAvatarFaviconService.h
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

/*
 * Attempts to extract an image from a domain name.
 *
 * This service expects the idenity to be an email address.
 *
 * After a domain is found, the following types of links are searched for:
 *
 *   <link href='apple-touch-icon-iphone.png' rel='apple-touch-icon-precomposed' />
 *   <link href='apple-touch-icon-ipad.png' rel='apple-touch-icon-precomposed' sizes='72x72' />
 *   <link href='apple-touch-icon-iphone4.png' rel='apple-touch-icon-precomposed' sizes='114x114' />
 *   <link href='http://static.mailchimp.com/favicon.ico' rel='icon' type='image/vnd.microsoft.icon' />
 *   <link href='http://static.mailchimp.com/favicon.ico' rel='shortcut icon' />
 *
 *   <meta itemprop="image" content="/images/google_favicon_128.png">
 *
 *   <meta name="twitter:image" value="http://womenandtech.com/wp/assets/interview2-ariel-featured-image1.jpg"/>
 *   <meta name="twitter:creator" value="@womenandtech"/>
 *
 *   <meta property="og:image" content="http://womenandtech.com/wp/assets/interview2-ariel-featured-image1.jpg"/>
 *
 *   <link href="//d297h9he240fqh.cloudfront.net/cache-6a19ac158/favicon.png" rel="icon" type="image/png">
 *   <link href="//d297h9he240fqh.cloudfront.net/cache-6a19ac158/apple-touch-icon-precomposed.png" rel="apple-touch-icon-precomposed" type="image/png">
 *   <link href="//d297h9he240fqh.cloudfront.net/cache-6a19ac158/apple-touch-icon-ipad-precomposed.png" rel="apple-touch-icon-precomposed" sizes="72x72" type="image/png">
 *   <link href="//d297h9he240fqh.cloudfront.net/cache-6a19ac158/apple-touch-icon-iphone4-precomposed.png" rel="apple-touch-icon-precomposed" sizes="114x114" type="image/png">
 *
 *   <meta property="og:image" content="http://www.kickstarter.com/images/compass/site/facebook_thumb.jpg"/>
 *
 * If no links can be found, it attempts to find apple-touch-icon.png
 * or favicon.ico at the root of the domain.
 */

#import "SubAvatarService.h"

@interface SubAvatarFaviconService : NSObject <SubAvatarService>

+ (id)service;

@end