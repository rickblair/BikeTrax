/*!
 *  \author         Ole A. Torvmark <o.a.torvmark@ti.com , torvmark@stalliance.no>
 *  \brief          SensorTag Light Service handler for SensorTag2-Example iOS application
 *  \copyright      Copyright (c) 2015 Texas Instruments Incorporated
 *  \file           sensorTagLightService.m
 */

/*
 * Copyright (c) 2015 Texas Instruments Incorporated
 *
 * All rights reserved not granted herein.
 * Limited License.
 *
 * Texas Instruments Incorporated grants a world-wide, royalty-free,
 * non-exclusive license under copyrights and patents it now or hereafter
 * owns or controls to make, have made, use, import, offer to sell and sell ("Utilize")
 * this software subject to the terms herein.  With respect to the foregoing patent
 *license, such license is granted  solely to the extent that any such patent is necessary
 * to Utilize the software alone.  The patent license shall not apply to any combinations which
 * include this software, other than combinations with devices manufactured by or for TI (“TI Devices”).
 * No hardware patent is licensed hereunder.
 *
 * Redistributions must preserve existing copyright notices and reproduce this license (including the
 * above copyright notice and the disclaimer and (if applicable) source code license limitations below)
 * in the documentation and/or other materials provided with the distribution
 *
 * Redistribution and use in binary form, without modification, are permitted provided that the following
 * conditions are met:
 *
 *   * No reverse engineering, decompilation, or disassembly of this software is permitted with respect to any
 *     software provided in binary form.
 *   * any redistribution and use are licensed by TI for use only with TI Devices.
 *   * Nothing shall obligate TI to provide you with source code for the software licensed and provided to you in object code.
 *
 * If software source code is provided to you, modification and redistribution of the source code are permitted
 * provided that the following conditions are met:
 *
 *   * any redistribution and use of the source code, including any resulting derivative works, are licensed by
 *     TI for use only with TI Devices.
 *   * any redistribution and use of any object code compiled from the source code and any resulting derivative
 *     works, are licensed by TI for use only with TI Devices.
 *
 * Neither the name of Texas Instruments Incorporated nor the names of its suppliers may be used to endorse or
 * promote products derived from this software without specific prior written permission.
 *
 * DISCLAIMER.
 *
 * THIS SOFTWARE IS PROVIDED BY TI AND TI’S LICENSORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 * BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL TI AND TI’S LICENSORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */


#import "sensorTagLightService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"
#import "masterMQTTResourceList.h"
#import "math.h"

@implementation sensorTagLightService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_LIGHT_SENSOR_SERVICE]) {
        return YES;
    }
    return NO;
}


-(instancetype) initWithService:(CBService *)service {
    self = [super initWithService:service];
    if (self) {
        self.btHandle = [bluetoothHandler sharedInstance];
        self.service = service;
        
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_LIGHT_SENSOR_CONFIG]) {
                self.config = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_LIGHT_SENSOR_DATA]) {
                self.data = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_LIGHT_SENSOR_PERIOD]) {
                self.period = c;
            }
        }
        if (!(self.config && self.data && self.period)) {
            NSLog(@"Some characteristics are missing from this service, might not work correctly !");
        }
        
       
    }
    return self;
}



-(BOOL) dataUpdate:(CBCharacteristic *)c {
    if ([self.data isEqual:c]) {
       // NSLog(@"sensorTagLightService: Recieved value : %@",c.value);
        
        self.textValue = [NSString stringWithFormat:@"%@",[self calcValue:c.value]];
        return YES;
    }
    return NO;
}

-(BOOL) dataUpdate:(CBCharacteristic *)c withTagData:(SensorTagData *)tagData
{
    BOOL rval = [self dataUpdate: c];
 //   if(rval)
 //   {
        tagData.light = _lightLevel;
 //   }
    
    return rval;
}

-(NSArray *) getCloudData {
    NSArray *ar = [[NSArray alloc]initWithObjects:
          [NSDictionary dictionaryWithObjectsAndKeys:
           //Value 1
           [NSString stringWithFormat:@"%0.1f",self.lightLevel],@"value",
           //Name 1
           MQTT_RESOURCE_NAME_LIGHT_LEVEL,@"name", nil], nil];
    return ar;
}

-(NSString *) calcValue:(NSData *) value {
    unsigned char tmp[value.length];
    [value getBytes:tmp length:value.length];
    uint16_t dat;
    dat = ((uint16_t)tmp[1] & 0xFF) << 8;
    dat |= (uint16_t)(tmp[0] & 0xFF);
    
    self.lightLevel = (float)[sensorTagLightService sfloatExp2ToDouble:dat];
    
    
    
    return [NSString stringWithFormat:@"Amb: %0.1f Lux",(float)self.lightLevel];
}

+(double) sfloatExp2ToDouble:(uint16_t) sfloat {
    uint16_t mantissa;
    uint8_t exponent;
    
    mantissa = sfloat & 0x0FFF;
    exponent = sfloat >> 12;
#ifdef SIGNED
    if (exponent >= 0x0008) {
        exponent = -((0x000F + 1) - exponent);
    }
#endif
#ifdef SIGNED
    if (mantissa >= 0x0800) {
        mantissa = -((0x0FFF + 1) - mantissa);
    }
#endif
    double output;
    double magnitude = pow(2.0f, exponent);
    output = (mantissa * magnitude);
    
    return output / 100.0f;
}


@end
