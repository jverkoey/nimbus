//
// Copyright 2011 Roger Chapman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NICellFactory.h"

@interface LabelEntry : NSObject <NICellObject> {

@private
NSString* _title;
Class _controllerClass;
}

+ (id)entryWithTitle:(NSString *)title controllerClass:(Class)controllerClass;

@property (nonatomic, readwrite, copy)    NSString* title;
@property (nonatomic, readwrite, assign)  Class controllerClass;

@end
