//
//  SSZipArchive.m
//  SSZipArchive
//
//  Created by Sam Soffes on 7/21/10.
//  Copyright (c) Sam Soffes 2010-2015. All rights reserved.
//

#import "SSZipArchive.h"
#include "unzip.h"
#include "zip.h"
#include "minishared.h"

#include <sys/stat.h>

NSString *const SSZipArchiveErrorDomain = @"SSZipArchiveErrorDomain";

#define CHUNK 16384

#ifndef API_AVAILABLE
// Xcode 7- compatibility
#define API_AVAILABLE(...)
#endif

@interface NSData(SSZipArchive)
- (NSString *)_base64RFC4648 API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));
- (NSString *)_hexString;
@end

@interface SSZipArchive ()
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

@implementation SSZipArchive
{
    /// path for zip file
    NSString *_path;
    zipFile _zip;
}

#pragma mark - Password check

+ (BOOL)isFilePasswordProtectedAtPath:(NSString *)path {
    // Begin opening
    zipFile zip = unzOpen(path.fileSystemRepresentation);
    if (zip == NULL) {
        return NO;
    }
    
    int ret = unzGoToFirstFile(zip);
    if (ret == UNZ_OK) {
        do {
            ret = unzOpenCurrentFile(zip);
            if (ret != UNZ_OK) {
                return NO;
            }
            unz_file_info fileInfo = {0};
            ret = unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if (ret != UNZ_OK) {
                return NO;
            } else if ((fileInfo.flag & 1) == 1) {
                return YES;
            }
            
            unzCloseCurrentFile(zip);
            ret = unzGoToNextFile(zip);
        } while (ret == UNZ_OK && UNZ_OK != UNZ_END_OF_LIST_OF_FILE);
    }
    
    return NO;
}

