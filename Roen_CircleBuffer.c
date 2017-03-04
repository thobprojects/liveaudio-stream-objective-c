//
//  Roen_CircleBuffer.c
//
//  Created by 罗亮富 on 14-1-14.
//  Copyright (c) 2014年 All rights reserved.
//

#include <stdio.h>
#include "Roen_CircleBuffer.h"

bool CircleBufferCreate(CircleBuffer *buffer, unsigned int size)
{
    buffer->head = -1;
    buffer->tail = -1;
    buffer->bytesAvailable = 0;
    buffer->data = (char *)malloc(size);
    buffer->size = size;
    return true;
}

void CircleBufferRelease(CircleBuffer *cBuf)
{
    free(cBuf->data);
    cBuf->size = 0;
    cBuf->head = -1;
    cBuf->tail = -1;
    cBuf->bytesAvailable = 0;
}


void WriteCircleBuffer(char *inData, unsigned int length, CircleBuffer *destBuf)
{
    if(length>destBuf->size)
    {
        printf("circle buff overflow due to input data too long\n");
        return;
    }
    
    bool resetHead = false;
    //in case the circle buffer won't be full after adding the data
    if(destBuf->tail+length<destBuf->size)
    {
        memcpy(&destBuf->data[destBuf->tail+1], inData, length);
        
        if((destBuf->tail < destBuf->head) && (destBuf->tail+length >= destBuf->head) )
            resetHead = true;
        
        destBuf->tail += length;
    }
    //in case the circle buffer will be overflow after adding the data
    else
    {
        unsigned int remainSize = destBuf->size - destBuf->tail - 1; //the remain size
        memcpy(&destBuf->data[destBuf->tail+1], inData, remainSize);
        
        unsigned int coverSize = length - remainSize; //size of data to be covered from the beginning
        memcpy(destBuf->data, inData+remainSize, coverSize);
        
        if(destBuf->tail < destBuf->head)
            resetHead = true;
        else
        {
            if(coverSize>destBuf->head)
                resetHead = true;
        }
        
        destBuf->tail = coverSize - 1;
    }
    
    if(destBuf->head == -1)
        destBuf->head = 0;
    
    if(resetHead)
    {
        if(destBuf->tail+1 < destBuf->size)
            destBuf->head = destBuf->tail + 1;
        else
            destBuf->head = 0;
        
        destBuf->bytesAvailable = destBuf->size;
     //   printf("RESET HEAD----->>>\n");
    }
    else
    {
        if(destBuf->tail>=destBuf->head)
            destBuf->bytesAvailable = destBuf->tail - destBuf->head + 1;
        else
            destBuf->bytesAvailable = destBuf->size - (destBuf->head - destBuf->tail - 1);
    }
  //  printf("write %d head:%d tail:%d available:%d\n",length,destBuf->head,destBuf->tail,destBuf->bytesAvailable);
}



void ReadCircleBuffer(CircleBuffer *src, unsigned int length, char *dataOut, unsigned int *availableLength)
{
    if(src->bytesAvailable == 0 || length <= 0)
    {
        *availableLength = 0;
    //    printf("No available data in circle buffer\n");
        return;
    }
    if(src->bytesAvailable < length)
        length = src->bytesAvailable;
    
    *availableLength = length;
    if(src->head<=src->tail)
    {
        memcpy(dataOut, &src->data[src->head], length);
        src->head += length;
        if(src->head > src->tail)
        {
            src->head = -1;
            src->tail = -1;
        }
    }
    else
    {
        if(src->head+length <= src->size)
        {
            memcpy(dataOut, &src->data[src->head], length);
            src->head += length;
            if(src->head == src->size)
                src->head = 0;
        }
        else
        {
            unsigned int frg1Len = src->size - src->head;
            memcpy(dataOut, &src->data[src->head], frg1Len);
            
            unsigned int frg2len = length - frg1Len;
            memcpy(dataOut+frg1Len, src->data, frg2len);
            
            src->head = frg2len - 1;
            if(src->head > src->tail)
            {
                src->head = -1;
                src->tail = -1;
            }
        }
    }
    
    src->bytesAvailable -= length;
  //   printf("Read %d head:%d tail:%d available:%d\n",length,src->head,src->tail,src->bytesAvailable);
}
