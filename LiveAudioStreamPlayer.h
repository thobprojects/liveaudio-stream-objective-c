//
//  LiveAudioStreamPlayer.h
//  YYDJ
//
//  Created by jiangwenbin on 14-1-13.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#include "Roen_CircleBuffer.h"


#define kCircleBufSize 960000 //16000rate*2Bytes = 32000 Bytes/s abuout 3 second data
#define kNumberBuffers  3
#define kAudioBufferSize 3200 //0.1s data

@interface LiveAudioStreamPlayer : NSObject
{
    CircleBuffer cirleBuffer;
    AudioQueueRef                 mQueue;
    AudioQueueBufferRef           mBuffers[kNumberBuffers];
    
    bool                          mIsRunning;
}

@property (nonatomic, readonly) bool isRunning;


-(void)inputData:(const void *)data length:(unsigned int)len;

-(void)start;

-(void)stop;

@end