+ (BOOL)isPasswordValidForArchiveAtPath:(NSString *)path password:(NSString *)pw error:(NSError **)error {
    if (error) {
        *error = nil;
    }

    zipFile zip = unzOpen(path.fileSystemRepresentation);
    if (zip == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:SSZipArchiveErrorDomain
                                         code:SSZipArchiveErrorCodeFailedOpenZipFile
                                     userInfo:@{NSLocalizedDescriptionKey: @"failed to open zip file"}];
        }
        return NO;
    }

    int ret = unzGoToFirstFile(zip);
    if (ret == UNZ_OK) {
        do {
            if (pw.length == 0) {
                ret = unzOpenCurrentFile(zip);
            } else {
                ret = unzOpenCurrentFilePassword(zip, [pw cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            if (ret != UNZ_OK) {
                if (ret != UNZ_BADPASSWORD) {
                    if (error) {
                        *error = [NSError errorWithDomain:SSZipArchiveErrorDomain
                                                     code:SSZipArchiveErrorCodeFailedOpenFileInZip
                                                 userInfo:@{NSLocalizedDescriptionKey: @"failed to open first file in zip file"}];
                    }
                }
                return NO;
            }
            unz_file_info fileInfo = {0};
            ret = unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if (ret != UNZ_OK) {
                if (error) {
                    *error = [NSError errorWithDomain:SSZipArchiveErrorDomain
                                                 code:SSZipArchiveErrorCodeFileInfoNotLoadable
                                             userInfo:@{NSLocalizedDescriptionKey: @"failed to retrieve info for file"}];
                }
                return NO;
            } else if ((fileInfo.flag & 1) == 1) {
                unsigned char buffer[10] = {0};
                int readBytes = unzReadCurrentFile(zip, buffer, (unsigned)MIN(10UL,fileInfo.uncompressed_size));
                if (readBytes < 0) {
                    // Let's assume the invalid password caused this error
                    if (readBytes != Z_DATA_ERROR) {
                        if (error) {
                            *error = [NSError errorWithDomain:SSZipArchiveErrorDomain
                                                         code:SSZipArchiveErrorCodeFileContentNotReadable
                                                     userInfo:@{NSLocalizedDescriptionKey: @"failed to read contents of file entry"}];
                        }
                    }
                    return NO;
                }
                return YES;
            }
            
            unzCloseCurrentFile(zip);
            ret = unzGoToNextFile(zip);
        } while (ret == UNZ_OK && UNZ_OK != UNZ_END_OF_LIST_OF_FILE);
    }

    // No password required
    return YES;
}

#pragma mark - Unzipping

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination
{
    return [self unzipFileAtPath:path toDestination:destination delegate:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(nullable NSString *)password error:(NSError **)error
{
    return [self unzipFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:error delegate:nil progressHandler:nil completionHandler:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination delegate:(nullable id<SSZipArchiveDelegate>)delegate
{
    return [self unzipFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:YES password:nil error:nil delegate:delegate progressHandler:nil completionHandler:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
              overwrite:(BOOL)overwrite
               password:(nullable NSString *)password
                  error:(NSError **)error
               delegate:(nullable id<SSZipArchiveDelegate>)delegate
{
    return [self unzipFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:error delegate:delegate progressHandler:nil completionHandler:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
              overwrite:(BOOL)overwrite
               password:(NSString *)password
        progressHandler:(void (^)(NSString *entry, unz_file_info zipInfo, long entryNumber, long total))progressHandler
      completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    return [self unzipFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:overwrite password:password error:nil delegate:nil progressHandler:progressHandler completionHandler:completionHandler];
}

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
        progressHandler:(void (^)(NSString *entry, unz_file_info zipInfo, long entryNumber, long total))progressHandler
      completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    return [self unzipFileAtPath:path toDestination:destination preserveAttributes:YES overwrite:YES password:nil error:nil delegate:nil progressHandler:progressHandler completionHandler:completionHandler];
}

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
     preserveAttributes:(BOOL)preserveAttributes
              overwrite:(BOOL)overwrite
               password:(nullable NSString *)password
                  error:(NSError * *)error
               delegate:(nullable id<SSZipArchiveDelegate>)delegate
{
    return [self unzipFileAtPath:path toDestination:destination preserveAttributes:preserveAttributes overwrite:overwrite password:password error:error delegate:delegate progressHandler:nil completionHandler:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
     preserveAttributes:(BOOL)preserveAttributes
              overwrite:(BOOL)overwrite
               password:(nullable NSString *)password
                  error:(NSError **)error
               delegate:(id<SSZipArchiveDelegate>)delegate
        progressHandler:(void (^)(NSString *entry, unz_file_info zipInfo, long entryNumber, long total))progressHandler
      completionHandler:(void (^)(NSString *path, BOOL succeeded, NSError * _Nullable error))completionHandler
{
    // Guard against empty strings
    if (path.length == 0 || destination.length == 0)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"received invalid argument(s)"};
        NSError *err = [NSError errorWithDomain:SSZipArchiveErrorDomain code:SSZipArchiveErrorCodeInvalidArguments userInfo:userInfo];
        if (error)
        {
            *error = err;
        }
        if (completionHandler)
        {
            completionHandler(nil, NO, err);
        }
        return NO;
    }
    
    // Begin opening
    zipFile zip = unzOpen(path.fileSystemRepresentation);
    if (zip == NULL)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"failed to open zip file"};
        NSError *err = [NSError errorWithDomain:SSZipArchiveErrorDomain code:SSZipArchiveErrorCodeFailedOpenZipFile userInfo:userInfo];
        if (error)
        {
            *error = err;
        }
        if (completionHandler)
        {
            completionHandler(nil, NO, err);
        }
        return NO;
    }
    
    NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    unsigned long long fileSize = [fileAttributes[NSFileSize] unsignedLongLongValue];
    unsigned long long currentPosition = 0;
    
    unz_global_info  globalInfo = {0ul, 0ul};
    unzGetGlobalInfo(zip, &globalInfo);
    
    // Begin unzipping
    if (unzGoToFirstFile(zip) != UNZ_OK)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"failed to open first file in zip file"};
        NSError *err = [NSError errorWithDomain:SSZipArchiveErrorDomain code:SSZipArchiveErrorCodeFailedOpenFileInZip userInfo:userInfo];
        if (error)
        {
            *error = err;
        }
        if (completionHandler)
        {
            completionHandler(nil, NO, err);
        }
        return NO;
    }
    
    BOOL success = YES;
    BOOL canceled = NO;
    int ret = 0;
    int crc_ret = 0;
    unsigned char buffer[4096] = {0};
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray<NSDictionary *> *directoriesModificationDates = [[NSMutableArray alloc] init];
    
    // Message delegate
    if ([delegate respondsToSelector:@selector(zipArchiveWillUnzipArchiveAtPath:zipInfo:)]) {
        [delegate zipArchiveWillUnzipArchiveAtPath:path zipInfo:globalInfo];
    }
    if ([delegate respondsToSelector:@selector(zipArchiveProgressEvent:total:)]) {
        [delegate zipArchiveProgressEvent:currentPosition total:fileSize];
    }
    
    NSInteger currentFileNumber = 0;
    NSError *unzippingError;
    do {
        @autoreleasepool {
            if (password.length == 0) {
                ret = unzOpenCurrentFile(zip);
            } else {
                ret = unzOpenCurrentFilePassword(zip, [password cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            if (ret != UNZ_OK) {
                unzippingError = [NSError errorWithDomain:@"SSZipArchiveErrorDomain" code:SSZipArchiveErrorCodeFailedOpenFileInZip userInfo:@{NSLocalizedDescriptionKey: @"failed to open file in zip file"}];
                success = NO;
                break;
            }
            
            // Reading data and write to file
            unz_file_info fileInfo;
            memset(&fileInfo, 0, sizeof(unz_file_info));
            
            ret = unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if (ret != UNZ_OK) {
                unzippingError = [NSError errorWithDomain:@"SSZipArchiveErrorDomain" code:SSZipArchiveErrorCodeFileInfoNotLoadable userInfo:@{NSLocalizedDescriptionKey: @"failed to retrieve info for file"}];
                success = NO;
                unzCloseCurrentFile(zip);
                break;
            }
            
            currentPosition += fileInfo.compressed_size;
            
            // Message delegate
            if ([delegate respondsToSelector:@selector(zipArchiveShouldUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
                if (![delegate zipArchiveShouldUnzipFileAtIndex:currentFileNumber
                                                     totalFiles:(NSInteger)globalInfo.number_entry
                                                    archivePath:path fileInfo:fileInfo]) {
                    success = NO;
                    canceled = YES;
                    break;
                }
            }
            if ([delegate respondsToSelector:@selector(zipArchiveWillUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
                [delegate zipArchiveWillUnzipFileAtIndex:currentFileNumber totalFiles:(NSInteger)globalInfo.number_entry
                                             archivePath:path fileInfo:fileInfo];
            }
            if ([delegate respondsToSelector:@selector(zipArchiveProgressEvent:total:)]) {
                [delegate zipArchiveProgressEvent:(NSInteger)currentPosition total:(NSInteger)fileSize];
            }
            
            char *filename = (char *)malloc(fileInfo.size_filename + 1);
            if (filename == NULL)
            {
                success = NO;
                break;
            }
            
            unzGetCurrentFileInfo(zip, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
            filename[fileInfo.size_filename] = '\0';
            
            //
            // Determine whether this is a symbolic link:
            // - File is stored with 'version made by' value of UNIX (3),
            //   as per http://www.pkware.com/documents/casestudies/APPNOTE.TXT
            //   in the upper byte of the version field.
            // - BSD4.4 st_mode constants are stored in the high 16 bits of the
            //   external file attributes (defacto standard, verified against libarchive)
            //
            // The original constants can be found here:
            //    http://minnie.tuhs.org/cgi-bin/utree.pl?file=4.4BSD/usr/include/sys/stat.h
            //
            const uLong ZipUNIXVersion = 3;
            const uLong BSD_SFMT = 0170000;
            const uLong BSD_IFLNK = 0120000;
            
            BOOL fileIsSymbolicLink = NO;
            if (((fileInfo.version >> 8) == ZipUNIXVersion) && BSD_IFLNK == (BSD_SFMT & (fileInfo.external_fa >> 16))) {
                fileIsSymbolicLink = YES;
            }
            
            NSString * strPath = @(filename);
            if (!strPath) {
                // if filename is non-unicode, detect and transform Encoding
                NSData *data = [NSData dataWithBytes:(const void *)filename length:sizeof(unsigned char) * fileInfo.size_filename];
#ifdef __MAC_10_13
                // Xcode 9+
                if (@available(macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0, *)) {
#else
                // Xcode 8-
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_9_2) {
#endif
                    // supported encodings are in [NSString availableStringEncodings]
                    [NSString stringEncodingForData:data encodingOptions:nil convertedString:&strPath usedLossyConversion:nil];
                } else {
                    // fallback to a simple manual detect for macOS 10.9 or older
                    NSArray<NSNumber *> *encodings = @[@(kCFStringEncodingGB_18030_2000), @(kCFStringEncodingShiftJIS)];
                    for (NSNumber *encoding in encodings) {
                        strPath = [NSString stringWithCString:filename encoding:(NSStringEncoding)CFStringConvertEncodingToNSStringEncoding(encoding.unsignedIntValue)];
                        if (strPath) {
                            break;
                        }
                    }
                }
                if (!strPath) {
                    // if filename encoding is non-detected, we default to something based on data
                    // _hexString is more readable than _base64RFC4648 for debugging unknown encodings
                    strPath = [data _hexString];
                }
            }
            if (!strPath.length) {
                // if filename data is unsalvageable, we default to currentFileNumber
                strPath = @(currentFileNumber).stringValue;
            }
            
            // Check if it contains directory
            BOOL isDirectory = NO;
            if (filename[fileInfo.size_filename-1] == '/' || filename[fileInfo.size_filename-1] == '\\') {
                isDirectory = YES;
            }
            free(filename);
            
            // Contains a path
            if ([strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location != NSNotFound) {
                strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            }
            
            NSString *fullPath = [destination stringByAppendingPathComponent:strPath];
            NSError *err = nil;
            NSDictionary *directoryAttr;
            if (preserveAttributes) {
                NSDate *modDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dos_date];
                directoryAttr = @{NSFileCreationDate: modDate, NSFileModificationDate: modDate};
                [directoriesModificationDates addObject: @{@"path": fullPath, @"modDate": modDate}];
            }
            if (isDirectory) {
                [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:directoryAttr  error:&err];
            } else {
                [fileManager createDirectoryAtPath:fullPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:directoryAttr error:&err];
            }
            if (nil != err) {
                if ([err.domain isEqualToString:NSCocoaErrorDomain] &&
                    err.code == 640) {
                    unzippingError = err;
                    unzCloseCurrentFile(zip);
                    success = NO;
                    break;
                }
                NSLog(@"[SSZipArchive] Error: %@", err.localizedDescription);
            }
            
            if ([fileManager fileExistsAtPath:fullPath] && !isDirectory && !overwrite) {
                //FIXME: couldBe CRC Check?
                unzCloseCurrentFile(zip);
                ret = unzGoToNextFile(zip);
                continue;
            }
            
            if (!fileIsSymbolicLink) {
                // ensure we are not creating stale file entries
                int readBytes = unzReadCurrentFile(zip, buffer, 4096);
                if (readBytes >= 0) {
                    FILE *fp = fopen(fullPath.fileSystemRepresentation, "wb");
                    while (fp) {
                        if (readBytes > 0) {
                            if (0 == fwrite(buffer, readBytes, 1, fp)) {
                                if (ferror(fp)) {
                                    NSString *message = [NSString stringWithFormat:@"Failed to write file (check your free space)"];
                                    NSLog(@"[SSZipArchive] %@", message);
                                    success = NO;
                                    unzippingError = [NSError errorWithDomain:@"SSZipArchiveErrorDomain" code:SSZipArchiveErrorCodeFailedToWriteFile userInfo:@{NSLocalizedDescriptionKey: message}];
                                    break;
                                }
                            }
                        } else {
                            break;
                        }
                        readBytes = unzReadCurrentFile(zip, buffer, 4096);
                    }

                    if (fp) {
                        if ([fullPath.pathExtension.lowercaseString isEqualToString:@"zip"]) {
                            NSLog(@"Unzipping nested .zip file:  %@", fullPath.lastPathComponent);
                            if ([self unzipFileAtPath:fullPath toDestination:fullPath.stringByDeletingLastPathComponent overwrite:overwrite password:password error:nil delegate:nil]) {
                                [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
                            }
                        }

                        fclose(fp);

                        if (preserveAttributes) {

                            // Set the original datetime property
                            if (fileInfo.dos_date != 0) {
                                NSDate *orgDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dos_date];
                                NSDictionary *attr = @{NSFileModificationDate: orgDate};

                                if (attr) {
                                    if (![fileManager setAttributes:attr ofItemAtPath:fullPath error:nil]) {
                                        // Can't set attributes
                                        NSLog(@"[SSZipArchive] Failed to set attributes - whilst setting modification date");
                                    }
                                }
                            }

                            // Set the original permissions on the file (+read/write to solve #293)
                            uLong permissions = fileInfo.external_fa >> 16 | 0b110000000;
                            if (permissions != 0) {
                                // Store it into a NSNumber
                                NSNumber *permissionsValue = @(permissions);

                                // Retrieve any existing attributes
                                NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[fileManager attributesOfItemAtPath:fullPath error:nil]];

                                // Set the value in the attributes dict
                                attrs[NSFilePosixPermissions] = permissionsValue;

                                // Update attributes
                                if (![fileManager setAttributes:attrs ofItemAtPath:fullPath error:nil]) {
                                    // Unable to set the permissions attribute
                                    NSLog(@"[SSZipArchive] Failed to set attributes - whilst setting permissions");
                                }
                            }
                        }
                    }
                    else
                    {
                        // if we couldn't open file descriptor we can validate global errno to see the reason
                        if (errno == ENOSPC) {
                            NSError *enospcError = [NSError errorWithDomain:NSPOSIXErrorDomain
                                                                       code:ENOSPC
                                                                   userInfo:nil];
                            unzippingError = enospcError;
                            unzCloseCurrentFile(zip);
                            success = NO;
                            break;
                        }
                    }
                }
            }
            else
            {
                // Assemble the path for the symbolic link
                NSMutableString *destinationPath = [NSMutableString string];
                int bytesRead = 0;
                while ((bytesRead = unzReadCurrentFile(zip, buffer, 4096)) > 0)
                {
                    buffer[bytesRead] = (int)0;
                    [destinationPath appendString:@((const char *)buffer)];
                }
                
                // Check if the symlink exists and delete it if we're overwriting
                if (overwrite)
                {
                    if ([fileManager fileExistsAtPath:fullPath])
                    {
                        NSError *error = nil;
                        BOOL removeSuccess = [fileManager removeItemAtPath:fullPath error:&error];
                        if (!removeSuccess)
                        {
                            NSString *message = [NSString stringWithFormat:@"Failed to delete existing symbolic link at \"%@\"", error.localizedDescription];
                            NSLog(@"[SSZipArchive] %@", message);
                            success = NO;
                            unzippingError = [NSError errorWithDomain:SSZipArchiveErrorDomain code:error.code userInfo:@{NSLocalizedDescriptionKey: message}];
                        }
                    }
                }
                
                // Create the symbolic link (making sure it stays relative if it was relative before)
                int symlinkError = symlink([destinationPath cStringUsingEncoding:NSUTF8StringEncoding],
                                           [fullPath cStringUsingEncoding:NSUTF8StringEncoding]);
                
                if (symlinkError != 0)
                {
                    // Bubble the error up to the completion handler
                    NSString *message = [NSString stringWithFormat:@"Failed to create symbolic link at \"%@\" to \"%@\" - symlink() error code: %d", fullPath, destinationPath, errno];
                    NSLog(@"[SSZipArchive] %@", message);
                    success = NO;
                    unzippingError = [NSError errorWithDomain:NSPOSIXErrorDomain code:symlinkError userInfo:@{NSLocalizedDescriptionKey: message}];
                }
            }
            
            crc_ret = unzCloseCurrentFile(zip);
            if (crc_ret == UNZ_CRCERROR) {
                //CRC ERROR
                success = NO;
                break;
            }
            ret = unzGoToNextFile(zip);
            
            // Message delegate
            if ([delegate respondsToSelector:@selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
                [delegate zipArchiveDidUnzipFileAtIndex:currentFileNumber totalFiles:(NSInteger)globalInfo.number_entry
                                            archivePath:path fileInfo:fileInfo];
            } else if ([delegate respondsToSelector: @selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:unzippedFilePath:)]) {
                [delegate zipArchiveDidUnzipFileAtIndex: currentFileNumber totalFiles: (NSInteger)globalInfo.number_entry
                                            archivePath:path unzippedFilePath: fullPath];
            }
            
            currentFileNumber++;
            if (progressHandler)
            {
                progressHandler(strPath, fileInfo, currentFileNumber, globalInfo.number_entry);
            }
        }
    } while (ret == UNZ_OK && success);
    
    // Close
    unzClose(zip);
    
    // The process of decompressing the .zip archive causes the modification times on the folders
    // to be set to the present time. So, when we are done, they need to be explicitly set.
    // set the modification date on all of the directories.
    if (success && preserveAttributes) {
        NSError * err = nil;
        for (NSDictionary * d in directoriesModificationDates) {
            if (![[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate: d[@"modDate"]} ofItemAtPath:d[@"path"] error:&err]) {
                NSLog(@"[SSZipArchive] Set attributes failed for directory: %@.", d[@"path"]);
            }
            if (err) {
                NSLog(@"[SSZipArchive] Error setting directory file modification date attribute: %@", err.localizedDescription);
            }
        }
    }
    
    // Message delegate
    if (success && [delegate respondsToSelector:@selector(zipArchiveDidUnzipArchiveAtPath:zipInfo:unzippedPath:)]) {
        [delegate zipArchiveDidUnzipArchiveAtPath:path zipInfo:globalInfo unzippedPath:destination];
    }
    // final progress event = 100%
    if (!canceled && [delegate respondsToSelector:@selector(zipArchiveProgressEvent:total:)]) {
        [delegate zipArchiveProgressEvent:fileSize total:fileSize];
    }
    
    NSError *retErr = nil;
    if (crc_ret == UNZ_CRCERROR)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"crc check failed for file"};
        retErr = [NSError errorWithDomain:SSZipArchiveErrorDomain code:SSZipArchiveErrorCodeFileInfoNotLoadable userInfo:userInfo];
    }
    
    if (error) {
        if (unzippingError) {
            *error = unzippingError;
        }
        else {
            *error = retErr;
        }
    }
    if (completionHandler)
    {
        if (unzippingError) {
            completionHandler(path, success, unzippingError);
        }
        else
        {
            completionHandler(path, success, retErr);
        }
    }
    return success;
}

#pragma mark - Zipping
+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray<NSString *> *)paths
{
    return [SSZipArchive createZipFileAtPath:path withFilesAtPaths:paths withPassword:nil];
}
+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath {
    return [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:directoryPath withPassword:nil];
}

+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath keepParentDirectory:(BOOL)keepParentDirectory {
    return [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:directoryPath keepParentDirectory:keepParentDirectory withPassword:nil];
}

+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray<NSString *> *)paths withPassword:(NSString *)password
{
    SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:path];
    BOOL success = [zipArchive open];
    if (success) {
        for (NSString *filePath in paths) {
            success &= [zipArchive writeFile:filePath withPassword:password];
        }
        success &= [zipArchive close];
    }
    return success;
}

+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath withPassword:(nullable NSString *)password {
    return [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:directoryPath keepParentDirectory:NO withPassword:password];
}


+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath keepParentDirectory:(BOOL)keepParentDirectory withPassword:(nullable NSString *)password {
    return [SSZipArchive createZipFileAtPath:path
                     withContentsOfDirectory:directoryPath
                         keepParentDirectory:keepParentDirectory
                                withPassword:password
                          andProgressHandler:nil
            ];
}

+ (BOOL)createZipFileAtPath:(NSString *)path
    withContentsOfDirectory:(NSString *)directoryPath
        keepParentDirectory:(BOOL)keepParentDirectory
               withPassword:(nullable NSString *)password
         andProgressHandler:(void(^ _Nullable)(NSUInteger entryNumber, NSUInteger total))progressHandler {
    
    SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:path];
    BOOL success = [zipArchive open];
    if (success) {
        // use a local fileManager (queue/thread compatibility)
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:directoryPath];
        NSArray<NSString *> *allObjects = dirEnumerator.allObjects;
        NSUInteger total = allObjects.count, complete = 0;
        NSString *fileName;
        for (fileName in allObjects) {
            BOOL isDir;
            NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
            [fileManager fileExistsAtPath:fullFilePath isDirectory:&isDir];
            
            if (keepParentDirectory)
            {
                fileName = [directoryPath.lastPathComponent stringByAppendingPathComponent:fileName];
            }
            
            if (!isDir) {
                success &= [zipArchive writeFileAtPath:fullFilePath withFileName:fileName withPassword:password];
            }
            else
            {
                if ([[NSFileManager defaultManager] subpathsOfDirectoryAtPath:fullFilePath error:nil].count == 0)
                {
                    NSString *tempFilePath = [self _temporaryPathForDiscardableFile];
                    NSString *tempFileFilename = [fileName stringByAppendingPathComponent:tempFilePath.lastPathComponent];
                    success &= [zipArchive writeFileAtPath:tempFilePath withFileName:tempFileFilename withPassword:password];
                }
            }
            complete++;
            if (progressHandler) {
                progressHandler(complete, total);
            }
        }
        success &= [zipArchive close];
    }
    return success;
}

// disabling `init` because designated initializer is `initWithPath:`
- (instancetype)init { @throw nil; }

// designated initializer
- (instancetype)initWithPath:(NSString *)path
{
    if ((self = [super init])) {
        _path = [path copy];
    }
    return self;
}


- (BOOL)open
{
    NSAssert((_zip == NULL), @"Attempting to open an archive which is already open");
    _zip = zipOpen(_path.fileSystemRepresentation, APPEND_STATUS_CREATE);
    return (NULL != _zip);
}


- (void)zipInfo:(zip_fileinfo *)zipInfo setDate:(NSDate *)date
{
    NSCalendar *currentCalendar = SSZipArchive._gregorian;
    NSCalendarUnit flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [currentCalendar components:flags fromDate:date];
    struct tm tmz_date;
    tmz_date.tm_sec = (unsigned int)components.second;
    tmz_date.tm_min = (unsigned int)components.minute;
    tmz_date.tm_hour = (unsigned int)components.hour;
    tmz_date.tm_mday = (unsigned int)components.day;
    // ISO/IEC 9899 struct tm is 0-indexed for January but NSDateComponents for gregorianCalendar is 1-indexed for January
    tmz_date.tm_mon = (unsigned int)components.month - 1;
    // ISO/IEC 9899 struct tm is 0-indexed for AD 1900 but NSDateComponents for gregorianCalendar is 1-indexed for AD 1
    tmz_date.tm_year = (unsigned int)components.year - 1900;
    zipInfo->dos_date = tm_to_dosdate(&tmz_date);
}

- (BOOL)writeFolderAtPath:(NSString *)path withFolderName:(NSString *)folderName withPassword:(nullable NSString *)password
{
    NSAssert((_zip != NULL), @"Attempting to write to an archive which was never opened");
    
    zip_fileinfo zipInfo = {0,0,0};
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error: nil];
    if (attr)
    {
        NSDate *fileDate = (NSDate *)attr[NSFileModificationDate];
        if (fileDate)
        {
            [self zipInfo:&zipInfo setDate: fileDate];
        }
        
        // Write permissions into the external attributes, for details on this see here: http://unix.stackexchange.com/a/14727
        // Get the permissions value from the files attributes
        NSNumber *permissionsValue = (NSNumber *)attr[NSFilePosixPermissions];
        if (permissionsValue != nil) {
            // Get the short value for the permissions
            short permissionsShort = permissionsValue.shortValue;
            
            // Convert this into an octal by adding 010000, 010000 being the flag for a regular file
            NSInteger permissionsOctal = 0100000 + permissionsShort;
            
            // Convert this into a long value
            uLong permissionsLong = @(permissionsOctal).unsignedLongValue;
            
            // Store this into the external file attributes once it has been shifted 16 places left to form part of the second from last byte
            
            // Casted back to an unsigned int to match type of external_fa in minizip
            zipInfo.external_fa = (unsigned int)(permissionsLong << 16L);
        }
    }
    
    unsigned int len = 0;
    zipOpenNewFileInZip3(_zip, [folderName stringByAppendingString:@"/"].fileSystemRepresentation, &zipInfo, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_NO_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL,
                         Z_DEFAULT_STRATEGY, password.UTF8String, 0);
    zipWriteInFileInZip(_zip, &len, 0);
    zipCloseFileInZip(_zip);
    return YES;
}

- (BOOL)writeFile:(NSString *)path withPassword:(nullable NSString *)password;
{
    return [self writeFileAtPath:path withFileName:nil withPassword:password];
}

// supports writing files with logical folder/directory structure
// *path* is the absolute path of the file that will be compressed
// *fileName* is the relative name of the file how it is stored within the zip e.g. /folder/subfolder/text1.txt
- (BOOL)writeFileAtPath:(NSString *)path withFileName:(nullable NSString *)fileName withPassword:(nullable NSString *)password
{
    NSAssert((_zip != NULL), @"Attempting to write to an archive which was never opened");
    
    FILE *input = fopen(path.fileSystemRepresentation, "r");
    if (NULL == input) {
        return NO;
    }
    
    const char *aFileName;
    if (!fileName) {
        aFileName = path.lastPathComponent.fileSystemRepresentation;
    }
    else {
        aFileName = fileName.fileSystemRepresentation;
    }
    
    zip_fileinfo zipInfo = {0,0,0};
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error: nil];
    if (attr)
    {
        NSDate *fileDate = (NSDate *)attr[NSFileModificationDate];
        if (fileDate)
        {
            [self zipInfo:&zipInfo setDate: fileDate];
        }
        
        // Write permissions into the external attributes, for details on this see here: http://unix.stackexchange.com/a/14727
        // Get the permissions value from the files attributes
        NSNumber *permissionsValue = (NSNumber *)attr[NSFilePosixPermissions];
        if (permissionsValue != nil) {
            // Get the short value for the permissions
            short permissionsShort = permissionsValue.shortValue;
            
            // Convert this into an octal by adding 010000, 010000 being the flag for a regular file
            NSInteger permissionsOctal = 0100000 + permissionsShort;
            
            // Convert this into a long value
            uLong permissionsLong = @(permissionsOctal).unsignedLongValue;
            
            // Store this into the external file attributes once it has been shifted 16 places left to form part of the second from last byte
            
            // Casted back to an unsigned int to match type of external_fa in minizip
            zipInfo.external_fa = (unsigned int)(permissionsLong << 16L);
        }
    }
    
    void *buffer = malloc(CHUNK);
    if (buffer == NULL)
    {
        return NO;
    }
    
    zipOpenNewFileInZip3(_zip, aFileName, &zipInfo, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, password.UTF8String, 0);
    unsigned int len = 0;
    
    while (!feof(input) && !ferror(input))
    {
        len = (unsigned int) fread(buffer, 1, CHUNK, input);
        zipWriteInFileInZip(_zip, buffer, len);
    }
    
    zipCloseFileInZip(_zip);
    free(buffer);
    fclose(input);
    return YES;
}

- (BOOL)writeData:(NSData *)data filename:(nullable NSString *)filename withPassword:(nullable NSString *)password;
{
    if (!_zip) {
        return NO;
    }
    if (!data) {
        return NO;
    }
    zip_fileinfo zipInfo = {0,0,0};
    [self zipInfo:&zipInfo setDate:[NSDate date]];
    
    zipOpenNewFileInZip3(_zip, filename.fileSystemRepresentation, &zipInfo, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, password.UTF8String, 0);
    
    zipWriteInFileInZip(_zip, data.bytes, (unsigned int)data.length);
    
    zipCloseFileInZip(_zip);
    return YES;
}


- (BOOL)close
{
    NSAssert((_zip != NULL), @"[SSZipArchive] Attempting to close an archive which was never opened");
    int error = zipClose(_zip, NULL);
    _zip = nil;
    return error == UNZ_OK;
}

#pragma mark - Private

+ (NSString *)_temporaryPathForDiscardableFile
{
    static NSString *discardableFileName = @".DS_Store";
    static NSString *discardableFilePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *temporaryDirectoryName = [NSUUID UUID].UUIDString;
        NSString *temporaryDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryDirectoryName];
        BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:temporaryDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (directoryCreated) {
            discardableFilePath = [temporaryDirectory stringByAppendingPathComponent:discardableFileName];
            [@"" writeToFile:discardableFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    });
    return discardableFilePath;
}

+ (NSCalendar *)_gregorian
{
    static NSCalendar *gregorian;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    
    return gregorian;
}

// Format from http://newsgroups.derkeiler.com/Archive/Comp/comp.os.msdos.programmer/2009-04/msg00060.html
// Two consecutive words, or a longword, YYYYYYYMMMMDDDDD hhhhhmmmmmmsssss
// YYYYYYY is years from 1980 = 0
// sssss is (seconds/2).
//
// 3658 = 0011 0110 0101 1000 = 0011011 0010 11000 = 27 2 24 = 2007-02-24
// 7423 = 0111 0100 0010 0011 - 01110 100001 00011 = 14 33 3 = 14:33:06
+ (NSDate *)_dateWithMSDOSFormat:(UInt32)msdosDateTime
{
    /*
     // the whole `_dateWithMSDOSFormat:` method is equivalent but faster than this one line,
     // essentially because `mktime` is slow:
     NSDate *date = [NSDate dateWithTimeIntervalSince1970:dosdate_to_time_t(msdosDateTime)];
    */
    static const UInt32 kYearMask = 0xFE000000;
    static const UInt32 kMonthMask = 0x1E00000;
    static const UInt32 kDayMask = 0x1F0000;
    static const UInt32 kHourMask = 0xF800;
    static const UInt32 kMinuteMask = 0x7E0;
    static const UInt32 kSecondMask = 0x1F;
    
    NSAssert(0xFFFFFFFF == (kYearMask | kMonthMask | kDayMask | kHourMask | kMinuteMask | kSecondMask), @"[SSZipArchive] MSDOS date masks don't add up");
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.year = 1980 + ((msdosDateTime & kYearMask) >> 25);
    components.month = (msdosDateTime & kMonthMask) >> 21;
    components.day = (msdosDateTime & kDayMask) >> 16;
    components.hour = (msdosDateTime & kHourMask) >> 11;
    components.minute = (msdosDateTime & kMinuteMask) >> 5;
    components.second = (msdosDateTime & kSecondMask) * 2;
    
    NSDate *date = [self._gregorian dateFromComponents:components];
    return date;
}

@end

#pragma mark - Private tools for unreadable data

@implementation NSData (SSZipArchive)

// `base64EncodedStringWithOptions` uses a base64 alphabet with '+' and '/'.
// we got those alternatives to make it compatible with filenames: https://en.wikipedia.org/wiki/Base64
// * modified Base64 encoding for IMAP mailbox names (RFC 3501): uses '+' and ','
// * modified Base64 for URL and filenames (RFC 4648): uses '-' and '_'
- (NSString *)_base64RFC4648
{
    NSString *strName = [self base64EncodedStringWithOptions:0];
    strName = [strName stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    strName = [strName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return strName;
}

// initWithBytesNoCopy from NSProgrammer, Jan 25 '12: https://stackoverflow.com/a/9009321/1033581
// hexChars from Peter, Aug 19 '14: https://stackoverflow.com/a/25378464/1033581
// not implemented as too lengthy: a potential mapping improvement from Moose, Nov 3 '15: https://stackoverflow.com/a/33501154/1033581
- (NSString *)_hexString
{
    const char *hexChars = "0123456789ABCDEF";
    NSUInteger length = self.length;
    const unsigned char *bytes = self.bytes;
    char *chars = malloc(length * 2);
    char *s = chars;
    NSUInteger i = length;
    while (i--) {
        *s++ = hexChars[*bytes >> 4];
        *s++ = hexChars[*bytes & 0xF];
        bytes++;
    }
    NSString *str = [[NSString alloc] initWithBytesNoCopy:chars
                                                   length:length * 2
                                                 encoding:NSASCIIStringEncoding
                                             freeWhenDone:YES];
    return str;
}

@end
