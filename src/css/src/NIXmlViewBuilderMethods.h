//
// Copyright 2011 Max Metral
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

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif
  
  /**
   * For filling in gaps in Apple's Foundation framework.
   *
   * @ingroup NimbusCore
   * @defgroup NIXmlViewBuilder-Methods NIXmlViewBuilder Methods
   * @{
   *
   */
  /**
   * Functions to create UIView "subview builder" compatible property sets
   * from XML files. This essentially allows an "HTML-like" markup language
   * for view construction which is nice complement to the CSS subsystem to
   * provide familiar design tools while maintaining high performance and native
   * look and feel.
   */
  
  /**
   * Construct an NSDictionary suitable for [UIView buildSubviews:] from an XML file.
   * Top level objects encoded in this XML must be UIView subclasses.
   *
   *  @return an NSDictionary that can be passed to UIView buildSubviews:
   */
  extern NSDictionary* NIViewDictionaryFromXmlData(NSData *xml);

  /**
   * Construct an NSDictionary suitable for [UIView buildSubviews:] from an XML file.
   * Top level objects encoded in this XML must be UIView subclasses.
   *
   *  @return an NSDictionary that can be passed to UIView buildSubviews:
   */
  extern NSDictionary* NIViewDictionaryFromXmlFile(NSString *xmlPath);

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Foundation Methods ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
