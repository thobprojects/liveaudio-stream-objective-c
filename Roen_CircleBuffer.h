//
//  Roen_CircleBuffer.h
//
//  Created by 罗亮富 on 14-1-14.
//  Copyright (c) 2014年 All rights reserved.
//

#ifndef YYDJ_Roen_CircleBuffer_h
#define YYDJ_Roen_CircleBuffer_h

struct CircleBuffer {
    unsigned int size; //bytes size
    int head; //head offset, the oldest byte position offset
    int tail; //tail offset, the lastest byte position offset
    unsigned int bytesAvailable; //bytes data available in cirle buffer
    char *data;
};

extern bool CircleBufferCreate(CircleBuffer *buffer, unsigned int size);

extern void CircleBufferRelease(CircleBuffer *cBuf);

extern void WriteCircleBuffer(char *inData, unsigned int length, CircleBuffer *destBuf);


//fuction name ReadCircleBuffer
// input parameters:
//src: the circle buffer which hold the source data
//length: the length of byte wish to read from the circle buffer
//dataOut: the destination buffer pointer which is used to hold the read out data
//availableLength: on output, which indicates the available bytes of data have been read out,
extern void ReadCircleBuffer(CircleBuffer *src, unsigned int length, char *dataOut, unsigned int *availableLength);

#endif
