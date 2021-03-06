/*
 Copyright (c) 2011, OpenEmu Team
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSURL+OELibraryAdditions.h"
#import "NSString+OEAdditions.h"

@implementation NSURL (OELibraryAdditions)

- (BOOL)hasImageSuffix
{
	NSArray  *imageSuffixes = [NSImage imageTypes];
	NSString *urlSuffix     = [[self pathExtension] lowercaseString];
	return [imageSuffixes containsObject:urlSuffix];
}

- (BOOL)isSubpathOfURL:(NSURL *)url
{
    NSArray *parentPathComponents = [[url standardizedURL] pathComponents];
    NSArray *ownPathComponentes   = [[self standardizedURL] pathComponents];
    
    NSUInteger ownPathCount = [ownPathComponentes count];
    
    for(NSUInteger i = 0, count = [parentPathComponents count]; i < count; i++)
        if(i >= ownPathCount || ![[parentPathComponents objectAtIndex:i] isEqualToString:[ownPathComponentes objectAtIndex:i]])
            return NO;
    
    return YES;
}

- (BOOL)isDirectory
{
    NSDictionary *resourceValues = [self resourceValuesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLIsPackageKey, nil] error:nil];
    return [[resourceValues objectForKey:NSURLIsDirectoryKey] boolValue] && ![[resourceValues objectForKey:NSURLIsPackageKey] boolValue];
}

- (NSNumber*)fileSize
{
    NSDictionary *resourceValues = [self resourceValuesForKeys:[NSArray arrayWithObject:NSURLFileSizeKey] error:nil];
    return [resourceValues objectForKey:NSURLFileSizeKey];
}

- (NSURL*)uniqueURLUsingBlock:(NSURL*(^)(NSInteger triesCount))block
{
    NSURL     *result       = self;
    NSInteger triesCount    = 1;
    while([result checkResourceIsReachableAndReturnError:nil])
    {
        triesCount++;
        result = block(triesCount);
    }
    return result;
}


+ (NSString*)validFilenameFromString:(NSString*)fileName
{
    NSCharacterSet *illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\":<>"];
    return [fileName stringByDeletingCharactersInSet:illegalFileNameCharacters];
}

- (NSURL*)urlRelativeToURL:(NSURL*)url
{
    NSString *absoluteString = [[self standardizedURL] absoluteString];
    NSRange range = [absoluteString rangeOfString:[[url standardizedURL] absoluteString]];
    NSURL *result = nil;
    if(range.location != NSNotFound && range.location == 0)
    {
        result = [NSURL URLWithString:[absoluteString substringFromIndex:range.length] relativeToURL:url];
    }
    else
    {
        result = self;
    }

    return [result standardizedURL];
}
@end
