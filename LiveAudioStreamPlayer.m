//
//  LiveAudioStreamPlayer.m
//  YYDJ
//
//  Created by jiangwenbin on 14-1-13.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import "LiveAudioStreamPlayer.h"


void AudioStreamPlaybackHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);

@implementation LiveAudioStreamPlayer
@synthesize isRunning = mIsRunning;

-(id)init
{
    self = [super init];
    if(self)
    {
        AudioStreamBasicDescription format; // 声音格式设置，这些设置要和采集时的配置一致
        memset(&format, 0, sizeof(format));
        
        format.mSampleRate = 16000; // 采样率 (立体声 = 8000)
        format.mFormatID = kAudioFormatLinearPCM; // PCM 格式
        format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        format.mChannelsPerFrame = 1;  // 1:单声道；2:立体声
        format.mBitsPerChannel = 16; // 语音每采样点占用位数
        format.mBytesPerFrame = format.mBitsPerChannel*format.mChannelsPerFrame/8;
        format.mFramesPerPacket = 1;
        format.mBytesPerPacket = format.mBytesPerFrame;

     //   AudioQueueRef queue;
        AudioQueueNewOutput(&format,
                            AudioStreamPlaybackHandler,
                            &cirleBuffer,  // opaque reference to whatever you like
                            CFRunLoopGetCurrent(),
                            kCFRunLoopCommonModes,
                            0,
                            &mQueue);

        for (int i = 0; i < kNumberBuffers; ++i)
            AudioQueueAllocateBuffer(mQueue, kAudioBufferSize, &mBuffers[i]);
        
        AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 5.0);
        
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        
        AudioSessionSetActive(true);
        
       CircleBufferCreate(&(cirleBuffer), kCircleBufSize);
        
        mIsRunning = false;
        
    }
    return self;
}

-(void)start
{
    if(!mIsRunning)
    {
        for (int i = 0; i < kNumberBuffers; ++i)
        {
            memset(mBuffers[i]->mAudioData, 0x00, kAudioBufferSize/10);
            mBuffers[i]->mAudioDataByteSize = kAudioBufferSize/10;
            AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL);
        }
        OSStatus s = AudioQueueStart(mQueue, NULL);
        mIsRunning = true;
        NSLog(@"OSStatus %d",(int)s);
    }
}

-(void)stop
{
    AudioQueueStop(mQueue, true);
    mIsRunning = false;
}

-(void)inputData:(const void *)data length:(unsigned int)len
{
    WriteCircleBuffer((char *)data, len, &cirleBuffer);
}

-(void)dealloc
{
    if(mIsRunning)
        [self stop];
    
    CircleBufferRelease(&cirleBuffer);
    AudioQueueDispose(mQueue,true);
    
    [super dealloc];
}

@end

#pragma mark- call back fuction

void AudioStreamPlaybackHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    
    CircleBuffer *cbuf = (CircleBuffer *)inUserData;
    unsigned int readLen = 0;
    
    if(cbuf->bytesAvailable>=0) //大于3秒的数据才读取
    {
        ReadCircleBuffer(cbuf, kAudioBufferSize, (char *)inBuffer->mAudioData, &readLen);
        inBuffer->mAudioDataByteSize = readLen;
    //    NSLog(@">> read %d on callback (buffer available %d)",readLen,cbuf->bytesAvailable);
    }
//    else
//        NSLog(@"waitting for buffer data..... (buffer available %d)  ...........",cbuf->bytesAvailable);
    
  
    if(readLen == 0)
    {
        memset(inBuffer->mAudioData, 0x00, 480);
        inBuffer->mAudioDataByteSize = 480;
    }
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

