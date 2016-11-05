# SubAvatar

A simple library to map identities to profile images. Uses pluggable
services, with built-in support for Apple Contacts, Gravatar, and Favicons.

## Services

### `SubAvatarAppleContactsService`

Given an email address, the Apple Contacts service queries the local
address book for contacts with the same email address, and returns their
attached image if found.

The user may be interrupted to give permission to access their address book.

### `SubAvatarGravatarService`

Given an email address, the Gravatar service queries gravatar.com for
any matching profile photos.

### `SubAvatarFaviconService`

Given an email address or domain name, the Favicon service fetches the root
HTML document for the domain and scans it for favicons, apple touch images, or
open-graph images.

## Usage

The `SubAvatarClient` class handles fetching, caching, and processing images.
The client can be given any number of services, which map the email address to
an image in different ways. The `lookupIdentity:block:` method can then be
called, passing an email address and a block that will be called when the image
is ready.

    SubAvatarClient *client = [SubAvatarClient client];

    // Add built-in services, in the order they should be queried
    [client addService:[SubAvatarAppleContactsService service]];
    [client addService:[SubAvatarGravatarService service]];
    [client addService:[SubAvatarFaviconService service]];

    // Optional: add built-in in-memory cache
    client.cache = [[SubAvatarMemoryCache alloc] init];

    // Optional: add block to process images
    client.imageProcessingBlock = ^ NSImage * (NSString *identity, NSImage *image) {
      return image;
    };

    // Fetch image for an email address
    [client lookupIdentity:@"north@sublink.ca" block:^(NSString *identity, NSImage *image) {
      // do something with `image`
    }];

For convenience, the `SubAvatarView` can be used in place of a regular
`NSImageView`:

    // Create avatar view
    SubAvatarView *view = [[SubAvatarView alloc] init];
    view.client = client;
    view.defaultImage = [NSImage imageNamed:@"DefaultAvatar"];

    // Assign an email address to the view
    [_profileView setIdentity:@"north@sublink.ca"];

## Writing a service

Services are classes that implement an `imageForIdentity` method. They should do
their fetching synchronosly, with the SubAvatarClient handling queueing and
background threads.

Here is an example that maps domain names to named images:

    @implementation NamedAvatarService

    - (NSImage *)imageForIdentity:(NSString *)identity {
      // Check for email address
      NSRange range = [identity rangeOfString:@"@"];
      if (range.location == NSNotFound) return nil;

      // Get domain
      NSString *domain = [[identity substringFromIndex:range.location + range.length] lowercaseString];

      // Map domains to image names
      NSDictionary *avatars = @{
        @"twitter.com": @"Twitter",
        @"facebookmail.com": @"Facebook",
      };

      // Load image by name
      NSString *imageName = avatars[domain];
      return imageName
        ? [NSImage imageNamed:imageName]
        : nil;
    }

    @end
