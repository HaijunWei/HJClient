//
//  HJRequestFormFile.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>

@interface HJRequestFormFile : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mineType;

+ (instancetype)fileWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString *)fileName
                    mineType:(NSString *)mineType;

@end
