//
//  TextureUtil.h
//  opengl-es
//
//  Created by blackox626 on 2020/8/11.
//  Copyright © 2020 vdian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextureUtil : NSObject

+ (GLuint)createTextureWithImageName:(NSString *)imageName;

+ (GLuint)createTextureWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
