//
//  HJRequestFormFile.m
//
//  Created by Haijun on 2018/9/22.
//

#import "HJRequestFormFile.h"

@implementation HJRequestFormFile

+ (instancetype)fileWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString *)fileName
                    mineType:(NSString *)mineType {
    HJRequestFormFile *file = [self new];
    file.data = data;
    file.name = name;
    file.fileName = fileName;
    file.mineType = mineType;
    return file;
}

@end
